# 上传到 GitHub

请上传本目录，原 D:/code/ruoyi 目录保留本机运行配置，不作为上传目录。

本目录是前后端合并的独立 Git 仓库，只有整理后的初始提交，未包含原开发历史。未设置远程仓库，尚未上传。

1. 在 GitHub 创建空仓库，先不要自动添加 README、LICENSE 或 .gitignore，本地均已准备。
2. 在本目录的 VS Code 终端中，替换下面的仓库地址后执行：

```powershell
git status
git remote add origin https://github.com/你的用户名/你的仓库名.git
git push -u origin main
```

按 GitHub 提示完成登录，不要把访问令牌写入远程URL或提交到文件。上传前确认暂存列表不含真实密码、运行配置、业务备份、上传附件。代码上传不会自动上线网站。

.env.example只作格式示例，真实值通过终端环境变量或被忽略的本机文件设置。首次运行见根目录README；历史测试结果与实际部署状态的限制也已写明。
