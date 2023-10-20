# packer块包含Packer配置，包括指定Packer的版本
packer {
  # required_plugins块指定当前模板构建镜像依赖的插件
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


# 输入变量(input variable)
# 可以通过命令行标志、环境便令或者特殊变量定义文件在运行时覆盖输入变量的值。但一旦packer运行，就无法修改输入变量值
# 如`packer build -var="ami_prefix=test"来改变输入变量的默认值
# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/variables#assigning-values-to-input-variables
variable "ami_prefix" {
  # 变量类型
  type = string
  # 默认值
  default = "learn-packer-linux-aws-redis"
}

# 局部变量(local variable)
# 局部变量可以设置为任何值，包括其他输入变量或者局部变量
# 当需要格式化常用值时，局部变量非常有用。
# 与输入变量不同，不能覆盖局部变量的值。局部变量设置为在运行时计算的表达式。表达式可以引用输入变量、局部变量、数据源和 HCL 函数。
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


# source块配置会被build块调用特定的builder插件。
# source块通过bulider和communicators来定义使用哪种虚拟化技术
#    ,如何加载你想要定制的镜像，以及如何连接它。builders和communicator捆绑在一起并在source块中并排配置。
# source块能够被多个build块重用，也可以在一个build块中使用多个source块。
# 构建器插件是 Packer 的一个组件，负责创建机器并将该机器转换为镜像。

# 语法: source "builder type" "name". 通过`builder type`和`name`一起组合允许用户在build块单独引用source.
# 下例中"amazon-ebs"为构建器类型,"ubuntu"为名字。
source "amazon-ebs" "ubuntu" {
  # 以下为amazon-ebs构建器专门的属性。
  ami_name      = "learn-packer-linux-aws"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  # ssh连接器https://developer.hashicorp.com/packer/docs/communicators/ssh
  # 通过指定ssh_username属性，packer可以通过使用临时的密钥对和安全组ssh连接到EC2实例进行实例配置
  ssh_username = "ubuntu"
}

# 新增一个源
source "amazon-ebs" "ubuntu-focal" {
  # 通过输入变量以及局部变量来更改生成的镜像名
  ami_name      = "${var.ami_prefix}-focal-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

# build块定义Packer 在 EC2 实例启动后应对其执行的操作。
build {
  # 指定构建器的名字。可以通过`only`或者`except`来指定或忽略某些build的执行
  name = "learn-packer"
  # build块通过`source.amazon-ebs.ubuntu`引用了source块定义的AMI。
  # 指定多个源可以并行构建
  sources = [
    "source.amazon-ebs.ubuntu",
    "source.amazon-ebs.ubuntu-focal"
  ]

  # 定义一个`shell`配置器
  provisioner "shell" {
    # 通过shell设置环境变量"F00=hello world"
    environment_vars = [
      "FOO=hello world",
    ]
    # inline定义需要运行的命令
    inline = [
      "echo Installing Redis",
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get install -y redis-server",
      "echo \"FOO is $FOO\" > example.txt",
    ]
  }

  # 配置器可以定义多个
  provisioner "shell" {
    inline = ["echo This provisioner runs last"]
  }

  # 如果采用以下的方式每个后处理器都将从构建器输出的制品开始,而不是从先前声明的后处理器创建的制品开始
  # 当镜像成功创建后，使用该镜像创建Vagrant box
  # 见https://developer.hashicorp.com/packer/tutorials/aws-get-started/aws-get-started-post-processors-vagrant
  #post-processor "vagrant" {}
  # 当镜像创建成功后，压缩镜像
  #post-processor "compress" {}

  # 如果需要连续，即后一个后处理器从前一个后处理器生成的制品开始操作，则应采用以下语法
  # 当镜像创建成功后，使用该镜像创建Vagrant box,并对Vagrant Box进行压缩。
  post-processors {
    post-processor "vagrant" {}
    post-processor "compress" {}
  }
}

