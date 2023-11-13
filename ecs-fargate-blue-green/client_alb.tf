resource "aws_security_group" "client_alb_sg" {
  name   = "client_alb_sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "everywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "client_alb" {
  #name               = "client_alb"
  name_prefix        = "cl-"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.client_alb_sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "client" {
  name = "client"
  port = 9090 # fake_Service
  #port                 = 80 # nginx
  protocol             = "HTTP"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 30
  target_type          = "ip"

  health_check {
    enabled             = true
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 30
    interval            = 60
    protocol            = "HTTP"
  }
}

resource "aws_lb_target_group" "client2" {
  name = "client2"
  port = 9090 # fake_Service
  #port                 = 80 # nginx
  protocol             = "HTTP"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 30
  target_type          = "ip"

  health_check {
    enabled             = true
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 30
    interval            = 60
    protocol            = "HTTP"
  }
}

resource "aws_lb_listener" "client_listener" {
  load_balancer_arn = aws_lb.client_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }

}

resource "aws_lb_listener" "client2_listener" {
  load_balancer_arn = aws_lb.client_alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client2.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }

}
