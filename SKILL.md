---
name: kb
description: 个人知识库记录（SurrealDB Cloud，多端共享）：计划、项目进度、里程碑、经验教训、备忘、公开文章。用 kb 命令一行写入，自动处理认证与转义。触发词：记录一下、记到知识库、沉淀经验、写备忘、建计划、任务复盘、总结教训、kb、记录进度、发布文章。
---

# kb — 个人知识库记录

数据存 SurrealDB Cloud（private/public 双区），**多端共享**：Windows、instabox、VPS 上的任何 agent 写的都是同一个库。
查看入口：私有仪表盘 https://kb.shumu.de5.net（密码认证）；公开站 https://shumu.de5.net。

## 何时记录（自觉时机）

| 时机 | 动作 |
|---|---|
| 接到多步骤/新目标任务 | `kb plan "目标" --priority high --deadline +7d`（可先 `kb project` 建项目再关联） |
| 完成一个阶段 | `kb progress <项目id> "一句话进展" --pct 50` |
| 计划完成/状态变化 | `kb set plan <id> status=done` |
| 任务结束有可复用心得 | `kb lesson "标题" "一句话可复用结论" --tags a,b --source 来源` |
| 随手记信息/命令/结论 | `kb note "内容" --title 标题`（重要则 --pin true） |
| 要对外分享的内容 | `kb article "标题" <slug> "Markdown 正文" --summary 摘要`（存草稿；**发布需用户确认**，然后 `kb publish <slug>` + 提醒用户 `cd kb-web && bun run deploy`） |

## 记录纪律（防垃圾数据）

1. **有信息量才记**：琐碎操作不记；排障 30 分钟以上、踩了坑、得出结论的必记
2. **takeaway 必须一句话可复用**（下次遇到同样问题能直接照做），细节放 --content
3. **progress 摘要一句话**，细节放 --detail
4. 不确定值默认：priority=medium，status 见命令帮助

## 使用

```bash
KB=~/.agents/skills/kb/bin/kb    # 已在 PATH 的端直接 kb
$KB plan "修复登录超时" --priority high --deadline +3d
$KB progress surreal_kb_setup "仪表盘上线" --pct 100
$KB lesson "curl 发中文会 GBK 乱码" "用 --data-binary @- 从 stdin 传" --tags curl,编码
$KB note "域名备忘：serenityhub.top 还空着" --pin true
$KB list lesson -n5             # 查最近记录
$KB sql "SELECT * FROM plan WHERE status = 'in_progress'"   # 兜底查询
```

需要环境变量 `SURREAL_AGENT_PASS`（agent 账户密码）。新设备部署：

```bash
curl -fsSL https://raw.githubusercontent.com/ryanlq/kb/main/install.sh | bash -s -- --pass <密码>
```

自动装 CLI+SKILL+全局指令（pi/Claude Code/Codex），零依赖（bash+curl）。更新：`cd ~/.agents/skills/kb && git pull`

## 边界与安全

- agent 账户：数据可写（表级 PERMISSIONS 限定），跨不出所在库；**不要执行 DEFINE/REMOVE 等 schema 语句**（改结构走 surreal/apply.sh，由管理员执行）
- article 的 publish 必须用户确认后执行
- 认证 JWT 缓存 55 分钟自动复用，无需关心
