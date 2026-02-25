# ShopOps Backend

ShopOps is a lightweight mobile-first business management system designed for African SMEs. This repository contains the backend API built with Go and Clean Architecture.

## Architecture

The project follows Clean Architecture principles:

- **Domain**: Core business entities and logic.
- **Usecases**: Application-specific business rules.
- **Repositories**: Data access abstraction.
- **Infrastructure**: External services (DB, Auth, etc.).
- **Delivery**: HTTP handlers and routing.

## Prerequisites

- [Go](https://go.dev/) 1.21+
- [MongoDB](https://www.mongodb.com/)
- [Git](https://git-scm.com/)

## Setup

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd shop-ops/back-end
    ```

2.  **Environment Variables:**
    Copy `.env.example` to `.env` and update the values.
    ```bash
    cp .env.example .env
    ```

3.  **Install Dependencies:**
    ```bash
    go mod download
    ```

4.  **Run the Application:**
    ```bash
    go run Delivery/main.go
    ```

## API Documentation

(To be added)
