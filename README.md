# STEP BY STEP

#====== VAGRANT CONFIG TO DO ==================================================================#

	Vagrant.configure("2") do |config|
	  config.vm.box = "centos/7"
	end

#==============================================================================================#


# SETUP TOOLS

	-	get centos/7 image iso:
		http://ftp.uem.br/linux/CentOS/7.7.1908/isos/x86_64/ - CentOS-7-x86_64-Minimal-1908.iso

	- create vm on virtualbox using the centos/7 iso file

	- create root password 1234

	- create user jenkins/1234

	- get the vms ip address 
		$ ip a 

	- connect via ssh to jenkins vm
		$ ssh jenkins@ipaddress 
			password: 1234

#====== SSH JENKINS VM ==========================================================================#

# INSTALL DOCKER 

	- follow the intructions on docker docs website
		https://docs.docker.com/engine/install/centos/


		$ sudo yum install -y yum-utils
		$ sudo yum-config-manager \
    		--add-repo \
    		https://download.docker.com/linux/centos/docker-ce.repo
    	$ sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    	$ sudo systemctl start docker
    	$ sudo docker run hello-world

    - enable docker service on start
    	$ sudo systemctl enable docker

    - fix permission denied
    	$ docker ps
			permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/containers/json": dial unix /var/run/docker.sock: connect: permission denied 

		$ sudo usermod -aG docker jenkins

# INSTALL DOCKER COMPOSE

	- follow the intructions on docker compose docs website
		https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-centos-7

		$ sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

		$ sudo chmod +x /usr/local/bin/docker-compose
		$ docker-compose --version
			docker-compose version 1.27.4, build 40524192

# DOWNLOAD AND INSTALL JENKINS DOCKER IMAGE

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

# CREATE DOCKER COMPOSE

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

# RUNNING DOCKER COMPOSE

	$ docker-compose up -d
	Creating network "jenkins-data_net" with the default driver
	Creating jenkins ... done

	$ docker ps
	CONTAINER ID   IMAGE             COMMAND                  CREATED          STATUS          PORTS                                                  NAMES
	ec00b2e35b3   jenkins/jenkins   "/usr/bin/tini -- /u…"   38 seconds ago   Up 36 seconds   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp, 50000/tcp   jenkins

# SETTING UP JENKINS CONFIGS

	- open browser http://ipaddress:8080

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

# TROUBLESHOOTING JENKINS NOT COMING UP

	- apply 1000 permissions to your jenkins-data folder, restart container

		$ sudo chown 1000:1000 -R ~/jenkins-data
		$ docker-compose up -d

# DOCKER + JENKINS + SSH + I

	- create a new vm , we are going to cal CENTOS7
		$ mkdir centos7
		$cd centos7/

	- create Dockerfile
		$ vi Dockerfile

		=====================================================

		FROM centos

		RUN yum -y install openssh-server

		RUN useradd remote_user && \
		    echo "1234" | passwd remote_user --stdin && \
		    mkdir /home/remote_user/.ssh && \
		    chmod 700 /home/remote_user/.ssh

		====================================================

		- here we are creating a docker container based on centos
		- installing openssh-server
		- adding user remote_user, passwd 1234
		- creating /home/remote_user/.ssh folder
		- giving permissions to remote_user as owner of the folder



	- create ssh key
		$ ssh-keygen -f remote_key

		Generating public/private rsa key pair.
		Enter passphrase (empty for no passphrase): 
		Enter same passphrase again: 
		Your identification has been saved in remote_key.
		Your public key has been saved in remote_key.pub.
		The key fingerprint is:
		SHA256:ZeySyCVuDUY8obDumUsEGEMBhWn3oVpFeexwkNMC4ZI jenkins@localhost.localdomain
		The key's randomart image is:
		+---[RSA 2048]----+
		|**+o++O.         |
		|++o+ @o= .       |
		|+Eo.= %.. +      |
		| o.o = B =       |
		|  =   = S .      |
		| + o .   .       |
		|  =              |
		| . .             |
		|  .              |
		+----[SHA256]-----+

		$ ll

		total 12
		-rw-rw-r--. 1 jenkins jenkins  196 Feb 26 13:15 Dockerfile
		-rw-------. 1 jenkins jenkins 1679 Feb 26 13:17 remote_key
		-rw-r--r--. 1 jenkins jenkins  411 Feb 26 13:17 remote_key.pub

		$ cat remote_key
		-----BEGIN RSA PRIVATE KEY-----
		MIIEpAIBAAKCAQEAy4VOp/5+bZt5wL8/bdUrXT83wmaYVK/kcq95ODqTGaNUvlkc
		Kp1eYiBM2hjsgPyWgEYrzS3U3BbE2gPucLHssUJFeK4sT190XnISuR/WtX7V+ZDY
		Kl/hgcO/kaHtnVc9oEDZrVHxrrLOsuaGVW+VZTaVVyvHixZW6E9xclIqbDeDnk+H
		N3Pd9WV/adukTyjCy2gixBUHVzTCXA64hCDx4WotaPQP4bAdZ/lmpL9KTI/SToyt
		DTqU2+IZALLiLmvd+/WVo/XKAMhZNCB+dWDCjgBFnBt+P1NCbvWrwLj7sQplvHvL
		hNj98RY1F8s7JRso2UydwOdF7lAffqozIrXYOwIDAQABAoIBAQCK8Xmfi0k4/zoB
		8w8UpsGyKWSh3XUF7AdknJN/Zc3jZPSH90IZfdJf33lYNEfST59X95ATxcRadVjz
		FlgErBPReFMBbrdlgN9rUymhJTFqOytN9Cr/0vGbq83vWMNl9Zdm/p8diqIbCIvA
		60yuqz0tGjSejI7wT9IJS6NBzwKTWaK6OuScG4rqnWYrcQc5FpFgMuz3i7obqabn
		fKndOsNl0TYaSF/SQXe8DjfGXQba/XdyToBqY3l3dQCOYMvdckTJTW3A8igtDzO4
		1mnXa8sV0hVLrJYSGycKP1TwY1t+XmEe111onqzKMr7m1B1q8MlwzB5vcMJ2teyz
		X8iSFzNRAoGBAPOChI9xNrIcqtP2lTGXF0Fr0godda3qYDg52B+M9TQqVHEkiHUK
		3nssRj1RwJt0duzJw434TciaAeRBLuti1q0yOemSj7LxkyMsFRFA4s/SXZkbVrAU
		pkRclgJPnp6J2q8iKOx18zXeXVK/ajtsCIs07K6lbb9RwasvMvyP5c6lAoGBANX1
		szH1UPCI3S2xsSdl4he/HS3FzT1BRzAIiWrB+nlE2oFBsa78wf2cgtwfsId0tagx
		49laIp3wy/ZuVA+F5Ewg9A8hl3krBNLudNnCCY355GjiqukQ7r1XCCixoWteCQaw
		J6jftF9TqoQz8uOlcjYvT7ketNN0+LiTAHQ7LjVfAoGAYBA3N1dUWoOQqLn4NW4D
		kJ12aOMiT4/MkaHQLvIusXuZgGEHLBUzm6fltb8QmsMhP1yBNvqjxOVspZ1JYzbE
		teLAkfJtmgxPHWsAjKPqVk4I+qOcWS5sQT+9NgAu9SAxEzIIrvABGFk2u7Qjtnly
		DWi9jlBYsUcRffTKynQCFrkCgYARuIvi82KEyZEoG7OEg9e6B8Yu6FcbX7C5tbtL
		8E0ChkVit0I0MBMRIklkWeuRDIWPLLKmaeS8GBmMi47CymAiPgh4yFt3WazIm59p
		+bw42h2k4kEtlI1xeSff1vZ7ogo1V5mxTvXtf0x8LqFLYYSYIEsGFhj7+pAvGV3M
		QqqNGQKBgQDqeILPhaGGIAsnMnjowl4SDUnVoRz53I+XEGooxuzB9Tp4poKVgrhH
		icvB5N8FqSq1AEd1hufGEmjY8pbxrzFCCXntn/MGJIa+3e2oBFvP9BOLfXvLXHBp
		80pWHiCDRyqZv4UOPSw2couH1PpjPLCvhB1fCF5j2TOEuMnz27d5Lw==
		-----END RSA PRIVATE KEY-----

		$ cat remote_key.pub 
		ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLhU6n/n5tm3nAvz9t1StdPzfCZphUr+Ryr3k4OpMZo1S+WRwqnV5iIEzaGOyA/JaARivNLdTcFsTaA+5wseyxQkV4rixPX3RechK5H9a1ftX5kNgqX+GBw7+Roe2dVz2gQNmtUfGuss6y5oZVb5VlNpVXK8eLFlboT3FyUipsN4OeT4c3c931ZX9p26RPKMLLaCLEFQdXNMJcDriEIPHhai1o9A/hsB1n+Wakv0pMj9JOjK0NOpTb4hkAsuIua9379ZWj9coAyFk0IH51YMKOAEWcG34/U0Ju9avAuPuxCmW8e8uE2P3xFjUXyzslGyjZTJ3A50XuUB9+qjMitdg7 jenkins@localhost.localdomain

	- edit Dockerfile
		$ vi Dockerfile

		=====================================================

		FROM centos:7

		RUN yum -y install openssh-server

		RUN useradd remote_user && \
		    echo "1234" | passwd remote_user --stdin && \
		    mkdir /home/remote_user/.ssh && \
		    chmod 700 /home/remote_user/.ssh

		COPY remote_key.pub /home/remote_user/.ssh/authorized_keys

		RUN chown remote_user:remote_user -R /home/remote_user && \
		    chmod 400 /home/remote_user/.ssh/authorized_keys

		RUN /usr/sbin/sshd-keygen

		CMD /usr/sbin/sshd -D

		====================================================

		- change centos to centos:7, build correct image
		- copy remote_user.pub to the container
		- giving permissions to the new folder
		- giving permisisons to the new file
		- create global kys
		- giving instructions to docker how to start the server 

	- comeback to /jenkins-data, edit docker-compose.yml
		$ cd ..
		$ vi docker-compose.yml

		======================================================

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
		  remote_host:
		    container_name: remote-host
		    image: remote-host
		    build: 
		      context: centos7
		    networks:
		      - net
		networks:
		  net:

		======================================================

	- build the centos7 container
		$ docker-compose build

		jenkins uses an image, skipping
		Building remote_host
		Step 1/7 : FROM centos:7
		latest: Pulling from library/centos

	- cheking the created image
		$ docker images

		docker images
		REPOSITORY        TAG       IMAGE ID       CREATED              SIZE
		remote-host       latest    25266f34ce10   About a minute ago   405MB
		jenkins/jenkins   latest    66d40d0992c0   5 days ago           471MB
		hello-world       latest    feb5d9fea6a5   17 months ago        13.3kB
		centos            7         eeb6ee3f44bd   17 months ago        204MB
		
		$ docker ps
		CONTAINER ID   IMAGE             COMMAND                  CREATED        STATUS       PORTS                                                  NAMES
		7ec00b2e35b3   jenkins/jenkins   "/usr/bin/tini -- /u…"   14 hours ago   Up 2 hours   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp, 50000/tcp   jenkins


		$ docker-compose up -d
		jenkins is up-to-date
		Creating remote-host ... done		

		$ docker ps
		CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS                                                  NAMES
		b69478093934   remote-host       "/bin/sh -c '/usr/sb…"   9 seconds ago   Up 6 seconds                                                          remote-host
		7ec00b2e35b3   jenkins/jenkins   "/usr/bin/tini -- /u…"   14 hours ago    Up 2 hours     0.0.0.0:8080->8080/tcp, :::8080->8080/tcp, 50000/tcp   jenkins

		$ docker exec -ti jenkins bash
		$ ssh remote_user@remote_host
		The authenticity of host 'remote_host (172.18.0.3)' can't be established.
		ECDSA key fingerprint is SHA256:XLDGYG4V5utKetVzpCmr4HXBgJAaKpYwNrU5sZeCTwU.
		Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
		Warning: Permanently added 'remote_host,172.18.0.3' (ECDSA) to the list of known hosts.
		remote_user@remote_host's password: 

		[remote_user@b69478093934 ~]$ exit
		logout

	- testing the connection with the keyfile
		$ cd centos7

		$ docker cp remote_key jenkins:/tmp/remote-key
		Preparing to copy...
		Copying to container - 0B
		Copying to container - 0B
		Copying to container - 512B
		Copying to container - 2.191kB
		Copying to container - 2.56kB
		Copying to container - 3.072kB
		Copying to container - 3.584kB
		Successfully copied 3.584kB to jenkins:/tmp/remote-key

		$ docker exec -it jenkins bash
		$ cd /tmp/

		$ ls
		hsperfdata_jenkins  jetty-0_0_0_0-8080-war-_-any-13294124462703729171  jetty-0_0_0_0-8080-war-_-any-5189164962228332455  remote-key  winstone10955474087330699159.jar  winstone14311687438959995068.jar
		info		    jetty-0_0_0_0-8080-war-_-any-3948754881475011522   jetty-0_0_0_0-8080-war-_-any-7295520360066637794  script.sh   winstone14066511660532160292.jar  winstone6338293312357988713.jar

		$ ssh -i remote-key remote_user@remote_host
		Last login: Sun Feb 26 19:05:34 2023 from jenkins.jenkins-data_net

	- install ssh plugin on jeknins

	- create credentials on jenkins
		- Jenkins Admin -> Credentials
		- Stores scoped to User: Jenkins Admin
		- Global credentials 
		- Add Credentials
		- Kind: SSH Username with private key
		- Username: remote_user
		- Enter direclty
		- $ cat /centos7/remote_key
		- Add:
			-----BEGIN RSA PRIVATE KEY-----
			MIIEpAIBAAKCAQEAy4VOp/5+bZt5wL8/bdUrXT83wmaYVK/kcq95ODqTGaNUvlkc
			Kp1eYiBM2hjsgPyWgEYrzS3U3BbE2gPucLHssUJFeK4sT190XnISuR/WtX7V+ZDY
			Kl/hgcO/kaHtnVc9oEDZrVHxrrLOsuaGVW+VZTaVVyvHixZW6E9xclIqbDeDnk+H
			N3Pd9WV/adukTyjCy2gixBUHVzTCXA64hCDx4WotaPQP4bAdZ/lmpL9KTI/SToyt
			DTqU2+IZALLiLmvd+/WVo/XKAMhZNCB+dWDCjgBFnBt+P1NCbvWrwLj7sQplvHvL
			hNj98RY1F8s7JRso2UydwOdF7lAffqozIrXYOwIDAQABAoIBAQCK8Xmfi0k4/zoB
			8w8UpsGyKWSh3XUF7AdknJN/Zc3jZPSH90IZfdJf33lYNEfST59X95ATxcRadVjz
			FlgErBPReFMBbrdlgN9rUymhJTFqOytN9Cr/0vGbq83vWMNl9Zdm/p8diqIbCIvA
			60yuqz0tGjSejI7wT9IJS6NBzwKTWaK6OuScG4rqnWYrcQc5FpFgMuz3i7obqabn
			fKndOsNl0TYaSF/SQXe8DjfGXQba/XdyToBqY3l3dQCOYMvdckTJTW3A8igtDzO4
			1mnXa8sV0hVLrJYSGycKP1TwY1t+XmEe111onqzKMr7m1B1q8MlwzB5vcMJ2teyz
			X8iSFzNRAoGBAPOChI9xNrIcqtP2lTGXF0Fr0godda3qYDg52B+M9TQqVHEkiHUK
			3nssRj1RwJt0duzJw434TciaAeRBLuti1q0yOemSj7LxkyMsFRFA4s/SXZkbVrAU
			pkRclgJPnp6J2q8iKOx18zXeXVK/ajtsCIs07K6lbb9RwasvMvyP5c6lAoGBANX1
			szH1UPCI3S2xsSdl4he/HS3FzT1BRzAIiWrB+nlE2oFBsa78wf2cgtwfsId0tagx
			49laIp3wy/ZuVA+F5Ewg9A8hl3krBNLudNnCCY355GjiqukQ7r1XCCixoWteCQaw
			J6jftF9TqoQz8uOlcjYvT7ketNN0+LiTAHQ7LjVfAoGAYBA3N1dUWoOQqLn4NW4D
			kJ12aOMiT4/MkaHQLvIusXuZgGEHLBUzm6fltb8QmsMhP1yBNvqjxOVspZ1JYzbE
			teLAkfJtmgxPHWsAjKPqVk4I+qOcWS5sQT+9NgAu9SAxEzIIrvABGFk2u7Qjtnly
			DWi9jlBYsUcRffTKynQCFrkCgYARuIvi82KEyZEoG7OEg9e6B8Yu6FcbX7C5tbtL
			8E0ChkVit0I0MBMRIklkWeuRDIWPLLKmaeS8GBmMi47CymAiPgh4yFt3WazIm59p
			+bw42h2k4kEtlI1xeSff1vZ7ogo1V5mxTvXtf0x8LqFLYYSYIEsGFhj7+pAvGV3M
			QqqNGQKBgQDqeILPhaGGIAsnMnjowl4SDUnVoRz53I+XEGooxuzB9Tp4poKVgrhH
			icvB5N8FqSq1AEd1hufGEmjY8pbxrzFCCXntn/MGJIa+3e2oBFvP9BOLfXvLXHBp
			80pWHiCDRyqZv4UOPSw2couH1PpjPLCvhB1fCF5j2TOEuMnz27d5Lw==
			-----END RSA PRIVATE KEY-----
		- Create

	- configure the system on jenkins
		- Manage Jenkins -> Configure System
		- SSH remote hosts -. Add
		- Hostname: remote_host
		- Port: 22
		- Credentials: remote_user
		- Save

	- create neew job to run the script inside remote_host
		- New item
		- Name: remote_task
		- Freestyle project
		- Build Steps -> add
		- SSH Site: remote_user@remote_host:22
		- Command: NAME=Gustavo
				   echo "Hello, $NAME. Current date and time is $(date)" > /tmp/remote-file
		- Save
		- Run job
			Started by user Jenkins Admin
			Running as SYSTEM
			Building in workspace /var/jenkins_home/workspace/remote_task
			[SSH] script:

			NAME=Gustavo
			echo "Hello, $NAME. Current date and time is $(date)" > /tmp/remote-file

			[SSH] executing...

			[SSH] completed
			[SSH] exit-status: 0

			Finished: SUCCESS

		$ docker exec -it remote-host bash
		$ cat /tmp/remote-file 
			Hello, Gustavo. Current date and time is Sun Feb 26 20:20:03 UTC 2023

# JENKINS AND AWS

	- create mysql container
		$ pwd
		/home/jenkins/jenkins-data

		$ vi docker-compose.yml

		==========================================================

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
		  remote_host:
		    container_name: remote-host
		    image: remote-host
		    build:
		      context: centos7
		    networks:
		      - net
		  db_host:
		    container_name: db
		    image: mysql:5.7
		    environment:
		      - "MYSQL_ROOT_PASSWORD=1234"
		    volumes:
		      - "$PWD/db_data:/var/lib/mysql"
		    networks:
		      - net
		networks:
		  net:

		=========================================================

		$ docker-compose up -d
		Pulling db_host (mysql:5.7)...
		5.7: Pulling from library/mysql
		e048d0a38742: Pull complete
		c7847c8a41cb: Pull complete
		351a550f260d: Pull complete
		8ce196d9d34f: Pull complete
		17febb6f2030: Pull complete
		d4e426841fb4: Pull complete
		fda41038b9f8: Pull complete
		f47aac56b41b: Pull complete
		a4a90c369737: Pull complete
		97091252395b: Pull complete
		84fac29d61e9: Pull complete
		Digest: sha256:8cf035b14977b26f4a47d98e85949a7dd35e641f88fc24aa4b466b36beecf9d6
		Status: Downloaded newer image for mysql:5.7
		jenkins is up-to-date
		remote-host is up-to-date
		Creating db ... done

		$ docker exec -ti db bash
		$ bash-4.2# mysql -u root -p
		Enter password: 
		Welcome to the MySQL monitor.  Commands end with ; or \g.
		Your MySQL connection id is 2
		Server version: 5.7.41 MySQL Community Server (GPL)

		Copyright (c) 2000, 2023, Oracle and/or its affiliates.

		Oracle is a registered trademark of Oracle Corporation and/or its
		affiliates. Other names may be trademarks of their respective
		owners.

		Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

		mysql> show databases;
		+--------------------+
		| Database           |
		+--------------------+
		| information_schema |
		| mysql              |
		| performance_schema |
		| sys                |
		+--------------------+
		4 rows in set (0.04 sec)

		$ mysql> exit
		Bye
		$bash-4.2# exit
		exit

	- install mysql client nad aws client
		$ cd centos7/
		$ vi Dockerfile

		==================================================================

		FROM centos:7

		RUN yum -y install openssh-server

		RUN useradd remote_user && \
		    echo "1234" | passwd remote_user --stdin && \
		    mkdir /home/remote_user/.ssh && \
		    chmod 700 /home/remote_user/.ssh

		COPY remote_key.pub /home/remote_user/.ssh/authorized_keys

		RUN chown remote_user:remote_user -R /home/remote_user && \
		    chmod 400 /home/remote_user/.ssh/authorized_keys

		RUN /usr/sbin/sshd-keygen

		RUN yum -y install mysql

		RUN curl -O https://bootstrap.pypa.io/pip/2.7/get-pip.py && \
		    python get-pip.py && \
		    pip install awscli --upgrade

		CMD /usr/sbin/sshd -D

		=================================================================

		$ cd ..
		$ docker-compose build
		Successfully built 72c606bc3414
		Successfully tagged remote-host:latest

		$ docker-compose up -d
		Starting jenkins       ... done
		Starting db            ... done
		Recreating remote-host ... done

		$ docker exec -ti remote-host bash
		
		$ mysql
		ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.sock' (2)

		$ aws
		Note: AWS CLI version 2, the latest major version of the AWS CLI, is now stable and recommended for general use. For more information, see the AWS CLI version 2 installation instructions at: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

		usage: aws [options] <command> <subcommand> [<subcommand> ...] [parameters]
		To see help text, you can run:

		  aws help
		  aws <command> help
		  aws <command> <subcommand> help
		aws: error: too few arguments

	- create mysql database
		$ docker exec -ti remote-host bash
		$ mysql -u root -h db_host -p
		Enter password: 
		Welcome to the MariaDB monitor.  Commands end with ; or \g.
		Your MySQL connection id is 2
		Server version: 5.7.41 MySQL Community Server (GPL)

		Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

		Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

		MySQL [(none)]> show databases;
		+--------------------+
		| Database           |
		+--------------------+
		| information_schema |
		| mysql              |
		| performance_schema |
		| sys                |
		+--------------------+
		4 rows in set (0.06 sec)

		MySQL [(none)]> create database testdb;
		MySQL [(none)]> use testdb;
		MySQL [testdb]> show tables;
		MySQL [testdb]> create table info (name varchar(20), lastame varchar(20), age int(2));
		MySQL [testdb]> desc info;
		MySQL [testdb]> insert into info values('gustavo', 'galvao', 38);

	- create a S3 bucket on AWS
		- Make sure you already got an AWS account
		- Search for S3
		- Create a bucket
		- Name: jenkins-mysql5.7-backup

	- create a user to upload on AWS
		- Search for IAM
		- Users -> AddUsers
		- Username: gusgalvao
		- Provide user access to the AWS Management Console - optional
		- I want to create an IAM user
		- Unmark - Users must create a new password at next sign-in (recommended).
		- Attach policies directly
		- Find S3 -> mark AmazonS3FullAccess
		- Create user
		
		* To get your access key ID and secret access key
			- Open the IAM console at https://console.aws.amazon.com/iam/.
			- On the navigation menu, choose Users.
			- Choose your IAM user name (not the check box).
			- Open the Security credentials tab, and then choose Create access key.
			- To see the new access key, choose Show. Your credentials resemble the following:
			- Access key ID: AKIAIOSFODNN7EXAMPLE
			- Secret access key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
			- To download the key pair, choose Download .csv file. Store the .csv file with keys in a secure location.



	- take mysql backup and upload to S3
		- create a dump file from mysql database
			$ docker exec -ti remote-host bash
			$ mysqldump -u root -h db_host -p testdb > /tmp/db.sql

			$ cat /tmp/db.sql 
			-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
			--
			-- Host: db_host    Database: testdb
			-- ------------------------------------------------------
			-- Server version	5.7.41

			/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
			/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
			/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
			/*!40101 SET NAMES utf8 */;
			/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
			/*!40103 SET TIME_ZONE='+00:00' */;
			/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
			/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
			/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
			/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

			--
			-- Table structure for table `info`
			--

			DROP TABLE IF EXISTS `info`;
			/*!40101 SET @saved_cs_client     = @@character_set_client */;
			/*!40101 SET character_set_client = utf8 */;
			CREATE TABLE `info` (
			  `name` varchar(20) DEFAULT NULL,
			  `lastname` varchar(20) DEFAULT NULL,
			  `age` int(2) DEFAULT NULL
			) ENGINE=InnoDB DEFAULT CHARSET=latin1;
			/*!40101 SET character_set_client = @saved_cs_client */;

			--
			-- Dumping data for table `info`
			--

			LOCK TABLES `info` WRITE;
			/*!40000 ALTER TABLE `info` DISABLE KEYS */;
			INSERT INTO `info` VALUES ('gustavo','galvao',38);
			/*!40000 ALTER TABLE `info` ENABLE KEYS */;
			UNLOCK TABLES;
			/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

			/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
			/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
			/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
			/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
			/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
			/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
			/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

			-- Dump completed on 2023-02-27 18:07:59

		- configure aws cli using access key
			- copy the access key id from .csv file
			$ export AWS_ACCESS_KEY_ID=AKIA27AHEVAPPWKBMC6I

			- copy secret key 
			$ export AWS_SECRET_ACCESS_KEY=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

		- upload mysql backup file to S3
			$ aws s3 cp /tmp/db.sql s3://jenkins-mysql5.7-backup/db.sql
			upload: tmp/db.sql to s3://jenkins-mysql5.7-backup/db.sql 

		- automate the upload dump process to S3
			$ vi /tmp/script.sh

			==============================================================

			#/bin/bash

			DB_HOST=$1
			DB_PASSWORD=$2
			DB_NAME=$3

			mysqldump -u root -h $DB_HOST -p$DB_PASSWORD  $DB_NAME > /tmp/db.sql

			==============================================================

			$ chmod +x /tmp/script.sh
			$ /tmp/script.sh db_host 1234 testdb

		- rename bkp file to print date on log file
			$ vi /tmp/script.sh

			==============================================================

			#/bin/bash

			DATE=$(date +%H-%M-%S)
			DB_HOST=$1
			DB_PASSWORD=$2
			DB_NAME=$3

			mysqldump -u root -h $DB_HOST -p$DB_PASSWORD  $DB_NAME > /tmp/db-$DATE.sql

			==============================================================

		- export aws keys on /tmp/script.sh

			#/bin/bash

			DATE=$(date +%H-%M-%S)
			DB_HOST=$1
			DB_PASSWORD=$2
			DB_NAME=$3

			mysqldump -u root -h $DB_HOST -p$DB_PASSWORD  $DB_NAME > /tmp/db-$DATE.sql
			export AWS_ACCESS_KEY_ID=AKIA27AHEVAPPWKBMC6I 
			export AWS_SECRET_ACCESS_KEY=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

		- final /tmp/script.sh

			==============================================================		

			#/bin/bash

			DATE=$(date +%H-%M-%S)
			BACKUP=db-$DATE.sql

			DB_HOST=$1
			DB_PASSWORD=$2
			DB_NAME=$3
			AWS_SECRET=$4
			BUCKET_NAME=$5

			mysqldump -u root -h $DB_HOST -p$DB_PASSWORD $DB_NAME > /tmp/$BACKUP && \
			export AWS_ACCESS_KEY_ID=AKIA27AHEVAPPWKBMC6I && \
			export AWS_SECRET_ACCESS_KEY=$AWS_SECRET && \
			echo "Uploading your $BACKUP backup" && \
			aws s3 cp /tmp/$BACKUP s3://$BUCKET_NAME/$BACKUP

			==============================================================

			$ /tmp/script.sh db_host 1234 testdb E+8+X8pGEhFvp8l0yIz7FwO/jxy2byfRGprYp4zQ jenkins-mysql5.7-backup
			Uploading your db-01-56-49.sql backup
			upload: ./db-01-56-49.sql to s3://jenkins-mysql5.7-backup/db-01-56-49.sql

	- configure mysql db password and aws secret key on jenkins credentials

		- Jenkins Admin -> Credentials
		- Stores scoped to User: Jenkins Admin -> User: Jenkins Admin -> Global credentials (unrestricted)
		- Add Credentials

		- Kind: Secret text
		- ID: MYSQL_PASSWORD
		- Secret: 1234

		- Kind: Secret text
		- ID: AWS_SECRET_KEY
		- Secret: AWS SECRET KEY

	- create a job on jenkins to backup the S3
		- New Item
		- Name: backup-to-aws
		- Freestyle project

		- General
		- Check "This project is parameterised"
		- Add parameters

			- Type: String parameter
			- Name: MYSQL_HOST
			- Default: db_host

			- Type: String parameter
			- Name: DATABASE_NAME
			- Default: testdb

			- Type: String parameter
			- Name: AWS_BUCKET_NAME
			- Default: jenkins-mysql5.7-backup

		- Build Environment
		- Check "Use secret text or file"
		- Add secrets

			- Variable: MYSQL_PASSWORD
			- Credentials: MYSQL_PASWORD

			- Variable: AWS_SECRET_KEY
			- Credentials: AWS_SECRET_KEY

		- Build Steps
			- Add build step: Execute shell script on remote host using ssh
			- SSH site: remote_user@remote_host:22
			- Command: /tmp/script.sh  $MYSQL_HOST $MYSQL_PASSWORD $DATABASE_NAME $AWS_SECRET_KEY $AWS_BUCKET_NAME
			- Click save and run

	- persist the script on the remote host

		- create aws-s3.sh
			$ pwd
			/home/jenkins/jenkins-data

			$ vi aws-s3.sh

			==============================================================		

			#/bin/bash

			DATE=$(date +%H-%M-%S)
			BACKUP=db-$DATE.sql

			DB_HOST=$1
			DB_PASSWORD=$2
			DB_NAME=$3
			AWS_SECRET=$4
			BUCKET_NAME=$5

			mysqldump -u root -h $DB_HOST -p$DB_PASSWORD $DB_NAME > /tmp/$BACKUP && \
			export AWS_ACCESS_KEY_ID=AKIA27AHEVAPPWKBMC6I && \
			export AWS_SECRET_ACCESS_KEY=$AWS_SECRET && \
			echo "Uploading your $BACKUP backup" && \
			aws s3 cp /tmp/$BACKUP s3://$BUCKET_NAME/$BACKUP

			==============================================================

		- give execution permissions to the file
			$ chmod +x aws-s3.sh

		- edit docker-compose.yml
			$ vi docker-compose.yml

			==============================================================

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
			  remote_host:
			    container_name: remote-host
			    image: remote-host
			    build:
			      context: centos7
			    volumes:
			      - "$PWD/aws-s3.sh:/tmp/script.sh"
			    networks:
			      - net
			  db_host:
			    container_name: db
			    image: mysql:5.7
			    environment:
			      - "MYSQL_ROOT_PASSWORD=1234"
			    volumes:
			      - "$PWD/db_data:/var/lib/mysql"
			    networks:
			      - net
			networks:
			  net: 

			==============================================================

		- reload the container
			$ docker-compose up -d

		- run th job on jenkins to test new script file

	- reuse jenkins job to persist on differents DBs to different buckets
		$ docker exec -ti remote-host bash
		
		- create different db on mysql
		$ mysql -u root -h db_host -p1234

		MySQL [(none)]> create database testdb2;
		Query OK, 1 row affected (0.08 sec)

		MySQL [(none)]> show databases;
		+--------------------+
		| Database           |
		+--------------------+
		| information_schema |
		| mysql              |
		| performance_schema |
		| sys                |
		| testdb2            |
		| testdb             |
		+--------------------+
		6 rows in set (0.07 sec)

		- create a second bucket on S#
			Bucket name: jenkins-mysql5.7-backup2

		- change the parameters on the jenkins job and run
			- MYSQL_HOST: db_host
			- DATABASE_NAME: testdb2
			- AWS_BUCKET_NAME: jenkins-mysql5.7-backup2

		- run and success