
# Create Repository.It is important for first build.
resource "aws_ecr_repository" "ecr-serverless" {
  name                 = "${var.ECR_SERVERLESS_REPOSITORY_NAME}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}
resource "aws_iam_role" "serverless-role" {
  name = "serverless-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "serverless-codebuild_policy" {
  name = "serverless-codebuild_policy"
  role = aws_iam_role.serverless-role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}
# Create Codebuild for project. It takes configuration from buildspec.yml
resource "aws_codebuild_project" "serverless-codebuild" {
  name          = "${var.ECR_SERVERLESS_REPOSITORY_NAME}"
  description   = "Csv importer docker build project"
  service_role  = aws_iam_role.serverless-role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.eu-west-3.amazonaws.com/v1/repos/Serverless-Application"
  }

}

# CodePipeline for triggering CodeBuild project when commit is pushed
resource "aws_codepipeline" "codepipeline" {
  name     = "csv-importer-pipeline"
  role_arn = aws_iam_role.serverless-codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.serverless-codepipeline_bucket.bucket
    type     = "S3"
  }
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        RepositoryName = "Serverless-Application"
        BranchName       = "main"
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = "csv-importer" # CodeBuild Project Name
      }
    }
  }

  }

resource "aws_s3_bucket" "serverless-codepipeline_bucket" {
  bucket = "csv-importer-codepipeline-bucket-22019283"
  acl    = "private"
}

resource "aws_iam_role" "serverless-codepipeline_role" {
  name = "csv-importer-full-access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codecommit.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }    
  ]
}
EOF
}
resource "aws_iam_role_policy" "serverless-codepipeline_policy" {
  name = "csv-importer_codepipeline_policy"
  role = aws_iam_role.serverless-codepipeline_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}