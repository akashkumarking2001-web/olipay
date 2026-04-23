class LegalContent {
  static const String privacyPolicy = '''
Privacy Policy for Olipay

Last Updated: [DATE_PLACEHOLDER]

1. Introduction
Welcome to Olipay. This Privacy Policy explains how we collect, use, and protect your information when you use our payment announcement application. Olipay is designed to read incoming payment notifications (from apps like Google Pay, PhonePe, Paytm, etc.) and announce them exclusively on your device.

2. Information We Access
- Notification Access: To function as a soundbox, our app requires the BIND_NOTIFICATION_LISTENER_SERVICE permission. This allows the app to read incoming notifications to extract payment amounts and sender names.
- Local Storage: We store your recent transaction history locally on your device for your reference.

3. How We Use Information
The notification data accessed is used strictly to identify transactional content and announce it via Text-to-Speech. WE DO NOT transmit, sell, or share your financial data, notification history, or personal information to third-party servers. All payment tracking occurs transparently on your device or via secure, encrypted channels to your registered business backend.

4. Battery and Background Usage
To ensure you never miss a payment, the app requests exemption from battery optimizations. This is used solely to keep the listener active.

5. Data Retention and Security
Your local transaction history is automatically purged after 30 days. Your business registration details (provided during subscription) are securely stored on our servers to manage authentication.

6. Changes to this Policy
We may update this policy periodically. We will notify you of any major changes via app updates.

Contact Us:
[CONTACT_EMAIL_PLACEHOLDER]
[COMPANY_ADDRESS_PLACEHOLDER]
''';

  static const String terms = '''
Terms and Conditions for Olipay

Last Updated: [DATE_PLACEHOLDER]

1. Acceptance of Terms
By downloading or using the Olipay app, you agree to these terms. If you do not agree with any of these terms, you are prohibited from using this app.

2. Service Description
Olipay provides a software-based Soundbox solution that reads and announces payment notifications. It is not affiliated directly with any bank or UPI application. The accuracy of announcements depends on the notification format provided by the third-party payment apps and the device's Text-to-Speech engine.

3. Subscription and Billing
Olipay operates on a subscription model (Monthly/Yearly). By subscribing, you agree to pay the standard package rates. Access to the notification listener feature will be suspended upon failure of payment.

4. Responsibilities
As a merchant, you are responsible for ensuring that you have an active network connection to receive the third-party notifications. Olipay is not liable for missed announcements due to device battery death, missing network, or third-party app delays.

5. Termination
We reserve the right to terminate or suspend your account immediately, without prior notice or liability, for any breach of these Terms.

Contact Us:
[CONTACT_EMAIL_PLACEHOLDER]
''';

  static const String refundPolicy = '''
Refund & Cancellation Policy

Last Updated: [DATE_PLACEHOLDER]

1. Subscription Cancellations
You can cancel your Olipay subscription at any time. Cancellations will take effect at the end of the current billing cycle. You will continue to have access to the app's features until your subscription period expires.

2. Refund Policy
- Trial Plans: If a trial period applies, it is entirely free and non-refundable.
- Monthly Subscriptions: Given the digital nature of this service, monthly subscriptions are strictly non-refundable once the billing cycle has started. 
- Yearly Subscriptions: If you are dissatisfied within the first 7 days of an annual subscription, you may contact our support team to request a pro-rated refund. Requests beyond 7 days will not be entertained.

3. Exceptional Circumstances
If the application absolutely fails to function on your specific device configuration despite technical support, a partial or full refund may be issued at management's discretion.

4. Contact
To request cancellations or report issues, please contact:
[CONTACT_EMAIL_PLACEHOLDER]
''';
}
