### make sure your setup correct variable to assign which role / task you would like to run

### 1st of all if the VM is brand new, you might want to run /test/vagrant/elk.sh
```
sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update -y
sudo apt-get install ansible git -y
sudo su <your username>
ssh-keygen -t rsa -b 4096 -f /home/<your username>/.ssh/id_rsa -C "<your username>@<your server name>" -q -N ""
cat /home/<your username>/.ssh/id_rsa.pub >> /home/<your username>/.ssh/authorized_keys
sudo chown <your username>:<your username> /home/<your username>/.ssh/id_rsa.pub
sudo chown <your username>:<your username> /home/<your username>/.ssh/id_rsa
```

### git clone repo
```
under /home/<your username>
$ git clone https://github.com/swiftstack/ansible-elk.git
```

### update `hosts` file to put <your username> in and update `192.168.22.201` to your VM IP address.
```
[all:vars]
elastic_repo='deb https://artifacts.elastic.co/packages/6.x/apt stable main'
caddy_source='https://caddyserver.com/download/linux/amd64?license=personal'
caddy_download='/home/<your username>/ansible-elk/elk/roles/elk-server/files/installers'
caddy_tarzip='caddy_linux_amd64_personal.tar.gz'
logstash_patterns_symlink='/usr/share/logstash/vendor/bundle/jruby/2.3.0/gems/logstash-patterns-core-4.1.2/patterns'
[hosts]
192.168.22.201
```

### update main.yaml file to put <your username> instead of ubuntu
from
```
---
- hosts: all
  remote_user: ubuntu
```
to
```
---
- hosts: all
  remote_user: <your username>
```


#### update local variable *roles/elk-server/vars/main.yam/* for which task you would like to run
##### e.g. run setup server and configure server only
```
# elk: 6.2.0
elk_server_task_run: elk-server			# setup elk server when your elk server has internet connectivity
elk_server_setup: true

elk_server_config_run: elk-config		# you have elk server and want to sync with grok pattern only
elk_server_configuration: true

elk_server_grok_run: elk-grok			# refresh grok pattern only
```

### PS: command with username and password `ansible_sudo_pass=<yourPassword>`
```
ansible-playbook -i hosts main.yaml -e "elk_role=elk-server" --user=<yourUsername> --extra-vars "ansible_sudo_pass=<yourPassword>" -vvvv
```
