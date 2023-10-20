os_name    = "ubuntu"
os_version = "16.04"
os_arch    = "aarch64"
//iso_url = https://old-releases.ubuntu.com/releases/16.04.4/ubuntu-16.04.1-server-arm64.iso
iso_urls = [
  "ubuntu-16.04.4-server-arm64.iso",
  "https://old-releases.ubuntu.com/releases/16.04.4/ubuntu-16.04.1-server-arm64.iso"
]
iso_checksum         = "b8b172cbdf04f5ff8adc8c2c1b4007ccf66f00fc6a324a6da6eba67de71746f6"
vmware_guest_os_type = "arm-ubuntu-64"
// <bs>等为模拟键盘执行删除操作,删除原来的boot命令
// net.ifnames=0为内核参数禁止可预测的网络接口重命名行为。不能设置该参数, 会导致使用默认网卡eth0，而不是ens33。从而导致网卡一直无法启动
boot_command = ["<enter><wait>",
  "<f6><esc>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
  "<bs><bs><bs>",
  "/install/vmlinuz ",
  "initrd=/install/initrd.gz ",
  #   "net.ifnames=0 ",
  "auto-install/enable=true ",
  "debconf/priority=critical ",
  "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu/16.04/preseed.cfg ",
"<enter>"]
// alicloud
alicloud_image_family = ""