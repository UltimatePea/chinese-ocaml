# GitHub 集成脚本

本目录包含与GitHub API交互的核心脚本和工具。

## 核心脚本

### github_auth.py

GitHub API认证和操作的核心工具。

#### 主要功能
- GitHub App认证
- Issues管理（创建、查看、关闭）
- Pull Requests管理（创建、查看、合并）
- CI状态检查

#### 使用方法

```bash
# 测试认证
python scripts/github/github_auth.py --test-auth

# 查看开放issues
python scripts/github/github_auth.py --get-issues

# 查看开放PRs
python scripts/github/github_auth.py --get-prs

# 查看特定issue详情
python scripts/github/github_auth.py --get-issue-details 123

# 查看特定PR状态
python scripts/github/github_auth.py --get-pr-status 123

# 创建新issue
python scripts/github/github_auth.py --create-issue "标题" "内容"

# 创建新PR
python scripts/github/github_auth.py --create-pr "标题" "内容" "分支名"

# 合并PR
python scripts/github/github_auth.py --merge-pr 123

# 关闭issue
python scripts/github/github_auth.py --close-issue 123 "可选的关闭评论"
```

## 认证配置

脚本依赖GitHub App认证，需要：
1. 私钥文件位于 `../claudeai-v1.pem`
2. App ID: 1595512
3. Installation ID: 75590650

详细认证说明请参考项目根目录的 `GITHUB_AUTHENTICATION.md`。

## 注意事项

- 所有脚本操作都会记录到GitHub audit log
- 创建issues和PRs需要适当的权限
- 合并PR时请确保CI检查通过
- 遵循项目的代码审查流程