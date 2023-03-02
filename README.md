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