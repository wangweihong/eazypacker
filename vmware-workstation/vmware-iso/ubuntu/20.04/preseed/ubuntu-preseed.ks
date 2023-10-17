# Ubuntu Server 20.04 LTS kickstart file

# Keyboard settings
keyboard us

# Disable interactive installation
preseed debconf debconf/frontend select Noninteractive

# Set the timezone
d-i time/zone string Asia/Shanghai

# Set the root password
d-i passwd/root-password password wwhvw
d-i passwd/root-password-again password wwhvw

# Create a user account
d-i passwd/user-fullname string wwhvw
d-i passwd/username string wwhvw
d-i passwd/user-password password wwhvw
d-i passwd/user-password-again password wwhvw

# Partitioning
d-i partman-auto/method string lvm
d-i partman-auto-lvm/guided_size string max
d-i partman-auto/choose_recipe select atomic
d-i partman/default_filesystem string ext4
d-i partman-auto/expert_recipe string                         \
    boot-root ::                                            \
        512 512 512 ext4                                  \
            $primary{ } $bootable{ }                     \
            method{ format } format{ }                 \
            use_filesystem{ } filesystem{ ext4 }      \
            mountpoint{ /boot }                        \
        .                                               \
        4096 10000 1000000000 ext4                  \
            $lvmok{ } lv_name{ root } in_vg{ system }  \
            method{ format } format{ }             \
            use_filesystem{ } filesystem{ ext4 }  \
            mountpoint{ / }                         \
        .                                               \
        1024 2048 4000 linux-swap                  \
            method{ swap } format{ }               \
        .
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm boolean true

# Install packages
tasksel tasksel/first multiselect standard
d-i pkgsel/include string openssh-server

# Grub installation
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev string /dev/sda

# Configure the package manager
d-i apt-setup/restricted boolean true
d-i apt-setup/universe boolean true

# Install the GRUB boot loader to the master boot record
d-i grub-installer/bootdev string /dev/sda

# Finish installation
d-i finish-install/reboot_in_progress note
