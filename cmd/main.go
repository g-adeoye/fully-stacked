package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"strconv"

	"github.com/jackc/pgx/v5"

	"github.com/fully-stacked/gen"
	_ "github.com/lib/pq"
)

func main() {
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
		fmt.Fprintf(os.Stderr, "Unable to connect to database: %v\n", err)
		os.Exit(1)
	}
	defer db.Close(ctx)

	if err := db.Ping(ctx); err != nil {
		log.Fatalln("Error from database ping:", err)
	}

	store := gen.New(db)

	_, err = store.CreateUsers(
		ctx,
		gen.CreateUsersParams{
			UserName:     "testuser",
			PasswordHash: "hash",
			Name:         "test",
		},
	)

	if err != nil {
		log.Fatalln("Error creating user : ", err)
	}

	eid, err := store.CreateExercise(ctx, "Exercise1")

	if err != nil {
		log.Fatalln("Error creating exercise:", err)
	}
	set, err := store.CreateSet(
		ctx,
		gen.CreateSetParams{
			ExerciseID: eid,
			Weight:     100,
		},
	)

	if err != nil {
		log.Fatalln("Error updating exercise:", err)
	}

	set, err = store.UpdateSet(ctx, gen.UpdateSetParams{
		ExerciseID: eid,
		SetID:      set.SetID,
		Weight:     2000,
	})

	if err != nil {
		log.Fatalln("Error updating set:", err)
	}
	log.Print("Done!")

	u, err := store.ListUsers(ctx)

	if err != nil {
		log.Fatalln("Error listing users:", err)
	}

	for _, usr := range u {
		fmt.Printf("Name: %s, ID: %d\n", usr.Name, usr.UserID)
	}
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
