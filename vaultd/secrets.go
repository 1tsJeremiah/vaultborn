package main

import (
"errors"
"fmt"
"os"
"strings"
"sync"

"github.com/joho/godotenv"
)

var (
loadOnce sync.Once
loadErr  error
allowSet map[string]struct{}
)

// ErrForbidden is returned when a requested secret is not in the allow list.
var ErrForbidden = errors.New("secret not allowed")

func loadEnv() {
if err := godotenv.Load(); err != nil && !os.IsNotExist(err) {
loadErr = err
return
}
data, err := os.ReadFile(".env.allow")
if err != nil {
if os.IsNotExist(err) {
return
}
loadErr = err
return
}
allowSet = make(map[string]struct{})
for _, line := range strings.Split(string(data), "\n") {
line = strings.TrimSpace(line)
if line == "" || strings.HasPrefix(line, "#") {
continue
}
allowSet[line] = struct{}{}
}
}

// GetEnvSecret loads secrets from .env and returns the value for key.
// If .env.allow exists, only keys listed within are returned.
func GetEnvSecret(key string) (string, error) {
loadOnce.Do(loadEnv)
if loadErr != nil {
return "", loadErr
}
if allowSet != nil {
if _, ok := allowSet[key]; !ok {
return "", ErrForbidden
}
}
val := os.Getenv(key)
if val == "" {
return "", fmt.Errorf("secret %s not found", key)
}
return val, nil
}
