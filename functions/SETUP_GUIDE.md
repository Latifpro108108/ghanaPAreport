# Firebase Cloud Functions Setup Guide

## Step 1: Install Firebase CLI

Open PowerShell/CMD and run:
```bash
npm install -g firebase-tools
```

## Step 2: Login to Firebase

```bash
firebase login
```
- This opens browser - login with your Google account

## Step 3: Initialize Functions (if not already done)

```bash
cd "C:\Users\dabon\OneDrive\Desktop\PowerAlert GH Mobile App\poweralert_gh_flutter"
firebase init functions
```

Select:
- **Use existing project** → Select `ghanapower-95aac`
- **JavaScript** (when asked for language)
- **Yes** to install dependencies now

## Step 4: Deploy Functions

The function code is already in `functions/index.js`. Just deploy:

```bash
firebase deploy --only functions
```

## Step 5: Update Firebase Console Settings

### Enable Required APIs (if not enabled):
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project `ghanapower-95aac`
3. Go to **Project Settings** → **Cloud Messaging**
4. Verify FCM is enabled

### Update Realtime Database Rules:
Go to **Realtime Database** → **Rules** and paste:

```json
{
  "rules": {
    "votes": {
      ".read": true,
      ".write": true
    },
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    }
  }
}
```

Click **Publish**

### Enable Firestore (for scheduled notifications):
1. Go to **Firestore Database**
2. Click **Create Database**
3. Select **Start in production mode**
4. Choose location (europe-west for Ghana is good)

## Step 6: Verify Functions

After deployment, check the functions are working:

```bash
firebase functions:log
```

You should see:
- `sendCrowdAlert` function deployed
- `schedulePowerCheck` function deployed

## Step 7: Get Function URLs

After deployment, Firebase will show you URLs like:
```
https://us-central1-ghanapower-95aac.cloudfunctions.net/sendCrowdAlert
```

You'll need these for the Flutter app.

## Troubleshooting

### If deployment fails:
1. Make sure you have the Blaze plan (free tier works but needs billing info)
2. Check that `package.json` has correct dependencies
3. Run `firebase functions:log` to see errors

### If functions don't work:
1. Check Firebase Console → Functions tab for errors
2. Verify FCM API is enabled in Google Cloud Console
3. Check if billing account is linked (required for outbound requests)

## Next: Update Flutter App

After deploying, update the Flutter app to call these functions instead of trying to send FCM directly.

See `CLOUD_FUNCTION_INTEGRATION.md` for Flutter code updates.
