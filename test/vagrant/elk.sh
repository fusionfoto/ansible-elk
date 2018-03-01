sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update -y
sudo apt-get install ansible git -y
sudo su ubuntu
ssh-keygen -t rsa -b 4096 -f /home/ubuntu/.ssh/id_rsa -C "ubuntu@elk" -q -N ""
cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa.pub
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa
