echo "evoked"
exit 0
# step constants
NAMESPACE=1475a9-test
BACKUP_DIR=accessLogs.`date +"%Y-%m-%d"`

# login open shift
oc login --token=$OC_TOKEN --server=https://api.silver.devops.gov.bc.ca:6443

# copy access logs to local directory
for pod in `oc get pods -l app=ols-router-web -n ${NAMESPACE} | grep -v ^NAME| awk '{print $1}'`; do
    # print out pod name
    echo $pod;

    # create directory for this pod
    mkdir -p /tmp/${BACKUP_DIR}/$pod || : ;

    # copy access log files
    for file in `oc -n ${NAMESPACE} exec $pod -- bash -c 'cd logs && ls localhost_*' `; do
        # print command
        echo oc cp $pod:/usr/local/tomcat/logs/$file /tmp/${BACKUP_DIR}/$pod;
        # execute command
        oc cp $pod:/usr/local/tomcat/logs/$file /tmp/${BACKUP_DIR}/$pod/$file -n ${NAMESPACE};
    done
done

# package the download logs
tar -czvf /tmp/${BACKUP_DIR}.tar.gz /tmp/${BACKUP_DIR}

# copy the log file to minio
python3 upload_logs.py ${BACKUP_DIR}.tar.gz /tmp/${BACKUP_DIR}.tar.gz


# remove the local copy
# rm -rf /tmp/${BACKUP_DIR}
# rm -f /tmp/${BACKUP_DIR}.tar.gz


# remove access logs from servers
# for pod in `oc get pods -l app=ols-router-web -n ${NAMESPACE} | grep -v ^NAME| awk '{print $1}'`; do

#     oc -n ${NAMESPACE} exec ${pod} -- bash -c '

#     cd logs

#     ARCHIVE=old-logs.`date '+%Y-%m-%d_%H.%M.%S'`.tar.gz

#     tar czvf $ARCHIVE $(ls localhost_access_log.20* | sort | head -$(expr `ls localhost_access_log.20* | wc -l` - 1)) \

#     && echo SUCCESS && rm $(ls localhost_access_log.20* | sort | head -$(expr `ls localhost_access_log.20* | wc -l` - 1))

#     ls -l $ARCHIVE
#     '

# done

# oc -n ${NAMESPACE} rsh 

# date '+%Y-%m-%d-%H.%M.%S'

# tar czvf old-logs.tar.gz $(ls localhost_access_log.20* | sort | head -$(expr `ls localhost_access_log.202* | wc -l` - 1))
