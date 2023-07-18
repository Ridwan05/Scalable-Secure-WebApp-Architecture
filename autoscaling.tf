# Create user data
data "template_file" "user_data" {
  template = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo bash -c 'echo You are accessing my server $(hostname -f) > /var/www/html/index.html'
sudo systemctl restart apache2
EOF
}

# Create a launch template in our VPC
resource "aws_launch_template" "webapptemplate" {
  name                   = "weblaunch3"
  image_id               = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data              = base64encode(data.template_file.user_data.rendered)
  vpc_security_group_ids = [aws_security_group.ec2web_access.id]

}

# Create autoscaling group specifying subnets to launch resouces in
resource "aws_autoscaling_group" "webApptier" {
  name             = "webApptier-autoscaling-group"
  max_size         = 3
  min_size         = 1
  desired_capacity = 2
  vpc_zone_identifier = [

    aws_subnet.subnets["Subnet1"].id,
    aws_subnet.subnets["Subnet2"].id,
    aws_subnet.subnets["Subnet3"].id
  ]

  launch_template {
    id      = aws_launch_template.webapptemplate.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.my_tgtgrp.arn]
}
