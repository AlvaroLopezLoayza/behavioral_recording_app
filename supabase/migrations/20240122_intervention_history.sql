-- Create Intervention Status History table
CREATE TABLE IF NOT EXISTS public.intervention_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_id UUID NOT NULL REFERENCES public.intervention_plans(id) ON DELETE CASCADE,
    previous_status TEXT,
    new_status TEXT NOT NULL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    changed_by UUID NOT NULL REFERENCES auth.users(id)
);

-- Enable RLS
ALTER TABLE public.intervention_status_history ENABLE ROW LEVEL SECURITY;

-- Policies (Mirroring Intervention Plans)
CREATE POLICY "Users can view intervention history for accessible patients"
ON public.intervention_status_history FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.intervention_plans p
        JOIN public.patient_access pa ON p.patient_id = pa.patient_id
        WHERE p.id = intervention_status_history.plan_id
        AND pa.user_id = auth.uid()
    )
);

-- Function to automatically record status changes
CREATE OR REPLACE FUNCTION public.log_intervention_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') OR (OLD.status IS DISTINCT FROM NEW.status) THEN
        INSERT INTO public.intervention_status_history (plan_id, previous_status, new_status, changed_by)
        VALUES (NEW.id, CASE WHEN TG_OP = 'INSERT' THEN NULL ELSE OLD.status END, NEW.status, auth.uid());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on intervention_plans
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tr_log_intervention_status_change') THEN
        CREATE TRIGGER tr_log_intervention_status_change
        AFTER INSERT OR UPDATE ON public.intervention_plans
        FOR EACH ROW
        EXECUTE FUNCTION public.log_intervention_status_change();
    END IF;
END $$;
