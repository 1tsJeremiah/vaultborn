package main

import (
go.mod "fmt"
go.mod "log"
go.mod "net/http"
)

func main() {
go.mod http.HandleFunc("/pull", func(w http.ResponseWriter, r *http.Request) {
go.mod go.mod key := r.URL.Query().Get("key")
go.mod go.mod fmt.Fprintf(w, "🔐 Fetched secret for key: %s", key)
go.mod })

go.mod http.HandleFunc("/inject", func(w http.ResponseWriter, r *http.Request) {
go.mod go.mod fmt.Fprintln(w, "💾 Secret stored")
go.mod })

go.mod http.HandleFunc("/handoff", func(w http.ResponseWriter, r *http.Request) {
go.mod go.mod fmt.Fprintln(w, "🤝 Secret handed off")
go.mod })

go.mod log.Println("Vaultd is running on :8080")
go.mod log.Fatal(http.ListenAndServe(":8080", nil))
}
