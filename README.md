# ScoutSuite Batch

ScoutSuite Batch is an AWS account security scanner specialist based on [ScoutSuite](https://github.com/nccgroup/ScoutSuite) and embedded into AWS Batch jobs.

## Description

People need to audit their account to seek security issues or validate compliance. ScoutSuite Batch is here to do the job for you at a defined frequency.
It ensures cost containment and security hardening.
Reports are stored into an S3 Bucket.

## Technicals details

ScoutSuite batch simply runs [ScoutSuite](https://github.com/nccgroup/ScoutSuite) into AWS Batch jobs.
It simply industrializes the deletion process thanks to the following AWS resources :
- CloudWatch Rule to trigger the deletion execution
- Batch to ensure a pay per use strategy
- ECR to host the Docker image that embeds ScoutSuite
- Lambda to gather the accounts to perform and submit the jobs
- S3 to store generated reports
- CloudWatch Logs to log the global activity

![ScoutSuite Batch Diagram](images/scoutsuitebatch-diagram.png)

## Prerequisites

ScoutSuite needs :
- a VPC
- a private subnet with Internet connection (through a NAT Gateway)

## Installation

1. deploy the [cf-scoutsuite-common.yml](cf-scoutsuite-common.yml) CloudFormation stack in the central account
2. Git clone scoutsuite scans repository into this directory
3. Build, tag and push the Docker image. Follow the information provided in the ECR repository page.
4. deploy the [cf-scoutsuite-org-account.yml](cf-scoutsuite-org-account.yml) in the account using AWS Organizations
5. deploy the [cf-scoutsuite-spoke-account.yml](cf-scoutsuite-spoke-account.yml) in all the accounts using to scan. To make it easy, use StackSets Stacks from the Organizations level.
6. deploy the [cf-scoutsuite-batch.yml](cf-scoutsuite-batch.yml) CloudFormation stack in the central account

Do not forget two different strong ExternalIds like UUID (one for Organizations role, one for scan role)

## How to use it

When installed, no action is needed.

## Extension

It is possible to export ScoutSuite's results into csv files and run Athena on into for large investigations.
