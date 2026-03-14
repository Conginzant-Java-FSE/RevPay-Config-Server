# RevPay — Config Server (Centralized Configuration)

> Single source of truth for all microservice configurations. Every service fetches its properties from here on startup — no scattered config files across repositories.

---

## Overview

The Config Server provides **centralized, environment-aware configuration** for all RevPay microservices. Instead of each service maintaining its own database URLs, JWT secrets, and service credentials, they all fetch this data from the Config Server at startup. This makes environment management clean and consistent across dev, staging, and production.

| Property | Value |
|---|---|
| **Service Name** | `config-server` |
| **Port** | `8888` |
| **Framework** | Spring Boot 3.2.5 + Spring Cloud Config Server |
| **Java Version** | 17 |
| **Config URL** | `http://localhost:8888/{service-name}/default` |

---

## Architecture Role

```
┌────────────────────────────────────────┐
│           Config Server :8888          │
│                                        │
│  auth-service/default    → DB URL,     │
│  user-service/default    → JWT secret, │
│  wallet-service/default  → credentials │
│  ...                                   │
└────────────────────────────────────────┘
         ▲ fetch on startup
         │
  All 6 Microservices
```

Each service includes in its `application.properties`:
```properties
spring.config.import=optional:configserver:http://config-server:8888
```

---

## Getting Started

### Run with Docker
```bash
docker build -t revpay-config .
docker run -p 8888:8888 \
  -e EUREKA_HOST=localhost \
  -e EUREKA_USERNAME=admin \
  -e EUREKA_PASSWORD=admin \
  -e DB_USER=revpay_user \
  -e DB_PASS=revpay_pass \
  -e JWT_SECRET=your-secret-here \
  revpay-config
```

### Run Locally
```bash
./mvnw spring-boot:run
```

### Verify a service config is being served
```bash
curl http://localhost:8888/auth-service/default
curl http://localhost:8888/user-service/default
curl http://localhost:8888/api-gateway/default
```

---

## Configuration

| Environment Variable | Description |
|---|---|
| `EUREKA_HOST` | Hostname of the Eureka server |
| `EUREKA_USERNAME` | Eureka basic auth username |
| `EUREKA_PASSWORD` | Eureka basic auth password |
| `DB_USER` | MySQL username injected into service configs |
| `DB_PASS` | MySQL password injected into service configs |
| `JWT_SECRET` | JWT signing secret shared across all services |

### Config served to each service includes:
```properties
spring.datasource.username=${DB_USER}
spring.datasource.password=${DB_PASS}
jwt.secret=${JWT_SECRET}
eureka.client.service-url.defaultZone=http://${EUREKA_USERNAME}:${EUREKA_PASSWORD}@${EUREKA_HOST}:8761/eureka/
```

---

## Security

- JWT secret is managed centrally — only needs to be rotated in one place
- Database credentials are never hardcoded in individual service repos
- Config Server itself registers with Eureka, so services can discover it by name

---

## Health & Monitoring

| Endpoint | Description |
|---|---|
| `GET /actuator/health` | Config server health |
| `GET /{service-name}/default` | Config served to a specific service |
| `GET /{service-name}/{profile}` | Profile-specific config (e.g., `prod`) |

---

## Docker Compose Integration

```yaml
config-server:
  build: ./config-server
  ports:
    - "8888:8888"
  environment:
    EUREKA_HOST: eureka-server
    DB_USER: revpay_user
    DB_PASS: revpay_pass
    JWT_SECRET: your-jwt-secret
  depends_on:
    eureka-server:
      condition: service_healthy
  healthcheck:
    test: ["CMD", "wget", "-q", "--spider", "http://localhost:8888/actuator/health"]
    interval: 10s
    retries: 10
```

---

## Dependencies

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-config-server</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>
```

---

## Project Structure

```
config-server/
├── src/main/java/com/revpay/configserver/
│   └── ConfigServerApplication.java
├── src/main/resources/
│   ├── application.properties
│   └── configs/
│       ├── auth-service.properties
│       ├── user-service.properties
│       ├── wallet-service.properties
│       ├── transaction-service.properties
│       ├── invoice-loan-service.properties
│       ├── notification-service.properties
│       └── api-gateway.properties
├── Dockerfile
└── pom.xml
```

---

## Related Services

Must start **after** Eureka Server and **before** all microservices. See the main [RevPay Microservices](https://github.com/Conginzant-Java-FSE/RevPay-Frontend) repository for startup order and full architecture.
