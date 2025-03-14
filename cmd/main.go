package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/fully-stacked/gen"
	"github.com/fully-stacked/logger"
	_ "github.com/lib/pq"
)

func main() {
	l := flag.Bool("local", false, "true - send to stdout, false - send to logging server")
	flag.Parse()
	logger.SetLoggingOutput(*l)

	logger.Logger.Debugf("Application logging to stdout = %v", *l)
	logger.Logger.Info("Starting the application")

	dbURI := fmt.Sprintf(
		"postgres://%s:%s@%s:%d/%s?sslmode=disable",
		GetAsString("DB_USER", "postgres"),
		GetAsString("DB_PASSWORD", "mysecretpassword"),
		GetAsString("DB_HOST", "localhost"),
		GetAsInt("DB_PORT", 5432),
		GetAsString("DB_NAME", "postgres"),
	)
	ctx := context.Background()

	db, err := pgx.Connect(ctx, dbURI)
	if err != nil {
		logger.Logger.Errorf("Error opening database: %s", err.Error())
		os.Exit(1)
	}
	defer db.Close(ctx)

	if err := db.Ping(ctx); err != nil {
		logger.Logger.Errorf("Error from database ping: %s", err.Error())
	}
	logger.Logger.Info("Database connection fine")

	store := gen.New(db)

	chuser, err := store.CreateUsers(
		ctx,
		gen.CreateUsersParams{
			UserName:     "testuser",
			PasswordHash: "hash",
			Name:         "test",
		},
	)

	if err != nil {
		logger.Logger.Errorf("Error creating user")
	}
	logger.Logger.Info("Success - user creation")
	eid, err := store.CreateExercise(ctx, "Exercise1")

	if err != nil {
		logger.Logger.Errorf("Error creating exercise")
	}
	logger.Logger.Info("Success - exercise creation")
	set, err := store.CreateSet(
		ctx,
		gen.CreateSetParams{
			ExerciseID: eid,
			Weight:     100,
		},
	)

	if err != nil {
		logger.Logger.Errorf("Error creating sets")
	}

	set, err = store.UpdateSet(ctx, gen.UpdateSetParams{
		ExerciseID: eid,
		SetID:      set.SetID,
		Weight:     2000,
	})

	if err != nil {
		logger.Logger.Errorf("Error updating set:", err)
	}

	u, err := store.ListUsers(ctx)

	if err != nil {
		logger.Logger.Errorf("Error listing users:", err)
	}

	for _, usr := range u {
		fmt.Printf("Name: %s, ID: %d\n", usr.Name, usr.UserID)
	}
	_, err = store.UpsertWorkout(
		ctx,
		gen.UpsertWorkoutParams{
			UserID:    chuser.UserID,
			SetID:     set.SetID,
			StartDate: pgtype.Timestamp{},
		})

	if err != nil {
		logger.Logger.Errorf("Error updating workouts")
	}
	logger.Logger.Info("Success - updating workout")
	logger.Logger.Info("Application complete")

	defer time.Sleep(1 * time.Second)
}

func GetAsString(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}

	return defaultValue
}

func GetAsInt(key string, defaultValue int) int {
	valueStr := GetAsString(key, "")
	if value, err := strconv.Atoi(valueStr); err == nil {
		return value
	}
	return defaultValue
}
