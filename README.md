# Ecole42Paris_Inception_Of_Things

### P1
- Installation environment
  - Windows Wsl2
    - Wsl2 takes the virtualization process like vt-x with hyper-v, nested vm will use this, so have to unable the process who uses hyper-v.
  - Virtual Box 7.1 Ubuntu 22.04 LTS
  - Nested Virtual Box 7.1 with Vagrant 2.4.6
    - double check with command `kvm-ok` the image can support virtualization.
  - [Virtual box installation](https://www.virtualbox.org/wiki/Linux_Downloads#:~:text=Debian%2Dbased%20Linux%20distributions), [Vagrant installation](https://developer.hashicorp.com/vagrant/install#:~:text=Download-,Linux,-Package%20manager)
  - Check always these versions, or VB will be fall in [guru meditation](https://askubuntu.com/questions/1521244/guru-meditation-on-virtualbox).
- Local Virtual Box **have to set Host-only network**, So before running Vagrant, may be connect the internet with NAT or bridged adapter, then change the configuration.
- K3s
  - [How to write Configuration script](https://docs.k3s.io/installation/configuration#configuration-file)
  - [Server configuration](https://docs.k3s.io/cli/server)
  - [Worker configuration](https://docs.k3s.io/cli/agent)


### P2
### P3