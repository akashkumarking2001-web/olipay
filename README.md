# Olipay - Smart Payment Soundbox 🔊💰

Olipay is a high-performance Flutter application designed for merchants and shop owners. It acts as a digital "Soundbox" that listens for incoming payment notifications from major UPI apps and provides instant voice announcements in the merchant's preferred language.

## ✨ Key Features
- **Instant Voice Alerts**: Real-time announcements for successful payments.
- **Multi-App Support**: GPay, PhonePe, Paytm, Amazon Pay, WhatsApp, and 30+ other banking apps.
- **Local Language Support**: High-quality voice output in **Tamil (தமிழ்)**, Hindi, Telugu, and English.
- **Merchant Dashboard**: View daily transaction totals and payment history at a glance.
- **Admin Portal**: Centralized dashboard to manage subscribers and monitor active plans.
- **Modern UI**: Dark-themed, glassmorphic design for a premium interactive experience.

## 📱 How to Use (Merchant)
1. **Register**: Sign up with your shop name and choosing a subscription plan.
2. **Grant Permissions**: Enable "Notification Access" so Olipay can read incoming UPI alerts.
3. **Stay Active**: Toggling "Listening" on the home screen ensures your voice alerts are ready.
4. **Volume Control**: Adjust voice speed and volume in Settings.

## 🛠 Tech Stack
- **Flutter**: Cross-platform mobile development.
- **Firebase**: Authentication (phone-based email dummy) and Firestore for merchant data.
- **Cashfree PG**: Integration for subscription payments.
- **TTS (Text-to-Speech)**: Native speech engines for regional accuracy.

## 🏛 Admin Access
To access the Admin Dashboard for demo purposes:
1. Go to the **Login Screen**.
2. Type `admin` in the phone field.
3. You will be instantly redirected to the Subscribers Overview.

## 🚀 Deployment (Building APK)
To build a production-ready APK, run:
```bash
flutter build apk --release --split-per-abi
```
The resulting files will be in `build/app/outputs/flutter-apk/`.

---
**Developed with ❤️ for Indian Merchants.**
