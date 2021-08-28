# Serverless CSV Importer

The purpose of this repo is to write the user records uploaded as csv files to the database. This project was created to run serverless on AWS Lambda. An s3 object storage is taken as the target and when a file is uploaded there, the lambda function would trigger automatically and the information in file will be write to the database. Before running it on AWS be sure that triggering with s3 bucket is set correctly in AWS lambda. You can find more information and related examples in below. Also there is an example username.csv file for templating.

# Table of contents

1. [Serverless CSV Importer](#serverless-csv-importer)
    * [Tech Stack](#tech-stack)
2. [Getting Started](#getting-started)
    * [Prerequisites](#prerequisites)
    * [Build](#build)
    * [Upload CSV](#upload-csv)
    * [Control Database](#control-database)
    * [Version Update](#version-update)
3. [Parameters](#parameters)
    * [Environment Parameters](#environment-variables)
    * [Modules](#modules)
4. [Csv Template](#csv-template)

## Tech Stack

* [Ubuntu(20.04.2 LTS)](https://ubuntu.com/)

  Ubuntu 20.04.2 is a good OS for developing python.All the modules in this project can be found on linux repos of python. You need to research for your OS version of modules if you have compatibling issues about modules.

* [Docker](https://www.docker.com/)

  Docker is standardized container platform. In this project it used for build container image to run on AWS Lambda service. Directly upload code to lambda was not preferred because it is easier to encapsulate code and libraries with docker.

* [Python(v3.8)](https://www.python.org/)

  Python is appropriate for scripting such as like this project's purpose. Since we do not need performance python preferred for this project. Since Python is an easy language, the effort for this project will also be reduced.


# Getting Started

In this section, you can see how to build the project and push the repository as a container. How to upload the csv to an S3 bucket and check the results from the database is also written in this section. Also, how to activate the new version is specified in the last section.

## Prerequisites

* **Local Development** :
   
   - Install python :

      ```sh
      sudo apt install software-properties-common -y
      sudo add-apt-repository ppa:deadsnakes/ppa
      sudo apt update
      sudo apt install python3.8 -y

      ```
   - Install python modules :
      ```sh
      pip3 install mysql-connector-python boto3 pandas
      ```
   - Add handler function to bottom of index.py with pseudo event:
      ```sh
      event=<example-json-event>
      handler(event, context):
      ```
   - Set Environment Variables:
      ```sh
      export DATABASE_NAME=<database-name>
      export DATABASE_USER=<database-user>
      .
      .
      .
      ```
   - Run the script
      ```sh
      python3 index.py
      ```   
* **On AWS** :

   - Push the commit: After commit is pushed , all building process is realized on aws codebuild automatically. It takes configuration from buildspec.yaml file. If you want to change build steps change only on buildspec.yaml .

## Upload CSV

   For uploading csv you only need your csv and a permitted AWS user. Just go to related s3 bucket and upload your csv file. After that function will trigger automatically.

## Control Database

   After upload your csv you can database for records. Go to RDS service on AWS and get host information. Then you can connect database a mysql client. You can find database credentials and table name on Infrastructure Repo. You can change credentials on the AWS database page if you want.

## Version Update

   Each version update corresponds to a new container. Container versioning was not considered throughout this project. If you wish, you can create a version for each container build using the $BUILD_ID environment variable on buildspec.yaml file. All you have to do to update to the new version is to pull the new container on the ECS when you're ready.

# Parameters


## Environment Variables
 
* **MARIADB_USER**: Mysql authorized user for connection database
* **MARIADB_PASSWORD**: Database password
* **MARIADB_HOST**: Address of Mysql database.
* **MARIADB_DATABASE**: Database name of application.
* **S3_KEY_ID**: S3 key id for connecting s3 bucket
* **S3_ACCESS_KEY**: S3 key access for connecting s3 bucket
* **S3_REGION_NAM**: Region of target s3 bucket
* **S3_BUCKET_NAME**: Name of target s3 bucket

## Modules

   * os : for getting environment variables

   * sys : module for system commands like exit

   * mysql.connector: mysql connector module for access the database

   * boto3: AWS S3 module to connect an s3 bucket

   * pandas: csv handler module

   * urllib.parse: for getting last uploaded file to s3 bucket


# CSV Template

   Application parses the user object from csv files.User object has "id" , "username" , "firstname" and "lastname" attributes. The CSV file must match with template for avoid any issue while parsing and writing users to database. An example template is on the below table.


| Id      | Username | First_Name     | Last_Name     |
| :---        |    :----:   |          ---: |          ---: |
| 9012      | booker12       | Rachel   | Booker   |
| 2070   | grey07        | Laura      | Grey        |