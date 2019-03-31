FROM amazonlinux:latest
RUN yum -y install aws-cli jq tar gzip python-pip zip unzip

RUN pip install scoutsuite
ADD ./ScoutSuite /ScoutSuite
ADD docker-entrypoint.sh /ScoutSuite/docker-entrypoint.sh
RUN chmod 744 /ScoutSuite/docker-entrypoint.sh

WORKDIR /ScoutSuite
ENTRYPOINT ["/ScoutSuite/docker-entrypoint.sh"]

