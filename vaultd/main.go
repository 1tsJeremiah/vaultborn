package main

import (
	"errors"
	"fmt"
	"log"
	"net/http"
)

func handlePull(w http.ResponseWriter, r *http.Request) {
	key := r.URL.Query().Get("key")
	if key == "" {
		http.Error(w, "missing key", http.StatusBadRequest)
		return
	}

	val, err := GetEnvSecret(key)
	if err != nil {
		if errors.Is(err, ErrForbidden) {
			http.Error(w, "forbidden", http.StatusForbidden)
			return
		}
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	fmt.Fprint(w, val)
}

func handleInject(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "💾 Secret stored")
}

func handleHandoff(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "🤝 Secret handed off")
}

func handleHealthz(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"ok"}`))
}

func main() {
	loadOnce.Do(loadEnv)
	if loadErr != nil {
		log.Printf("Warning: %v", loadErr)
	}

	http.HandleFunc("/pull", handlePull)
	http.HandleFunc("/inject", handleInject)
	http.HandleFunc("/handoff", handleHandoff)
	http.HandleFunc("/healthz", handleHealthz)

	log.Println("Vaultd is running on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
