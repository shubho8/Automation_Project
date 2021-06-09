sudo apt update -y

name="shubho"
s3bucket="upgrad-shubho"

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


{

file=/var/www/html/inventory.html
if [ -f "$file" ]; then
    cat {
    echo "<tbody>"
    echo "<tr>"
    echo "<td>awk '{print $2}' /var/log/apache2/*.log</td>"
    echo "<td>awk '{print $4,$5}' /var/log/apache2/*.log</td>"
    echo "<td>awk '{print $9}' /var/log/apache2/*.log</td>"
    echo "<td>awk '{print $10}' /var/log/apache2/*.log</td>"
    echo "<tr>"
    echo "</tbody>"
    } >> $file
else 
    touch $file
    {
    echo "<html>"
    echo "<table>"
    echo "<thead>"
    echo "<th>Log Type</th>"
    echo "<th>Time Created</th>"
    echo "<th>Type</th>"
    echo "<th><Size</th>"
    echo "</thead>"
    }>> $file
fi


if [ `id -u` -ne 0 ]; then
      echo "This script can be executed only as root, Exiting.."
      exit 1
else
  cron_file="/etc/cron.d/automation"

	if [ ! -f $cron_file ]; then
	   echo "cron file for root doesnot exist, creating.."
	   touch $cron_file

    grep -qi "cleanup_script" $CRON_FILE
	if [ $? != 0 ]; then
	   * * * * * root /root/Automation_Project/automation.sh
	fi
	fi
fi