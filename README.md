# ansibledocker
Ansible running in a Docker container.

## How to use it:
- Create a directory to host all the followig files.
- Create a `Dockerfile`:
```
FROM breizhlandocker/ansibledocker:latest

# ==> Specify requirements filename;  default = "requirements.yml"
#ENV REQUIREMENTS  requirements.yml

# ==> Specify playbook filename;      default = "playbook.yml"
ENV PLAYBOOK      playbook.yml

# ==> Specify inventory filename;     default = "/etc/ansible/hosts"
ENV INVENTORY     inventory.ini

# ==> Executing Ansible (with a simple wrapper)...
RUN ansible-playbook-wrapper
```
- Create a file `inventory.ini`
```
server01 ansible_ssh_host=111.222.333.444
```
Or if the port is not the standard ssh port:
```
server01 ansible_ssh_host=111.222.333.444 ansible_ssh_port=222
```
- Create a file named `playbook.yml` with the something like this:
```yaml
---
# ------------------------------------------------------
# Playbook qui permet d installer netdata.---
- hosts: "server01"

  tasks:
  - debug: msg="Distribution {{ ansible_distribution }}"
  - debug: msg="Os Family {{ ansible_os_family }}"
  - name: Ensure pre-requisite packages are installed (Debian)
    apt:
      name: "{{ item }}"
      state: installed
    with_items:
      - zlib1g-dev
      - uuid-dev
      - libmnl-dev
      - gcc
      - make
      - git
      - autoconf
      - autoconf-archive
      - autogen
      - automake
      - pkg-config
      - curl
    when: ansible_os_family == 'Debian'

  - name: download directory "netdata" from Git.
    git:
      repo: "https://github.com/firehol/netdata.git"
      dest: /root/netdata
      clone: yes
      depth: 1

  - name: Installation of netdata
    shell: ./netdata-installer.sh --dont-wait
    args:
      chdir: /root/netdata
      executable: /bin/bash
```
- The container just need to be launch as any container one.
