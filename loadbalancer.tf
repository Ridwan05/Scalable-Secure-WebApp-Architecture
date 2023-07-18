# Create loadbalancer with Subnet1, Subnet2 & Subnet3 attched
resource "aws_lb" "my_elb" {
  name               = "my-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elbweb_access.id]
  subnets = [
    aws_subnet.subnets["Subnet1"].id,
    aws_subnet.subnets["Subnet2"].id,
    aws_subnet.subnets["Subnet3"].id
  ]

  tags = {
    "Name" = "MyElb"
  }
}

# Create loadbalancer target group
resource "aws_lb_target_group" "my_tgtgrp" {
  name        = "my-tgtgrp"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.my_vpc.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
  }
}

# Configure loadbalancer to listen on port 80
resource "aws_lb_listener" "my_elb" {
  load_balancer_arn = aws_lb.my_elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tgtgrp.arn
  }
}


