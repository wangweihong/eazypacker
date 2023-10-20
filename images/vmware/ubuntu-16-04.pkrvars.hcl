

// 引导命令
boot_command = [
  "<enter><wait>",
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
  "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
  "<enter>"
]
//variable "boot_command" {
//  type = list(string)
//  # <bs>等为模拟键盘执行删除操作,删除原来的boot命令
//  # net.ifnames=0为内核参数禁止可预测的网络接口重命名行为。不能设置该参数, 会导致使用默认网卡eth0，而不是ens33。从而导致网卡一直无法启动
//  default = [
//    "<enter><wait>",
//    "<f6><esc>",
//    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
//    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
//    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
//    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
//    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
//    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
//    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
//    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
//    "<bs><bs><bs>",
//    "/install/vmlinuz ",
//    "initrd=/install/initrd.gz ",
//    #   "net.ifnames=0 ",
//    "auto-install/enable=true ",
//    "debconf/priority=critical ",
//    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
//    "<enter>"
//  ]
//}
boot_wait = "5s"
// 引导等待时间
// 定义当vm启动并输入引导命令时Packer等待的时间
//variable "boot_wait" {
//  type    = string
//  default = "5s"
//}
//api_prefix =
//
//variable "ami_prefix" {
//  type    = string
//  default = "ami-ubuntu-16.04"
//}
ami_prefix = "ami-ubuntu-16.04"
// iso路径
iso_urls = [
  "iso/ubuntu-16.04.4-server-amd64.iso",
  "https://old-releases.ubuntu.com/releases/16.04.4/ubuntu-16.04-server-amd64.iso"
]
//variable "iso_urls" {
//  type = list(string)
//  // 先从本地路径iso/查找iso,如果不存在再去指定URL下载
//  default = [
//    "iso/ubuntu-16.04.4-server-amd64.iso",
//    "https://old-releases.ubuntu.com/releases/16.04.4/ubuntu-16.04-server-amd64.iso"
//  ]
//}
output_dir = ""
//variable "output_dir" {
//  type    = string
//  default = ""
//}
iso_checksum = "b8b172cbdf04f5ff8adc8c2c1b4007ccf66f00fc6a324a6da6eba67de71746f6"
// 也可以指定从某个文件中读取"file:./shasums.txt"
//variable "iso_checksum" {
//  type = string
//  default = "b8b172cbdf04f5ff8adc8c2c1b4007ccf66f00fc6a324a6da6eba67de71746f6"
//}

user     = "wwhvw"
password = "wwhvw"
shutdown = "shutdown_command"
// 安装系统后连接到虚拟机上的ssh账号,必须要preseed.cfg保持一致
//variable "user" {
//  type    = string
//  default = "wwhvw"
//}
//
//variable "password" {
//  type    = string
//  default = "wwhvw"
//}

//
//variable "shutdown"{
//  type = string
//  default = "shutdown_command"
//}