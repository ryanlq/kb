# kb — 个人知识库（多端 agent 自觉记录）

数据存 [SurrealDB Cloud](https://surrealdb.com)（private/public 双区），任何设备上的 agent 用一条命令沉淀：计划、进度、经验、备忘、公开文章。

- 公开文章站：https://shumu.de5.net
- 私有仪表盘：https://kb.shumu.de5.net（密码认证）
- JSON API：https://api.shumu.de5.net/api/articles

## 一键安装（新设备 / 新 agent）

```bash
curl -fsSL https://raw.githubusercontent.com/ryanlq/kb/main/install.sh | bash -s -- --pass <SURREAL_AGENT_PASS>
```

密码找管理员获取。安装内容：

1. `~/.agents/skills/kb/`（SKILL.md + bin/kb，纯 bash+curl 零依赖）
2. 自动向已安装的 agent harness 写入全局指令（pi / Claude Code / Codex，幂等不重复）
3. 自动验证数据库连通性

更新：`cd ~/.agents/skills/kb && git pull`

## 用法（agent 视角）

```bash
kb plan "修复登录超时" --priority high --deadline +3d        # 接到任务
kb progress surreal_kb_setup "仪表盘上线" --pct 100          # 阶段进展
kb lesson "curl 发中文会乱码" "用 --data-binary @- 传" --tags curl   # 沉淀经验
kb note "域名 serenityhub.top 还空着" --pin true             # 备忘
kb article "我的第一篇文章" hello-world "# 正文..."           # 公开区草稿
kb list lesson -n 5                                          # 查最近
kb sql "SELECT * FROM plan WHERE status = 'in_progress'"     # 兜底查询
```

完整命令：`kb help`。记录纪律：**有信息量才记，takeaway 一句话可复用，琐碎不刷屏**。

## 何时记（agent 自觉时机）

| 时机 | 命令 |
|---|---|
| 接到多步骤任务 | `kb plan` |
| 阶段性完成 | `kb progress` |
| 踩坑得出可复用结论 | `kb lesson`（最重要） |
| 值得留的信息 | `kb note` |
| 对外内容 | `kb article`（草稿；发布需用户确认） |

## 体系架构

```
SurrealDB Cloud（唯一真相）
├── private/main   计划/项目/里程碑/时间线/经验/备忘  → kb-dashboard 仪表盘（密码认证）
└── public/main    文章                              → Starlight 静态站 + Worker JSON API
```

## 安全

- `agent` 数据库账户：VIEWER + 表级 PERMISSIONS（可写数据、跨不出所在库）
- 仪表盘：密码登录 + HMAC Cookie 会话
- 密码只存各端环境变量 / Cloudflare Secrets，不入仓库
