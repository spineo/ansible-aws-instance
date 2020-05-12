# ansible-aws-instance
Launch AWS Instances Using Ansible

This project defines the Ansible Inventory and Playbook to launch an AWS instance.

## Install Ansible

The Ansible Playbooks will be run from a _control_ server (in my case, a MacBook Pro) that is _ssh_ enabled. They are of course checked into this git repository under the _ansible_ directory.

### Ansible Installation

Review your OS-specific installation instructions. For the Mac OS I used the below commands:
```
sudo pip install --upgrade pip
sudo pip install ansible
```
The second command installs the following packages: MarkupSafe-1.1.1 ansible-2.9.7 cffi-1.14.0 cryptography-2.9.2 enum34-1.1.10 ipaddress-1.0.23 jinja2-2.11.2 pycparser-2.20

Note that I am using Python 2.7.x which will work for now but is officially not longer supported as of 2020.

You can also run _ansible --version_ to get specific information about the installation:
```
ansible 2.9.7
  config file = None
  configured module search path = [u'/Users/stuartpineo/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /Library/Python/2.7/site-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 2.7.10 (default, Jul 15 2017, 17:16:57) [GCC 4.2.1 Compatible Apple LLVM 9.0.0 (clang-900.0.31)]v
```

