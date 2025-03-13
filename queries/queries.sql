-- name: ListUsers :many
-- get all users ordered by the username
SELECT *
FROM gowebapp.users
ORDER BY user_name;

-- name: ListImages :many
-- get all images ordered by the id
SELECT *
FROM gowebapp.images
ORDER BY image_id;

-- name: ListExercises :many
-- get all exercises ordered by the exercise name
SELECT *
FROM gowebapp.exercises
ORDER BY exercise_name;

-- name: ListSets :many
-- get all sets ordered by weight
SELECT *
FROM gowebapp.sets
ORDER BY weight;

-- name: ListWorkouts :many
-- get all workouts ordered by id
SELECT *
FROM gowebapp.workouts
ORDER BY workout_id;

-- name: GetUser :one
-- get users of a particular user_id
SELECT *
FROM gowebapp.users
WHERE user_id = $1;

-- name: GetUserWorkout :many
-- get a particular user information and workouts
SELECT 
    u.user_id, 
    w.workout_id, 
    w.start_date, 
    w.set_id
FROM gowebapp.users u, 
    gowebapp.workouts w
WHERE u.user_id = w.user_id
  AND u.user_id = $1;

-- name: GetUserSets :many
-- get a particular user information, exercise sets and workouts
SELECT 
    u.user_id,
    w.workout_id, 
    w.start_date,
    s.set_id,
    s.weight
FROM
    gowebapp.users u,
    gowebapp.workouts w, 
    gowebapp.sets s
WHERE u.user_id = w.user_id
  AND w.set_id = s.set_id
  AND u.user_id = $1;

-- name: GetUserImage :one
-- get a particular user image
SELECT
    u.name,
    u.user_id,
    i.image_data
FROM 
    gowebapp.users u,
    gowebapp.images i
WHERE u.user_id = i.user_id
  AND u.user_id = $1;

-- name: DeleteUsers :exec
-- delete a particular user
DELETE
FROM gowebapp.users
WHERE user_id = $1;

-- name: DeleteUserImage :exec
-- delete a particular user's image
DELETE
FROM gowebapp.images i
WHERE i.user_id = $1;

-- name: DeleteUserWorkouts :exec
-- delete a particular user's workout
DELETE
FROM gowebapp.workouts w
WHERE w.user_id = $1;

-- name: DeleteExercise :exec
-- delete a particular exercise
DELETE
FROM gowebapp.exercises e
WHERE e.exercise_id = $1;

-- name: DeleteSets :exec
-- delete a particular exercise sets
DELETE
FROM gowebapp.sets s
WHERE s.set_id = $1;

-- name: CreateExercise :one
-- insert a new exercise 
INSERT INTO gowebapp.exercises (exercise_name)
VALUES ($1) RETURNING exercise_id;

-- name: UpsertExercise :one
-- insert or update exercise of a particular id
INSERT INTO gowebapp.exercises (exercise_name)
VALUES ($1) ON CONFLICT (exercise_id) DO
UPDATE 
    SET exercise_name = EXCLUDED.exercise_name
    RETURNING exercise_id;


-- name: CreateUserImage :one
-- insert a new image
INSERT INTO gowebapp.images (user_id, content_type, image_data)
VALUES (
    $1,
    $2,
    $3
) RETURNING *;

-- name: UpsertUserImage :one
-- insert or update image of a particular id
INSERT INTO gowebapp.images (image_data)
VALUES ($1) ON CONFLICT (image_id) DO
UPDATE
    SET image_date = EXCLUDED.image_data
    RETURNING image_id;

-- name: CreateSet :one
-- insert new exercise sets
INSERT INTO gowebapp.sets (exercise_id, weight)
VALUES (
    $1,
    $2
) RETURNING *;

-- name: UpdateSet :one
-- insert a sets id
UPDATE gowebapp.sets
SET (exercise_id, weight) = ($1, $2)
WHERE set_id = $3 RETURNING *;

-- name: CreateWorkout :one
-- insert new workouts
INSERT INTO gowebapp.workouts (user_id, set_id, start_date)
VALUES (
    $1, $2, $3
) RETURNING *;

-- name: UpsertWorkout :one
-- insert or update workouts based on a particular ID
INSERT INTO gowebapp.workouts (user_id, set_id, start_date)
VALUES (
    $1, $2, $3
) ON CONFLICT (workout_id) DO
UPDATE
    SET user_id = EXCLUDED.user_id,
    set_id = EXCLUDED.set_id,
    start_date = EXCLUDED.start_date
    RETURNING workout_id;

-- name: CreateUsers :one
-- insert new user
INSERT INTO gowebapp.users (user_name, password_hash, name)
VALUES ($1, $2, $3) RETURNING *;
