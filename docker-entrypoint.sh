#!/bin/sh

TMP_ASSUME_ROLE_FILE=/tmp/assume-role.json

if [ -z "${ACCOUNT}" ]; then echo "ACCOUNT not set !"; exit 1; fi
if [ -z "${REPORTING_BUCKET}" ]; then echo "REPORTING_BUCKET not set !"; exit 1; fi
if [ -z "${SCOUTSUITE_SCAN_ROLE}" ]; then echo "SCOUTSUITE_SCAN_ROLE not set !"; exit 1; fi
if [ -z "${SCOUTSUITE_ROLE_EXTERNALID}" ]; then echo "SCOUTSUITE_ROLE_EXTERNALID not set !"; exit 1; fi

echo "Collecting credentials for ${ACCOUNT} with role ${SCOUTSUITE_SCAN_ROLE}"
aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT}:role/${SCOUTSUITE_SCAN_ROLE} \
										--external-id ${SCOUTSUITE_ROLE_EXTERNALID} \
                    --role-session-name ${SCOUTSUITE_SCAN_ROLE} \
                    >${TMP_ASSUME_ROLE_FILE}

export AWS_SECRET_ACCESS_KEY=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SecretAccessKey`
if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then echo "AWS_SECRET_ACCESS_KEY not set !"; exit 1; fi

export AWS_ACCESS_KEY_ID=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.AccessKeyId`
if [ -z "${AWS_ACCESS_KEY_ID}" ]; then echo "AWS_ACCESS_KEY_ID not set !"; exit 1; fi

export AWS_SESSION_TOKEN=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SessionToken`
if [ -z "${AWS_SESSION_TOKEN}" ]; then echo "AWS_SESSION_TOKEN not set !"; exit 1; fi

echo "Generating HTML Account audit ..."
scout aws

echo "Saving the report files in s3://${REPORTING_BUCKET}/${ACCOUNT}"
report_file_prefix=${ACCOUNT}-scoutsuite
mv scoutsuite-report ${report_file_prefix}-report
zip -qr ${report_file_prefix}-report.zip ${report_file_prefix}-report
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
unset AWS_SESSION_TOKEN
aws s3 cp ${report_file_prefix}-report.zip \
          s3://${REPORTING_BUCKET}/${ACCOUNT}/
