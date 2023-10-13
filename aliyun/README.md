# 构建阿里云镜像
描述如何通过packer构建阿里云镜像
# 步骤
1. 设置阿里云私钥和密钥。**NOTE:** 一定要注意确认账户是否有权限
    ```
    export ALICLOUD_ACCESS_KEY=xxx
    export ALICLOUD_SECRET_KEY=
    ```
2. [可选]`export PACKER_LOG=1`启动packer调试  
3. 执行`packer init .`安装插件
4. 执行`packer build .` 

## TroubleShooting
### `No alicloud image was found matching filters: centos_7_9_x64_20G_alibase_20211027.vhd`
 不一定是镜像问题。确认IAM账号是否具有ecs权限。