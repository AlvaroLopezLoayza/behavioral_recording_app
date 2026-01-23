-- Migration to fix RLS policies for intervention_plans to include patient owners

ALTER TABLE intervention_plans ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view intervention plans for accessible patients_v2" ON intervention_plans;
DROP POLICY IF EXISTS "Users can create intervention plans for patients they manage_v2" ON intervention_plans;
DROP POLICY IF EXISTS "Users can update intervention plans for patients they manage_v2" ON intervention_plans;
DROP POLICY IF EXISTS "Users can delete intervention plans for patients they manage_v2" ON intervention_plans;

-- Create new policies
CREATE POLICY "Users can view intervention plans_v3" ON intervention_plans
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM patients p
    WHERE p.id = intervention_plans.patient_id
    AND (
      p.owner_id = auth.uid()
      OR EXISTS (
        SELECT 1 FROM patient_access pa
        WHERE pa.patient_id = p.id AND pa.user_id = auth.uid()
      )
    )
  )
);

CREATE POLICY "Users can create intervention plans_v3" ON intervention_plans
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM patients p
    WHERE p.id = intervention_plans.patient_id
    AND (
      p.owner_id = auth.uid()
      OR EXISTS (
        SELECT 1 FROM patient_access pa
        WHERE pa.patient_id = p.id AND pa.user_id = auth.uid() AND pa.role IN ('owner', 'editor')
      )
    )
  )
);

CREATE POLICY "Users can update intervention plans_v3" ON intervention_plans
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM patients p
    WHERE p.id = intervention_plans.patient_id
    AND (
      p.owner_id = auth.uid()
      OR EXISTS (
        SELECT 1 FROM patient_access pa
        WHERE pa.patient_id = p.id AND pa.user_id = auth.uid() AND pa.role IN ('owner', 'editor')
      )
    )
  )
);

CREATE POLICY "Users can delete intervention plans_v3" ON intervention_plans
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM patients p
    WHERE p.id = intervention_plans.patient_id
    AND (
      p.owner_id = auth.uid()
      OR EXISTS (
        SELECT 1 FROM patient_access pa
        WHERE pa.patient_id = p.id AND pa.user_id = auth.uid() AND pa.role IN ('owner', 'editor')
      )
    )
  )
);
