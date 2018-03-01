### make sure your setup correct variable to assign which role / task you would like to run

```
$ ansible-playbook -i hosts main.yaml -e "elk_role=elk-ssnode"
or debug mode -vvvv or -check
# ansible-playbook -i hosts main.yaml -e "elk_role=elk-ssnode" -v
```

#### update global variable *./hosts* under the root folder for which role you would like to run
##### e.g.
```
[all:vars]
elk_role=elk-ssnode
```

#### update local variable *./role/rolefolder/vars/main.yaml* for which task you would like to run
##### e.g.
```
elk-server-run: elk-config.yml
```
