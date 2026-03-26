# FAIRGO — Production Deployment Guide

## Architecture Overview

```
[Flutter Apps] ──────────────────────────────────────────┐
                                                          │
[Admin Web] ──── Vercel ──── REST ──── [API on Vercel]   │
                                  └── Socket.IO ── [Railway]
                                                          │
                                            [Aiven PostgreSQL] ◄─┘
```

| Service       | Platform | URL Example                          |
|---------------|----------|--------------------------------------|
| Admin Web     | Vercel   | `https://fairgo-admin.vercel.app`    |
| REST API      | Vercel   | `https://fairgo-api.vercel.app`      |
| Socket.IO     | Railway  | `https://fairgo-socket.up.railway.app` |
| Database      | Aiven    | Already running ✓                    |

---

## Step 1 — Generate Secure Secrets

Run these commands on your local machine to generate random secrets:

```bash
# Generate JWT_SECRET
openssl rand -base64 64

# Generate JWT_REFRESH_SECRET  
openssl rand -base64 64
```

Save both outputs — you'll need them in Steps 2 and 3.

---

## Step 2 — Deploy REST API to Vercel

### 2.1 — Import project

1. Go to [vercel.com](https://vercel.com) → **Add New Project**
2. Import from GitHub → `suppawitfuangnoi/fairgo`
3. Set **Root Directory** to `apps/api`
4. Framework: **Next.js** (auto-detected)

### 2.2 — Add Environment Variables

In Vercel project → **Settings → Environment Variables**, add:

| Variable              | Value                                                                 |
|-----------------------|-----------------------------------------------------------------------|
| `DATABASE_URL`        | `postgres://avnadmin:YOUR_AIVEN_PASSWORD@YOUR_HOST:24372/defaultdb?sslmode=require` |
| `JWT_SECRET`          | *(your generated secret from Step 1)*                                |
| `JWT_REFRESH_SECRET`  | *(your second generated secret from Step 1)*                        |
| `NODE_ENV`            | `production`                                                         |
| `ADMIN_WEB_URL`       | `https://fairgo-admin.vercel.app` *(update after Step 4)*           |

### 2.3 — Deploy

Click **Deploy**. After success, note the URL (e.g. `https://fairgo-api.vercel.app`).

---

## Step 3 — Deploy Socket.IO Server to Railway

> Railway is needed because Vercel is serverless — WebSocket connections can't persist.

### 3.1 — Create Railway project

1. Go to [railway.app](https://railway.app) → **New Project**
2. **Deploy from GitHub** → `suppawitfuangnoi/fairgo`
3. Set **Root Directory** to `apps/api`
4. Railway will detect `railway.json` automatically

### 3.2 — Add Environment Variables in Railway

| Variable              | Value                                                                 |
|-----------------------|-----------------------------------------------------------------------|
| `DATABASE_URL`        | *(same Aiven URL as above)*                                          |
| `JWT_SECRET`          | *(same secret as Vercel — must match)*                              |
| `JWT_REFRESH_SECRET`  | *(same refresh secret as Vercel — must match)*                      |
| `NODE_ENV`            | `production`                                                         |
| `PORT`                | `4000`                                                               |
| `ADMIN_WEB_URL`       | `https://fairgo-admin.vercel.app`                                   |

### 3.3 — Generate a public domain

In Railway → **Settings → Networking** → **Generate Domain**  
Note the URL (e.g. `https://fairgo-socket.up.railway.app`)

---

## Step 4 — Deploy Admin Web to Vercel

### 4.1 — Import project (second Vercel project)

1. Vercel → **Add New Project** → same GitHub repo
2. Set **Root Directory** to `apps/admin-web`
3. Framework: **Next.js**

### 4.2 — Add Environment Variables

| Variable                  | Value                                       |
|---------------------------|---------------------------------------------|
| `NEXT_PUBLIC_API_URL`     | `https://fairgo-api.vercel.app`             |
| `NEXT_PUBLIC_SOCKET_URL`  | `https://fairgo-socket.up.railway.app`      |

### 4.3 — Deploy

Click **Deploy**. Note URL (e.g. `https://fairgo-admin.vercel.app`).

### 4.4 — Update CORS

Go back to the Vercel API project → **Settings → Environment Variables**  
Update `ADMIN_WEB_URL` to the actual admin-web URL → **Redeploy**.

---

## Step 5 — Run Database Migration

After API is deployed, trigger Prisma DB push once via Railway terminal or locally:

```bash
# From repo root, run locally (uses the Aiven DB directly)
cd /path/to/fairgo
DATABASE_URL="postgres://avnadmin:AVNS_...@...aivencloud.com:24372/defaultdb?sslmode=require" \
  npx prisma db push --schema=prisma/schema.prisma --skip-generate
```

---

## Step 6 — Verify Deployment

Test each endpoint:

```bash
# Health check
curl https://fairgo-api.vercel.app/api/v1/health

# Admin login
curl -X POST https://fairgo-api.vercel.app/api/v1/auth/admin-login \
  -H "Content-Type: application/json" \
  -d '{"phone":"0800000000","password":"admin1234"}'
```

Then open `https://fairgo-admin.vercel.app` and log in.

---

## Flutter App Configuration

Update `apps/customer-mobile/lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://fairgo-api.vercel.app/api/v1';
  static const String socketUrl = 'https://fairgo-socket.up.railway.app';
}
```

Same for `apps/driver-mobile/lib/config/api_config.dart`.

---

## Environment Variable Checklist

- [ ] `DATABASE_URL` — Aiven PostgreSQL (same for API + Railway)
- [ ] `JWT_SECRET` — 64-char random string (same for API + Railway)
- [ ] `JWT_REFRESH_SECRET` — 64-char random string (same for API + Railway)
- [ ] `NEXT_PUBLIC_API_URL` — Vercel API URL (admin-web only)
- [ ] `NEXT_PUBLIC_SOCKET_URL` — Railway Socket.IO URL (admin-web only)
- [ ] `ADMIN_WEB_URL` — admin-web Vercel URL (API + Railway CORS)

---

## Costs (Estimated)

| Service         | Free Tier              | Paid            |
|-----------------|------------------------|-----------------|
| Vercel (API)    | 100GB bandwidth/mo     | $20/mo (Pro)    |
| Vercel (Admin)  | Included in same team  | —               |
| Railway         | $5 credit/mo free      | ~$5–10/mo       |
| Aiven (DB)      | Already provisioned    | ~$19/mo         |
| **Total**       | **Free to start**      | **~$44/mo**     |

