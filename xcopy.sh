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
