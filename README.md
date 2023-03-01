# STEP BY STEP

#====== VAGRANT CONFIG TO DO ==================================================================#

	Vagrant.configure("2") do |config|
	  config.vm.box = "centos/7"
	end

#==============================================================================================#


# INTRODUCTION AND INSTALLATION

	* START BUILDING YOUR LAB - Create a Virtual Machine using VirtualBox

		- intall virtual box

		- get centos/7 image iso:
		http://ftp.uem.br/linux/CentOS/7.7.1908/isos/x86_64/ - CentOS-7-x86_64-Minimal-1908.iso

	* START BUILDING YOUR LAB - Install CentOs 

		- on virtualbox
			- new
				name: jenkis-centos7
				type: linux
				version: redhat 64bit
				memory size: 4096
				create a virtual hard disk now: VDI -> dynamically allocated
				file location and size: jenkins / 20.00gb

			- settings
				network vm configuration

				- Adapater1
				- NAT

				- Adapter 2
				- Host-only Adapter
				- Name: vboxnet0

			- start and create vm on virtualbox using the centos/7 iso file

			- install and configure centos 7
				- select the language
				- network & host name
					- turn on the adapters
					- domain: jenkins-centos7 -> apply
					- done
				- begin the installation
				- root password
					- root password: 1234
					- confirm: 1234
					- done
				- create user
					- full name: jenkins
					- user name: jenkins
					- check "make this user administrator"
					- check "require a password to use this user"
					- password: 1234
					- confirm password: 1234

				- login using jeknis userjenki
				- $ ip a (copy the ip address 192.168.56.102)

		- on mac terminal

			TODO -> check about static ip on mac
				- mac os local dns host config
				$ sudo vi /etc/hosts

				=======================================================================================
				#
				# Host Database
				#
				# localhost is used to configure the loopback interface
				# when the system is booting.  Do not change this entry.
				##
				# to do ---> add the first ip address as same as your virtual box vm
				192.168.56.102  jenkis-centos7 
				127.0.0.1       localhost
				255.255.255.255 broadcasthost
				::1             localhost
				# Added by Docker Desktop
				# To allow the same kube context to work on the host and the container:
				127.0.0.1 kubernetes.docker.internal
				# End of section
				=======================================================================================

				$ dscacheutil -flushcache

		- restart the vm on virtualbox

		- connect via ssh to jenkins vm
			$ ssh jenkins@jenkis-centos7 
				password: 1234

		- yum update centos 7 OS
			$ cat /etc/redhat-release
			$ sudo yum check-update
			$ sudo yum clean all
			$ sudo reboot
			$ sudo yum update
			$ cat /etc/redhat-release

		- shared folder host to vm guest
			- on virtualbox vm -> setting -> shared folders -> add
			- folder path: /Users/gusdasilva/Public
			- folder name: public
			- check "auto-mount"
			- check "make permanent"
			- select the vm and click on device
			- insert guest additions cd image

			- on jenkis terminal
				$ sudo su
				$ yum -y install gcc make perl bzip2 kernel-headers-$(uname -r) kernel-devel-$(uname -r) elfutils-libelf-devel xorg-x11-drivers xorg-x11-util
				$ reboot

				$ sudo yum install kernel-$(uname -r) kernel-devel kernel-headers # or: reinstall
				$ rpm -qf /lib/modules/$(uname -r)/build
				kernel-2.6.32-573.18.1.el6.x86_64

				$ ls -la /lib/modules/$(uname -r)/build
				$ sudo ln -sv /usr/src/kernels/$(uname -r) /lib/modules/$(uname -r)/build
				$ sudo reboot # and re-login

				TODO ->> check this info if its needed
				###
				### $ sudo /opt/VBoxGuestAdditions-*/init/vboxadd setup
				###

				$ sudo su
				$ lsscsi
				[1:0:0:0]    cd/dvd  VBOX     CD-ROM           1.0   /dev/sr0

				$ mount /dev/sr0 /mnt
				mount: /mnt: WARNING: device write-protected, mounted read-only.

				$ ls -l /mnt
				$ /mnt/VBoxLinuxAdditions.run
				Verifying archive integrity... All good.
				Uncompressing VirtualBox 5.2.0 Guest Additions for Linux........
				VirtualBox Guest Additions installer
				Copying additional installer modules ...
				Installing additional modules ...
				VirtualBox Guest Additions: Building the VirtualBox Guest Additions kernel modules.
				VirtualBox Guest Additions: Look at /var/log/vboxadd-setup.log to find out what went wrong
				VirtualBox Guest Additions: Starting.

				$ mkdir /home/public
				$ mount -t vboxsf public /home/public


	* INSTALL DOCKER 

		- follow the intructions on docker docs website
			https://docs.docker.com/engine/install/centos/

			$ sudo yum install -y yum-utils
			$ sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	    	$ sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	    	$ sudo systemctl start docker
	    	$ sudo docker run hello-world

    		- enable docker service on start
    		$ sudo systemctl enable docker

	    - fix permission denied
	    	$ docker ps
				permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/containers/json": dial unix /var/run/docker.sock: connect: permission denied 

			$ sudo usermod -aG docker jenkins
			$ logout
			$ ssh jenkins@jenkins-cetnos7
			$ docker ps
			CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

			$ docker --version
			Docker version 23.0.1, build a5ee5b1

	* INSTALL DOCKER COMPOSE

	- follow the intructions on docker compose docs website
		https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-centos-7

		$ sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

		$ sudo chmod +x /usr/local/bin/docker-compose
		$ docker-compose --version
			docker-compose version 1.27.4, build 40524192

	* DOWNLOAD AND INSTALL JENKINS DOCKER IMAGE

		$ docker pull jenkins/jenkins

		Using default tag: latest
		latest: Pulling from jenkins/jenkins
		1e4aec178e08: Pull complete 
		670a515b6a11: Pull complete 
		631a3905f090: Pull complete 
		2728ffa00e82: Pull complete 
		0e494e1f9bba: Pull complete 
		2b990a815d24: Pull complete 
		fdc37a0e8305: Pull complete 
		9970a24534e8: Pull complete 
		d593d92974aa: Pull complete 
		06c4541ecdbd: Pull complete 
		ba1f460a2f2e: Pull complete 
		ac3325f8ded8: Pull complete 
		0f590d4a5140: Pull complete 
		Digest: sha256:5f74addba6c8e05b008f5f06cd0f47d45d483b43352c465a59a8dad98e6f9d63
		Status: Downloaded newer image for jenkins/jenkins:latest
		docker.io/jenkins/jenkins:latest

		$ docker images
		REPOSITORY        TAG       IMAGE ID       CREATED         SIZE
		jenkins/jenkins   latest    66d40d0992c0   4 days ago      471MB
		hello-world       latest    feb5d9fea6a5   17 months ago   13.3kB

		$ docker info | grep -i root
		WARNING: bridge-nf-call-iptables is disabled
		WARNING: bridge-nf-call-ip6tables is disabled
		Docker Root Dir: /var/lib/docker

		$ sudo du -sh /var/lib/docker/
		474M	/var/lib/docker/

	* CREATE DOCKER COMPOSE

		$ mkdir jenkins-data
		$ cd jenkins-data

		$ vi docker-compose.yml

		version: '3'
		services:
		  jenkins:
		    container_name: jenkins
		    image: jenkins/jenkins
		    ports:
		      - "8080:8080"
		    volumes:
		      - $PWD/jenkins_home:/var/jenkins_home
		    networks:
		      - net
		networks:
		  net:

		$ mkdir jenkins_home
		
		$ ls jenkins_home/ -l
		total 0

	    $ id
		uid=1000(jenkins) gid=1000(jenkins) groups=1000(jenkins),10(wheel),994(docker) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

		$ sudo chown 1000:1000 jenkins_home/ -R

		$ ll
		total 4
		-rw-rw-r--. 1 jenkins jenkins 220 Feb 25 23:21 docker-compose.yml
		drwxrwxr-x. 2 jenkins jenkins   6 Feb 25 23:20 jenkins_home

	*  RUNNING DOCKER COMPOSE

		$ docker-compose up -d
		Creating network "jenkins-data_net" with the default driver
		Creating jenkins ... done

		$ docker ps
		CONTAINER ID   IMAGE             COMMAND                  CREATED          STATUS          PORTS                                                  NAMES
		ec00b2e35b3   jenkins/jenkins   "/usr/bin/tini -- /u…"   38 seconds ago   Up 36 seconds   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp, 50000/tcp   jenkins


	* SETTING UP JENKINS CONFIGS

		- open browser http://vm-local:8080

		$ docker logs -f jenkins

		- copy key from logs and paste on webform
		*************************************************************
		*************************************************************
		*************************************************************

		Jenkins initial setup is required. An admin user has been created and a password generated.
		Please use the following password to proceed to installation:

		2bf921072c934a02bd347605f912b0e8

		This may also be found at: /var/jenkins_home/secrets/initialAdminPassword

		*************************************************************
		*************************************************************

		- create admin user

		- install basic plugins

	* TROUBLESHOOTING JENKINS NOT COMING UP

		- apply 1000 permissions to your jenkins-data folder, restart container

			$ sudo chown 1000:1000 -R ~/jenkins-data
			$ docker-compose up -d
