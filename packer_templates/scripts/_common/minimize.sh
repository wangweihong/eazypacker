#!/bin/sh -eux
# 这个脚本的目的是减小磁盘映像的大小，同时确保系统功能正常

case "$PACKER_BUILDER_TYPE" in
qemu) exit 0 ;;
esac

# Whiteout root
# 使用 dd 命令在根目录和 /boot 目录中创建大量的零字节文件，然后立即删除这些文件。这样做是为了创建一个"白板"区域，使文件系统能够更有效地使用可用空间。这是为了最小化磁盘镜像的大小
count=$(df --sync -kP / | tail -n1 | awk -F ' ' '{print $4}')
count=$((count - 1))
dd if=/dev/zero of=/tmp/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed"
rm /tmp/whitespace

# Whiteout /boot
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
count=$((count - 1))
dd if=/dev/zero of=/boot/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed"
rm /boot/whitespace

set +e
# 记录交换分区UUID
swapuuid="$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)"
case "$?" in
2 | 0) ;;
*) exit 1 ;;
esac
set -e

if [ "x${swapuuid}" != "x" ]; then
    # Whiteout the swap partition to reduce box size
    # Swap is disabled till reboot
    swappart="$(readlink -f /dev/disk/by-uuid/"$swapuuid")"
    # 关闭交换分区
    /sbin/swapoff "$swappart" || true
    # 使用 dd 命令将交换分区填充为零字节，以清除数据
    dd if=/dev/zero of="$swappart" bs=1M || echo "dd exit code $? is suppressed"
    # 使用 mkswap 命令重新创建交换分区，并将其 UUID 设置为原来的 UUID。这是为了确保重新启动后系统仍然能够正确使用交换分区
    /sbin/mkswap -U "$swapuuid" "$swappart"
fi

# 缓冲数据写入磁盘
sync
