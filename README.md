# JATOS Terraform

> **Warning**
> This `README.md` and instructions are still in a WIP state, but the code should work fine.

Terraform code for deploying a JATOS instance into the AWS cloud. Allocates the following resources into your AWS account:
| Type | # | Reason | Specs | Price |
| --- | --- | --- | --- | --- |
| EC2 Instance | 1 | The server running nginx and JATOS. |  | 
| EBS Volume | 3 | Persistence containers for ec2 data, study assets, and result uploads. | 10GB x2, 4GB x1 | 
| RDS Database | 1 | MySQL database for tabular study data. | 5GiB t3-micro | $0.017/GB/hour = $0.085/hour |

Supports using plain HTTP with an EIP domain, plain HTTP with a custom domain, or automatic configuration of SSL with a
custom domain using a LetsEncrypt certificate.

## Usage

To enable this script to deploy to your account, you first need to make a 
