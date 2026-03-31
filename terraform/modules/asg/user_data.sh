#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

REGION="us-east-1"
ACCOUNT_ID="272183979798"
REPO_DIR="/home/ec2-user/shopflow-aws-terraform-microservices"

echo "Starting bootstrap..."

dnf update -y
dnf install -y docker git postgresql15 awscli

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

if [ ! -d "$REPO_DIR" ]; then
  cd /home/ec2-user
  git clone https://github.com/pvlk13/shopflow-aws-terraform-microservices.git
fi

cd "$REPO_DIR"

aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

get_param() {
  local name="$1"
  local decrypt="${2:-false}"

  if [ "$decrypt" = "true" ]; then
    aws ssm get-parameter \
      --name "$name" \
      --with-decryption \
      --query 'Parameter.Value' \
      --output text \
      --region "$REGION"
  else
    aws ssm get-parameter \
      --name "$name" \
      --query 'Parameter.Value' \
      --output text \
      --region "$REGION"
  fi
}

DB_HOST="$(get_param /shopflow/db/host)"
DB_PORT="$(get_param /shopflow/db/port)"
DB_NAME="$(get_param /shopflow/db/name)"
DB_USER="$(get_param /shopflow/db/user)"
DB_PASSWORD="$(get_param /shopflow/db/password true)"

for v in DB_HOST DB_PORT DB_NAME DB_USER DB_PASSWORD; do
  if [ -z "${!v}" ] || [ "${!v}" = "None" ]; then
    echo "ERROR: $v is empty"
    exit 1
  fi
done

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
  -f "$REPO_DIR/db/init.sql"

docker compose up -d

echo "Bootstrap completed successfully."