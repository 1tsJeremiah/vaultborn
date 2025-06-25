package main

import (
    "fmt"
    "os"
)

func main() {
    if len(os.Args) < 2 {
        fmt.Println("vault-agent: missing command. Try `pull`, `inject`, or `handoff`.")
        return
    }

    cmd := os.Args[1]
    switch cmd {
    case "pull":
        fmt.Println("🔑 pulling secrets for key:", os.Args[3])
    case "inject":
        fmt.Println("💉 injecting secret to target:", os.Args[3])
    case "handoff":
        fmt.Println("🤝 performing agent handoff...")
    default:
        fmt.Println("❓ unknown command:", cmd)
    }
}
