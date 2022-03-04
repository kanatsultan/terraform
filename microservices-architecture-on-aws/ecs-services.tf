resource "aws_ecs_service" "client" {
  name            = "${var.default_tags.project}-client"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_defination.client.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  load_balancer {
    # target_group_arn = ?
    container_name = "client"
    container_port = 9090
  }

}
