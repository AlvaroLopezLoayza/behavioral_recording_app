-- 1. Create Contexts Table
CREATE TABLE IF NOT EXISTS contexts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  type TEXT DEFAULT 'physical', -- physical, social, activity, etc.
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Add context_id to ABC Records
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'abc_records' AND column_name = 'context_id') THEN
        ALTER TABLE abc_records ADD COLUMN context_id UUID REFERENCES contexts(id) ON DELETE SET NULL;
    END IF;
END $$;

-- 3. Enable RLS for Contexts
ALTER TABLE contexts ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies for Contexts (Inherited from Patient)

-- VIEW: Same logic as behavior definitions - if you can see patient, you can see contexts
DROP POLICY IF EXISTS "View contexts via patient access" ON contexts;
CREATE POLICY "View contexts via patient access"
ON contexts FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM patients p
    WHERE p.id = contexts.patient_id
    AND (
      p.owner_id = auth.uid()
      OR EXISTS (SELECT 1 FROM patient_access pa WHERE pa.patient_id = p.id AND pa.user_id = auth.uid())
    )
  )
);

-- INSERT: Editors and Owners
DROP POLICY IF EXISTS "Create contexts via patient access" ON contexts;
CREATE POLICY "Create contexts via patient access"
ON contexts FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM patients p
    WHERE p.id = patient_id
    AND (
      p.owner_id = auth.uid()
      OR EXISTS (SELECT 1 FROM patient_access pa WHERE pa.patient_id = p.id AND pa.user_id = auth.uid() AND pa.role IN ('editor', 'owner'))
    )
  )
);

-- UPDATE: Editors and Owners
DROP POLICY IF EXISTS "Update contexts via patient access" ON contexts;
CREATE POLICY "Update contexts via patient access"
ON contexts FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM patients p
    WHERE p.id = contexts.patient_id
    AND (
      p.owner_id = auth.uid()
      OR EXISTS (SELECT 1 FROM patient_access pa WHERE pa.patient_id = p.id AND pa.user_id = auth.uid() AND pa.role IN ('editor', 'owner'))
    )
  )
);

-- DELETE: Owner of patient or 'owner' role
DROP POLICY IF EXISTS "Delete contexts via patient access" ON contexts;
CREATE POLICY "Delete contexts via patient access"
ON contexts FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM patients p
    WHERE p.id = contexts.patient_id
    AND (
      p.owner_id = auth.uid() -- Real owner
      OR EXISTS (SELECT 1 FROM patient_access pa WHERE pa.patient_id = p.id AND pa.user_id = auth.uid() AND pa.role = 'owner') -- Assigned owner
    )
  )
);
