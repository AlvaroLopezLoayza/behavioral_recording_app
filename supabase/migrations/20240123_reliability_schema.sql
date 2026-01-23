-- Migration: Create Reliability Records Table
-- Description: Stores calculated Interobserver Agreement (IOA) scores and parameters.

CREATE TABLE IF NOT EXISTS public.reliability_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    behavior_definition_id UUID NOT NULL REFERENCES public.behavior_definitions(id) ON DELETE CASCADE,
    observer_1_id UUID NOT NULL REFERENCES auth.users(id),
    observer_2_id UUID NOT NULL REFERENCES auth.users(id),
    method TEXT NOT NULL, -- 'total_count', 'mean_per_interval', 'exact_agreement'
    score REAL NOT NULL, -- Percentage (0-100)
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    parameters JSONB DEFAULT '{}'::jsonb, -- Additional config like interval size
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Enable RLS
ALTER TABLE public.reliability_records ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view reliability records for patients they have access to" 
ON public.reliability_records FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.patients p
        WHERE p.id = reliability_records.patient_id
        AND (
            p.owner_id = auth.uid()
            OR EXISTS (
                SELECT 1 FROM public.patient_access pa
                WHERE pa.patient_id = p.id AND pa.user_id = auth.uid()
            )
        )
    )
);

CREATE POLICY "Users can insert reliability records for patients they have access to" 
ON public.reliability_records FOR INSERT 
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.patients p
        WHERE p.id = reliability_records.patient_id
        AND (
            p.owner_id = auth.uid()
            OR EXISTS (
                SELECT 1 FROM public.patient_access pa
                WHERE pa.patient_id = p.id AND pa.user_id = auth.uid()
            )
        )
    )
);

CREATE POLICY "Owners can delete reliability records" 
ON public.reliability_records FOR DELETE 
USING (
    EXISTS (
        SELECT 1 FROM public.patients p
        WHERE p.id = reliability_records.patient_id
        AND p.owner_id = auth.uid()
    )
);

-- Grant access to authenticated users
GRANT ALL ON public.reliability_records TO authenticated;
GRANT ALL ON public.reliability_records TO service_role;
