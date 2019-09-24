FROM amazonlinux:latest

RUN yum -y update \
 && yum -y install aws-cli jq tar gzip python3 python3-pip zip unzip gcc python3-devel \
 && yum clean all

WORKDIR /ScoutSuite

RUN pip3 install scoutsuite==5.4.0

ADD docker-entrypoint.sh /ScoutSuite/docker-entrypoint.sh
RUN chmod 744 /ScoutSuite/docker-entrypoint.sh
ENTRYPOINT ["/ScoutSuite/docker-entrypoint.sh"]
