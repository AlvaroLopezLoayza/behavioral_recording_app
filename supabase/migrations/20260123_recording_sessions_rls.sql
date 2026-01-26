-- Migration: Fix RLS Policies for recording_sessions and abc_records
-- Description: Enables RLS and adds policies based on patient access.

-- 1. recording_sessions
ALTER TABLE public.recording_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view recording sessions for accessible patients" ON public.recording_sessions;
CREATE POLICY "Users can view recording sessions for accessible patients"
ON public.recording_sessions FOR SELECT
USING (
  public.user_has_patient_access(patient_id, auth.uid())
  OR EXISTS (SELECT 1 FROM public.patients WHERE id = patient_id AND owner_id = auth.uid())
);

DROP POLICY IF EXISTS "Users can create recording sessions for accessible patients" ON public.recording_sessions;
CREATE POLICY "Users can create recording sessions for accessible patients"
ON public.recording_sessions FOR INSERT
WITH CHECK (
  public.user_has_patient_access(patient_id, auth.uid())
  OR EXISTS (SELECT 1 FROM public.patients WHERE id = patient_id AND owner_id = auth.uid())
);

DROP POLICY IF EXISTS "Users can update their own recording sessions" ON public.recording_sessions;
CREATE POLICY "Users can update their own recording sessions"
ON public.recording_sessions FOR UPDATE
USING (
  observer_id = auth.uid() OR public.user_has_patient_access(patient_id, auth.uid())
);

-- 2. abc_records
ALTER TABLE public.abc_records ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view abc records for accessible patients" ON public.abc_records;
CREATE POLICY "Users can view abc records for accessible patients"
ON public.abc_records FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.behavior_definitions bd
    JOIN public.patients p ON bd.patient_id = p.id
    WHERE bd.id = abc_records.behavior_definition_id
    AND (
      p.owner_id = auth.uid()
      OR public.user_has_patient_access(p.id, auth.uid())
    )
  )
);

DROP POLICY IF EXISTS "Users can create abc records for accessible patients" ON public.abc_records;
CREATE POLICY "Users can create abc records for accessible patients"
ON public.abc_records FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.behavior_definitions bd
    JOIN public.patients p ON bd.patient_id = p.id
    WHERE bd.id = behavior_definition_id
    AND (
      p.owner_id = auth.uid()
      OR public.user_has_patient_access(p.id, auth.uid())
    )
  )
);

DROP POLICY IF EXISTS "Users can update their own abc records" ON public.abc_records;
CREATE POLICY "Users can update their own abc records"
ON public.abc_records FOR UPDATE
USING (
  observer_id = auth.uid()
);

DROP POLICY IF EXISTS "Users can delete their own abc records" ON public.abc_records;
CREATE POLICY "Users can delete their own abc records"
ON public.abc_records FOR DELETE
USING (
  observer_id = auth.uid()
);
