# Get repository data of csv-importer
data "aws_ecr_repository" "ecs-serverless" {
  name = "${var.ECR_FACTORIAL_REPOSITORY_NAME}"
}
# Create ECS cluster
resource "aws_ecs_cluster" "factorial_calculator_cluster" {
  name = "Factorial-Calculator"
}
# Create Task definiton for ECS Cluster
resource "aws_ecs_task_definition" "factorial_calculator_task" {
  family                   = "factorial-calculator-deploy-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "factorial-calculator-deploy-task",
      "image": "${data.aws_ecr_repository.ecs-serverless.repository_url}:latest", 
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}" # execution role for givin permission to task definition
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "Terraform-ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# ECS Factorial Service
resource "aws_ecs_service" "factorial_service" {
  name            = "factorial-calculator-service"
  cluster         = "${aws_ecs_cluster.factorial_calculator_cluster.id}"
  task_definition = "${aws_ecs_task_definition.factorial_calculator_task.arn}"
  launch_type     = "FARGATE"
  desired_count   = 1
  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    container_name   = "${aws_ecs_task_definition.factorial_calculator_task.family}"
    container_port   = 80 
  }
  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_1.id}","${aws_default_subnet.default_subnet_2.id}"]
    assign_public_ip = true 
    security_groups  = ["${aws_security_group.service_security_group.id}"]
  }
}

# Network configurations for ECS and Load Balancer
resource "aws_default_vpc" "default_vpc" {

}
resource "aws_default_subnet" "default_subnet_1" {
  availability_zone = "eu-west-3a"
}
resource "aws_default_subnet" "default_subnet_2" {
  availability_zone = "eu-west-3b"
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0 
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

# Load Balancer which is used for reaching the ECS service
resource "aws_alb" "application_load_balancer" {
  name               = "factorial-calculator-lb"
  load_balancer_type = "application"
  subnets = [
    "${aws_default_subnet.default_subnet_1.id}",
    "${aws_default_subnet.default_subnet_2.id}"
  ]
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0 
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.default_vpc.id}" # Referencing the default VPC
  health_check {
    matcher = "200,301,302"
    path = "/"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_alb.application_load_balancer.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
  }
}

