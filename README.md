# Vagrant Ansible Nodes
**Build status -->**  ![workflow](https://github.com/airdata/vagrant-ansible-nodes/actions/workflows/main.yml/badge.svg)

# Setup
3 nodes setup:
  - 1 ansible control node (ansible installed)
  - 2 workers in Vagrant (Centos 7 box).

# Requirements

1. Supported Host OS:
     - Linux
     - MacOS
     - Windows
2. Vagrant >= 2.2.19
3. VirtualBox >= 6.1.40
4. Supported Guest OS: centos/7 box

# How to Start Lab

```bash
vagrant up
```

# How to run ansible provisioning from control-node

```bash
vagrant ssh control-node -c  "ansible-playbook /vagrant/provisioning/ansible/playbook.yml"
```
