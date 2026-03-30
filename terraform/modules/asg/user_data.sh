#!/bin/bash
dnf update -y
dnf install -y docker git postgresql15
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

cd /home/ec2-user
git clone https://github.com/pvlk13/shopflow-aws-terraform-microservices.git
cd /home/ec2-user/shopflow-aws-terraform-microservices

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 272183979798.dkr.ecr.us-east-1.amazonaws.com

DB_HOST=$(aws ssm get-parameter --name "/shopflow/db/host" --query "Parameter.Value" --output text --region us-east-1)
DB_PORT=$(aws ssm get-parameter --name "/shopflow/db/port" --query "Parameter.Value" --output text --region us-east-1)
DB_NAME=$(aws ssm get-parameter --name "/shopflow/db/name" --query "Parameter.Value" --output text --region us-east-1)
DB_USER=$(aws ssm get-parameter --name "/shopflow/db/user" --query "Parameter.Value" --output text --region us-east-1)
DB_PASSWORD=$(aws ssm get-parameter --name "/shopflow/db/password" --with-decryption --query "Parameter.Value" --output text --region us-east-1)

cat > .env <<EOF
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
EOF

until PGPASSWORD="$DB_PASSWORD" PGSSLMODE=require psql \
  -h "$DB_HOST" \
  -p "$DB_PORT" \
  -U "$DB_USER" \
  -d "$DB_NAME" \
  -c '\q'; do
  echo "DB not ready yet..."
  sleep 5
done

PGPASSWORD="$DB_PASSWORD" PGSSLMODE=require psql \
  -h "$DB_HOST" \
  -p "$DB_PORT" \
  -U "$DB_USER" \
  -d "$DB_NAME" \
  -f /home/ec2-user/shopflow-aws-terraform-microservices/db/init.sql

docker-compose up -d