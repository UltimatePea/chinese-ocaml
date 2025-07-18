# 项目分析脚本

这个目录包含了用于分析骆言项目代码质量和技术债务的Python脚本。

## 脚本说明

### 技术债务分析脚本
- `analyze_technical_debt.py` - 综合技术债务分析
- `analyze_code_quality.py` - 代码质量分析
- `analyze_code_complexity.py` - 代码复杂度分析
- `analyze_code_duplication.py` - 代码重复分析

### 长函数分析脚本
- `analyze_long_functions.py` - 长函数基础分析
- `analyze_long_functions_comprehensive.py` - 长函数综合分析
- `comprehensive_long_function_analysis.py` - 长函数深度分析
- `find_long_functions.py` - 查找长函数
- `find_long_functions_systematic.py` - 系统化查找长函数
- `find_actual_long_functions.py` - 实际长函数查找

### 深度嵌套和错误处理分析
- `analyze_deep_nesting.py` - 深度嵌套分析
- `analyze_error_handling.py` - 错误处理分析
- `analyze_complex_patterns.py` - 复杂模式分析

### 工具脚本
- `comprehensive_analysis.py` - 综合代码分析
- `add_comment.py` - 添加注释工具

## 使用方法

这些脚本主要用于开发期间的代码质量分析。运行脚本前请确保：

1. 在项目根目录执行
2. 已安装必要的Python依赖

```bash
# 回到项目根目录
cd ..

# 运行分析脚本
python scripts/analysis/analyze_technical_debt.py
```

## 注意事项

- 这些脚本是开发工具，不影响项目的核心功能
- 分析结果仅供参考，需要结合实际情况判断
- 建议定期运行这些脚本来监控代码质量

## 维护说明

这些脚本会随着项目的发展而持续更新和改进。如果发现问题或有改进建议，请在项目的issue中反馈。