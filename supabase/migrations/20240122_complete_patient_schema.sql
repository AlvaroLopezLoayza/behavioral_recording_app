-- 1. Patients Table
CREATE TABLE IF NOT EXISTS patients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  birth_date DATE,
  diagnosis TEXT,
  owner_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Patient Access Table
CREATE TABLE IF NOT EXISTS patient_access (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id),
  role TEXT CHECK (role IN ('viewer', 'editor', 'owner')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(patient_id, user_id)
);

-- 3. Add patient_id to Behavior Definitions
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'behavior_definitions' AND column_name = 'patient_id') THEN
        ALTER TABLE behavior_definitions ADD COLUMN patient_id UUID REFERENCES patients(id) ON DELETE CASCADE;
    END IF;
END $$;

-- 4. Enable RLS
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE behavior_definitions ENABLE ROW LEVEL SECURITY;

-- -------------------------------------------------------------
-- Policies for 'patients' table
-- -------------------------------------------------------------

DROP POLICY IF EXISTS "Users can view patients they own or have access to" ON patients;
CREATE POLICY "Users can view patients they own or have access to"
ON patients FOR SELECT
USING (
  auth.uid() = owner_id 
  OR 
  EXISTS (
    SELECT 1 FROM patient_access 
    WHERE patient_id = patients.id 
    AND user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Users can create patients" ON patients;
CREATE POLICY "Users can create patients"
ON patients FOR INSERT
WITH CHECK (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owners and Editors can update patients" ON patients;
CREATE POLICY "Owners and Editors can update patients"
ON patients FOR UPDATE
USING (
  auth.uid() = owner_id
  OR
  EXISTS (
    SELECT 1 FROM patient_access
    WHERE patient_id = patients.id
    AND user_id = auth.uid()
    AND role IN ('editor', 'owner')
  )
);

DROP POLICY IF EXISTS "Owners can delete patients" ON patients;
CREATE POLICY "Owners can delete patients"
ON patients FOR DELETE
USING (auth.uid() = owner_id);

-- -------------------------------------------------------------
-- Policies for 'patient_access' table
-- -------------------------------------------------------------

DROP POLICY IF EXISTS "Users can view access records" ON patient_access;
CREATE POLICY "Users can view access records"
ON patient_access FOR SELECT
USING (
  user_id = auth.uid()
  OR
  EXISTS (
    SELECT 1 FROM patients
    WHERE id = patient_access.patient_id
    AND owner_id = auth.uid()
  )
  OR
  EXISTS (
    SELECT 1 FROM patient_access pa
    WHERE pa.patient_id = patient_access.patient_id
    AND pa.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Owners and Editors can invite users" ON patient_access;
CREATE POLICY "Owners and Editors can invite users"
ON patient_access FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM patients
    WHERE id = patient_access.patient_id
    AND owner_id = auth.uid()
  )
  OR
  EXISTS (
    SELECT 1 FROM patient_access pa
    WHERE pa.patient_id = patient_access.patient_id
    AND pa.user_id = auth.uid()
    AND pa.role IN ('editor', 'owner')
  )
);

DROP POLICY IF EXISTS "Revoke access" ON patient_access;
CREATE POLICY "Revoke access"
ON patient_access FOR DELETE
USING (
  user_id = auth.uid()
  OR
  EXISTS (
    SELECT 1 FROM patients
    WHERE id = patient_access.patient_id
    AND owner_id = auth.uid()
  )
  OR
  EXISTS (
    SELECT 1 FROM patient_access pa
    WHERE pa.patient_id = patient_access.patient_id
    AND pa.user_id = auth.uid()
    AND pa.role IN ('editor', 'owner')
  )
);

-- -------------------------------------------------------------
-- Policies for 'behavior_definitions' table
-- -------------------------------------------------------------

DROP POLICY IF EXISTS "View definitions via patient access" ON behavior_definitions;
CREATE POLICY "View definitions via patient access"
ON behavior_definitions FOR SELECT
USING (
  (patient_id IS NULL AND created_by = auth.uid())
  OR
  EXISTS (
    SELECT 1 FROM patients p
    WHERE p.id = behavior_definitions.patient_id
    AND (
      p.owner_id = auth.uid()
      OR EXISTS (SELECT 1 FROM patient_access pa WHERE pa.patient_id = p.id AND pa.user_id = auth.uid())
    )
  )
);

DROP POLICY IF EXISTS "Create definitions via patient access" ON behavior_definitions;
CREATE POLICY "Create definitions via patient access"
ON behavior_definitions FOR INSERT
WITH CHECK (
  (patient_id IS NULL AND created_by = auth.uid())
  OR
  EXISTS (
    SELECT 1 FROM patients p
    WHERE p.id = patient_id
    AND (
      p.owner_id = auth.uid()
      OR EXISTS (SELECT 1 FROM patient_access pa WHERE pa.patient_id = p.id AND pa.user_id = auth.uid() AND pa.role IN ('editor', 'owner'))
    )
  )
);

DROP POLICY IF EXISTS "Update definitions via patient access" ON behavior_definitions;
CREATE POLICY "Update definitions via patient access"
ON behavior_definitions FOR UPDATE
USING (
  (patient_id IS NULL AND created_by = auth.uid())
  OR
  EXISTS (
    SELECT 1 FROM patients p
    WHERE p.id = behavior_definitions.patient_id
    AND (
      p.owner_id = auth.uid()
      OR EXISTS (SELECT 1 FROM patient_access pa WHERE pa.patient_id = p.id AND pa.user_id = auth.uid() AND pa.role IN ('editor', 'owner'))
    )
  )
);
