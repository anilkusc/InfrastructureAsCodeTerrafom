
# Create Repository.It is important for first build. 
resource "aws_ecr_repository" "ecr-containerized" {
  name                 = "${var.ECR_FACTORIAL_REPOSITORY_NAME}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_iam_role" "ecs-role" {
  name = "ecs-role"

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

resource "aws_iam_role_policy" "ecs-codebuild_policy" {
  name = "ecs-codebuild_policy"
  role = aws_iam_role.ecs-role.id

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
resource "aws_codebuild_project" "ecs-codebuild" {
  name          = "${var.ECR_FACTORIAL_REPOSITORY_NAME}"
  description   = "Csv importer docker build project"
  service_role  = aws_iam_role.ecs-role.arn

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
    location        = "https://git-codecommit.eu-west-3.amazonaws.com/v1/repos/Containerized-Application"
  }

}

# CodePipeline for triggering CodeBuild project when commit is pushed
resource "aws_codepipeline" "ecs-codepipeline" {
  name     = "factorial-calculator-pipeline"
  role_arn = aws_iam_role.ecs-codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.ecs-codepipeline_bucket.bucket
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
        RepositoryName = "Containerized-Application"
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
        ProjectName = "${aws_codebuild_project.ecs-codebuild.name}"
      }
    }
  }

  }
# S3 for writing build logs.
resource "aws_s3_bucket" "ecs-codepipeline_bucket" {
  bucket = "factorial-calculator-codepipeline-bucket-22019283"
  acl    = "private"
}

resource "aws_iam_role" "ecs-codepipeline_role" {
  name = "factorial-calculator-full-access"

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
resource "aws_iam_role_policy" "ecs-codepipeline_policy" {
  name = "csv-importer_codepipeline_policy"
  role = aws_iam_role.ecs-codepipeline_role.id

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