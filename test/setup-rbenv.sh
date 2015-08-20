#!/bin/bash

set -e
set -o pipefail
set -x


until curl -fSkL -o /tmp/dot.rbenv.tar.gz http://dlc2.wakame.axsh.jp/wakameci/kemumaki-box-rhel6/current/dot.rbenv.tar.gz; do
  sleep 1
done

rm -rf ${HOME}/.rbenv
tar zxf /tmp/dot.rbenv.tar.gz -C ${HOME}/
rm /tmp/dot.rbenv.tar.gz

sudo mkdir -p /var/lib/jenkins
sudo rm -rf /var/lib/jenkins/.rbenv
sudo ln -fs ${HOME}/.rbenv /var/lib/jenkins/

if ! [[ -f ${HOME}/.bash_profile.saved ]]; then
  mv -i ${HOME}/.bash_profile{,.saved}
fi
cp -p ${HOME}/.bash_profile{.saved,}

{
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"'
  echo 'eval "$(rbenv init -)"'
} >> ${HOME}/.bash_profile

source ${HOME}/.bash_profile
rbenv --version

rbenv local 2.1.1
rbenv local
rbenv exec gem list
rbenv exec gem install bundle --no-ri --no-rdoc
rbenv exec gem list

#
sudo yum -y install libxml2 libxml2-devel libxslt1-devel
