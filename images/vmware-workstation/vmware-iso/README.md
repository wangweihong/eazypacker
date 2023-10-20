# 构建VmwareWorkstation镜像
描述如何通过在VmwareWorkstation通过ubuntu iso构建黄金镜像

# 注意
* 只能在安装Vmware Workstation的Windows系统运行!

# 步骤
1. 在windows环境安装packer
   * https://releases.hashicorp.com/packer/1.9.4/packer_1.9.4_windows_amd64.zip
    下载解压packer.exe后
   * 拷贝程序到C:\Users\Administrator\bin目录下
2. [可选]设置代理(否则可能无法下载插件)。
    ```
    export HTTP_PROXY=http://127.0.0.1:10811
    export HTTPS_PROXY=http://127.0.0.1:10811
    ```
3. 安装插件`packer init .`
4. 构建`packer build .`

# 调试
* 日志 `PACKER_LOG=1 packer build .`
* 交互式 `PACKER_LOG=1 packer build -debug .`

# 其他
* 默认iso会下载到当前路径下packer_cache目录中。

# 参考
* https://medium.com/@maros.kukan/automating-golden-image-builds-with-packer-3b1c6010b467
* [ubuntu 22.04的变化](https://imagineer.in/blog/packer-build-for-ubuntu-20-04/)