-- =====================================================
-- FIX: RLS Infinite Recursion in patients/patient_access
-- Issue: Circular reference between tables causes infinite recursion
-- Solution: Use SECURITY DEFINER function to bypass RLS checks
-- =====================================================

-- Step 1: Create helper function that bypasses RLS
CREATE OR REPLACE FUNCTION public.user_has_patient_access(p_patient_id UUID, p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- This function runs with elevated privileges and bypasses RLS
  -- preventing the circular reference issue
  RETURN EXISTS (
    SELECT 1 FROM patient_access
    WHERE patient_id = p_patient_id
    AND user_id = p_user_id
  );
END;
$$;

-- Step 2: Drop existing problematic policies on patients table
DROP POLICY IF EXISTS "Users can view patients they own or have access to" ON patients;
DROP POLICY IF EXISTS "Users can create patients" ON patients;
DROP POLICY IF EXISTS "Owners and Editors can update patients" ON patients;
DROP POLICY IF EXISTS "Owners can delete patients" ON patients;

-- Step 3: Recreate patients policies with fixed logic

-- SELECT: Use helper function to avoid direct patient_access query in policy
CREATE POLICY "Users can view patients they own or have access to"
ON patients FOR SELECT
USING (
  auth.uid() = owner_id 
  OR 
  public.user_has_patient_access(id, auth.uid())
);

-- INSERT: Simple ownership check (no recursion risk)
CREATE POLICY "Users can create patients"
ON patients FOR INSERT
WITH CHECK (auth.uid() = owner_id);

-- UPDATE: Check ownership OR editor/owner role
-- Note: This still queries patient_access, but only during UPDATE operations
-- which don't trigger the same recursion as SELECT during INSERT
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

-- DELETE: Only direct owner can delete (simplified to avoid any recursion)
CREATE POLICY "Owners can delete patients"
ON patients FOR DELETE
USING (auth.uid() = owner_id);

-- Step 4: Verify the policies were created successfully
SELECT 
  schemaname, 
  tablename, 
  policyname, 
  cmd,
  CASE 
    WHEN qual IS NOT NULL THEN 'USING clause present'
    ELSE 'No USING clause'
  END as using_status,
  CASE 
    WHEN with_check IS NOT NULL THEN 'WITH CHECK clause present'
    ELSE 'No WITH CHECK clause'
  END as check_status
FROM pg_policies 
WHERE tablename IN ('patients', 'patient_access')
ORDER BY tablename, policyname;
