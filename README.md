# Hello 算法 (LazyCat)

《Hello 算法》动画图解、一键运行的数据结构与算法教程，打包为 LazyCat LPK v2 静态应用。上游项目：[krahets/hello-algo](https://github.com/krahets/hello-algo)。

## 部署信息

- **包名**：`cloud.lazycat.app.hello-algo`
- **版本**：跟随上游 release tag 自动更新（每日 UTC 02:00 检查，北京时间 10:00）
- **类型**：纯静态站（mkdocs 多语言构建，无后端服务）
- **min_os_version**：1.5.0
- **内容**：zh / zh-hant / en / ja / ru 五种语言完整站点（约 150 MB）

## 架构

```
上游 krahets/hello-algo (tag 1.3.0 ...)
   │  schedule 检查（sync-upstream job）
   │  bump package.yml version → push
   ▼
本仓库（LPK 配置 + build.sh）
   │  push 触发 → ca-x/lazycat-github-action
   │  buildscript: clone 上游 tag 源码 → pip install mkdocs → 多语言 mkdocs build → site/
   ▼
LPK 打包（contentdir: ./site）→ GitHub Release + 喵喵商店发布
```

## 关键实现

- **版本来源**：`update.version_source.type: git`；git 源不支持 schedule 自动检查，由 `sync-upstream` job 每日比对上游 release tag（`gh api .../releases/latest`），有新版本即 bump `package.yml` 并 push，触发发布。
- **构建**：`build.sh` 在 CI 中克隆上游指定 tag 源码，安装 `mkdocs-material==9.5.5` + `mkdocs-glightbox`，按上游 Dockerfile 的流程做 5 次 mkdocs build（zh + zh-hant/en/ja/ru），产物拷贝到 `site/`。
- **服务**：无容器服务，lzcinit 直接 `file:///lzcapp/pkg/content/` 提供静态文件。
- **发布**：仅喵喵商店（`APPSTORE_*`），Release 附带 `<package-id>-v<version>.lpk`。

## 文件结构

```
package.yml              # 包元数据（版本随上游同步）
lzc-manifest.yml         # 运行结构（file:// 静态服务）
lzc-build.yml            # 构建配置（contentdir + buildscript）
build.sh                 # CI 构建脚本（clone 上游 + mkdocs）
icon.png                 # 应用图标
.github/lazycat-action.yml      # Action 配置（git 版本源 / 喵喵商店）
.github/workflows/lazycat.yml   # 上游同步 + 发布工作流
```
