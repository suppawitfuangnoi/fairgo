# FAIRGO - Fair-Pricing Ride-Hailing Platform

A production-ready ride-hailing platform for Thailand where passengers set their fare range and drivers can choose jobs or submit counter-offers. Built with transparent pricing and fairness at its core.

## Architecture

```
fairgo/
├── apps/
│   ├── api/              # Next.js Backend API (Route Handlers)
│   ├── admin-web/        # Next.js Admin Dashboard
│   ├── customer-mobile/  # Flutter Customer App
│   └── driver-mobile/    # Flutter Driver App
├── packages/
│   ├── shared-types/     # Shared TypeScript types
│   ├── validation/       # Zod validation schemas
│   ├── config/           # Shared configuration
│   └── utils/            # Shared utilities
├── prisma/               # Database schema & migrations
└── docs/                 # Documentation
```

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Backend API | Next.js 14 (Route Handlers), TypeScript |
| Admin Dashboard | Next.js 14, Tailwind CSS, Recharts |
| Customer App | Flutter 3.x, Provider |
| Driver App | Flutter 3.x, Provider |
| Database | PostgreSQL + Prisma ORM |
| Monorepo | Turborepo + pnpm workspaces |
| Authentication | Phone OTP + JWT + Refresh Tokens |

## Prerequisites

- **Node.js** >= 18.x
- **pnpm** >= 8.x (`npm install -g pnpm`)
- **PostgreSQL** >= 14.x
- **Flutter** >= 3.x (for mobile apps)
- **Android Studio** or **Xcode** (for mobile development)

## Getting Started

### 1. Clone and Install Dependencies

```bash
git clone <repo-url> fairgo
cd fairgo
pnpm install
```

### 2. Set Up Environment Variables

Copy the example env files:

```bash
cp apps/api/.env.example apps/api/.env
cp apps/admin-web/.env.example apps/admin-web/.env
```

Update `apps/api/.env` with your PostgreSQL connection:

```env
DATABASE_URL="postgresql://user:password@localhost:5432/fairgo?schema=public"
JWT_SECRET="your-super-secret-jwt-key-change-in-production"
JWT_REFRESH_SECRET="your-refresh-secret-key-change-in-production"
PORT=4000
```

### 3. Set Up Database

```bash
# Generate Prisma client
cd prisma && npx prisma generate

# Run migrations
npx prisma migrate dev --name init

# Seed the database with sample data
npx prisma db seed
```

### 4. Run the API Server

```bash
cd apps/api
pnpm dev
# API runs on http://localhost:4000
```

### 5. Run the Admin Dashboard

```bash
cd apps/admin-web
pnpm dev
# Admin dashboard runs on http://localhost:3001
```

### 6. Run Flutter Apps

```bash
# Customer App
cd apps/customer-mobile
flutter pub get
flutter run

# Driver App
cd apps/driver-mobile
flutter pub get
flutter run
```

## Default Accounts (Seed Data)

### Admin Login
- **Email:** admin@fairgo.th
- **Password:** admin123

### Customer Accounts (OTP Login)
| Phone | Name | OTP Code |
|-------|------|----------|
| +66811111111 | Somchai Jaidee | 123456 |
| +66822222222 | Nattaya Srisuwan | 123456 |
| +66833333333 | Piyapong Wongchai | 123456 |

### Driver Accounts (OTP Login)
| Phone | Name | Vehicle | Status |
|-------|------|---------|--------|
| +66844444444 | Kittisak Saetang | Taxi | Verified |
| +66855555555 | Prasert Tongkham | Taxi | Verified |
| +66866666666 | Anuchit Bumrung | Motorcycle | Verified |
| +66877777777 | Wichai Kaewmanee | Tuk-Tuk | Pending |

## API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/request-otp` | Request OTP for phone login |
| POST | `/api/v1/auth/verify-otp` | Verify OTP and get tokens |
| POST | `/api/v1/auth/refresh` | Refresh access token |
| POST | `/api/v1/auth/logout` | Logout and invalidate tokens |
| POST | `/api/v1/auth/admin-login` | Admin email/password login |

### User Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/users/me` | Get current user profile |
| PATCH | `/api/v1/users/me` | Update user profile |

### Ride Requests
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/rides` | Create a ride request |
| GET | `/api/v1/rides` | List user's ride requests |
| GET | `/api/v1/rides/:id` | Get ride request details |
| DELETE | `/api/v1/rides/:id` | Cancel a ride request |
| POST | `/api/v1/rides/fare-estimate` | Get fare estimate |
| GET | `/api/v1/rides/nearby` | Get nearby rides (drivers) |

### Offers
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/offers` | Submit a driver offer |
| GET | `/api/v1/offers` | List driver's offers |
| POST | `/api/v1/offers/:id/respond` | Accept/reject an offer |

### Trips
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/trips` | List trips |
| GET | `/api/v1/trips/:id` | Get trip details |
| PATCH | `/api/v1/trips/:id/status` | Update trip status |

### Ratings
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/ratings` | Rate a completed trip |

### Admin
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/admin/dashboard` | Dashboard statistics |
| GET | `/api/v1/admin/users` | List all users |
| GET | `/api/v1/admin/users/:id` | Get user details |
| PATCH | `/api/v1/admin/users/:id` | Update user status |
| POST | `/api/v1/admin/drivers/:id/verify` | Verify/reject driver |
| GET | `/api/v1/admin/trips` | List all trips |
| GET | `/api/v1/admin/rides` | List all ride requests |

## Core Flows

### Customer Ride Flow
1. Customer sets pickup & drop-off location
2. Selects vehicle type (Taxi, Motorcycle, Tuk-Tuk)
3. System calculates fare estimate with min/max range
4. Customer sets fare offer within range
5. Request is broadcast to nearby drivers
6. Drivers can submit offers (counter-offers)
7. Customer accepts or rejects driver offers
8. Fare is locked on acceptance
9. Trip begins and is tracked in real-time
10. Trip completion, payment, and rating

### Driver Offer Flow
1. Driver goes online and sees nearby ride requests
2. Views ride details (pickup, drop-off, passenger offer)
3. Submits own fare offer with ETA and optional message
4. Waits for passenger acceptance
5. On acceptance, navigates to pickup
6. Completes trip lifecycle (en route → arrived → pickup → in progress → completed)

## Default Pricing Rules

| Vehicle Type | Base Fare (THB) | Per KM (THB) | Per Min (THB) |
|-------------|----------------|--------------|---------------|
| Taxi | 35 | 6.50 | 2.00 |
| Motorcycle | 25 | 5.00 | 1.50 |
| Tuk-Tuk | 40 | 8.00 | 2.50 |

## Trip Status State Machine

```
DRIVER_ASSIGNED → DRIVER_EN_ROUTE → DRIVER_ARRIVED → PICKUP_CONFIRMED → IN_PROGRESS → COMPLETED
       ↓                ↓                 ↓                  ↓               ↓
    CANCELLED        CANCELLED         CANCELLED          CANCELLED       CANCELLED
```

## Phase 1 Features (Current)

- Phone OTP authentication (mock service, dev code: 123456)
- JWT + refresh token authentication
- Role-based access control (CUSTOMER, DRIVER, ADMIN)
- Ride request creation with fare range
- Driver offer/counter-offer system
- Trip lifecycle management with state machine
- Fare estimation using Haversine formula
- Admin dashboard with KPIs and user management
- Driver verification workflow
- Rating system
- Comprehensive seed data

## Upcoming Phases

### Phase 2
- Wallet & payment integration
- Push notifications (FCM)
- Real-time updates (WebSocket/Pusher)
- Driver document verification
- Reports & analytics

### Phase 3
- Advanced analytics & pricing intelligence
- Promotions & coupon engine
- Support center
- Advanced admin controls

### Phase 4
- AI fare recommendations
- Fraud detection
- Fleet management
- Vehicle rental

## Development

### Project Scripts

```bash
# Root level
pnpm dev          # Run all apps in dev mode
pnpm build        # Build all apps
pnpm lint         # Lint all apps

# Individual apps
cd apps/api && pnpm dev        # API server
cd apps/admin-web && pnpm dev  # Admin dashboard
```

### Database Management

```bash
# In the prisma/ directory
npx prisma studio    # Open Prisma Studio GUI
npx prisma generate  # Regenerate Prisma Client
npx prisma migrate dev --name <name>  # Create migration
npx prisma db seed   # Run seed script
```

## License

Proprietary - All rights reserved.
