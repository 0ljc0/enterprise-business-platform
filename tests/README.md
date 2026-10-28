# 测试说明

本目录保留历史自动化测试代码与验收结果。原本机演示种子、密码文件不公开，因此依赖03_demo.local.sql、02_demo.local.sql或seed-credentials.local.txt的测试不能在新克隆后直接运行。请先自行建立隔离测试账号与种子，不要复制真实业务数据。MySQL管理员密码从MYSQL_PWD环境变量读取。

第十阶段干净安装测试依赖先构建Windows部署包、Windows/JDK/Python/MySQL/Redis环境；涉及目录和端口请先检查脚本。部分路径沿用原本机D盘约定，跨机器执行前需配置。原466项通过的完整记录见docs/stage10/03_测试与验收记录.md。
