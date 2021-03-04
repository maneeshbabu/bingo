package main

import (
	"net/http"
	"os"

	"github.com/labstack/echo/v4"
)

func main() {
	port := os.Getenv("PORT")

	if port == "" {
		port = "3000"
	}

	e := echo.New()
	e.Static("/", "vue-app/dist")
	e.Static("/vue-org", "vue-app")

	e.GET("/hello", func(c echo.Context) error {
		return c.String(http.StatusOK, "Hello, World!")
	})
	e.Logger.Fatal(e.Start(":" + port))
}
