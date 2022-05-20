# install pssh as needed
sudo yum install pssh
# copy
pscp -A -h hostnames.txt -l username -pw password filename.ext /tmp -p 5 -e /tmp