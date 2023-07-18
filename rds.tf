# Designate subnets for RDS
resource "aws_db_subnet_group" "subgrp" {
  name = "subgrp"
  subnet_ids = [
    aws_subnet.subnets["Subnet4"].id,
    aws_subnet.subnets["Subnet5"].id,
    aws_subnet.subnets["Subnet6"].id
  ]

  tags = {
    Name = "My DB subnet group"
  }
}

# Create DB instance
resource "aws_db_instance" "default" {
  allocated_storage      = 10
  db_subnet_group_name   = aws_db_subnet_group.subgrp.id
  engine                 = "Mysql"
  engine_version         = "8.0.32"
  instance_class         = "db.t2.micro"
  multi_az               = true
  username               = "admin"
  password               = var.db_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false

}
