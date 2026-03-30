resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_description = "EC2 CPU exceeds 70%"
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]
          ],
          period = 60,
          stat   = "Average",
          region = var.aws_region,
          title  = "EC2 CPU Utilization"
        }
      },
      {
        type   = "metric",
        x      = 12,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
          ],
          period = 60,
          stat   = "Sum",
          region = var.aws_region,
          title  = "ALB Request Count"
        }
      },
      {
        type   = "metric",
        x      = 0,
        y      = 6,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.order_tg_arn_suffix, "LoadBalancer", var.alb_arn_suffix]
          ],
          period = 60,
          stat   = "Average",
          region = var.aws_region,
          title  = "Order Service Healthy Hosts"
        }
      },
      {
        type   = "metric",
        x      = 12,
        y      = 6,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_instance_identifier]
          ],
          period = 60,
          stat   = "Average",
          region = var.aws_region,
          title  = "RDS CPU Utilization"
        }
      },
      {
        type   = "metric",
        x      = 0,
        y      = 12,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.db_instance_identifier]
          ],
          period = 60,
          stat   = "Average",
          region = var.aws_region,
          title  = "RDS Database Connections"
        }
      }
    ]
  })
}