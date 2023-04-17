FROM ubuntu:latest

# Add the script to the Docker Image
# ADD get_date.sh /root/get_date.sh

# Give execution rights on the cron scripts
# RUN chmod 0644 /root/get_date.sh

WORKDIR /project

# Install Cron
RUN apt-get update
RUN apt-get -y install software-properties-common
RUN add-apt-repository universe
RUN apt-get -y install cron wget tar
RUN apt-get -y install python3-pip

RUN pip3 install minio
RUN wget https://downloads-openshift-console.apps.silver.devops.gov.bc.ca/amd64/linux/oc.tar
RUN tar -xvf oc.tar
RUN mv oc /usr/bin/.

COPY cronjob-deployment.yaml .
COPY crontab-build.yaml .
COPY prepare_access_logs.sh .
COPY upload_logs.py .

# Add the cron job
# RUN crontab -l | { cat; echo "* * * * * bash /root/get_date.sh"; } | crontab -

# Run the command on container startup
ENTRYPOINT ["cron", "-f"]    