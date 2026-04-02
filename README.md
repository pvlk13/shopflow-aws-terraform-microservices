# 🛒 ShopFlow — AWS Microservices with Terraform

<p align="center">
  <img src="https://img.shields.io/badge/AWS-Cloud-orange?style=for-the-badge&logo=amazonaws" />
  <img src="https://img.shields.io/badge/Terraform-IaC-844FBA?style=for-the-badge&logo=terraform&logoColor=white" />
  <img src="https://img.shields.io/badge/Microservices-Distributed%20System-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Multi--AZ-High%20Availability-success?style=for-the-badge" />
</p>

<p align="center">
  <b>Production-grade, multi-AZ microservices architecture on AWS with Terraform</b>
</p>

---

## 🌟 Overview

**ShopFlow** is a **cloud-native microservices platform** built on AWS using **Terraform (Infrastructure as Code)**.

The system is designed with a **Multi-AZ architecture** to ensure **high availability, automatic failover, and fault tolerance**. It leverages **Auto Scaling Groups (ASG)** with CloudWatch-based policies to dynamically **scale out during high traffic and scale in during low demand**, optimizing both performance and cost.

This project demonstrates how to design and operate a **scalable, resilient distributed system** using modern DevOps and cloud engineering practices.

---

## 🚀 Key Highlights

- Multi-AZ deployment for high availability  
- Infrastructure fully provisioned using Terraform  
- Auto Scaling with CloudWatch alerts (scale in/out)  
- Failover handling via ALB health checks  
- Secure VPC architecture with public/private subnets  
- Polyglot microservices (Python, Go, Java)  
- Database versioning using Flyway  
- Dockerized services with ECR integration  

---

## 🏗️ Architecture

```text
                           Internet
                              │
                              ▼
                    ┌────────────────────┐
                    │  Application Load  │
                    │     Balancer       │
                    └─────────┬──────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
   User Service        Product Service      Order Service
   (FastAPI)              (Go)             (Spring Boot)
          │                   │                   │
          └──────────────┬────┴──────────────┬───┘
                         ▼                   ▼
                  PostgreSQL (RDS)     (Future extensions)
```

### 🔄 Request Flow

1. Client → ALB (public subnet via Internet Gateway)  
2. ALB → EC2 instances (private app subnets)  
3. Services → RDS (private DB subnets)  
4. Instances → Internet via NAT Gateway (for ECR pulls, updates)  

---

## 🌐 AWS Network & Infrastructure Architecture

The system follows a **three-tier VPC design**:

### 🌍 Public Layer
- Application Load Balancer (ALB)
- Internet Gateway (IGW)
- Public route table (`0.0.0.0/0 → IGW`)

### 🔒 Private Application Layer
- EC2 instances (Auto Scaling Group)
- NAT Gateway for outbound internet access
- Private route table (`0.0.0.0/0 → NAT`)

### 🗄️ Private Database Layer
- PostgreSQL (RDS)
- No direct internet access

### 🔐 Security Groups

- **ALB SG:** Allows HTTP/HTTPS from internet  
- **App SG:** Allows traffic only from ALB  
- **DB SG:** Allows PostgreSQL only from app layer  

👉 Ensures strict **layer isolation and secure communication**

---

## 🧩 Microservices

### 👤 User Service (FastAPI)
- Register, login, fetch user profile  
- Uses PostgreSQL  

### 📦 Product Service (Go)
- Product catalog APIs  
- Currently uses in-memory storage  

### 🧾 Order Service (Spring Boot)
- Create and fetch orders  
- Uses PostgreSQL  

---

## ☁️ Terraform Infrastructure

```text
terraform/
├── environments/dev/
└── modules/
    ├── vpc/
    ├── security-groups/
    ├── alb/
    ├── asg/
    ├── rds/
    └── cloudwatch/
```

### Modules include:
- VPC (multi-AZ networking)
- ALB (routing + listeners)
- ASG (auto scaling)
- RDS (PostgreSQL)
- CloudWatch (monitoring & alarms)
---
### 📈 Auto Scaling with Intelligent Alerts

This project implements **dynamic scaling using AWS Auto Scaling Groups (ASG)** driven by **CloudWatch alarms**:

- 🔺 **Scale Out Trigger**
  - When EC2 CPU utilization exceeds threshold
  - Automatically adds new instances
  - Ensures system handles increased traffic

- 🔻 **Scale In Trigger**
  - When CPU utilization drops below threshold
  - Reduces number of instances
  - Optimizes cost and resource usage

- 📊 Metrics Monitored:
  - EC2 CPU Utilization
  - ALB Target Health
  - Request Load

👉 This demonstrates **real-world elasticity and cost optimization strategies** used in production systems.

---

### 🧯 Failover & High Availability

The architecture is designed for **fault tolerance and resilience**:

- ✅ Services run in **multiple subnets across availability zones**
- ✅ **Application Load Balancer (ALB)** automatically routes traffic to healthy instances
- ✅ **Unhealthy instances are detected and removed**
- ✅ Auto Scaling replaces failed instances automatically

#### 🔁 Failover Scenario Demonstrated

- If an instance becomes unhealthy or crashes:
  - ALB stops routing traffic to it
  - CloudWatch detects unhealthy targets
  - ASG launches a replacement instance
  - Traffic continues without downtime

👉 This demonstrates **zero/minimal downtime architecture**, a key production requirement.

---

## 🗄️ Database Versioning (Flyway)

```text
db/
├── migration/
└── seed/
```

- Version-controlled schema migrations  
- Repeatable seed data  
- Consistent environments across deployments  

---

## 🐳 Containerization & ECR Workflow

### 🔹 Build (multi-architecture)

```bash
docker buildx build --platform linux/amd64 -t user-service ./services/user-service
```

### 🔹 Authenticate with ECR

```bash
aws ecr get-login-password --region <region> \
| docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
```

### 🔹 Tag & Push

```bash
docker tag user-service:latest <ecr-url>/user-service:latest
docker push <ecr-url>/user-service:latest
```

### 🔹 Deployment

- EC2 instances pull images from ECR  
- IAM roles provide secure access  
- Services run via Docker  

---

## 📊 Observability

- CloudWatch dashboards  
- CPU-based scaling alarms  
- ALB health monitoring  

---

## 🚀 Deployment

```bash
cd terraform/environments/dev
terraform init
terraform apply
```

---
## 🌍 Final Access URLs / Domain Endpoints

After deployment, the application is accessible through the **Application Load Balancer (ALB) DNS endpoint** or your **custom domain** if Route 53 / ACM is configured.

### 🔗 Main Entry Point
- 🌐 **Base URL:** `http://<alb-dns-name>` or `https://<your-domain>`

> Replace the placeholder above with the final ALB DNS name from Terraform output or your mapped custom domain.

---

### 🧭 Service Endpoints

#### 👤 User Service
- 📝 Register User: `http://<alb-dns-name>/users/register`
- 🔐 Login User: `http://<alb-dns-name>/users/login`
- 🙍 Get User Profile: `http://<alb-dns-name>/users/profile/{user_id}`
- ❤️ Health Check: `http://<alb-dns-name>/health`

#### 📦 Product Service
- 📃 Get All Products: `http://<alb-dns-name>/products`
- ➕ Add Product: `http://<alb-dns-name>/products`
- 🔎 Get Product by ID: `http://<alb-dns-name>/products/{id}`
- ❤️ Health Check: `http://<alb-dns-name>/health`

#### 🧾 Order Service
- ➕ Create Order: `http://<alb-dns-name>/orders`
- 📚 Get All Orders: `http://<alb-dns-name>/orders`
- 🔎 Get Order by ID: `http://<alb-dns-name>/orders/{id}`
- 👤 Get Orders by User: `http://<alb-dns-name>/orders/user/{userId}`
- ❤️ Health Check: `http://<alb-dns-name>/orders/health`

---

### ☁️ Where to Find the Final Domain

You can get the final ALB DNS name from:

```bash
terraform output
```

or specifically:

```bash
terraform output alb_dns_name
```

If a custom domain is configured, that domain can be mapped to the ALB using:

- 🌐 **Amazon Route 53**
- 🔒 **AWS Certificate Manager (ACM)** for HTTPS

---

### ✅ Example

```text
Base URL: http://shopflow-alb-123456789.us-east-1.elb.amazonaws.com
```

Example requests:

```text
http://shopflow-alb-123456789.us-east-1.elb.amazonaws.com/products
http://shopflow-alb-123456789.us-east-1.elb.amazonaws.com/users/register
http://shopflow-alb-123456789.us-east-1.elb.amazonaws.com/orders
```

---

### 💡 Notes

- 🚦 All traffic first reaches the **ALB**
- 🔀 The ALB routes requests to the correct microservice based on path rules
- 🛡️ Backend instances remain private and are not directly exposed to the internet
- 🌍 If a custom domain is added, it becomes the user-facing endpoint for the entire platform

---
## 💼 Key Engineering Achievements

- Designed **multi-AZ cloud architecture** with failover  
- Implemented **auto scaling with real-time alerts**  
- Built **secure VPC with layered isolation**  
- Integrated **Flyway for DB lifecycle management**  
- Developed **polyglot microservices system**  
- Enabled **containerized deployment via ECR**  

---

## 🔮 Future Improvements

- JWT authentication  
- Persistent product database  
- CI/CD pipeline (GitHub Actions)  
- Kubernetes (EKS) migration  
- Centralized logging (CloudWatch / ELK)
- Better UI

---

## 👨‍💻 Author

**Vijayalakshmi**  
Cloud | DevOps | Distributed Systems 🚀  

---

## ⭐ Support

If you like this project:
- Star ⭐ the repo  
- Fork 🍴 it  
- Share 📢 it  

---
