# SNS Integration Test

Tests SNS topic creation with email and SMS subscriptions.

## Prerequisites

**Email**: no prerequisites required. AWS sends a confirmation email after apply. Click the link to activate the subscription.

**SMS (Optional)**: AWS accounts are in SMS sandbox mode by default and require additional setup

>[!NOTE]
>SMS delivery may also require a configured origination identity (depending on region), see  [AWS SMS sandbox documentation](https://docs.aws.amazon.com/sns/latest/dg/sns-sms-sandbox.html) for details.

>[!TIP]
>Use email subscriptions to quickly verify the setup.

If you still want to test SMS: 

1. Navigate to SNS > Text messaging (SMS) > Sandbox destination phone numbers
2. Add your phone number in E.164 format (eg. +12222222222)
3. Enter the verification code AWS sends via text

## Running
```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform destroy
```
