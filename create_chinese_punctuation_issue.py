#!/usr/bin/env python3
"""
创建中文标点符号词法分析修复issue
"""

import json
import time
import jwt
import requests
from pathlib import Path

# GitHub App 配置
APP_ID = "1595512"
INSTALLATION_ID = "75590650"
PRIVATE_KEY_PATH = "../claudeai-v1.pem"

def generate_jwt():
    """生成JWT token"""
    private_key_path = Path(__file__).parent / PRIVATE_KEY_PATH
    
    with open(private_key_path, 'r') as f:
        private_key = f.read()
    
    now = int(time.time())
    payload = {
        'iat': now,
        'exp': now + 600,  # 10分钟有效期
        'iss': APP_ID
    }
    
    return jwt.encode(payload, private_key, algorithm='RS256')

def get_installation_token():
    """获取installation token"""
    jwt_token = generate_jwt()
    
    headers = {
        'Authorization': f'Bearer {jwt_token}',
        'Accept': 'application/vnd.github+json'
    }
    
    url = f'https://api.github.com/app/installations/{INSTALLATION_ID}/access_tokens'
    
    response = requests.post(url, headers=headers)
    response.raise_for_status()
    
    return response.json()['token']

def create_issue():
    """创建issue"""
    token = get_installation_token()
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    issue_data = {
        'title': '技术债务修复：中文标点符号词法分析错误',
        'body': '''## 问题描述

通过技术债务分析发现，当前词法分析器无法正确处理以下中文标点符号：

- 【 (Chinese left bracket)
- 】 (Chinese right bracket) 
- ； (Chinese semicolon)
- ｜ (Chinese pipe)
- → (Chinese arrow)
- ⇒ (Chinese double arrow)
- ← (Chinese assign arrow)

## 错误信息

```
ERROR - Yyocamlc_lib.Lexer_tokens.LexError("不支持的字符: 【", _)
ERROR - Yyocamlc_lib.Lexer_tokens.LexError("不支持的字符: 】", _)
ERROR - Yyocamlc_lib.Lexer_tokens.LexError("不支持的字符: ；", _)
ERROR - Yyocamlc_lib.Lexer_tokens.LexError("不支持的字符: ｜", _)
ERROR - Yyocamlc_lib.Lexer_tokens.LexError("不支持的字符: →", _)
ERROR - Yyocamlc_lib.Lexer_tokens.LexError("不支持的字符: ⇒", _)
ERROR - Yyocamlc_lib.Lexer_tokens.LexError("不支持的字符: ←", _)
```

## 复现步骤

1. 运行 `dune exec -- ./test/chinese_punctuation.exe`
2. 观察中文标点符号解析失败

## 影响

这个问题直接影响骆言编程语言的核心中文特性，阻碍了完整的中文编程体验。

## 解决方案

需要在词法分析器中添加对这些Unicode中文标点符号的支持，具体涉及：

1. 更新词法分析器的Unicode字符识别逻辑
2. 为这些标点符号添加对应的Token定义
3. 确保测试通过

## 优先级

高优先级 - 这是影响核心功能的技术债务问题

## 分类

- 技术债务修复
- 词法分析器改进
- 中文编程特性完善
''',
        'labels': ['技术债务', '词法分析器', '中文特性', 'bug']
    }
    
    url = 'https://api.github.com/repos/UltimatePea/chinese-ocaml/issues'
    
    response = requests.post(url, headers=headers, json=issue_data)
    response.raise_for_status()
    
    issue = response.json()
    print(f"✅ Issue创建成功: #{issue['number']}")
    print(f"标题: {issue['title']}")
    print(f"URL: {issue['html_url']}")
    
    return issue['number']

if __name__ == '__main__':
    try:
        issue_number = create_issue()
        print(f"\n📝 下一步: 创建PR来修复Issue #{issue_number}")
    except Exception as e:
        print(f"❌ 错误: {e}")