package main

import (
	"encoding/json"
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
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var key, value string
	if r.Header.Get("Content-Type") == "application/json" {
		var body struct {
			Key   string `json:"key"`
			Value string `json:"value"`
		}
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			http.Error(w, "bad request", http.StatusBadRequest)
			return
		}
		key = body.Key
		value = body.Value
	} else {
		if err := r.ParseForm(); err != nil {
			http.Error(w, "bad request", http.StatusBadRequest)
			return
		}
		key = r.FormValue("key")
		value = r.FormValue("value")
	}

	if key == "" {
		http.Error(w, "missing key", http.StatusBadRequest)
		return
	}

	if allowSet != nil {
		if _, ok := allowSet[key]; !ok {
			http.Error(w, "forbidden", http.StatusForbidden)
			return
		}
	}

	if err := SetEnvSecret(key, value); err != nil {
		log.Printf("inject error: %v", err)
		if errors.Is(err, ErrForbidden) {
			http.Error(w, "forbidden", http.StatusForbidden)
			return
		}
		http.Error(w, "failed to store secret", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	fmt.Fprint(w, "stored")
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
