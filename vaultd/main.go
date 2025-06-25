// 🔀 Merge resolution prompt for Codex task

// 🤖 Codex Task Prompt:
// Resolve the merge conflict between 'codex/add-/healthz-http-get-endpoint' and 'main' branch in `vaultd/main.go`
// Goal: Integrate the `/healthz` endpoint *without* duplicating the `main()` function or breaking existing behavior.

// ✅ Acceptance Criteria:
// - Only one `main()` function should remain
// - `/pull`, `/inject`, `/handoff`, and `/healthz` endpoints must all be handled
// - `godotenv.Load()` must be preserved with proper error logging
// - Code must compile and serve on port 8080

// 💡 Hint: You will need to refactor all handlers into a single `main()` function block.

// 📦 Dependencies:
import (
    "fmt"
    "log"
    "net/http"
    "os"

    "github.com/joho/godotenv"
)

// 🔧 Refactored `main()` should include:
// - godotenv loading
// - definition for all 4 endpoints
// - ListenAndServe

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

    fmt.Println("🚀 vaultd is running on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
