resource "aws_ecs_task_defination" "client" {
  family                   = "${var.default_tags.project}-client"
  requires_compatibilities = ["FARGATE"]
  memory                   = 512
  cpu                      = 256
  network_mode             = "awsvpc"
  container_definations = jsonencode(
    [
      {
        name      = "client-container"
        image     = "nicholasjackson/fake-service/tree/v0.23.1"
        cpu       = 0
        essential = true

        portMappings = [
          {
            containerPort = 9090
            hostport      = 9090
            protocol      = "tcp"
          }
        ]

        environment = [
          {
            name  = "NAME"
            value = "client"
          },
          {
            name  = "MESSAGE"
            value = "Hello from the client"
          }
        ]
      }
    ]
  )
}
