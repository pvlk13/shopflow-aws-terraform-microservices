# 🛒 ShopFlow — AWS Terraform Microservices

<p align="center">
  <img src="https://img.shields.io/badge/AWS-Cloud-orange?style=for-the-badge&logo=amazonaws" />
  <img src="https://img.shields.io/badge/Terraform-IaC-844FBA?style=for-the-badge&logo=terraform&logoColor=white" />
  <img src="https://img.shields.io/badge/FastAPI-User%20Service-009688?style=for-the-badge&logo=fastapi&logoColor=white" />
  <img src="https://img.shields.io/badge/Go-Product%20Service-00ADD8?style=for-the-badge&logo=go&logoColor=white" />
  <img src="https://img.shields.io/badge/Spring%20Boot-Order%20Service-6DB33F?style=for-the-badge&logo=springboot&logoColor=white" />
  <img src="https://img.shields.io/badge/PostgreSQL-Database-336791?style=for-the-badge&logo=postgresql&logoColor=white" />
</p>

<p align="center">
  <b>Polyglot microservices e-commerce platform deployed on AWS with Terraform</b>
</p>

---

## ✨ Overview

**ShopFlow** is a portfolio-grade, cloud-focused microservices project that demonstrates how to provision and run a distributed application on AWS using **Terraform** and a **polyglot service architecture**.

The project combines:

- **User Service** built with **Python FastAPI**
- **Product Service** built with **Go**
- **Order Service** built with **Java Spring Boot**
- **PostgreSQL** for persistent data
- **Flyway** for schema migrations and seed data
- **Terraform** for provisioning AWS infrastructure
- **Application Load Balancer + Auto Scaling + CloudWatch** for production-style deployment patterns

This repository is designed to showcase both **application engineering** and **cloud infrastructure engineering** in a single project.

---

## 🎯 What this project demonstrates

- Designing a **microservices architecture** with independent services
- Using **different languages/frameworks** in one system
- Provisioning AWS resources with **modular Terraform**
- Running services behind an **Application Load Balancer**
- Using **private application and database subnets**
- Managing a **PostgreSQL** database with **Flyway migrations**
- Storing database connection values in **AWS Systems Manager Parameter Store**
- Adding **CloudWatch dashboards and scaling alarms**
- Packaging services with **Docker**

---

## 🏗️ Architecture

```text
                           Internet
                              │
                              ▼
                    ┌────────────────────┐
                    │  Application Load  │
                    │     Balancer       │
                    │   HTTP → HTTPS     │
                    └─────────┬──────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
          ▼                   ▼                   ▼
 ┌────────────────┐  ┌────────────────┐  ┌────────────────┐
 │  User Service  │  │ Product Service│  │  Order Service │
 │  FastAPI       │  │ Go             │  │ Spring Boot    │
 │  Port 8001     │  │ Port 8002      │  │ Port 8003      │
 └────────┬───────┘  └────────────────┘  └────────┬───────┘
          │                                        │
          └──────────────────────┬─────────────────┘
                                 ▼
                     ┌────────────────────────┐
                     │     PostgreSQL RDS     │
                     │   users + orders data  │
                     └────────────────────────┘

Infrastructure layout:
- Public subnets: ALB + NAT Gateway
- Private app subnets: EC2 Auto Scaling Group
- Private DB subnets: RDS PostgreSQL
```

---

## 🧠 Architecture deep dive

### 1) Entry layer
Traffic enters through an **AWS Application Load Balancer (ALB)**.  
The ALB redirects **HTTP (80)** traffic to **HTTPS (443)** and uses listener rules to route requests by path:

- `/users/*` → **user-service**
- `/products` and `/products/*` → **product-service**
- `/orders` and `/orders/*` → **order-service**

### 2) Compute layer
Application instances run inside an **Auto Scaling Group** using a launch template.  
The ASG deploys EC2 instances in **private application subnets**, which is a good production-oriented design because app instances are not directly exposed to the public internet.

### 3) Data layer
The project provisions **Amazon RDS PostgreSQL** inside **private DB subnets**.  
The database is used by:

- **user-service** for user registration/login/profile data
- **order-service** for order storage

### 4) Database initialization
The project uses **Flyway** to apply:

- schema migrations in `db/migration`
- seed data in `db/seed`

This keeps schema setup versioned and reproducible.

### 5) Secrets/config handling
Database host, port, username, password, and DB name are stored in **AWS Systems Manager Parameter Store**, which is a strong step toward cleaner secret/config management.

### 6) Monitoring and scaling
The Terraform setup includes:

- **CloudWatch dashboard**
- alarms for:
  - high EC2 CPU → scale out
  - low EC2 CPU → scale in
  - unhealthy ALB targets

This makes the infrastructure feel much closer to a real deployment than a simple demo stack.

---

## ☁️ AWS infrastructure provisioned with Terraform

The Terraform code is organized into reusable modules:

```text
terraform/
├── environments/
│   └── dev/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
└── modules/
    ├── alb/
    ├── asg/
    ├── cloudwatch/
    ├── ec2/
    ├── rds/
    ├── security-groups/
    └── vpc/
```

### Modules included

#### 🌐 `vpc`
Creates:

- VPC
- Internet Gateway
- public subnets
- private app subnets
- private DB subnets
- public route table
- NAT Gateway
- private route table for app subnets

#### 🔐 `security-groups`
Defines three main security groups:

- **ALB security group**
  - allows inbound HTTP/HTTPS from the internet
- **App security group**
  - allows app traffic from the ALB
  - temporarily allows SSH from configured CIDRs
- **DB security group**
  - allows PostgreSQL traffic only from the app security group

#### 🗄️ `rds`
Creates:

- PostgreSQL RDS instance
- DB subnet group
- random DB password
- SSM parameters for DB connection values

#### ⚖️ `alb`
Creates:

- Application Load Balancer
- target groups for each service
- HTTP listener with redirect to HTTPS
- HTTPS listener with path-based routing rules

#### 📈 `asg`
Creates:

- Launch template
- Auto Scaling Group
- IAM role and instance profile
- scaling policies
- SSM read access
- ECR pull permissions

#### 📊 `cloudwatch`
Creates:

- CloudWatch dashboard
- CPU alarms for scaling
- unhealthy host alarm for load balancer health

---

## 🧩 Services

```text
services/
├── user-service/
├── product-service/
└── order-service/
```

### 👤 User Service — FastAPI
**Path:** `services/user-service`  
**Language/Framework:** Python + FastAPI + SQLAlchemy  
**Container Port:** `8001`

#### Responsibilities
- register user
- login user
- fetch user profile
- health check

#### Main endpoints
- `GET /health`
- `POST /users/register`
- `POST /users/login`
- `GET /users/profile/{user_id}`

#### Notes
- Uses PostgreSQL via SQLAlchemy
- User model stores:
  - `id`
  - `name`
  - `email`
  - `password`

---

### 📦 Product Service — Go
**Path:** `services/product-service`  
**Language/Framework:** Go standard library  
**Container Port:** `8002`

#### Responsibilities
- list products
- create product
- fetch product by ID
- health check

#### Main endpoints
- `GET /health`
- `GET /products`
- `POST /products`
- `GET /products/{id}`

#### Notes
- Current implementation uses an **in-memory product slice**
- No external database is used for products yet
- Includes starter demo products:
  - Laptop
  - Headphones
  - Chair

This makes the service simple and fast for demo purposes, while leaving room for a future persistent catalog implementation.

---

### 🧾 Order Service — Spring Boot
**Path:** `services/order-service`  
**Language/Framework:** Java 17 + Spring Boot + Spring Data JPA  
**Container Port:** `8003`

#### Responsibilities
- create orders
- list all orders
- fetch order by ID
- fetch orders by user
- health check

#### Main endpoints
- `POST /orders`
- `GET /orders`
- `GET /orders/{id}`
- `GET /orders/user/{userId}`
- `GET /orders/health`

#### Notes
- Uses PostgreSQL through Spring Data JPA
- Persists `orders` table records with:
  - `id`
  - `userId`
  - `productId`
  - `quantity`
  - `status`
- New orders are created with status: `CREATED`

---

## 🗃️ Database schema and seed data

### Migration files
```text
db/
├── migration/
│   ├── V1__create_users_table.sql
│   └── V2__create_orders_table.sql
└── seed/
    └── R__seed_demo_data.sql
```

### Tables created

#### `users`
- `id`
- `name`
- `email`
- `password`

#### `orders`
- `id`
- `user_id`
- `product_id`
- `quantity`
- `status`

### Seed data
The repository includes demo seed data for:

- sample users
- sample orders

This is useful for local testing and quick demos.

---

## 🐳 Docker and local orchestration

The repository contains a `docker-compose.yaml` file that runs:

- `user-service`
- `product-service`
- `order-service`
- `flyway`
- `flyway-seed`

### Important detail
The compose file pulls service images from **Amazon ECR**, which means local Compose usage assumes those images are already built and pushed.

### Port mapping
- user-service → `8001:8001`
- product-service → `8010:8002`
- order-service → `8015:8003`

This port mapping aligns with the ALB target group strategy used in Terraform, where the load balancer forwards to host ports that map into the actual service container ports.

---

## 🚀 Request flow

A typical request flow looks like this:

### User flow
1. Client sends `POST /users/register`
2. ALB routes `/users/*` to **user-service**
3. user-service writes user data into PostgreSQL

### Product flow
1. Client sends `GET /products`
2. ALB routes `/products` to **product-service**
3. product-service returns in-memory catalog data

### Order flow
1. Client sends `POST /orders`
2. ALB routes `/orders` to **order-service**
3. order-service stores the order in PostgreSQL

---

## 📂 Repository structure

```text
.
├── db/
│   ├── migration/
│   └── seed/
├── docs/
│   └── images/
│       └── output.png
├── services/
│   ├── user-service/
│   ├── product-service/
│   └── order-service/
├── terraform/
│   ├── environments/
│   │   └── dev/
│   └── modules/
├── docker-compose.yaml
└── README.md
```

---

## 🛠️ Tech stack

### Application
- Python 3.11
- FastAPI
- SQLAlchemy
- Go 1.22
- Java 17
- Spring Boot 3.x
- Spring Data JPA

### Database
- PostgreSQL
- Flyway

### Infrastructure
- AWS VPC
- AWS ALB
- AWS EC2 Auto Scaling
- AWS RDS
- AWS IAM
- AWS Systems Manager Parameter Store
- AWS CloudWatch

### Delivery
- Docker
- Terraform

---

## ▶️ Run services locally

### Option 1 — run service by service

#### User service
```bash
cd services/user-service
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8001
```

#### Product service
```bash
cd services/product-service
go run main.go
```

#### Order service
```bash
cd services/order-service
mvn spring-boot:run
```

> You will need PostgreSQL and the required environment variables for the services that persist data.

---

### Option 2 — run with Docker Compose
```bash
docker compose up
```

> This assumes the referenced ECR images are available and environment variables such as `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, and `DB_PASSWORD` are provided.

---

## ☁️ Deploy infrastructure with Terraform

Terraform is currently structured with a `dev` environment.

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### Example dev settings currently defined
- region: `us-east-1`
- 2 public subnets
- 2 private app subnets
- 2 private DB subnets
- desired capacity: `2`
- min size: `2`
- max size: `3`

---

## 📊 Observability and scaling

This project goes beyond simple infrastructure provisioning by also including operational visibility.

### CloudWatch dashboard metrics
- EC2 CPU utilization
- ALB request count
- order-service healthy host count
- RDS CPU utilization
- RDS database connections

### Scaling behavior
- scale out when CPU is high
- scale in when CPU is low

This is a strong portfolio signal because it shows attention not only to deployment, but also to runtime operations.

---

## 🧪 Current API summary

### User Service
```http
GET    /health
POST   /users/register
POST   /users/login
GET    /users/profile/{user_id}
```

### Product Service
```http
GET    /health
GET    /products
POST   /products
GET    /products/{id}
```

### Order Service
```http
GET    /orders/health
POST   /orders
GET    /orders
GET    /orders/{id}
GET    /orders/user/{userId}
```

---

## 🖼️ Sample output

If you want to keep a visual in the README, you can use the image already in the repo:

```md
![ShopFlow Output](docs/images/output.png)
```

---

## 💼 Why this project stands out

This project is strong from a resume and portfolio perspective because it shows:

- **polyglot backend development**
- **microservices decomposition**
- **AWS infrastructure provisioning with Terraform**
- **private/public subnet design**
- **load balancing and auto scaling**
- **database migration management**
- **monitoring and alarms**
- **container packaging**

It demonstrates that the project is not only about writing APIs, but also about designing how those APIs run in a cloud environment.

---
## 🔮 Suggested next enhancements

- Add **JWT-based authentication and authorization**
- Persist product catalog in **PostgreSQL or DynamoDB**
- Add **repository query methods** for more efficient order filtering
- Add **service-to-service validation** before order creation
- Add **unit and integration tests**
- Use **ECS or EKS** for container orchestration
- Add **structured logging and distributed tracing**

---

## 🤝 Contributing

Contributions, suggestions, and improvements are welcome.

```bash
git checkout -b feature/your-feature
git commit -m "Add your feature"
git push origin feature/your-feature
```

---

## 👨‍💻 Author

**Vijayalakshmi**  
Built for cloud engineering practice, distributed systems learning, and DevOps portfolio development.

---

## 📄 License

Add your preferred license here, for example:

```text
MIT License
```

---

## ⭐ Support

If you found this project useful:

- Star the repository
- Fork it
- Share feedback
- Build on top of it