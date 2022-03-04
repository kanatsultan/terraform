resource "aws_security_group" "client_alb" {
  name_prefix = "${var.default_tags.project}-ecs-client-alb"
  description = "security group for client service application load balancer"
  vpc_id      = aws_vpc.admin_account_vpc.id
}

resource "aws_security_group_rule" "client_alb_allow_80" {
  security_group_id = aws_security_group.client_alb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow HTTP traffic"
}

resource "aws_security_group_rule" "client_alb_allow_outboud" {
  security_group_id = aws_security_group.client_alb.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow outbound trffic"
}

resource "aws_security_group" "ecs-client-service" {
  name_prefix = "${var.default_tags.project}-ecs-client-service"
  description = "ECS Client service security group"
  vpc_id      = aws_vpc.admin_account_vpc.id
}

resource "aws_security_group_rule" "ecs_client_service_allow_9090" {
  security_group_id        = aws_security_group.ecs-client-service.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9090
  to_port                  = 9090
  source_security_group_id = aws_security_group.client_alb.id
}

resource "aws_security_group_rule" "client_alb_allow_outboud_9090" {
  security_group_id        = aws_security_group.ecs-client-service.id
  type                     = "egress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.client_alb.id
}