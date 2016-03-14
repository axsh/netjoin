#!/bin/bash

set -e
set -x

netjoin_root_dir=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)

if [ ! -e ${netjoin_root_dir}/seed ]; then
  curl -L https://www.dropbox.com/s/dyg2nkeeg07uu0a/centos-6.7-minimum.tar.gz?dl=0 -o ${netjoin_root_dir}/seed
fi
