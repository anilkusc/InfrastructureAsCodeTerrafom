
# Contianer Repositoory which is created on prebuild section
data "aws_ecr_repository" "ecr-serverless" {
  name = "${var.ECR_SERVERLESS_REPOSITORY_NAME}"
}
# Lambda function that workig with container image
resource "aws_lambda_function" "csv-importer-serverless" {
   function_name = "${var.LAMBDA_FUNCTION_NAME}"
   role = aws_iam_role.iam_for_lambda.arn
   # image repo address which will be used
   image_uri = "${data.aws_ecr_repository.ecr-serverless.repository_url}:latest"
   # Specify that lambda will be use container image
   package_type = "Image"
   description = "${var.LAMBDA_DESCRIPTION}"
   # Environment variables for lambda service.These variables will be inject to container.
   environment {
     variables = {
       S3_KEY_ID = "${var.ACCESS_KEY_ID}" 
       S3_ACCESS_KEY = "${var.ACCESS_KEY_SECRET}"
       S3_REGION_NAME = "${var.REGION}"
       S3_BUCKET_NAME = "${aws_s3_bucket.bucket.bucket}"
       MARIADB_USER = "${aws_db_instance.csv-database.username}"
       MARIADB_PASSWORD = "${aws_db_instance.csv-database.password}"
       MARIADB_HOST = "${aws_db_instance.csv-database.address}"
       MARIADB_DATABASE = "${aws_db_instance.csv-database.name}"
     }
   }
    depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
  ]
}

resource "aws_iam_role" "iam_for_lambda" {
 name = "lambda-role"
 assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Action": "sts:AssumeRole",
           "Principal": {
               "Service": "lambda.amazonaws.com"
           },
           "Effect": "Allow"
       }
   ]
}
 EOF
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
# It creates mysql database for writing csv file to database.It is publicly accesible in the sake of simplicity.
resource "aws_db_instance" "csv-database" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "${var.DATABASE_NAME}"
  username             = "${var.DATABASE_USER}"
  password             = "${var.DATABASE_PASSWORD}"
  parameter_group_name = "default.mysql5.7"
  publicly_accessible = true
  skip_final_snapshot  = true
}

# S3 bucket for  uploading csv files
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.S3_NAME}"
  acl    = "public-read-write"
}
# Triggering lambda function when uploaded a file to s3 store
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv-importer-serverless.arn
    events              = ["s3:ObjectCreated:*"]
  }
    depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv-importer-serverless.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}