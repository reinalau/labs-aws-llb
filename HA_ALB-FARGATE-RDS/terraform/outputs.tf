output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "DNS name del Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "URL completa de la aplicación"
  value       = "http://${aws_lb.main.dns_name}"
}

output "rds_endpoint" {
  description = "Endpoint  o address de la base de datos RDS"
  value       = aws_db_instance.main.endpoint

}

output "rds_port" {
  description = "Puerto de la base de datos RDS"
  value       = aws_db_instance.main.port
}

output "public_subnet_ids" {
  description = "IDs de las subnets públicas"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  description = "IDs de las subnets privadas"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "ecr_repository_url" {
  description = "URL del repositorio ECR"
  value       = data.aws_ecr_repository.main.repository_url
}

output "ecs_cluster_name" {
  description = "Nombre del cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Nombre del servicio ECS"
  value       = aws_ecs_service.main.name
}