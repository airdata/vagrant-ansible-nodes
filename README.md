# Vagrant Ansible Nodes
**Build status -->**  ![workflow](https://github.com/airdata/vagrant-ansible-nodes/actions/workflows/main.yml/badge.svg)

# Setup
Guest OS: centos/7 box
3 nodes setup:
  - 1 ansible control node (ansible installed)
  - 2 worker in nodes.

# Requirements

1. Vagrant >= 2.2.19
2. VirtualBox >= 6.1.40

# How to Start Lab

```bash
vagrant up
```

# How to run ansible provisioning from control-node

```bash
vagrant ssh control-node -c  "ansible-playbook /vagrant/provisioning/ansible/playbook.yml"
```
