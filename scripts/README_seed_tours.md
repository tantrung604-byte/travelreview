# Seed tours to Firestore

This script upserts the curated `seededTours` dataset into the `tours` collection.

## 1) Install dependencies

```powershell
Set-Location "C:\Users\tantr\StudioProjects\travelreview_app\scripts"
npm install
```

## 2) Set environment

- `FIREBASE_PROJECT_ID`: your Firebase project id
- `GOOGLE_APPLICATION_CREDENTIALS`: absolute path to a service-account JSON key file

PowerShell example:

```powershell
$env:FIREBASE_PROJECT_ID = "your-project-id"
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\keys\service-account.json"
```

## 3) Dry run

```powershell
npm run seed:tours:dry
```

## 4) Apply

```powershell
npm run seed:tours
```

The script merges fields into existing documents (`SetOptions(merge: true)` behavior).

