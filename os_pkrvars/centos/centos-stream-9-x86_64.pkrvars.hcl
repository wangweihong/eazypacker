os_name                  = "centos-stream"
os_version               = "9"
os_arch                  = "x86_64"
iso_url                  = "https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-dvd1.iso"
iso_checksum             = "file:https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-dvd1.iso.SHA256SUM"
parallels_guest_os_type  = "centos"
virtualbox_guest_os_type = "RedHat_64"
vmware_guest_os_type     = "centos-64"
boot_command             = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/9ks.cfg<enter><wait>"]
// alicloud
alicloud_image_family = "acs:centos_stream_9_x64"