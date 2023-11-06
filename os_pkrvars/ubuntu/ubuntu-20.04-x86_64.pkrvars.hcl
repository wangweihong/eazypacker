os_name    = "ubuntu"
os_version = "20.04"
os_arch    = "x86_64"
iso_urls = [
  "iso/ubuntu-20.04.6-live-server-amd64.iso",
  "https://releases.ubuntu.com/focal/ubuntu-20.04.6-live-server-amd64.iso"
]
//iso_url                 = "https://releases.ubuntu.com/focal/ubuntu-20.04.6-live-server-amd64.iso"
iso_checksum             = "file:https://releases.ubuntu.com/focal/SHA256SUMS"
parallels_guest_os_type  = "ubuntu"
virtualbox_guest_os_type = "Ubuntu_64"
vmware_guest_os_type     = "ubuntu-64"
boot_command             = ["<wait><enter><wait><enter><wait><f6><wait><esc><wait> autoinstall ds=nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu/<enter><wait>"]
// alicloud
alicloud_image_family = "acs:ubuntu_20_04_x64_amd"