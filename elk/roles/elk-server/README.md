## make sure your ansible version is higher than 2.2.x for supporting systemd
```
$ sudo apt-get install software-properties-common
$ sudo apt-add-repository ppa:ansible/ansible
$ sudo apt-get update
$ sudo apt-get install ansible
```

## download all the required deb into ./file/installers, if you have higher elk version such as 5.6 ... etc, please manual download it or just use non-dpkg one
```
$ wget https://artifacts.elastic.co/downloads/logstash/logstash-5.5.0.deb
$ wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.5.0.deb
$ wget https://artifacts.elastic.co/downloads/kibana/kibana-5.5.0-amd64.deb
```
#### ps: caddy need to download on your client ( mac or windows ) from caddy's website
```
https://caddyserver.com/download

remember choose your platform
```

## double check first secion
```
- name: ELK server deployment
  hosts: localhost
  remote_user: ss
  become: yes
  become_method: sudo

  vars:
    cert_hostname: elk-swift

```

## double check your deb/tar.gz(caddy) version if you are using elk-server-dpkg.yml this playbook
```
  - name: Install Elasticsearch
    apt:
      deb: /root/installers/elasticsearch-5.5.0.deb

  - name: Install Logstash
    apt:
      deb: /root/installers/logstash-5.5.0.deb

  - name: Install Kibana
    apt:
      deb: /root/installers/kibana-5.5.0-amd64.deb

  - name: Untar Caddy tarball on remote host
    unarchive:
      src: files/installers/caddy_v0.10.4_linux_amd64.tar.gz
      dest: /tmp

```

## modify ./files/config/caddy/Caddyfile make sure host ip, and name matching your node
```
http://192.168.201.239 {
  proxy / localhost:5601

  gzip

  tls off #tls example@example.com #Your email for Let's Encrypt Verification

  #log /var/log/caddy/access.log
}

http://elk-swift {
  proxy / localhost:5601

  gzip

  tls off #tls example@example.com #Your email for Let's Encrypt Verification

  #log /var/log/caddy/access.log
}
```

## run ansible playbook, using run at localhost as example
```
$ sudo ansible-playbook -i "localhost," -c local elk-server-dpkg.yml
```

## after setup you might run configure playbook but you have to double check in elk-config.yml
```
double confirm your elk IP address
vars:
  cert_ip: 192.168.201.239


double confirm your default grok patterns location in src:
- name: create symlink for patterns
  file:
    src: /usr/share/logstash/vendor/bundle/jruby/1.9/gems/logstash-patterns-core-4.1.1/patterns
    dest: /etc/logstash/patterns
    state: link
```
## run ansible config playbook, using run at localhost as example
```
$ sudo ansible-playbook -i "localhost," -c local elk-config.yml
```

#### here is the example ansible output

##### installation yml example
```
$ hostname
elk-log-replay

$ cat elk-server-dpkg.yml
---
#
# Deploying ELK stack server using .deb files
#

- name: ELK server deployment
  hosts: elk-log-replay
  remote_user: ss
  become: yes
  become_method: sudo

  vars:
    cert_hostname: elk-log-replay

  tasks:

  ### INSTALL DEPENDENCIES

  - name: Install dependencies and utilities
    apt:
      name: "{{item}}"
      state: present
    with_items:
      - aptitude
      - software-properties-common
      - apt-transport-https
      - language-pack-en
      - python-pip
      - vim
      - wget
      - curl
      - screen
      - zip
      - unzip
      - apache2-utils
      - python-passlib
      - default-jdk

  - name: Create directory for installer files
    file:
      path: /root/installers
      state: directory
      mode: 0755
      owner: root
      group: root

  - name: Copy all installers to target machine
    copy:
      src: files/installers/
      dest: /root/installers
      mode: 0755
      owner: root
      group: root

  ### INSTALL ELASTICSEARCH

  - name: Install Elasticsearch
    apt:
      deb: /root/installers/elasticsearch-5.5.2.deb

  - name: Start Elasticsearch on boot
    systemd:
      name: elasticsearch
      enabled: yes
      masked: no

  - name: Restart Elasticsearch
    service:
      name: elasticsearch
      state: restarted

  ### INSTALL LOGSTASH

  - name: Install Logstash
    apt:
      deb: /root/installers/logstash-5.5.2.deb

  - name: Start Logstash on boot
    systemd:
      name: logstash
      enabled: yes
      masked: no

  - name: Restart Logstash
    service:
      name: logstash
      state: restarted

  ### INSTALL KIBANA

  - name: Install Kibana
    apt:
      deb: /root/installers/kibana-5.5.2-amd64.deb

  - name: Start Kibana on boot
    systemd:
      name: kibana
      enabled: yes
      masked: no

  - name: Restart Kibana
    service:
      name: kibana
      state: restarted

  ### INSTALL CADDY SERVER

  - name: Untar Caddy tarball on remote host
    unarchive:
      src: files/installers/caddy_v0.10.6_linux_amd64.tar.gz
      dest: /tmp

  - name: Install Caddy Server
    copy:
      remote_src: True
      src: /tmp/caddy
      dest: /usr/local/bin/caddy
      mode: 0755
      owner: root
      group: root

  - name: Allow Caddy to bind to privileged ports (80, 443) as non-root user
    command: setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy
    become: true
    become_user: root

  - name: Set up Caddy directory
    file:
      path: /etc/caddy
      state: directory
      mode: 0755
      owner: root
      group: www-data

  - name: Set up SSL directory for Caddy
    file:
      path: /etc/ssl/caddy
      state: directory
      mode: 0770
      owner: www-data
      group: root

  - name: Put Caddyfile w/ reverse proxy config in place
    copy:
      src: files/config/caddy/Caddyfile
      dest: /etc/caddy/Caddyfile
      mode: 0444
      owner: www-data
      group: www-data

  - name: Create Caddy log directory
    file:
      path: /var/log/caddy
      state: directory
      owner: www-data
      group: root

  - name: Install systemd definition for Caddy
    copy:
      remote_src: True
      src: /tmp/init/linux-systemd/caddy.service
      dest: /etc/systemd/system/caddy.service
      mode: 0644
      owner: root
      group: root

  - name: Force systemd daemon reload
    systemd:
      name: caddy
      daemon_reload: yes

  - name: Start Caddy on boot
    systemd:
      name: caddy
      enabled: yes
      masked: no

  - name: Restart Caddy
    service:
      name: caddy
      state: restarted
```

##### installation
```
$ sudo ansible-playbook -i "elk-log-replay," -c local elk-server-dpkg.yml

PLAY [ELK server deployment] **************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************
ok: [elk-log-replay]

TASK [Install dependencies and utilities] *************************************************************************************************************************************************
changed: [elk-log-replay] => (item=[u'aptitude', u'software-properties-common', u'apt-transport-https', u'language-pack-en', u'python-pip', u'vim', u'wget', u'curl', u'screen', u'zip', u'unzip', u'apache2-utils', u'python-passlib', u'default-jdk'])

TASK [Create directory for installer files] ***********************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Copy all installers to target machine] **********************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Install Elasticsearch] **************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Start Elasticsearch on boot] ********************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Restart Elasticsearch] **************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Install Logstash] *******************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Start Logstash on boot] *************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Restart Logstash] *******************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Install Kibana] *********************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Start Kibana on boot] ***************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Restart Kibana] *********************************************************************************************************************************************************************
changed: [elk-log-replay]



---
TASK [Untar Caddy tarball on remote host] *************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Install Caddy Server] ***************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Allow Caddy to bind to privileged ports (80, 443) as non-root user] *****************************************************************************************************************
changed: [elk-log-replay]

TASK [Set up Caddy directory] *************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Set up SSL directory for Caddy] *****************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Put Caddyfile w/ reverse proxy config in place] *************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Create Caddy log directory] *********************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Install systemd definition for Caddy] ***********************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Force systemd daemon reload] ********************************************************************************************************************************************************
ok: [elk-log-replay]

TASK [Start Caddy on boot] ****************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Restart Caddy] **********************************************************************************************************************************************************************
changed: [elk-log-replay]

PLAY RECAP ********************************************************************************************************************************************************************************
elk-log-replay             : ok=24   changed=22   unreachable=0    failed=0
```

##### configuration
```
$ sudo ansible-playbook -i "elk-log-replay," -c local elk-config.yml

PLAY [all] ********************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************
ok: [elk-log-replay]

TASK [git] ********************************************************************************************************************************************************************************
fatal: [elk-log-replay]: FAILED! => {"before": "f27386e00ecf739cc0063a6c336f005b57f26725", "changed": false, "failed": true, "msg": "Local modifications exist in repository (force=no)."}
	to retry, use: --limit @/tmp/elk-swift/ansible/playbooks/elk/elk-config.retry

PLAY RECAP ********************************************************************************************************************************************************************************
elk-log-replay             : ok=1    changed=0    unreachable=0    failed=1

$ sudo ansible-playbook -i "elk-log-replay," -c local elk-config.yml

PLAY [all] ********************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************
ok: [elk-log-replay]

TASK [git] ********************************************************************************************************************************************************************************
Username for 'https://github.com': chianingwang
Password for 'https://chianingwang@github.com':
changed: [elk-log-replay]

TASK [copy logstash.yml] ******************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Ensures /etc/logstash/extra_patterns/ dir exists] ***********************************************************************************************************************************
changed: [elk-log-replay]

TASK [copy extra_patterns/swift] **********************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Ensures /etc/logstash/conf.d/ dir exists] *******************************************************************************************************************************************
ok: [elk-log-replay]

TASK [copy conf.d/*] **********************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [create symlink for patterns] ********************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Restart logstash] *******************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [copy elasticsearch/elasticsearch.yml] ***********************************************************************************************************************************************
changed: [elk-log-replay]

TASK [uncomment line in elasticsearch.yml with cert_ip] ***********************************************************************************************************************************
changed: [elk-log-replay]

TASK [Restart elasticsearch] **************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [copy kibana/kibana.yml] *************************************************************************************************************************************************************
changed: [elk-log-replay]

TASK [uncomment line in kibana.yml with cert_ip] ******************************************************************************************************************************************
changed: [elk-log-replay]

TASK [Restart kibana] *********************************************************************************************************************************************************************
changed: [elk-log-replay]

PLAY RECAP ********************************************************************************************************************************************************************************
elk-log-replay             : ok=15   changed=13   unreachable=0    failed=0
```
