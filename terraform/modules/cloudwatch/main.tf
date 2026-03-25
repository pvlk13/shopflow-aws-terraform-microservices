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
        type = "metric",
        x    = 0,
        y    = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name ]
          ],
          period = 60,
          stat   = "Average",
          region = "us-east-1",
          title  = "EC2 CPU"
        }
      }
    ]
  })
}