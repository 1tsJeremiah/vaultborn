package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/joho/godotenv"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Printf("Warning: %v", err)
	}

	http.HandleFunc("/pull", func(w http.ResponseWriter, r *http.Request) {
		key := r.URL.Query().Get("key")
		fmt.Fprintf(w, "🔑 Fetched secret for key: %s", key)
	})

	http.HandleFunc("/inject", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "🔐 Secret stored")
	})

	http.HandleFunc("/handoff", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "🧳 Secret handed off")
	})

	http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok"}`))
	})

	fmt.Println("🚀 vaultd is running...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
