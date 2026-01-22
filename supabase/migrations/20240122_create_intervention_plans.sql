-- Ensure handle_updated_at function exists
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Intervention Plans table
CREATE TABLE IF NOT EXISTS public.intervention_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hypothesis_id UUID NOT NULL REFERENCES public.functional_hypotheses(id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    replacement_behavior TEXT NOT NULL,
    strategies JSONB NOT NULL DEFAULT '[]',
    status TEXT NOT NULL CHECK (status IN ('proposed', 'active', 'discontinued')),
    created_by UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.intervention_plans ENABLE ROW LEVEL SECURITY;

-- Policies
-- Users can view intervention plans for patients they have access to
CREATE POLICY "Users can view intervention plans for accessible patients"
ON public.intervention_plans FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.patient_access
        WHERE patient_access.patient_id = intervention_plans.patient_id
        AND patient_access.user_id = auth.uid()
    )
);

-- Users can insert intervention plans for patients they have 'owner' or 'editor' access to
CREATE POLICY "Users can create intervention plans for patients they manage"
ON public.intervention_plans FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.patient_access
        WHERE patient_access.patient_id = intervention_plans.patient_id
        AND patient_access.user_id = auth.uid()
        AND (patient_access.role = 'owner' OR patient_access.role = 'editor')
    )
);

-- Users can update intervention plans for patients they have 'owner' or 'editor' access to
CREATE POLICY "Users can update intervention plans for patients they manage"
ON public.intervention_plans FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM public.patient_access
        WHERE patient_access.patient_id = intervention_plans.patient_id
        AND patient_access.user_id = auth.uid()
        AND (patient_access.role = 'owner' OR patient_access.role = 'editor')
    )
);

-- Users can delete intervention plans for patients they have 'owner' or 'editor' access to
CREATE POLICY "Users can delete intervention plans for patients they manage"
ON public.intervention_plans FOR DELETE
USING (
    EXISTS (
        SELECT 1 FROM public.patient_access
        WHERE patient_access.patient_id = intervention_plans.patient_id
        AND patient_access.user_id = auth.uid()
        AND (patient_access.role = 'owner' OR patient_access.role = 'editor')
    )
);

-- Trigger for updated_at
CREATE TRIGGER set_intervention_plans_updated_at
    BEFORE UPDATE ON public.intervention_plans
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
