ssh remote_user@remote_host
exit
cd /tmp/
ls
ssh -i remote-key remote_user@remote_host
exit
cd
cd ansible/
ansible -i hosts -m ping test1
cd /home/jenkins/jenkins-data/jenkins-ansible
exit
cd && cd ansible/
ansible-playbook -i hosts play.yml
exit
ssh web
cd ansible
ls
pwd
cd
pwd
ls
cd ansible/
ansible -m ping -i hosts web1
exit
ls
cd home/
ls
cd ..
cd
ls
eixt
exit
ls
cd tmp/
ls
cd ..
cd
ls
cd ansible/
ls
ansible-playbook i hosts people.yml
ansible-playbook -i hosts people.yml
exit
cd 
cd ansible/
ls
ansible-playbook -i hosts people.yml
ansible-playbook -i hosts people.yml -e "PEOPLE_AGE=25"
pwd
exit
