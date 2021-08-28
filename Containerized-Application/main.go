package main

import (
	"fmt"
	"net/http"
	"strconv"
)

func main() {
	http.HandleFunc("/", FactorialCalculateHandler)
	http.ListenAndServe(":80", nil)
}

//Handler for root URI.It send input to FactorialCalculator function return the value.
func FactorialCalculateHandler(w http.ResponseWriter, r *http.Request) {
	numbers, ok := r.URL.Query()["number"]

	if !ok || len(numbers[0]) < 1 {
		fmt.Fprintf(w, "Url Parameter 'number' is missing")
		return
	}
	number := numbers[0]
	input, err := strconv.Atoi(number)
	if err != nil {
		fmt.Fprintf(w, "Wrong Parameter")
		return
	}
	result := FactorialCalculate(input)
	if result == -1 {
		fmt.Fprintf(w, "Parameter must be positive")
		return
	}
	fmt.Fprintf(w, "Result is: %s", strconv.Itoa(result))
}

// Take the input parameter and return the factorial
func FactorialCalculate(input int) int {
	if input < 0 {
		return -1
	}
	total := 1
	for i := 1; i < input+1; i++ {
		total = total * i
	}
	return total
}
