#!/bin/bash

cd /home/app
FILE_NAME=accessLogs.`date +"%Y-%m"`-*
LOCAL_FILE_NAME=`date +"%Y-%m-%d"`.tar.gz
mc alias set routerminio https://minio-router-datastore-prod-api.apps.silver.devops.gov.bc.ca ${MINIO_KEY} ${MINIO_SECRET}
FILE_PATH=`mc find routerminio/test-access-logs --name ${FILE_NAME}`


mc cp ${FILE_PATH} /tmp/${LOCAL_FILE_NAME}
tar -xvf /tmp/${LOCAL_FILE_NAME}
mv -r tmp/* /apps/logs/router/.
rm -rf tmp

