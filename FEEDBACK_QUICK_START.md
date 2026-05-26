# Feedback System - Quick Start Guide

## Backend Setup (Complete ✅)

All backend components have been implemented:
- Database migration (V7)
- Entity, Repository, Service, Controller
- CSV/Excel export
- JWT authentication
- Multi-tenant support

## Start the Application

```powershell
cd omoiservespare
mvnw spring-boot:run
```

## Test the Backend

```powershell
.\test-feedback-system.ps1
```

## Frontend Integration

### 1. Update Feedback.jsx (User Submission)

Key changes:
- Replace `localStorage.setItem("userFeedbacks", ...)` with API call
- Add `POST http://localhost:8080/api/feedback`
- Include JWT token in Authorization header
- Add rating input (1-5 stars)

### 2. Update App_Feedback.jsx (Admin Dashboard)

Key changes:
- Replace hardcoded `feedbackData` with API call
- Add `GET http://localhost:8080/api/feedback`
- Implement real-time polling (every 30 seconds)
- Connect export buttons to `/export/csv` and `/export/excel`
- Add "Mark as Reviewed" functionality

## API Endpoints

- `POST /api/feedback` - Submit feedback
- `GET /api/feedback?page=0&size=20&status=NEW` - Get feedback
- `PUT /api/feedback/{id}/review` - Mark reviewed
- `GET /api/feedback/export/csv` - Download CSV
- `GET /api/feedback/export/excel` - Download Excel

## Security

- All endpoints require JWT token
- Only PROFESSIONAL users can access admin features
- Multi-tenant: Each company sees only their feedback

## Complete Documentation

See `FEEDBACK_SYSTEM_IMPLEMENTATION.md` for:
- Detailed API documentation
- Frontend code examples
- Troubleshooting guide
- Production considerations
