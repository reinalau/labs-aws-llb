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
  description = "Endpoint o address de la base de datos RDS (sin puerto)"
  value       = aws_db_instance.main.address
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

output "eks_cluster_name" {
  description = "Nombre del cluster EKS"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint del cluster EKS"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security Group del cluster EKS"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "configure_kubectl" {
  description = "Comando para configurar kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.main.name}"
}

output "db_name" {
  description = "Nombre de la base de datos"
  value       = aws_db_instance.main.db_name
}