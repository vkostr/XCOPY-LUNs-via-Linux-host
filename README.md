# XCOPY-LUNs-via-Linux-host
Purpose of this script is to copy one LUN/snap to another on single InfiniBox via XCOPY on the array. The reason is that we cannot promote snapshot to separate LUN now, but via XCOPY from the host, we can do this.

ddpt description
http://sg.danny.cz/sg/ddpt.html

Run example

root@sales-demo-05:/home/vasilyk# blockdev --getsz /dev/mapper/mpathfs
2516582400
root@sales-demo-05:/home/vasilyk# blockdev --getsz /dev/mapper/mpathfr
2516582400
root@sales-demo-05:/home/vasilyk# mount /dev/mapper/mpathfs /xcopy_source/
mount: /xcopy_source: wrong fs type, bad option, bad superblock on /dev/mapper/mpathfs, missing codepage or helper program, or other error.
root@sales-demo-05:/home/vasilyk# mkfs /dev/mapper/mpathfs
mke2fs 1.44.1 (24-Mar-2018)
Discarding device blocks: done
Creating filesystem with 314572800 4k blocks and 78643200 inodes
Filesystem UUID: bed3ea00-c181-4b4e-b52e-d9bb498be756
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968,
        102400000, 214990848

Allocating group tables: done
Writing inode tables: done
Writing superblocks and filesystem accounting information: done

root@sales-demo-05:/home/vasilyk# mount /dev/mapper/mpathfs /xcopy_source/
root@sales-demo-05:/home/vasilyk# ls -l /xcopy_source/
total 16
drwx------ 2 root root 16384 Aug 19 15:35 lost+found
root@sales-demo-05:/home/vasilyk# head -c 1T </dev/urandom > /xcopy_source/1TB_file
root@sales-demo-05:/home/vasilyk# ls -l /xcopy_source/
total 1074791444
-rw-r--r-- 1 root root 1099511627776 Aug 19 17:25 1TB_file
drwx------ 2 root root         16384 Aug 19 15:35 lost+found
root@sales-demo-05:/home/vasilyk# umount /xcopy_source
root@sales-demo-05:/home/vasilyk# mount /dev/mapper/mpathfr /xcopy_dest/
mount: /xcopy_dest: wrong fs type, bad option, bad superblock on /dev/mapper/mpathfr, missing codepage or helper program, or other error.
root@sales-demo-05:/home/vasilyk# cat xcopy.sh
#!/bin/bash
# first parameter = input device
# second parameter = output device
# device size must be the same
# changing bs variable can reduce speed, max speed should be at bs=32768. 32768 is max setting, lower settings should be calculated dividing by 2

bs=32768
s=`blockdev --getsz $1`
i=0
while [ $i -le $s ]
do
ddpt of=$2 bs=512 oflag=xcopy,direct if=$1 iflag=xcopy,direct count=$bs verbose=-1 skip=$i seek=$i
i=$(( $i+$bs ))
done
root@sales-demo-05:/home/vasilyk# time ./xcopy.sh /dev/mapper/mpathfs /dev/mapper/mpathfr
real    11m30.878s
user    2m3.000s
sys     1m11.657s
root@sales-demo-05:/home/vasilyk# mount /dev/mapper/mpathfr /xcopy_dest/
root@sales-demo-05:/home/vasilyk# ls -l /xcopy_dest/
total 1074791444
-rw-r--r-- 1 root root 1099511627776 Aug 19 17:25 1TB_file
drwx------ 2 root root         16384 Aug 19 15:35 lost+found
root@sales-demo-05:/home/vasilyk# mount /dev/mapper/mpathfs /xcopy_source/
root@sales-demo-05:/home/vasilyk# md5sum /xcopy_source/1TB_file
53dc6dfdfc89f099c0d5177c652b5764  /xcopy_source/1TB_file
root@sales-demo-05:/home/vasilyk# md5sum /xcopy_dest/1TB_file
53dc6dfdfc89f099c0d5177c652b5764  /xcopy_dest/1TB_file
root@sales-demo-05:/home/vasilyk#
