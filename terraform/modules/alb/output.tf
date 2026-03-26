output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "user_tg_arn" {
  value = aws_lb_target_group.user_tg.arn
}

output "product_tg_arn" {
  value = aws_lb_target_group.product_tg.arn
}

output "order_tg_arn" {
  value = aws_lb_target_group.order_tg.arn
}