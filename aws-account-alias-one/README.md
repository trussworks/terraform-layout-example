# aws-account-alias-one Account Setup

When running `aws-vault`, you may be prompted to enter your keychain (laptop) password with the option to choose "Allow" or "Always Allow". Choose "Always Allow".

1. Log in to AWS for the appropriate account (`aws-account-alias-one`)
1. If you haven't already, setup your MFA device.
1. Generate access keys for your IAM user and configure the `aws-account-alias-one` profile using the following commands in your terminal:

   ```bash
   aws-vault add $AWS_PROFILE
   Enter Access Key ID: YOUR_ACCESS_KEY_ID
   Enter Secret Access Key: YOUR_SECRET_ACCESS_KEY
   ```

1. Then run the following commands:

   ```bash
   aws configure --profile $AWS_PROFILE set mfa_serial arn:aws:iam::111111111111:mfa/YOUR_IAM_USER_NAME
   aws configure --profile $AWS_PROFILE set region us-west-2
   aws configure --profile $AWS_PROFILE set output json
   ```

1. Test the aws-vault configuration works by issuing the following command `aws sts get-caller-identity`. You should get something back like:

    ```json
    {
        "UserId": "AIDAJ3D1XAR4KVEJDBVUG",
        "Account": "111111111111",
        "Arn": "arn:aws:iam::111111111111:user/youruser"
    }

1. Test you are able to access an AWS service by running `aws s3 ls`. If you get `An error occurred (AccessDenied) when calling the ListBuckets operation: Access Denied`, the vault session is not mfa-ed. You will have to remove your session by running `aws-vault remove -s <account_alias>`. Run `aws s3 ls` again and you should be prompted to enter an MFA token.
