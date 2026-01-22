-- Create functional_hypotheses table
CREATE TABLE functional_hypotheses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  behavior_definition_id UUID NOT NULL REFERENCES behavior_definitions(id) ON DELETE CASCADE,
  function_type TEXT NOT NULL,
  description TEXT,
  confidence FLOAT DEFAULT 0.0,
  status TEXT DEFAULT 'draft',
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Validation check for status
ALTER TABLE functional_hypotheses ADD CONSTRAINT check_hypothesis_status 
  CHECK (status IN ('draft', 'active', 'disproven', 'verified'));

-- Validation check for function_type
ALTER TABLE functional_hypotheses ADD CONSTRAINT check_function_type
  CHECK (function_type IN ('socialPositive', 'socialNegative', 'automaticPositive', 'automaticNegative', 'unknown'));

-- Enable RLS
ALTER TABLE functional_hypotheses ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can view hypotheses if they have access to the patient via behavior definition
CREATE POLICY "Users can view hypotheses linked to their patients"
  ON functional_hypotheses FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM behavior_definitions bd
      JOIN patients p ON bd.patient_id = p.id
      LEFT JOIN patient_access pa ON p.id = pa.patient_id
      WHERE bd.id = functional_hypotheses.behavior_definition_id
      AND (p.owner_id = auth.uid() OR pa.user_id = auth.uid())
    )
    OR
    EXISTS (
      SELECT 1 FROM behavior_definitions bd
      WHERE bd.id = functional_hypotheses.behavior_definition_id
      AND bd.created_by = auth.uid() -- Fallback for definitions not linked to patient
    )
  );

-- Users can insert/update if they have editor/owner access
CREATE POLICY "Users can manage hypotheses with editor access"
  ON functional_hypotheses FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM behavior_definitions bd
      JOIN patients p ON bd.patient_id = p.id
      LEFT JOIN patient_access pa ON p.id = pa.patient_id
      WHERE bd.id = functional_hypotheses.behavior_definition_id
      AND (
        p.owner_id = auth.uid() 
        OR (pa.user_id = auth.uid() AND pa.role IN ('editor', 'owner'))
      )
    )
    OR
    (created_by = auth.uid()) -- Fallback
  );
