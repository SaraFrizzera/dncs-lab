ip link set enp0s8 up
ip addr add 192.168.2.2/23 dev enp0s8

ip route add 192.168.0.0/16 via 192.168.2.1

#installazione docker

apt-get update
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get -qq install docker-ce docker-ce-cli containerd.io

docker pull -q dustnic82/nginx-test
docker run -d -p 80:80 dustnic82/nginx-test
