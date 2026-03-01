resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2-ssm-profile-a"
  role = aws_iam_role.ec2_ssm_role.name
}


data "aws_ami" "amazon_linux_a" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

data "aws_ami" "amazon_linux_b" {
  region = "us-west-2"

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "ec2_a_sg" {
  name   = "ec2-a-sg"
  vpc_id = module.vpc1.vpc_id

  ingress {
    description = "Allow all from VPC 2"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc2.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_b_sg" {
  region = "us-west-2"

  name   = "ec2-b-sg"
  vpc_id = module.vpc2.vpc_id

  ingress {
    description = "Allow all from VPC 1"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc1.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_a" {
  ami           = data.aws_ami.amazon_linux_a.id
  instance_type = "t3.micro"
  subnet_id     = module.vpc1.private_subnets[0]

  vpc_security_group_ids = [
    aws_security_group.ec2_a_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  tags = {
    Name = "TGW-Test-EC2-useast1"
  }
}

resource "aws_instance" "ec2_b" {
  region = "us-west-2"

  ami           = data.aws_ami.amazon_linux_b.id
  instance_type = "t3.micro"
  subnet_id     = module.vpc2.private_subnets[0]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name


  vpc_security_group_ids = [
    aws_security_group.ec2_b_sg.id
  ]

  tags = {
    Name = "TGW-Test-EC2-uswest2"
  }
}
