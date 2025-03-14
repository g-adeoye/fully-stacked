package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/k0kubun/pp"
)

var router *mux.Router

func main() {
	log.Println("Initializing logging server at port 8010.")
	runServer(":8010")
}

func runServer(addr string) {
	router = mux.NewRouter()
	initializeRoutes()

	scheme := pp.ColorScheme{
		String: pp.Green | pp.Bold,
		Float:  pp.Black | pp.BackgroundWhite | pp.Bold,
	}
	pp.SetColorScheme(scheme)

	log.Fatal(http.ListenAndServe(addr, router))
}

// respond with error handle error response
func respondWithError(w http.ResponseWriter, code int, message string) {
	response, _ := json.Marshal(message)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	w.Write(response)
}

// log handler to handle log POST request
func loghandler(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(r.Body)

	if err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request payload")
		return
	}
	defer r.Body.Close()
	pp.Println(string(body))
	w.WriteHeader(http.StatusCreated)
}

// initializeRoutes to initialize different routes
func initializeRoutes() {
	router.HandleFunc("/log", loghandler).Methods(http.MethodPost)
}
