name="shubho"
s3bucket="upgrad-shubho"

sudo apt update -y

dpkg --get-selections | grep apache
if [ $? -eq 0 ]; then
  echo "Process is running."
 else
  sudo apt update
  sudo apt install apache2
  sudo service apache2 start
 fi

sudo systemctl restart apache2

cd /var/log/apache2/
tarfile="Shubho-httpd-logs-`date +%d%m%Y-%H%M%S`.tar"
tar cvf ${tarfile} *.log
mv ${tarfile} /tmp/

aws s3 cp Shubho-httpd-logs-`date +%d%m%Y-%H%M%S`.tar s3://'$s3bucket'/