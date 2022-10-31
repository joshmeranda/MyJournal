# Investigation

While testing the logging implementation for Harvester v1.1.0, it was noticed that the fluentd pods would sometimes be
marked with the `Unknown` status:

```shell
NAMESPACE                   NAME                                                              READY   STATUS              RESTARTS   AGE
cattle-logging-system       rancher-logging-kube-audit-fluentd-configcheck-ac2d4553           0/1     Unknown             0          10m
cattle-logging-system       rancher-logging-root-fluentd-configcheck-ac2d4553                 0/1     Unknown             0          10m
```

Manually testing this is not exactly practical due to the inconsistency of the bug's occurrence, and the amount of time
it takes to install each harvester cluster. Luckily the processes of deploying a harvester cluster and setting up
kubeconfigs is largely automated already, so we should just need a few tweaks.

Note: due to limitations to my current hardware this is testing on only single node (non-HA) Harvester cluster.

## Issues

### Kubeconfig

In order to test for the status of the `fluentd` pods, we need to either

- configure out local system to point to the harvester cluster.
- ssh into the harvester host

I don't really want to deal with copying remote files to the local system, or merging kubeconfig, so we're gonna ssh
into the cluster's host.

### SSH Timing

The harvester launch script will wait until the harvester host is up and is serving on http. We don't really care about
the http for this test, so we are going to launch harvester in the background and start querying it until things go our
way.

```shell
launch-harvester.bash &
ssh rancher@192.168.1.30
```

### SSH Interactive Prompts

There are generally 2 interactive prompts that come up when SSHing into a new machine when not using certs.

The first asking for host authenticity:

```shell
The authenticity of host '192.168.1.30 (192.168.1.30)' can't be established.
ECDSA key fingerprint is SHA256:evRPIRr6PVa4QX8BmkEmdDyRX1IPttVhbV/Pqcczr7Q.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

And the second asking for a password:

```shell
Password:
```

Silencing the password prompt is failry easy using the `sshpass` tool, which passes the given password to the given ssh
command. This works well for `ssh` and `scp`.

Silencing the host authenticity prompt is less straight forward.

My first attempt was to set the `StrictHostKeyChecking` to `no` / `off` but this still resulted in a warning about a man
in the middle attack. Next I tried to remove the host from the `$HOME/.ssh/known_hosts` file using `ssh-keygen -R <ip>
-f $HOME/.ssh/known_hosts`. We still need `StictHostKeyChecking` to be either `accept-new`, `off`, or `no` to prevent
the interactive message from blocking the ssh connection.

### Optimizing

One of the biggest time sinks when launching harvester is waiting for the http server to be ready. For the purposes of
this investigation we don't really care when harvester is "ready". So we can actually disable the https check by editing
the `ipxe-examples/vagrant-pxe-harvestr/ansible/boot_harvester_node.yml` and comment out the relevant section:

```yaml
---
- name: create "Booting Node {{ node_number}}" message
  shell: >
    figlet "Booting Node {{ node_number }}" 2>/dev/null || echo "Booting Node {{ node_number }}"
  register: figlet_result

- name: print "Booting Node {{ node_number }}"
  debug:
    msg: "{{ figlet_result.stdout }}"

- name: set Harvester Node IP fact
  set_fact:
    harvester_node_ip: "{{ harvester_network_config['cluster'][node_number | int]['ip'] }}"

- name: boot Harvester Node {{ node_number }}
  shell: >
    vagrant up harvester-node-{{ node_number }}
  register: harvester_node_boot_result

# disable this check for automated testing
#- name: wait for Harvester Node {{ harvester_node_ip }} to get ready
#  uri:
#    url: "https://{{ harvester_node_ip }}"
#    validate_certs: no
#    status_code: 200
#    timeout: 120
#  register: auth_modes_lookup_result
#  until: auth_modes_lookup_result.status == 200
#  retries: 20
#  delay: 120
```

## Final Design

The final design has 2 parts.

### 1. Ansible

First we will modify the existing ansible tasks by disabling the existing `wait for Harvester Node` task, and replacing
it with a series of tasks that set up and wait for the node to be ready for ssh connections:

```yaml
- name: "clear Harvester Node {{ harvester_node_ip }} from hosts file"
  shell: >
    ssh-keygen -R {{ harvester_node_ip }} -f /$HOME/.ssh/known_hosts

- name: "wait for ssh connection to Harvester Node {{ harvester_node_ip }}"
  shell: >
    sshpass -p password1234 ssh -o ConnectTimeout=10 rancher@{{ harvester_node_ip }} -- exit
  register: boot_harvester_ssh
  retries: 20
  delay: 30
  until: boot_harvester_ssh.rc == 0
```

### 2. Script

In a driver script we will run the ansible script to launch the Harvester node, and send an "unknown status checker"
script to the node via `scp`. This checker script will inform the driver if the relevant pods were ever in an "Unknown"
state, and dump the pod's description and logs. The driver will then fetch these files from the node to be analyzed
later. If no pod was found to be in an "Unknown" state, the script will continue until either the desired state was
found or the maximum amount of attempts exceeded.

## Scripts

- Modified ipxe-examples repo: [joshmeranda/ipxe-examples](https://github.com/joshmeranda/ipxe-examples/tree/inv-2787)
- Driver: [2787-driver.sh](./2787-driver.sh)
- Pod Checker: [check-pods.sh](./check-pods.sh)
