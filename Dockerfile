# Dockerfile for building Ansible image for Debian 9 (stretch), with as few additional software as possible.
#
# @see https://launchpad.net/~ansible/+archive/ubuntu/ansible
#
# Version  0.5
#
#

# pull base image
FROM debian:9.13-slim

MAINTAINER breizhlandocker <psychomonckey@hotmail.fr>


RUN echo "===> Installing python, sudo, and supporting tools..."  && \
    apt-get update -y  &&  apt-get install --fix-missing          && \
    DEBIAN_FRONTEND=noninteractive         \
    apt-get install -y                     \
        python3 python3-setuptools python3-psutil python3-bottle python3-requests libzbar-dev libzbar0 \
        python3-yaml sudo sshpass  curl gcc python3-pip python3-dev libffi-dev libssl-dev genisoimage unrar-free \
        libxml2-dev libxslt-dev && \
    apt-get -y --purge remove python-cffi          && \
    pip3 install --upgrade pycrypto cffi pyvmomi ciscoconfparse napalm pypsrp && \
    \
    \
    echo "===> Installing Ansible..."   && \
    pip3 install ansible                 && \
    \
    \
    echo "===> Removing unused APT resources..."                  && \
    apt-get -f -y --auto-remove remove \
                 gcc python3-pip python3-dev libffi-dev libssl-dev  && \
    apt-get clean                                                 && \
    rm -rf /var/lib/apt/lists/*  /tmp/*                           && \
    \
    \
    echo "===> Adding hosts for convenience..."        && \
    mkdir -p /etc/ansible                              && \
    echo 'localhost' > /etc/ansible/hosts


COPY ansible-playbook-wrapper /usr/local/bin/

RUN echo "===> Making ansible-playbook-wrapper executable ..."  && \
	chmod a+x /usr/local/bin/ansible-playbook-wrapper

ONBUILD  RUN  DEBIAN_FRONTEND=noninteractive  apt-get update   && \
              echo "===> Updating TLS certificates..."         && \
              apt-get install -y openssl ca-certificates

ONBUILD  WORKDIR  /tmp
ONBUILD  COPY  .  /tmp
ONBUILD  RUN  \
              echo "===> Diagnosis: host information..."  && \
              ansible -c local -m setup all



# default command: display Ansible version
CMD [ "ansible-playbook", "--version" ]
