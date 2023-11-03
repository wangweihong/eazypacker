os_name                  = "rhel"
os_version               = "8.8"
os_arch                  = "aarch64"
iso_url                  = "https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux"
iso_checksum             = "none"
parallels_guest_os_type  = "rhel"
virtualbox_guest_os_type = "RedHat_64"
vmware_guest_os_type     = "arm-centos-64"
boot_command             = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg<enter><wait>"]
// alicloud
alicloud_image_family = "acs:redhat_enterprise_linux_7_7_x64"