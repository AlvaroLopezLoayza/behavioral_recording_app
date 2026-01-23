-- =====================================================
-- FIX: RLS Infinite Recursion in patient_access table
-- Run this script in Supabase SQL Editor
-- =====================================================

-- Step 1: Drop the problematic policies
DROP POLICY IF EXISTS "Users can view access records for their patients" ON patient_access;
DROP POLICY IF EXISTS "Owners and Editors can invite users" ON patient_access;
DROP POLICY IF EXISTS "Owners/Editors can revoke access or User can leave" ON patient_access;

-- Step 2: Create the fixed policies (no circular references)

-- VIEW: Users can see access records if:
-- 1. It is their own access record
-- 2. They are the owner of the patient (check patients table directly)
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
CREATE POLICY "Owners can revoke access or User can leave"
ON patient_access FOR DELETE
USING (
  user_id = auth.uid() -- User can leave
  OR
  EXISTS (
    SELECT 1 FROM patients
    WHERE id = patient_access.patient_id
    AND owner_id = auth.uid() -- Patient owner can remove anyone
  )
);

-- Verify the policies were created successfully
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'patient_access'
ORDER BY policyname;
