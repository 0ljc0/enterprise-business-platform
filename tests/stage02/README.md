# 集成测试

在项目根目录先构建后端，再执行：

```powershell
python tests/stage02/run.py
```

运行器新建带时间戳的独立测试数据库，导入基础结构和本地演示种子，启动18083端口，执行71项检查，结束后停止测试后端，保留测试库便于检查。不会修改原考试库或业务库。需要本机MySQL、Redis运行，且03_demo.local.sql和seed-credentials.local.txt存在。结果输出到项目根目录stage02-test-results.json；首次交付结果归档为本目录results.json。不要直接对真实业务库运行三个单独的用例脚本。
