output "alb_url" {
  description = "URL for the ALB"
  value       = aws_lb.commitflow.dns_name
}

output "alb_target_group" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.commitflow.arn
}
