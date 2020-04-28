# orgname-infra Account Setup

The `infra` account in an AWS Organization should be reserved for infra
resources used throughout the organization. The most common examples of
such infrastructure are the root DNS zone and an Atlantis deployment, but
there may be others more specific to your project. For more information,
please refer to the Engineering Playbook on [AWS Organization
Patterns](https://github.com/trussworks/Engineering-Playbook/blob/master/infra/aws/aws-organizations.md#the-id-account).

## Setting Up aws-vault

For most users, you will be provided a set of temporary credentials by
an infrastructure engineer who will help you get your access sorted out
for this account.

TODO: We need to add instructions for how to set this setup with
`setup-new-aws-user` once we iron out issues with that.
