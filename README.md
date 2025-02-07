# README

Simple rails application that receives and processes events from Stripe.

## System Requirements

- **Ruby**: 3.3.6  
- **Rails**: 8.x  
- **Database**:  
  - **Production**: PostgreSQL  
  - **Development**: SQLite


  README

Simple rails application that receives and processes events from Stripe.

System Requirements

- Ruby: 3.3.6
- Rails: 8.x
- Database:
  - Production: PostgreSQL
  - Development: SQLite

Setup Instructions

1️⃣ Install Dependencies
Run the setup script to install required gems and prepare the database:
bin/setup

This will:
- Run bundle install
- Prepare the database (rails db:prepare)
- Clear logs and temp files

If you prefer manual setup:
bundle install
rails db:prepare

2️⃣ Set Environment Variables
Create a .env file or export environment variables:
STRIPE_SECRET_KEY="your_stripe_secret_key"
STRIPE_WEBHOOK_SECRET="your_webhook_secret"

Ensure you replace "your_stripe_secret_key" and "your_webhook_secret" with your actual credentials.

3️⃣ Start Stripe CLI for Webhook Testing
Run Stripe CLI to forward webhooks to your local app:
stripe listen --forward-to localhost:3000/webhooks/stripe

This will return:
> Ready! You are using Stripe API Version [YYYY-MM-DD]. Your webhook signing secret is whsec_XXXX

Copy "whsec_XXXX" and update your .env file:
STRIPE_WEBHOOK_SECRET="whsec_XXXX"

4️⃣ Start the Application
Start Rails server and background job processing:
web: bundle exec rails server -p $PORT
worker: bin/jobs

Alternatively, run each process manually:
rails server
bin/jobs

5️⃣ Trigger Stripe Events for Testing
Once your app is running, manually trigger Stripe events:

Test Subscription Creation
stripe trigger customer.subscription.created

Test Subscription Deletion
stripe trigger customer.subscription.deleted

This will simulate Stripe sending webhooks and validate that your application correctly processes these events.


💡 Notes
- Webhooks are idempotent, meaning the app will ignore duplicate events.
- Failed events will retry automatically up to 3 times before being marked as failed.

📖 Additional Resources
- Stripe Webhook Documentation: https://docs.stripe.com/webhooks
- Stripe CLI: https://docs.stripe.com/cli
