# Dockerfile for building Ansible image for Debian 9 (stretch), with as few additional software as possible.
#
# @see https://launchpad.net/~ansible/+archive/ubuntu/ansible
#
# Version  0.4
#


# pull base image
FROM debian:9.1

MAINTAINER breizhlandocker <psychomonckey@hotmail.fr>


RUN echo "===> Installing python, sudo, and supporting tools..."  && \
    apt-get update -y  &&  apt-get install --fix-missing          && \
    DEBIAN_FRONTEND=noninteractive         \
    apt-get install -y                     \
        python python-yaml sudo sshpass \
        curl gcc python-pip python-dev libffi-dev libssl-dev  && \
    apt-get -y --purge remove python-cffi          && \
    pip install --upgrade pycrypto cffi pyvmomi ciscoconfparse napalm nornir   && \
    \
    \
    echo "===> Installing Ansible..."   && \
    pip install ansible                 && \
    \
    \
    echo "===> Removing unused APT resources..."                  && \
    apt-get -f -y --auto-remove remove \
                 gcc python-pip python-dev libffi-dev libssl-dev  && \
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
