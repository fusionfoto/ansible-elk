### make sure your setup correct variable to assign which role / task you would like to run

### Spin up a test VM ( if you have a ubuntu VM or bare metal, then you can skip this )
```
$ cd test/vagrant

$ vagrant up
then
$ vagrant ssh elk
```

### preparation
```
ubuntu@elk:~$ cd git/

ubuntu@elk:~/git$ git clone https://github.com/swiftstack/ansible-elk.git
Cloning into 'ansible-elk'...
remote: Counting objects: 121, done.
remote: Compressing objects: 100% (13/13), done.
remote: Total 121 (delta 1), reused 11 (delta 1), pack-reused 106
Receiving objects: 100% (121/121), 50.83 KiB | 0 bytes/s, done.
Resolving deltas: 100% (21/21), done.
Checking connectivity... done.

ubuntu@elk:~/git$ cd ansible-elk/elk
```

#### update global variable *./hosts* under the root folder for which role you would like to run
##### e.g.
```
[all:vars]
#elk_role=elk-server
#elk_role=elk-ssnode
#elastic_repo='deb https://artifacts.elastic.co/packages/5.x/apt stable main'
elastic_repo='deb https://artifacts.elastic.co/packages/6.x/apt stable main'
caddy_source='https://caddyserver.com/download/linux/amd64?license=personal'
caddy_download='/home/ubuntu/git/ansible-elk/elk/roles/elk-server/files/installers'
caddy_tarzip='caddy_linux_amd64_personal.tar.gz'
#logstash_patterns_symlink='/usr/share/logstash/vendor/bundle/jruby/1.9/gems/logstash-patterns-core-4.1.1/patterns'
logstash_patterns_symlink='/usr/share/logstash/vendor/bundle/jruby/2.3.0/gems/logstash-patterns-core-4.1.2/patterns'
[hosts]
192.168.22.201
```

#### update local variable *./role/rolefolder/vars/main.yaml* for which task you would like to run e.g setup + configuration
##### e.g. i want to setup elk server
```
# elk: 6.2.0
elk_server_task_run: elk-server			    # setup elk server when your elk server has internet connectivity
elk_server_setup: true
#elk_server_task_run: elk-server-dpkg		# setup elk server from downloaded packages if your VM doesn't have internet connection

elk_server_config_run: elk-config			# you have elk server and want to sync with grok pattern only
elk_server_configuration: true
```


### install elk + rsyslog receiver
```
$ ansible-playbook -i hosts main.yaml -e "elk_role=elk-server"
or debug mode -vvvv or --check
$ ansible-playbook -i hosts main.yaml -e "elk_role=elk-server" -v
```

#### update `elk/roles/elk-server/vars/main.yaml` for update grok pattern only ( configuration only )
```
# elk: 6.2.0
elk_server_task_run: elk-server			    # setup elk server when your elk server has internet connectivity
elk_server_setup: false                     # skip setup server
#elk_server_task_run: elk-server-dpkg		# setup elk server from downloaded packages if your VM doesn't have internet connection

elk_server_config_run: elk-config			# you have elk server and want to sync with grok pattern only
elk_server_configuration: true              # reload grok pattern only and restart logstash
```

### install install grok pattern
```
$ ansible-playbook -i hosts main.yaml -e "elk_role=elk-server"
or debug mode -vvvv or -check
$ ansible-playbook -i hosts main.yaml -e "elk_role=elk-server" -v
```
