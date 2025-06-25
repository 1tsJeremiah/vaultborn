package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Printf("warning: %v", err)
	}

	http.HandleFunc("/pull", handlePull)
	http.HandleFunc("/inject", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "💾 Secret stored")
	})
	http.HandleFunc("/handoff", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "🤝 Secret handed off")
	})

	log.Println("Vaultd is running on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func handlePull(w http.ResponseWriter, r *http.Request) {
	key := r.URL.Query().Get("key")
	if key == "" {
		http.Error(w, "missing key parameter", http.StatusBadRequest)
		return
	}

	val, ok := os.LookupEnv(key)
	if !ok || val == "" {
		http.Error(w, "secret not found", http.StatusNotFound)
		return
	}

	fmt.Fprint(w, val)
}
