# Initialize MongoDB Database - Quick Guide

## Why is helpdesk_db not visible?

MongoDB creates databases **lazily** - the database only appears after you insert the first document. This is normal MongoDB behavior!

## ✅ Solution: Initialize the Database

I've created a special endpoint to initialize the database without requiring authentication.

### Step 1: Restart the Application

The application needs to restart to load the new endpoint.

**Stop the current application** (Press Ctrl+C in the terminal where it's running)

Then restart:
```powershell
./mvnw spring-boot:run
```

### Step 2: Call the Init Endpoint

Once the application restarts, run this command:

```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/helpdesk/init" -Method Post
```

This will:
- Create the `helpdesk_db` database
- Create the `tickets` collection
- Insert a test ticket
- Return confirmation

### Step 3: Refresh MongoDB Compass

Click the **Refresh** button in MongoDB Compass, and you'll see:
- Database: `helpdesk_db`
- Collection: `tickets`
- 1 document (the test ticket)

## Alternative: Check Status

You can check if the database exists:

```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/helpdesk/status" -Method Get
```

## What Gets Created

The init endpoint creates a test ticket with:
- Ticket Number: TKT-2026-00001
- Subject: "Database Initialization Ticket"
- Status: OPEN
- Priority: MEDIUM
- One message in the conversation

## After Initialization

Once initialized, you can:
1. View the ticket in MongoDB Compass
2. Create more tickets through the API
3. Test the complete helpdesk system

## Quick Commands

```powershell
# Initialize database
Invoke-RestMethod -Uri "http://localhost:8080/api/helpdesk/init" -Method Post | ConvertTo-Json

# Check status
Invoke-RestMethod -Uri "http://localhost:8080/api/helpdesk/status" -Method Get | ConvertTo-Json
```

## 🎉 That's It!

After running the init endpoint, refresh MongoDB Compass and you'll see `helpdesk_db`!
