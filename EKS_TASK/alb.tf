resource "aws_lb" "my_load_balancer" {
  name               = "my-elb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for j in data.aws_subnet.public_subnets : j.id]
  tags = {
    Name = "my-elb"
    Date = local.current_date
    Env  = "${terraform.workspace}"
  }
}


# Configure target group
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main_vpc.id
  tags = {
    Name = "my-target-group"
    Date = local.current_date
    Env  = "${terraform.workspace}"
  }
}

# Attach target group to ELB listener
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}


resource "aws_autoscaling_attachment" "eks_node_group_attachment" {
  autoscaling_group_name = data.aws_autoscaling_groups.eks_asg.names[0]
  lb_target_group_arn    = aws_lb_target_group.my_target_group.arn

}

