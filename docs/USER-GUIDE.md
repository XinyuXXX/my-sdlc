# my-sdlc 用户使用指南

四个宿主的安装与激活：Claude Code、Kimi Code CLI、GitHub Copilot、OpenCode。
每种宿主分用户级（全项目生效）和项目级（单项目生效）两种装法。

## 一条命令安装（推荐）

仓库根部的 `install.sh` 封装了所有路径细节：

```bash
cd ~/coding-workspace/sdlc/my-sdlc

# 用户级，全项目生效
./install.sh kimi user
./install.sh claude user --with-hook
./install.sh copilot user --with-hook
./install.sh opencode user

# 项目级，只装进某个项目（省略路径默认当前目录）
./install.sh all project ~/coding-workspace/go-miniprogram --with-hook
```

脚本做两件事：把 `skills/` 下 47 个技能以符号链接铺进目标目录（my-sdlc 更新即生效，无需重装），并在加 `--with-hook` 时安装 SessionStart 自动注入 hook。重复执行安全，链接用 `ln -sfn` 幂等覆盖。

项目级安装后建议把技能目录加进该项目的 `.gitignore`（链接是本机绝对路径，提交对别人是死链）：

```bash
echo ".kimi/" >> .gitignore    # 按宿主换成 .claude/ .github/ .opencode/
```

## 各宿主明细

### Claude Code

| 级别 | 技能路径 | hook |
|---|---|---|
| 用户级 | `~/.claude/skills/` | 写入 `~/.claude/settings.json` 的 `hooks.SessionStart` |
| 项目级 | `<项目>/.claude/skills/` | 写入 `<项目>/.claude/settings.json` |

hook 注册时会先备份原 settings 为 `settings.json.bak-my-sdlc`。装好后 poteto-mode 在每次会话开始和上下文压缩后自动注入，无需手动激活。

### Kimi Code CLI

| 级别 | 技能路径 | hook |
|---|---|---|
| 用户级 | `~/.kimi/skills/` | 不支持 |
| 项目级 | `<项目>/.kimi/skills/` | 不支持 |

技能在会话启动时自动出现在系统提示里，但 poteto-mode 需要手动激活：新会话输入 `/skill:poteto-mode`，可以在后面直接跟任务描述（`/skill:poteto-mode 修一下登录页的 bug`）。

### GitHub Copilot（CLI 与 VS Code）

| 级别 | 技能路径 | hook |
|---|---|---|
| 用户级 | `~/.copilot/skills/` | 写入 `~/.copilot/hooks/my-sdlc.json` |
| 项目级 | `<项目>/.github/skills/` | 写入 `<项目>/.github/hooks/my-sdlc.json` |

**hook 兼容性结论：可用，走独立 JSON 文件这条路。** Copilot CLI 支持命令型 `sessionStart` hook 注入 `additionalContext`，my-sdlc 的脚本在无平台环境变量时输出的正是 Copilot 的 SDK 标准格式（已实测输出形状正确）。三个已知边界：

- 不要用插件形式的 `hooks.json`（有未修复的触发缺陷，copilot-cli#2540）。本脚本写的是独立的 hooks 目录 JSON，不受影响。
- `copilot -p` 非交互模式不加载仓库级 hook（copilot-cli#3345），交互会话正常。
- 很旧的版本（v0.0.420 前后）sessionStart 完全不触发（copilot-cli#1730），升级到近期版本即可。

不装 hook 时的激活方式：prompt 里点名，`Use the /poteto-mode skill to ...`。

### OpenCode

| 级别 | 技能路径 | hook |
|---|---|---|
| 用户级 | `~/.config/opencode/skills/`（注意不是 `~/.opencode`） | 不支持 |
| 项目级 | `<项目>/.opencode/skills/` | 不支持 |

OpenCode 原生有 `skill` 工具，按需加载。激活方式是点名：`Load the poteto-mode skill and ...`。它也兼容读 `.claude/skills/` 和 `.agents/skills/`，所以如果你已经为 Claude 装过用户级，OpenCode 直接就能看到。

## 验证安装

装完后开一个新会话，确认两点。

1. 技能清单里出现 poteto-mode、grill-me、clean-code-guard 等 47 个名字。Claude Code 用 `/plugin` 或直接看启动提示；Kimi 看系统提示的 Project/User 技能组；Copilot CLI 用 `/skills list`；OpenCode 看它 skill 工具的可用列表。
2. 激活 poteto-mode 后给一个任务，确认它按 playbook 路由（回复里会出现 playbook 步骤清单）。

## 各宿主机的能力差异

同样的技能内容，在不同宿主上能兑现的程度不同。

- **自动注入**：只有 Claude Code 的 hook 链路完整可靠。Copilot 可用但有上述边界。Kimi 和 OpenCode 只能手动激活。
- **子代理分工**：architect、arena、swarm、interrogate 这些技能设计上是多模型对抗评审。单模型宿主上退化为同模型多实例，信号变弱但仍有效。
- **playbook 里的占位符**：`<pstack-skills-directory>` 指本仓库的 `skills/` 目录，`<host-temp-directory>` 指系统临时目录。

## 卸载

删掉目标目录里的符号链接即可，hook 是独立的 JSON 文件或 settings.json 里的一个条目，删掉对应条目就卸干净了。符号链接不持有任何内容，删除不影响 my-sdlc 本体。
