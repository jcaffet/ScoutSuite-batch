#!/bin/sh

TMP_ASSUME_ROLE_FILE=/tmp/assume-role.json

echo "Collecting credentials for ${ACCOUNT} for role ${SCOUTSUITE_SCAN_ROLE}"
aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT}:role/${SCOUTSUITE_SCAN_ROLE} \
                    --role-session-name ${SCOUTSUITE_SCAN_ROLE} \
                    >${TMP_ASSUME_ROLE_FILE}

export AWS_SECRET_ACCESS_KEY=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SecretAccessKey`
export AWS_ACCESS_KEY_ID=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.AccessKeyId`
export AWS_SESSION_TOKEN=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SessionToken`

if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then echo "AWS_SECRET_ACCESS_KEY not set !"; exit 1; fi
if [ -z "${AWS_ACCESS_KEY_ID}" ]; then echo "AWS_ACCESS_KEY_ID not set !"; exit 1; fi
if [ -z "${AWS_SESSION_TOKEN}" ]; then echo "AWS_SESSION_TOKEN not set !"; exit 1; fi

now=`date +'%Y-%m-%d'`
report_file_prefix=${ACCOUNT}-${now}

echo "Generating HTML Account audit ..."
python Scout.py aws

echo "Saving the report files in s3://${SCOUTSUITE_BUCKET}/reports/${ACCOUNT}"
report_file_prefix=${ACCOUNT}
mv scoutsuite-report ${report_file_prefix}-scoutsuite-report
zip -qr ${report_file_prefix}-scoutsuite-report.zip ${report_file_prefix}-scoutsuite-report
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
unset AWS_SESSION_TOKEN
aws s3 cp ${report_file_prefix}-scoutsuite-report.zip s3://${SCOUTSUITE_BUCKET}/reports/${ACCOUNT}/ 

