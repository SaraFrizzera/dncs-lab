# DNCS-LAB

This repository contains the Vagrant files required to run the virtual lab environment used in the DNCS course.
```


        +-----------------------------------------------------+
        |                                                     |
        |                                                     |eth0
        +--+--+                +------------+             +------------+
        |     |                |            |             |            |
        |     |            eth0|            |eth2     eth2|            |
        |     +----------------+  router-1  +-------------+  router-2  |
        |     |                |            |             |            |
        |     |                |            |             |            |
        |  M  |                +------------+             +------------+
        |  A  |                      |eth1                       |eth1
        |  N  |                      |                           |
        |  A  |                      |                           |
        |  G  |                      |                     +-----+----+
        |  E  |                      |eth1                 |          |
        |  M  |            +-------------------+           |          |
        |  E  |        eth0|                   |           |  host-c  |
        |  N  +------------+      SWITCH       |           |          |
        |  T  |            |                   |           |          |
        |     |            +-------------------+           +----------+
        |  V  |               |eth2         |eth3                |eth0
        |  A  |               |             |                    |
        |  G  |               |             |                    |
        |  R  |               |eth1         |eth1                |
        |  A  |        +----------+     +----------+             |
        |  N  |        |          |     |          |             |
        |  T  |    eth0|          |     |          |             |
        |     +--------+  host-a  |     |  host-b  |             |
        |     |        |          |     |          |             |
        |     |        |          |     |          |             |
        ++-+--+        +----------+     +----------+             |
        | |                              |eth0                   |
        | |                              |                       |
        | +------------------------------+                       |
        |                                                        |
        |                                                        |
        +--------------------------------------------------------+



```

# Requirements
 - Python 3
 - 10GB disk storage
 - 2GB free RAM
 - Virtualbox
 - Vagrant (https://www.vagrantup.com)
 - Internet

# How-to
 - Install Virtualbox and Vagrant
 - Clone this repository
`git clone https://github.com/dustnic/dncs-lab`
 - You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
[~/dncs-lab] vagrant up
```
Once you launch the vagrant script, it may take a while for the entire topology to become available.
 - Verify the status of the 4 VMs
 ```
 [dncs-lab]$ vagrant status                                                                                                                                                                
Current machine states:

router                    running (virtualbox)
switch                    running (virtualbox)
host-a                    running (virtualbox)
host-b                    running (virtualbox)
```
- Once all the VMs are running verify you can log into all of them:
`vagrant ssh router`
`vagrant ssh switch`
`vagrant ssh host-a`
`vagrant ssh host-b`
`vagrant ssh host-c`

# Assignment
This section describes the assignment, its requirements and the tasks the student has to complete.
The assignment consists in a simple piece of design work that students have to carry out to satisfy the requirements described below.
The assignment deliverable consists of a Github repository containing:
- the code necessary for the infrastructure to be replicated and instantiated
- an updated README.md file where design decisions and experimental results are illustrated
- an updated answers.yml file containing the details of

## Design Requirements
- Hosts 1-a and 1-b are in two subnets (*Hosts-A* and *Hosts-B*) that must be able to scale up to respectively 273 and 504 usable addresses
- Host 2-c is in a subnet (*Hub*) that needs to accommodate up to 251 usable addresses
- Host 2-c must run a docker image (dustnic82/nginx-test) which implements a web-server that must be reachable from Host-1-a and Host-1-b
- No dynamic routing can be used
- Routes must be as generic as possible
- The lab setup must be portable and executed just by launching the `vagrant up` command

## Tasks
- Fork the Github repository: https://github.com/dustnic/dncs-lab
- Clone the repository
- Run the initiator script (dncs-init). The script generates a custom `answers.yml` file and updates the Readme.md file with specific details automatically generated by the script itself.
  This can be done just once in case the work is being carried out by a group of (<=2) engineers, using the name of the 'squad lead'.
- Implement the design by integrating the necessary commands into the VM startup scripts (create more if necessary)
- Modify the Vagrantfile (if necessary)
- Document the design by expanding this readme file
- Fill the `answers.yml` file where required (make sure that is committed and pushed to your repository)
- Commit the changes and push to your own repository
- Notify the examiner that work is complete specifying the Github repository, First Name, Last Name and Matriculation number. This needs to happen at least 7 days prior an exam registration date.

# Notes and References
- https://rogerdudler.github.io/git-guide/
- http://therandomsecurityguy.com/openvswitch-cheat-sheet/
- https://www.cyberciti.biz/faq/howto-linux-configuring-default-route-with-ipcommand/
- https://www.vagrantup.com/intro/getting-started/


# Design
## Subnets

The IP addresses assigned are chosen following the requirements specified in the answers.yml file. The class of IP addresses used is 192.168.0.0/16:

    "Host-A" must scale up to 273 usable addresses, it contains Host-A and 237 other hosts + router-1 port eth1
    "Host-B" must scale up to 504 usable addresses, it contains Host-B and 6 other hosts + router-1 port eth1
    "Host-C" must scale up to 251 usable addresses, it contains Host-C and 3 other hosts + router-2 eth1
    "Router" must have 2 addresses for router-1 eth2 port and router-2 eth2 port  


| Device       | Network       | Subnet              |  Broadcast    | Hosts | Host-min      | Host-max      |
|--------------|---------------|---------------------|---------------|-------|---------------|---------------|
| Host-a       | 192.168.2.0   | 255.255.254.0 - /23 | 192.168.3.255 | 510   | 192.168.2.1 	 | 192.168.2.254 |
| Host-b       | 192.168.3.0   | 255.255.254.0 - /23 | 192.168.3.255 | 510   | 192.168.3.1   | 192.168.3.254 |
| Host-c       | 192.168.1.0   | 255.255.255.0 - /24 | 192.168.1.255 | 254   | 192.168.1.1   | 192.168.1.254 |
| Router       | 10.0.0.4      | 255.255.255.252 -/30| 10.0.0.7      | 2     | 10.0.0.5      | 10.0.0.6      |

## VLANs

| Subnet | Interface |   Host   | Vlan tag |     IP      |
|:------:|:---------:|:--------:|:--------:|:-----------:|
|    A   | eth1.10   | router-1 |    10    | 192.168.2.1 |
|    C   | eth1.20   | router-1 |    20    | 192.168.1.1 |

## Network map configured with IPs

|   Host   | Interface | VLAN tag |  IP address  |             Description             |
|:--------:|:---------:|:--------:|:------------:|:-----------------------------------:|
| router-1 | eth1.10   |    10    |  192.168.2.1 |    Default gateway for network A    |   
|          | eth1.20   |    20    |  192.168.1.1 |    Default gateway for network C    |   
|          |   eth2    |   None   |  10.0.0.5    |           Link to router-2          |   
|  host-a  |   eth1    |   None   |  192.168.2.2 | Link with access port on the switch |   
|  host-b  |   eth1    |   None   |  192.168.3.1 | Link with access port on the switch |   
| router-2 |   eth2    |   None   |  10.0.0.6    |          Link to router-1           |   
|          |   eth1    |   None   |  192.168.1.2 |            Link to host-c           |   
|  host-c  |   eth1    |   None   |  192.168.1.3 |           Link to router-2          |   


        +----------------------------------------------------------------------+
        |                                                                      |
        |                                                                      |eth0
        +--+--+                  +------------+                          +------------+
        |     |                  |            |                          |            |
        |     |            eth0  |            |eth2                eth2  |            |
        |     +------------------+  router-1  +--------------------------+  router-2  |
        |     |                  |            |.5                      .6|            |
        |     |                  |            |      172.16.3.64/30      |            |
        |  M  |                  +------------+                          +------------+
        |  A  |          192.168.2.1/23 |eth1.10                        eth1   |.2
        |  N  |          192.168.1.1/23 |eth1.20                               |
        |  A  |                         |                                      |     
        |  G  |                         |                       192.168.1.3/24 |
        |  E  |                         |eth1                           eth1   |.3
        |  M  |            +--------------------------+                  +-----+----+
        |  E  |     eth0   |          TRUNK           |                  |          |
        |  N  +------------+         SWITCH           |                  |          |
        |  T  |            |  10                   20 |                  |  host-c  |
        |     |            +--------------------------+                  |          |
        |  V  |               |eth1.10             |eth1.20              |          |
        |  A  |               |                    |                     +----------+
        |  G  |               |                    |                           |eth0
        |  R  |               | 192.168.2.2/23     | 192.168.3.1/23            |
        |  A  |               | eth1               |eth1                       |
        |  N  |         +----------+           +----------+                    |
        |  T  |         |          |           |          |                    |
        |     |  eth0   |          |           |          |                    |
        |     +---------+  host-a  |           |  host-b  |                    |
        |     |         |          |           |          |                    |
        |     |         |          |           |          |                    |
        ++-+--+         +----------+           +----------+                    |
        | |                                        |eth0                       |
        | |                                        |                           |
        | +----------------------------------------+                           |
        |                                                                      |
        |                                                                      |
        +----------------------------------------------------------------------+


 
