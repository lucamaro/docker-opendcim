# docker-opendcim

**This is based on work of angelrr7702**

Docker container for [Opendcim][3] v.4.3

"This is openDCIM, a free, web based Data Center Infrastructure Management application. " "openDCIM does not contend to be a function by function replacement for commercial applications. Instead, openDCIM covers the majority of features needed by the developers - as is often the case of open source software. The software is released under the GPL v3 license, so you are welcome to take it, modify it, and share it with others, as long as you acknowledge where it came from."


## Install dependencies

  - [Docker][2]

To install docker in Ubuntu 15.04 use the commands:

    $ sudo apt-get update
    $ wget -qO- https://get.docker.com/ | sh

 To install docker in other operating systems check [docker online documentation][4]

## Usage

To build container, customize DBPASS variable in Makefile, then use the command below:

    $ make build
    
To run container use the command below:

    $ make run


## Accessing the opendcim applications:

After that check with your browser at addresses:

  - **http://host_ip/**

Log in using login/password dcim/dcim  please replace it after initial web install with command :

    $ make after-install
    
This will ask for new password for dcim user and it will remove the install script for security.

To access the container from the server that the container is running :

    $ docker exec -it dcim /bin/bash
    $ docker exec -it dcimdb /bin/bash

note: deploy this container behind proxy with SSL :

https://github.com/jwilder/nginx-proxy

https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion

## More Info

About Opendcim: [www.opendcim.org][1]

To help improve this container [docker-opendcim][5]

Example of this [docker-opendcim][6]

For additional info about us and our projects check our site [www.quantumobject.org][7]

[1]:http://www.opendcim.org
[2]:https://www.docker.com
[3]:http://www.opendcim.org/downloads.html
[4]:http://docs.docker.com
[5]:https://github.com/QuantumObject/docker-opendcim
[6]:https://www.quantumobject.com:32769
[7]:https://www.quantumobject.org/
