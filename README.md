# 七牛客户端上传工具

自学go的一个练手小Demo(也是一个轮子), 从服务端获取上传文件到七牛服务器的凭证，上传文件成功后返回文件的下载地址

## 使用帮助

```bash
# 在bin目录下选择适合当前操作系统平台的可执行文件执行

# 如当前为linux 64位系统, 上传test文件，并保存为testkey
$ bin/qiniu-client-linux-amd64 -k testkey test 
Upload file with key:  testkey
Upload file success, You can download it from:
http://7xkp7e.com1.z0.glb.clouddn.com/testkey
```

## 服务端代码

<https://github.com/crazygit/qiniu-manager>

