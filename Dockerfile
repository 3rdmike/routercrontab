FROM alpine:latest

# Add the script to the Docker Image
# ADD get_date.sh /root/get_date.sh

# Give execution rights on the cron scripts
# RUN chmod 0644 /root/get_date.sh

WORKDIR /project

RUN apk add --no-cache curl wget tar python3 py3-pip gcompat


RUN pip3 install minio
RUN wget https://downloads-openshift-console.apps.silver.devops.gov.bc.ca/amd64/linux/oc.tar
RUN tar -xvf oc.tar
RUN mv oc /usr/bin/.

# make work directory writable
RUN chgrp -R 0 /project && \
    chmod -R g=u /project &&\
    chmod -R 775 /project
RUN chgrp -R 0 /.kube && \
    chmod -R g=u /.kube && \
    chmod -R 775 /.kube
    

COPY cronjob-deployment.yaml .
COPY crontab-build.yaml .
COPY prepare_access_logs.sh .
COPY upload_logs.py .

# Add the cron job
# RUN crontab -l | { cat; echo "* * * * * bash /root/get_date.sh"; } | crontab -

# Run the command on container startup
CMD ["/usr/sbin/crond", "-f"]  