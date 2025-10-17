#!/bin/bash
dnf update -y
dnf install -y docker

# Iniciar Docker
systemctl start docker
systemctl enable docker

sleep 30

# Descargar imagen desde S3
aws s3 cp s3://${s3_bucket}/${docker_image_name} /tmp/

# Cargar imagen Docker
docker load < /tmp/${docker_image_name}

# Ejecutar contenedor
docker run -d -p 5000:5000 \
  -e DB_HOST=${db_host} \
  -e DB_USER=${db_user} \
  -e DB_PASSWORD=${db_password} \
  -e DB_NAME=${db_name} \
  --restart=always \
  ${project_name}:latest

# Limpiar archivo temporal
rm /tmp/${docker_image_name}