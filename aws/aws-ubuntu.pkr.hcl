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

# build块定义Packer 在 EC2 实例启动后应对其执行的操作。
build {
  name = "learn-packer"
  # build块通过`source.amazon-ebs.ubuntu`引用了source块定义的AMI。
  sources = [
    "source.amazon-ebs.ubuntu"
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
}

