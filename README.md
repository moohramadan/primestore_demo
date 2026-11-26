# PrimeStore Demo

A full-stack e-commerce demo built with **Flutter** and **Go**. It includes customer shopping flows and seller tools, backed by PostgreSQL and AWS S3.

## Project Overview

The repository contains two applications:

- `primestore_demo_app/` — a cross-platform Flutter client for Android, iOS, web, Windows, macOS, and Linux.
- `primestore_demo_backend/` — a Gin REST API with PostgreSQL storage and AWS S3 image uploads.

## Features

### Shopping

- Email/password and Google authentication
- Email verification and OTP flows
- Refresh-token session management
- Product categories, brands, featured products, and product details
- Search-ready product catalog structure
- Shopping cart and wishlist
- Checkout and order creation
- Saved addresses
- Light and dark themes

### Seller

- Seller profile management
- Product creation and editing
- Product image upload through presigned S3 URLs
- Seller order management screens

### Backend

- JWT authentication and authorization
- Seller-only protected routes
- Login, OTP, address, and checkout rate limiting
- SQLC-generated database access
- PostgreSQL migrations
- AWS S3 image storage
- SMTP email support

## Tech Stack

| Layer | Technologies |
| --- | --- |
| Mobile & desktop client | Flutter, Dart, GetX, HTTP |
| Backend | Go, Gin |
| Database | PostgreSQL, SQLC |
| Cloud services | AWS S3, SMTP, Google Sign-In |
| Authentication | JWT, refresh tokens, secure local storage |

## Repository Structure

```text
.
├── primestore_demo_app/
│   ├── lib/
│   │   ├── features/          # Customer authentication and shopping features
│   │   ├── seller_features/   # Seller profiles, products, and orders
│   │   ├── data/              # API repositories
│   │   ├── common/            # Shared widgets
│   │   └── utils/             # Constants and theme configuration
│   └── test/                  # Flutter widget and model tests
└── primestore_demo_backend/
    ├── api/                   # Gin handlers and middleware
    ├── db/
    │   ├── migration/         # PostgreSQL migrations
    │   └── sqlc/              # SQLC-generated database code
    ├── internal/orders/       # Cart, checkout, order, and inventory domain
    └── util/                  # Configuration and integrations
```

## Prerequisites

- Flutter SDK 3.x
- Dart SDK 3.x
- Go 1.27 or newer
- PostgreSQL 16 or Docker
- [golang-migrate](https://github.com/golang-migrate/migrate) for database migrations
- [SQLC](https://sqlc.dev/) when regenerating database code
- AWS S3 bucket and credentials
- SMTP provider credentials
- Google OAuth client ID

## Quick Start

### 1. Start PostgreSQL

From the repository root:

```bash
cd primestore_demo_backend
make postgres
make createdb
```

The Makefile uses PostgreSQL on port `5433` with the database name `primestore`.

### 2. Configure the backend

Create `primestore_demo_backend/.env` with the required values:

```dotenv
DB_DRIVER=postgres
DB_SOURCE=postgres://postgres:secret@localhost:5433/primestore?sslmode=disable
HTTP_SERVER_ADDRESS=:8080
TOKEN_SECRET=replace-with-a-long-random-secret-at-least-32-characters
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USERNAME=your-smtp-user
SMTP_PASSWORD=your-smtp-password
SMTP_FROM=noreply@example.com
GOOGLE_CLIENT_ID=your-google-oauth-client-id
S3_BUCKET=your-s3-bucket
S3_PUBLIC_BASE_URL=https://your-s3-public-base-url
AWS_REGION=your-aws-region
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
```

Keep `.env` private. It is excluded by Git.

### 3. Run migrations

```bash
cd primestore_demo_backend
make migrateup
```

### 4. Start the API

```bash
cd primestore_demo_backend
make server
```

The API listens at `http://localhost:8080` by default.

### 5. Run the Flutter app

```bash
cd primestore_demo_app
flutter pub get
flutter run
```

For Android emulators, the client currently uses `http://10.0.2.2:8080`. Update `lib/utils/constants/api_constants.dart` if your API address differs, including for a physical device or hosted backend.

## API Groups

| Area | Example endpoints |
| --- | --- |
| Users | `POST /users`, `POST /users/login`, `POST /users/refresh`, `GET /users/me` |
| Email verification | `POST /users/verify-email/send`, `POST /users/verify-email/confirm` |
| Catalog | `GET /categories`, `GET /brands`, `GET /products/featured` |
| Cart | `GET /cart`, `POST /cart/items`, `PUT /cart/items/:id`, `DELETE /cart/items/:id` |
| Checkout | `POST /checkout` |
| Wishlist | `GET /wishlist`, `POST /wishlist`, `DELETE /wishlist/:product_id` |
| Addresses | `GET /addresses`, `POST /addresses`, `PUT /addresses/:id/default` |
| Seller | `GET /seller/profile`, `POST /seller/profile`, `POST /seller/products`, `PUT /seller/products/:id` |

Most account, cart, checkout, address, wishlist, and seller operations require authentication.

## Development Commands

### Backend

```bash
cd primestore_demo_backend
go test ./...
go vet ./...
go run main.go
make migrateup
make sqlc
```

### Flutter

```bash
cd primestore_demo_app
flutter pub get
flutter test
flutter analyze
flutter run
```

## Validation Status

Verified in this repository:

- Go tests: passing
- Go vet: passing
- Flutter tests: passing
- Flutter analysis: 266 findings, with no analyzer errors and mostly lint/style suggestions; review findings before release

## Notes

- Do not commit real credentials or `.env` files.
- Replace emulator/host-specific API addresses before packaging a release.
- Configure Firebase and Google Sign-In files/services for the platforms you support.
- AWS and SMTP integrations require valid external service configuration.
