CREATE SCHEMA IF NOT EXISTS gowebapp;

-- ********************************** gowebapp.users
CREATE TABLE gowebapp.users
(
    user_id         bigserial NOT NULL,
    user_name       text NOT NULL,
    password_hash   text NOT NULL,
    name      text NOT NULL,
    config          jsonb NOT NULL DEFAULT '{}'::JSONB,
    is_enabled      boolean NOT NULL DEFAULT TRUE,
    CONSTRAINT PK_users PRIMARY KEY (user_id)   
);

-- ********************************* gowebapp.exercises
CREATE TABLE gowebapp.exercises
(
    exercise_id     bigserial NOT NULL,
    exercise_name   text NOT NULL,
    CONSTRAINT PK_exercises PRIMARY KEY (exercise_id)
);

-- ********************************* gowebapp.images
CREATE TABLE gowebapp.images
(
    image_id    bigserial NOT NULL,
    user_id     bigserial NOT NULL,
    content_type text NOT NULL DEFAULT 'image/png',
    image_data  bytea NOT NULL,
    CONSTRAINT  PK_images PRIMARY KEY (image_id, user_id),
    CONSTRAINT  FK_65 FOREIGN KEY (user_id) REFERENCES gowebapp.users (user_id)
);

CREATE INDEX FK_67 ON gowebapp.images
(
    user_id
);

-- ********************************* gowebb.sets
CREATE TABLE gowebapp.sets
(
    set_id      bigserial NOT NULL,
    exercise_id bigserial NOT NULL,
    weight      int NOT NULL DEFAULT 0,
    CONSTRAINT PK_sets  PRIMARY KEY (set_id, exercise_id),
    CONSTRAINT FK_106 FOREIGN KEY (exercise_id) REFERENCES gowebapp.exercises (exercise_id)
);

CREATE INDEX FK_108 ON gowebapp.sets
(
    exercise_id
);

-- ******************************* geowebb.workouts
CREATE TABLE gowebapp.workouts
(
    workout_id      bigserial NOT NULL,
    set_id          bigserial NOT NULL,
    user_id         bigserial NOT NULL,
    exercise_id     bigserial NOT NULL,
    start_date      timestamp NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_workouts PRIMARY KEY (workout_id, set_id, user_id, exercise_id),
    CONSTRAINT FK_71 FOREIGN KEY (set_id, exercise_id) REFERENCES gowebapp.sets (set_id, exercise_id),
    CONSTRAINT FK_74 FOREIGN KEY (user_id) REFERENCES gowebapp.users (user_id)
);

CREATE INDEX FK_73 ON gowebapp.workouts
(
    set_id, exercise_id
);

CREATE INDEX FK_76 ON gowebapp.workouts
(
    user_id
);