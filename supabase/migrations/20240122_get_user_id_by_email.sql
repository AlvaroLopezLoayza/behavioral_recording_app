-- Create a secure function to look up user ID by email
-- This allows users to share patients without exposing the entire user list

create or replace function get_user_id_by_email(email_input text)
returns uuid
language plpgsql
security definer -- Runs with privileges of the creator (postgres), bypassing RLS
as $$
declare
  target_user_id uuid;
begin
  select id into target_user_id
  from auth.users
  where email = email_input;
  
  return target_user_id;
end;
$$;
