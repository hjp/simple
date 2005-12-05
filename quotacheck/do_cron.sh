#!/bin/sh

/usr/local/sbin/quotastat
/usr/local/sbin/quotacheck
find /usr/local/dfstat/quotacheck-timestamps -type f -name '*:*' -print |  sed -e 's/.*\///' -e 's/:/ /' |
while read user mount_t
do
    mount=`echo $mount_t | sed -e 's/_/\//'`
    "/usr/local/dfstat/quotagraph" "--fs=$mount" "--user=$user" "--data=b" /usr/local/dfstat/quota.stat.????-??
    @@@scp@@@ /usr/local/www//wsr/intranet/quotas/$user$mount_t.gif "intra.wsr.ac.at:/usr/local/www/intra/informationssysteme/quotas/$user$mount_t.gif"
done
