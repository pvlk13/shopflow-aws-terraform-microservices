package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"strings"
)

type Product struct {
	ID       int     `json:"id"`
	Name     string  `json:"name"`
	Category string  `json:"category"`
	Price    float64 `json:"price"`
	Stock    int     `json:"stock"`
}

var products = []Product{
	{ID: 1, Name: "Laptop", Category: "Electronics", Price: 999.99, Stock: 10},
	{ID: 2, Name: "Headphones", Category: "Electronics", Price: 199.99, Stock: 25},
	{ID: 3, Name: "Chair", Category: "Furniture", Price: 149.99, Stock: 15},
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("GET /health")
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(map[string]string{
		"status":  "ok",
		"service": "product-service",
	})
}

func listProductsHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("GET /products")
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(products)
}

func getProductHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("GET", r.URL.Path)

	idStr := strings.TrimPrefix(r.URL.Path, "/products/")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid product id", http.StatusBadRequest)
		return
	}

	for _, product := range products {
		if product.ID == id {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusOK)
			_ = json.NewEncoder(w).Encode(product)
			return
		}
	}

	http.Error(w, "Product not found", http.StatusNotFound)
}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/health", healthHandler)
	mux.HandleFunc("/products", listProductsHandler)
	mux.HandleFunc("/products/", getProductHandler)

	log.Println("product-service running on port 8002")

	err := http.ListenAndServe(":8002", mux)
	if err != nil {
		log.Fatal(err)
	}
}