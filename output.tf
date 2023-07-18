output "alb-dns" {
  value = aws_lb.my_elb.dns_name
}