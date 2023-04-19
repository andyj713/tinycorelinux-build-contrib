# mount host shares
#
[ $(which vmware-checkvm) ] && \
[ vmware-checkvm ] && \
[ $(which vmhgfs-fuse) ] && \
[ -d /mnt/hgfs ] && \
vmhgfs-fuse /mnt/hgfs
