package main

import (
	"log"
	"net/http"
	"os"
)

var port = os.Getenv("PORT")

func main() {
	h := http.NewServeMux()
	h.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Header().Add("Content-Type", "text/plain")
		w.Write([]byte("Healthy"))
	})

	if port == "" {
		port = "8808"
	}

	s := http.Server{
		Handler: h,
		Addr:    ":" + port,
	}

	log.Fatal(s.ListenAndServe())
}
