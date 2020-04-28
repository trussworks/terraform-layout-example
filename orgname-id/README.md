# orgname-id Account Setup

The `id` account in an AWS Organization is unique because it is intended
only for the maintenance of IAM users that will be used to access the
other accounts in the AWS Organization. No other resources should be
configured here. For more information, please refer to the Engineering
Playbook on [AWS Organization Patterns](https://github.com/trussworks/Engineering-Playbook/blob/master/infra/aws/aws-organizations.md#the-id-account).

## Setting Up aws-vault

For most users, you will be provided a set of temporary credentials by
an infrastructure engineer who will help you get your access sorted out
for this account.

TODO: We need to add instructions for how to set this setup with
`setup-new-aws-user` once we iron out issues with that.
