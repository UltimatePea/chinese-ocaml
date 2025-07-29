# Python脚本标准化指南

**Author: Charlie, 策略规划代理**  
**Date: 2025-07-29**  
**Type: 开发标准文档**

## 📋 目标

为项目中的Python工具脚本建立统一的质量标准，提升代码可维护性、可靠性和开发体验。

## 🎯 标准化要求

### 1. 文档标准

#### Docstring格式
```python
#!/usr/bin/env python3
"""
Script Title

简要中文描述脚本用途。

Detailed English description of the script functionality,
including usage patterns and key features.

Usage:
    python script_name.py [options]
    
Options:
    --option1    Description
    --option2    Description
    
Author: [Agent Name], [Role]
Version: X.Y - [Version Description]
"""
```

#### 函数文档
```python
def function_name(param1: Type1, param2: Type2 = default) -> ReturnType:
    """
    中文功能描述。
    
    Args:
        param1: 参数1描述
        param2: 参数2描述，默认值说明
        
    Returns:
        返回值描述
        
    Raises:
        ExceptionType: 异常条件描述
    """
```

### 2. 类型标注

**必需的类型标注**:
- 所有函数参数和返回值
- 复杂数据结构（Dict, List等）
- 可选参数使用Optional

```python
from typing import List, Dict, Any, Optional

def analyze_files(files: List[str], config: Optional[Dict[str, Any]] = None) -> Dict[str, int]:
    # Implementation
    pass
```

### 3. 错误处理

#### 具体异常处理
```python
# ❌ 避免：
try:
    # some operation
except:
    return None

# ✅ 推荐：
try:
    # some operation
except (IOError, ValueError) as e:
    print(f"Error: Failed to process file: {e}", file=sys.stderr)
    return None
```

#### 系统错误输出
```python
import sys

# 错误信息输出到stderr
print(f"Error: {error_message}", file=sys.stderr)
sys.exit(1)
```

### 4. 命令行参数

使用`argparse`提供标准化的命令行接口：

```python
import argparse

def main() -> None:
    parser = argparse.ArgumentParser(
        description='脚本功能描述',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  python script.py --option1 value1    # 示例1
  python script.py --help             # 显示帮助
        """
    )
    parser.add_argument(
        '--option1', 
        type=str, 
        default='default_value',
        help='选项描述'
    )
    
    args = parser.parse_args()
    # Use args.option1 etc.
```

### 5. 项目结构检查

脚本应检查必要的目录和文件存在：

```python
import os
import sys

def validate_project_structure(src_dir: str) -> bool:
    """验证项目结构的完整性"""
    if not os.path.exists(src_dir):
        print(f"Error: Source directory '{src_dir}' not found", file=sys.stderr)
        return False
    return True

def main() -> None:
    if not validate_project_structure('src'):
        sys.exit(1)
    # Continue with main logic
```

## 📊 已标准化的脚本

### ✅ 完成标准化
1. **find_long_functions.py** - 长函数分析工具
   - ✅ 添加类型标注
   - ✅ 改进错误处理
   - ✅ 标准化命令行参数
   - ✅ 完善文档

2. **debug_validation_tests.py** - AST分析调试工具
   - ✅ 添加类型标注  
   - ✅ 改进异常处理
   - ✅ 标准化命令行接口
   - ✅ 完善文档

### 🔄 待标准化
- scripts/analyze_coverage.py
- scripts/token_conversion_analyzer.py  
- scripts/poetry_architecture_analysis.py
- 其他scripts/目录下的Python文件

## 🎉 预期收益

### 开发体验改善
- **一致性**: 统一的代码风格和接口
- **可靠性**: 更好的错误处理和验证
- **易用性**: 标准化的命令行参数和帮助信息

### 维护性提升
- **可读性**: 清晰的文档和类型标注
- **调试友好**: 具体的错误信息和异常处理
- **扩展性**: 标准化的结构便于修改和扩展

## 📋 实施清单

- [x] 建立标准化指南文档
- [x] 标准化find_long_functions.py
- [x] 标准化debug_validation_tests.py  
- [ ] 标准化scripts/目录下的主要分析脚本
- [ ] 创建脚本质量检查工具
- [ ] 添加pre-commit hooks进行质量控制

---

**状态**: 🔄 进行中 - Phase 1完成  
**类型**: 🔧 纯技术债务清理，无新功能添加  
**影响**: 📈 正面 - 提升开发工具质量和一致性