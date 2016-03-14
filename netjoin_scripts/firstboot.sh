#!/bin/bash

for i in `find / -maxdepth 1 -mindepth 1 -name "*.sh"`; do
  ${i} | tee -a /root/firstboot.log
done
