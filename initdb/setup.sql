create table users
(
  user_id text UNIQUE,
  password text,
  insert_data timestamp with time zone,
  update_data timestamp with time zone
);

