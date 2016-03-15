#!/bin/bash

set -e
set -x

netjoin_root_dir=$(cd $(dirname ${BASH_SOURCE[0]}); cd ../; pwd)
kvm_dir=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)


node_name=$1
kvm_disk_size=$2
kvm_memory_size=$3

seed_image_path="${netjoin_root_dir}/seed"
kvm_image_path="${kvm_dir}/${node_name}.raw"

if [ ! -e ${seed_image_path} ]; then
  echo '[ERROR]: need to download seed file'
  exit -1
fi

cd ${kvm_dir}

if [ ! -e ${kvm_image_path} ]; then
  tar xzf ${seed_image_path}
  mv `ls ${kvm_dir}/*.raw` ${kvm_image_path}
  qemu-img resize ${kvm_image_path} +${kvm_disk_size}G

  parted --script -- ${kvm_image_path} rm 2
  parted --script -- ${kvm_image_path} rm 1
  parted --script -- ${kvm_image_path} mkpart primary ext4 63s 100%
fi

mkdir -p ${kvm_dir}/mnt || :
mount -o loop,offset=32256 ${kvm_image_path} ${kvm_dir}/mnt

rsync -aHA ${kvm_dir}/rootfs/ ${kvm_dir}/mnt/

cat >> ${kvm_dir}/mnt/etc/rc.d/rc.local <<EOF
if [ ! -e /root/firstbooted ]; then
  /root/firstboot.sh
fi
touch /root/firstbooted
EOF

umount ${kvm_dir}/mnt

i=0
nic_options=""
for mac in `cat macaddress`; do
  nic_options="${nic_options} -netdev tap,ifname=${node_name}-eth${i},id=hostnet${i},script=,downscript="
  nic_options="${nic_options} -device virtio-net-pci,netdev=hostnet${i},mac=${mac},bus=pci.0,addr=0x$((${i}+3))"
  i=$((${i}+1))
done
nic_options="${nic_options} \\"

cat > ${kvm_dir}/run.sh <<EOF
#!/bin/bash

name=${node_name}
num=`shuf -i 10-99 -n 1`
kvm_cmd=/usr/libexec/qemu-kvm
memory=${kvm_memory_size}

bridge_internal='brint'
bridge_global='brglo'

eth0=${node_name}-eth0
eth1=${node_name}-eth1

\${kvm_cmd} \\
  -name \${name} -cpu qemu64,+vmx -m \${memory} -smp 1 \\
  -vnc 127.0.0.1:110\${num} -k en-us -rtc base=utc \\
  -monitor telnet:127.0.0.1:140\${num},server,nowait \\
  -serial telnet:127.0.0.1:150\${num},server,nowait \\
  -serial file:console.log \\
  -drive file=./\${name}.raw,media=disk,boot=on,index=0,cache=none,if=virtio \\
  ${nic_options}
  -pidfile kvm.pid -daemonize -enable-kvm

i=0
for bridge in \`cat bridge\`; do
  brctl addif \${bridge} \${name}-eth\${i}
  ip link set \${name}-eth\${i} up
  i=\$((\${i}+1))
done
EOF

chmod +x ${kvm_dir}/run.sh
${kvm_dir}/run.sh
