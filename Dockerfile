# Base image for building the go project
FROM golang:1.14.6-alpine AS build

# Updates the repository and installs git
RUN apk update && apk upgrade && apk add --no-cache git
RUN apk add --update nodejs nodejs-npm

# Switches to /tmp/app as the working directory, similar to 'cd'
WORKDIR /tmp/app

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .

# Builds the curre
# The location of the binary file is /tmp/app/out/api
RUN GOOS=linux go build -v -o ./bin/bingo .

RUN mkdir -p /tmp/app/bin/frontend/dist/
RUN cd frontend && npm install && npm run build && cp -r dist/ /tmp/app/bin/frontend/

COPY VERSION ./bin/VERSION
COPY VERSION ./bin/frontend/dist/VERSION

#########################################################

# The project has been successfully built and we will use a
# lightweight alpine image to run the server 
FROM alpine:latest
LABEL author="Maneesh Babu M <maneesh@amagi.com>" version=2.0.0 

# To resolve timezone issue inside docker
RUN apk add --no-cache tzdata

# Adds CA Certificates to the image
RUN apk add ca-certificates

# Copies the binary file from the BUILD container to /app folder
COPY --from=build /tmp/app/bin/ /app/

# Switches working directory to /app
WORKDIR "/app"

EXPOSE 3000

# Runs the binary once the container starts
CMD ["./bingo"]