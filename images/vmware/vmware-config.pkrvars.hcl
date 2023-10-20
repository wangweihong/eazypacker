/*-----------VMWare相关配置-------------*/

/*-----------通用配置-------------------*/

// 如果设置, packer将会启动并设置服务http_directory指定的目录且随机端口的http服务
// builder可以通过类似于`wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/foo/bar/preseed.cfg`来使用该目录
http_directory = "preseed"
ssh_port       = 22
ssh_timeout    = "3600s"
// 指定当vm安装好系统后packer连接vm的方式。linux一般是ssh, windows一般是winrm.
communicator = "ssh"
//variable "http_directory" {
//  type = string
//  default = "preseed"
//}

//variable "ssh_port"{
//  type = number
//  default = 22
//}
//
//variable "ssh_timeout"{
//  type = string
//  default = "3600s"
//}

// 指定当vm安装好系统后packer连接vm的方式。linux一般是ssh, windows一般是winrm.
//variable "communicator"{
//  type = string
//  default = "ssh"
//}

/*-----------VMWare硬件配置--------------*/
cpus      = 2
memory    = 2048
disk_size = 40960
headless  = false
// vmx硬件配置
// vmx 配置https://sanbarrow.com/vmx/vmx-network.html
vmx_data = {
  # 设置虚拟机启动时连接网卡
  "ethernet0.startConnected" : "true",
  "ethernet0.addressType" : "generated",
  "ethernet0.virtualDev" : "e1000"
  "ethernet0.present" : "TRUE"
}
disk_type_id                   = 0
vmx_remove_ethernet_interfaces = true
vnc_disable_password           = true
vnc_bind_address               = "127.0.0.1"
//variable "cpus" {
//  type    = string
//  default = "2"
//}
//
//variable "memory" {
//  type    = string
//  default = "2048"
//}
//
//// 磁盘大小,单位为MB
//variable "disk_size" {
//  type    = string
//  default = "40960"
//}
//
//variable "headless" {
//  type = boolean
//  default = false
//}
//
//// vmx硬件配置
//// vmx 配置https://sanbarrow.com/vmx/vmx-network.html
//variable "vmx_data" {
//  type = map(string)
//  default =  {
//    # 设置虚拟机启动时连接网卡
//    "ethernet0.startConnected" : "true",
//    "ethernet0.addressType" : "generated",
//    "ethernet0.virtualDev" : "e1000"
//    "ethernet0.present" : "TRUE"
//  }
//}
//
////  设置虚拟磁盘类型。0表示保存到同一个文件
//variable "disk_type_id"{
//  type = number
//  default = 0
//}
//
//// 安装完系统后删除网卡, 否则所有基于该镜像创建出来的虚拟机都会使用同样IP
//variable "vmx_remove_ethernet_interfaces"{
//  type = boolean
//  default = true
//}
//
//variable "vnc_disable_password" {
//  type = boolean
//  default = true
//}
//
//variable "vnc_bind_address" {
//  type = string
//  default = "127.0.0.1"
//}