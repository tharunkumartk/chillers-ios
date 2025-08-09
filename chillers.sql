-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.event_attendees (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  event_id uuid,
  user_id uuid,
  status text DEFAULT 'going'::text CHECK (status = ANY (ARRAY['going'::text, 'maybe'::text, 'not_going'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT event_attendees_pkey PRIMARY KEY (id),
  CONSTRAINT event_attendees_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id),
  CONSTRAINT event_attendees_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.events (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  host_id uuid,
  title text NOT NULL,
  description text,
  location text,
  event_date date NOT NULL,
  event_time text,
  image_url text,
  max_attendees integer,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  spots_remaining integer,
  total_spots integer,
  rsvp_deadline timestamp with time zone,
  co_hosts ARRAY DEFAULT '{}'::uuid[],
  waitlist_enabled boolean DEFAULT false,
  is_open_invite boolean DEFAULT false,
  theme text,
  status text DEFAULT 'upcoming'::text CHECK (status = ANY (ARRAY['upcoming'::text, 'past'::text, 'cancelled'::text])),
  contact text,
  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT events_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.users(id)
);
CREATE TABLE public.post_votes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  post_id uuid,
  user_id uuid,
  vote_type text CHECK (vote_type = ANY (ARRAY['upvote'::text, 'downvote'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT post_votes_pkey PRIMARY KEY (id),
  CONSTRAINT post_votes_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id),
  CONSTRAINT post_votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.posts (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  author_id uuid,
  content text NOT NULL CHECK (length(content) <= 250),
  upvotes integer DEFAULT 0,
  downvotes integer DEFAULT 0,
  parent_post_id uuid,
  is_quote boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT posts_pkey PRIMARY KEY (id),
  CONSTRAINT posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id),
  CONSTRAINT posts_parent_post_id_fkey FOREIGN KEY (parent_post_id) REFERENCES public.posts(id)
);
CREATE TABLE public.user_approvals (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  reviewer_id uuid,
  candidate_id uuid,
  decision text CHECK (decision = ANY (ARRAY['approve'::text, 'reject'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_approvals_pkey PRIMARY KEY (id),
  CONSTRAINT user_approvals_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.users(id),
  CONSTRAINT user_approvals_candidate_id_fkey FOREIGN KEY (candidate_id) REFERENCES public.users(id)
);
CREATE TABLE public.user_profiles (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid UNIQUE,
  first_name text,
  last_name text,
  height text,
  age integer,
  company text,
  school text,
  bio text,
  location text,
  gender text,
  sexuality text,
  profile_images ARRAY DEFAULT '{}'::text[],
  tags ARRAY DEFAULT '{}'::text[],
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  apn_device_token text,
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.user_prompts (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  question text NOT NULL,
  answer text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_prompts_pkey PRIMARY KEY (id),
  CONSTRAINT user_prompts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.users (
  id uuid NOT NULL,
  phone_number text NOT NULL UNIQUE,
  name text,
  profile_complete boolean DEFAULT false,
  approval_status text DEFAULT 'pending'::text CHECK (approval_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])),
  vouch_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.vouches (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  voucher_id uuid,
  vouchee_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT vouches_pkey PRIMARY KEY (id),
  CONSTRAINT vouches_voucher_id_fkey FOREIGN KEY (voucher_id) REFERENCES public.users(id),
  CONSTRAINT vouches_vouchee_id_fkey FOREIGN KEY (vouchee_id) REFERENCES public.users(id)
);