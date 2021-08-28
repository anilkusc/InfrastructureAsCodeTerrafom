# Infrastructure of Demo Project

The purpose of this repo is to build a demo project consisting of 3 repos from an Infrastructure as code perspective. The other 2 repos are Serverless CSV Importer and Containerized Factorial Calculator applications. To install these applications, you must first follow the instructions in this repo. With the help of this repo, necessary components are created in the AWS cloud environment.After apply this repo, specified rules will be defined, configurations will be applied , applications will be able to deployed and development can be continued after the infrastructure is ready. In order to make the infrastructure ready, [CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/welcome.html) and [CodePipeline](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html) configurations must be made for the 2 projects mentioned above.You can create this CI/CD resources with the ease of prebuild folder.


# Table of contents

1. [Infrastructure of Demo Projects](#infrastructure-of-demo-projects)
    * [Tech Stack](#tech-stack)
    * [Quick Access](#quick-access)
2. [Getting Started](#getting-started)
    * [Prerequisites](#prerequisites)
    * [Installation](#installation)
    * [Destroying](#destroying)
    * [Variables](#variables)
    * [Cautions](#cautions)
3. [Components](#components)
    * [Elastic Container Service](#elastic-container-service)
    * [Lambda Function](#lambda-function)
    * [Elastic Container Registry](#elastic-container-registry)
    * [Database](#database)
    * [S3 Object Storage](#s3-object-storage)
    * [CodeBuild Project](#codebuild-project)
    * [CodePipeline Project](#codepipeline-project)
4. [Further Information](#further-information)


## Tech Stack



* [Ubuntu(20.04.2 LTS)](https://ubuntu.com/)

  Ubuntu 20.04.2 is used for all of the projects.Because it is easier to contact with cloud services with linux based systems.

* [Terraform-HCL(v1.0.2)](https://www.terraform.io/)

  Terraform is one of the most used IaC tools. It has made it easy to create infrastructure with its unique HCL (Hashicorp Configuration Language). Its modular structure, well-documented, well-explained module reference pages and compatibility with all major cloud providers are effective factors in choosing Terraform.

* [AWS(aws-cli/2.2.18)](https://aws.amazon.com/)

  AWS is the widely used cloud service founded by Amazon. All resources used for this demo are hosted on AWS.

## Quick Access

1. Sign in to AWS with related user credentials.

   ```sh
    aws configure
   ```

2. Create codebuild and codepipeline for repos with prebuild folder.

   ```sh
    cd prebuild && terraform init && terraform apply --auto-approve && cd ..
   ```

3. Wait(~5 min.) until CodeCommit builds finished.(You can check it from CodeBuild projects)

4. Install terraform module
   ```sh
    terraform init
   ```

5. Apply the terraform configurations.
   ```sh
   terraform apply --auto-approve
   ```

6. Enter your aws acces key and secret.

7. Check if everything is OK :) 

# Getting Started

This section shows how to build projects from stract. To start the project, first you need to provide prerequisites. Then follow the instructions in Installation. To destroy the infrastructure, follow the instructions in the Destroying section. You can find information about variables in the Variables section. In the Cautions section, there are warnings that you need to pay attention to.

## Prerequisites

* **Install AWS-cli** :

Aws-cli must be installed on the system. The quick install command for Linux is given below. For other operating systems, you can refer to the  [aws-cli documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) 

  ```sh
  sudo apt update && apt install unzip -y && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && sudo unzip awscliv2.zip && sudo ./aws/install
  ```

* **Install Terraform**:

Terraform must be installed to the system for apply the configurations. <a href="https://learn.hashicorp.com/tutorials/terraform/install-cli">terraform documentation </a>.

  ```sh
  sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update && sudo apt-get install terraform -y
  ```

* **Push Projects to the Repo** :

 You need to push Inftrastructure , Containerized App , Serverless projects to repositories.

## Installation

1. Login to AWS with aws-cli and give key , id , region informations belongs to your aws user.
   ```sh
   aws configure
   ```
2. Clone this repo
   ```sh
   git clone <repository_address>
   ```
3. For the build from scratch apply the prebuild folder
   ```sh
   cd prebuild && terraform init && terraform apply --auto-approve && cd ..
   ```
4. When prebuild is done install terraform modules.
   ```sh
   terraform init
   ```
5. Apply the terraform configuration
   ```sh
   terraform apply --auto-approve
   ```
6. Give Your AWS Access Key and Id as variable to the prompt on the cli

6. Control If Infrastructure is Running



## Destroying

1. Delete content of target S3 buckets first.(Deleting S3 buckets while it have some contents is not allowed by AWS)
2. Delete Infrastructure 
   ```sh
   terraform destroy --auto-approve
   ```
3. Delete prebuilds

   ```sh
   cd prebuild && terraform destroy --auto-approve && cd ..
   ```

## Variables

Variable definition can be found on the <i>variables.tf</i> files. Value of variables are in the <i>terraform.tfvars</i> files. If you do not specify values of the variables , these variables are requested from the user at runtime. This type of variables are usually used for sensitive data.

* **REGION**: AWS Cloud region
* **S3_NAME**: S3 Bucket name for the serverless application
* **LAMBDA_DESCRIPTION**: Description of the lambda function
* **LAMBDA_FUNCTION_NAME**: Name of the lambda function
* **ACCESS_KEY_ID**: AWS Access Key Id.Not defined in the tfvars file. So it will be prompted on runtime.
* **ACCESS_KEY_SECRET**: AWS Access Key Secret.Not defined in the tfvars file. So it will be prompted on runtime
* **ECR_SERVERLESS_REPOSITORY_NAME**: Container Registry Repository name for serverless csv importer application
* **ECR_FACTORIAL_REPOSITORY_NAME**:Container Registry Repository name for containerized factorial calculator application
* **DATABASE_USER**: Database username 
* **DATABASE_PASSWORD**: Database password 
* **DATABASE_NAME**: Database name to create at startup

## Cautions

* In order for s3 objects to be deleted, the files inside must be deleted first. Before destroying, you must delete the contents of the s3 objects to be removed from the AWS platform. If you get an s3 bucket error during the destruction process, delete the contents of the S3 objects in AWS. If you give the destroy command again, it will continue from where you left off.

* After applying the prebuild folder, the CI/CD pipelines will be organized and the first build process for applications will start. Usually, it is unlikely to encounter such a problem, but if the first build takes a long time, the serverless lambda function cannot pull the container and it can give error. It is recommended to check that everything is OK in CI/CD after prebuild sectionç

* If you are going to push projects for the first time, be careful not to change the project names. If you are going to change the name, be sure to change the variable names in the folder where the variable files are.

* Database accesses are publicly accessible by default. You can change these settings on AWS.

* If you do not want to push sensitive information to the repo such as database user informations and AWS keys , delete the values to which these parameters are assigned from the terrform.tfvars file. Thus, the user will be prompted for these values during runtime.

# Components

This section contains information about terraform components.

### Elastic Container Service
 
 * This component is used for creating elastic container service. It contains "iam roles" , "aws_ecs_service" , "aws_ecs_task_definition". Also there are some Load balancer configurations for binding Load Balancer to ECS.Load Balancer configuration also have some VPC,scurity group configuration and rules. It is stand for forwarding traffic to the right instances and allow reaching Load Balancer from public access.

### Lambda Function
 
 * This component is for creating lambda function for csv importer application.Component(Resource) name is "aws_lambda_function". It designed to run container image that import csv from s3 and write it to database. So it needs a container image which is builded on prebuild section. It can give error can not find specified image. So this is important that look out if csv importer image has built. It has also environment variables for database and s3 objects.

### Elastic Container Registry

  * It creates a repository on Elastic Container Registry(ECR). Resource name is "aws_ecr_repository" and there are not many attributes about this component.

### Database
 
  * "aws_db_instance" component is stands for creating various databases on the AWS ecosystem. You need to fill the specifications on component for creating database.

### S3 Object Storage

  * "aws_s3_bucket" is responsible for creating s3 bucket. It can be used for storing CI/CD pipeline logs or trigger lambda function etc. If you want to delete tihs component firstly you need to delete contents of it.

### CodeBuild Project
 
  * This "aws_codebuild_project" creates codebuild for specified AWS codecommit repo. It needs some configuration like artifacts ,environment ,logs_config ,source . 

### CodePipeline Project

  * "aws_codepipeline_project" component creates a codepipeline project based on a CodeBuild project. This component is added for automatically trigger the build when a commit is pushed to the repository.

# Further Information

 * https://www.terraform.io/docs/index.html
 * https://docs.aws.amazon.com/
 * https://docs.aws.amazon.com/codebuild/
 * https://docs.aws.amazon.com/codecommit/
 * https://docs.aws.amazon.com/codepipeline/
 * https://aws.amazon.com/en/ecr/
 * https://aws.amazon.com/en/ecs/
 * https://aws.amazon.com/en/rds/
 * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
 * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
 * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
 * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
 * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project
 * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline
