-- Enable RLS on tables
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_access ENABLE ROW LEVEL SECURITY;

-- -------------------------------------------------------------
-- Policies for 'patients' table
-- -------------------------------------------------------------

-- VIEW: Owner or anyone with an access record can view
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

-- INSERT: Authenticated users can create patients
CREATE POLICY "Users can create patients"
ON patients FOR INSERT
WITH CHECK (auth.uid() = owner_id);

-- UPDATE: Owner or Editors/Owners via access can update
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

-- DELETE: Only Owner (creator) can delete functionality for now to be safe, 
-- or those with 'owner' role access.
CREATE POLICY "Owners can delete patients"
ON patients FOR DELETE
USING (
  auth.uid() = owner_id
  OR
  EXISTS (
    SELECT 1 FROM patient_access
    WHERE patient_id = patients.id
    AND user_id = auth.uid()
    AND role = 'owner'
  )
);

-- -------------------------------------------------------------
-- Policies for 'patient_access' table
-- -------------------------------------------------------------

-- VIEW: Users can see access records if:
-- 1. It is their own access record
-- 2. They are the owner of the patient (check patients table directly)
-- REMOVED: Circular check that caused infinite recursion
CREATE POLICY "Users can view access records for their patients"
ON patient_access FOR SELECT
USING (
  user_id = auth.uid()
  OR
  EXISTS (
    SELECT 1 FROM patients
    WHERE id = patient_access.patient_id
    AND owner_id = auth.uid()
  )
);

-- INSERT: Only patient owners can invite new users
-- SIMPLIFIED: Removed circular patient_access check to prevent recursion
CREATE POLICY "Owners can invite users"
ON patient_access FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM patients
    WHERE id = patient_access.patient_id
    AND owner_id = auth.uid()
  )
);

-- DELETE: 
-- 1. Users can remove themselves (leave)
-- 2. Patient owners can remove others
-- SIMPLIFIED: Removed circular patient_access check
CREATE POLICY "Owners can revoke access or User can leave"
ON patient_access FOR DELETE
USING (
  user_id = auth.uid() -- Leave
  OR
  EXISTS (
    SELECT 1 FROM patients
    WHERE id = patient_access.patient_id
    AND owner_id = auth.uid() -- Patient Owner removing someone
  )
);
