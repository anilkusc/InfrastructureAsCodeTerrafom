# Containerized Factorial Calculator

The purpose of this repo is to calculate factorial by user input. This project was created to run AWS ECS.After the program is deployed, the user sends an http parameter as number and the factorial value of the number in this parameter is calculated. Before sending http request be sure your parameter is correct and service is running.


# Table of contents

1. [Containerized Factorial Calculator](#containerized-factorial-calculator)
    * [Tech Stack](#tech-stack)
2. [Getting Started](#getting-started)
    * [Prerequisites](#prerequisites)
    * [Build](#build)
    * [API](#api)
    * [Version Update](#version-update)

## Tech Stack

* [Ubuntu(20.04.2 LTS)](https://ubuntu.com/)

* [Docker](https://www.docker.com/)

* [Golang(v1.15)](https://golang.org/)

  Golang is a very useful programming language for performance-seeking applications. It is easy to scale, build and containerize. That's why go language is used in this project.

# Getting Started

In this section, you can see how to dockerize project and push the repository as a container. Also there is an explanation of building on local environment. You can find how to update version too.

## Prerequisites

   
   - Install golang :

      ```sh
      curl https://golang.org/dl/go1.15.14.linux-amd64.tar.gz
      rm -rf /usr/local/go && tar -C /usr/local -xzf go1.15.14.linux-amd64.tar.gz
      export PATH=$PATH:/usr/local/go/bin
      go version
      ```

   - Install docker(Optional) :

      ```sh
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
             $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      apt-get update
      apt-get install docker-ce docker-ce-cli containerd.io
      ```


## Build

   - Run Project:
      ```sh
      go run main.go
      ```
      or
      ```sh
      go build -o main . && ./main
      ```
   - Build as Docker(Optional):
      ```sh
      docker build -t <image-name> .
      ```
   - Run as container(Optional)
      ```sh
      docker run -dit -p 80:80 <image-name>
      ```   
## API

You need to pass number parameter for sending http request. Example request and response:

Request
```sh
curl "localhost:80?number=4"
```

Response
```sh
24
```

## Version Update

   Each version update corresponds to a new container. Container versioning was not considered throughout this project. If you wish, you can create a version for each container build using the $BUILD_ID environment variable on buildspec.yaml file. All you have to do to update to the new version is to pull the new container on the AWS ECS when you're ready.