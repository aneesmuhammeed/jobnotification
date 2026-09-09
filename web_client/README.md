# JobNoti Web Client

This is the independent web frontend for the JobNoti platform, built with **Vite, React, and Vanilla CSS**. It connects to the exact same Supabase database and Firebase project as the Flutter mobile app, allowing you to deploy the web version freely without touching the mobile app code.

## 🚀 Getting Started

### Prerequisites
- Node.js installed

### Installation
1. Clone the repo and navigate to this directory (`web_client`).
2. Run `npm install` to install all dependencies.
3. Run `npm run dev` to start the local development server.

---

## ✅ What Has Been Implemented

- **Modern Tech Stack & UI:** Built with Vite and React. The UI utilizes a modern glassmorphism design approach with smooth transitions and typography (`index.css`).
- **Supabase Authentication:** Fully working login and signup flow. New signups automatically create a corresponding record in the `profiles` table.
- **Job Board (`/`):** Public/Authenticated users can view a list of all active jobs, sorted by the latest. Users can apply to jobs directly.
- **Admin Dashboard (`/admin`):** A protected route available only to users with the `admin` role. Admins can:
  - Create new job postings.
  - View all existing jobs.
  - Toggle job visibility (`is_active`).
  - Delete jobs.
- **My Applications (`/applications`):** Users can track jobs they've applied for.
- **Telegram File Uploads:** Replicated the Flutter app's logic to upload resumes. When a user uploads a resume, it is sent to the configured Telegram bot, and the `document_path` (file ID) is saved to Supabase.
- **Progressive Web App (PWA):** Added `manifest.json` and a Firebase Service Worker (`firebase-messaging-sw.js`).
- **Web Push Notifications:** Added a Bell icon in the navigation bar to request Push Notification permissions from the browser. 
  - *Note on iOS:* For iPhones to receive push notifications, the user MUST tap **"Add to Home Screen"** in Safari. Once the web app is running from the home screen, the notification prompt will work (iOS 16.4+).

---

## 🚧 What Remains to be Implemented (Future Enhancements)

While the MVP is complete, here are some features that can be added in the future:

1. **Job Editing:** Currently, admins can create and delete jobs, but editing existing job details is not yet implemented.
2. **Resume Viewing:** The app successfully uploads resumes to Telegram and stores the File ID, but there is no UI yet to download or view the previously uploaded resume directly from the web app.
3. **Pagination:** The Job Board and Admin Dashboard currently load all jobs at once. Pagination or infinite scrolling should be added as the database grows.
4. **Profile Settings:** A page for users to update their Full Name and toggle notification preferences (`notification_enabled`, `daily_reminder_enabled`).
5. **VAPID Key Configuration:** For robust Web Push notifications across all browsers, a VAPID key from the Firebase Console should be explicitly added to the `getToken` call in `src/lib/firebase.js`.
6. **Backend Edge Functions Compatibility:** Ensure that the Supabase edge functions (which send FCM notifications) correctly handle the web/iOS push token format if any specific payload differences arise compared to Android.

---

## 🌍 Deployment

You can deploy this application for free on services like **Vercel, Netlify, or Firebase Hosting**.

1. Connect your repository to the hosting service.
2. Set the root directory to `web_client` (if applicable).
3. Build command: `npm run build`
4. Publish directory: `dist`
