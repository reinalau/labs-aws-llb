![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat&logo=amazonaws&logoColor=white)

## Laboratorios AWS con Iac

Este es un repo donde se van compartiendo diferentes casos de uso de aws con su correspondiente Infraestructura como codigo (IAC). 
El objetivo es explorar las pequeñas arquitecturas estables, robustas y resilientes que nos ofrece AWS, comprendiendo como es el proceso de deployment.

## Proyectos - Laboratorios

- [CRUD con Lambda + DynamoDB + API Gateway](https://github.com/reinalau/labs-aws-llb/tree/main/CRUD_Lambda-Dynamo-Apigateway)

- [Arquitectura Alta Disponibilidad con ALB + Auto Scaling + EC2 + RDS (CloudFormation + Terraform)](https://github.com/reinalau/labs-aws-llb/tree/main/HA_ALB-AS-EC2-RDS)

- [Arquitectura Alta Disponibilidad con ALB + ECS Fargate + RDS (CloudFormation + Terraform)](https://github.com/reinalau/labs-aws-llb/tree/main/HA_ALB-FARGATE-RDS)

- [Arquitectura Alta Disponibilidad con ALB + EKS Fargate + RDS (Terraform)](https://github.com/reinalau/labs-aws-llb/tree/main/HA_ALB-EKS-RDS)

## 🧹 Limpieza de ambiente AWS
Recordar que todos los laboratorios pueden llegar a tener un costo minimo en la consola. La idea es analizar la IAC--> impactar --> analzar la infraestructura creada en aws e inmediatamente despues de testear: destruir. 
Para evitar sorpresas seguir las indicaciones de delete/destroy o eliminación manual de recursos via la consola de aws.


## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver archivo [LICENSE](LICENSE) para más detalles.