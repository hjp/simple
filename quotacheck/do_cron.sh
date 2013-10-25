#!/bin/sh

unset PERL_UNICODE

ts_dir=/usr/local/dfstat/quotacheck-timestamps

/usr/local/sbin/quotastat
/usr/local/sbin/quotacheck

find $ts_dir -type f -name '*:*:*' -mtime +60 -exec rm {} \;

find $ts_dir -type f -name '*:*:*' -print |  sed -e 's/.*\///' -e 's/:/ /g' |
while read user mount_t data
do
    g="/usr/local/dfstat/quotacheck-graphs/$user${mount_t}_$data.png"
    mount=`echo $mount_t | sed -e 's/_/\//g'`
    "/usr/local/dfstat/quotagraph" "--fs=$mount" "--user=$user" "--data=$data" /usr/local/dfstat/quota.stat.????-?? > "$g"
    @@@scp@@@ "$g" \
	"intra.wsr.ac.at:/usr/local/www/intra/informationssysteme/quotas/$user${mount_t}_$data.png"
done
find /usr/local/dfstat/quotacheck-graphs/ -atime +60 -exec rm {} \;
