resource "aws_iam_role" "aws_batch_service_role" {
  name               = "aws_batch_service_role"
  assume_role_policy = data.aws_iam_policy_document.aws_batch_service_assume_role.json
}

data "aws_iam_policy_document" "aws_batch_service_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role_ecs" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

# basic example
resource "aws_security_group" "open_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"

  vpc_id = module.vpc.vpc_id
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_batch_compute_environment" "metaflow_compute_env" {
  compute_environment_name = "metaflow_compute_env"

  compute_resources {
    max_vcpus = 32

    subnets            = module.vpc.private_subnets
    security_group_ids = [aws_security_group.open_sg.id]
    type               = "FARGATE" # "FARGATE_SPOT"
  }

  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role_ecs]
}
