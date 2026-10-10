# 代码目录

每个阶段的代码放在这里，**每个可独立运行的项目都有自己的 README**。

## 目录规划

| 目录 | 阶段 | 内容 | 出现时间 |
|---|---|---|---|
| `Text01/` | Day 0 | 最早期的语法练习（存档，不再修改） | 已有 |
| `stage1-javase/` | W1–W2 | 每日小程序：OOP / 集合 / 泛型 / Stream / IO / 并发 / Maven 多模块 / SQL 练习 | W1 |
| `stage1-library/` | W3 | **项目一**：控制台图书管理系统（JDBC + MySQL + 分层 + 事务 + JUnit） | W3 末 |
| `stage2-admin-api/` | W4–W7 | **项目二**：企业后台管理系统后端（Spring Boot 3 + MyBatis-Plus + RBAC + Swagger） | W6 末 |
| `stage3-fullstack/` | W8–W9 | **项目三**：全栈电商（后端 + `frontend/` Vue3，含 Redis / MQ / 秒杀） | W9 末 |
| `stage4-deploy/` | W10 | Dockerfile / docker-compose / Nginx / CI 部署方案 | W10 末 |
| `stage4-micro/` | W11 | 微服务拆分版（Nacos + OpenFeign + Gateway + Sentinel）+ 压测报告 | W11 末 |

## 每个项目必须有的东西（缺一不可）

```
<项目名>/
├── README.md            ← 项目简介、技术栈、架构图(mermaid)、启动三步、接口清单、踩坑记录
├── .gitignore
├── pom.xml              ← 或 frontend/package.json
├── src/                 ← 分层包结构，别把所有类堆在一个包里
├── sql/                 ← schema.sql + data.sql（能一键建库）
├── docs/                ← 表设计、接口文档、设计说明、压测/优化报告
└── src/test/            ← 单元测试（Service 层至少覆盖主要分支）
```

## 命名与包结构约定

- 包名：`com.gagahaolihai.<项目名>`，例如 `com.gagahaolihai.library`
- 分层：`controller` / `service`(`impl`) / `mapper`(`dao`) / `entity`(`domain`) / `dto` / `vo` / `config` / `common` / `util` / `exception`
- 数据库表：小写下划线（`sys_user`、`biz_order_item`），字段同风格
- REST 路径：`/api/v1/users`，复数名词，动作用 HTTP 方法表达

## 提交纪律

- 每写完一个可运行的小功能就提交，**不要攒一天一次提交**
- commit 信息写清"做了什么"，不写 `update` / `fix`
- 大项目用 `feat(模块): 描述`，例如 `feat(order): 新增订单超时自动取消（延迟队列）`

## 关于 `Text01`

这是最开始练语法的 IntelliJ 工程，保留作为起点对照。**里面的 `out/`、`.idea/` 已加入 `.gitignore`，不要提交。**

> 建议：以后新建 Java 工程时，把 `.idea/` 从版本控制里彻底排除（`git rm -r --cached .idea`），只在需要共享配置时才提交。
