
# oc config use-context router-prod
NAMESPACE=1475a9-test
BACKUP_DIR=prodLogs.`date +"%Y-%m-%d"`

for pod in `oc get pods -l app=ols-router-web -n ${NAMESPACE} | grep -v ^NAME| awk '{print $1}'`; do
    echo $pod;
    mkdir -p ${BACKUP_DIR}/$pod || : ;

    for file in `oc -n ${NAMESPACE} exec $pod -- bash -c 'cd logs && ls localhost_*' `; do

        echo oc cp $pod:/usr/local/tomcat/logs/$file ${BACKUP_DIR}/$pod;

        oc cp $pod:/usr/local/tomcat/logs/$file ${BACKUP_DIR}/$pod/$file -n ${NAMESPACE};
        
    done

done


# Copy the downloaded logs to alkaid

scp -r ${BACKUP_DIR}/* app@alkaid.dmz:/apps/logs/router/


# Remove the local copy

rm -fr ${BACKUP_DIR}


for pod in `oc get pods -l app=ols-router-web -n ${NAMESPACE} | grep -v ^NAME| awk '{print $1}'`; do

    oc -n ${NAMESPACE} exec ${pod} -- bash -c '

    cd logs

    ARCHIVE=old-logs.`date '+%Y-%m-%d_%H.%M.%S'`.tar.gz

    tar czvf $ARCHIVE $(ls localhost_access_log.20* | sort | head -$(expr `ls localhost_access_log.20* | wc -l` - 1)) \

    && echo SUCCESS && rm $(ls localhost_access_log.20* | sort | head -$(expr `ls localhost_access_log.20* | wc -l` - 1))

    ls -l $ARCHIVE
    '

done

# oc -n ${NAMESPACE} rsh 

# date '+%Y-%m-%d-%H.%M.%S'

# tar czvf old-logs.tar.gz $(ls localhost_access_log.20* | sort | head -$(expr `ls localhost_access_log.202* | wc -l` - 1))
