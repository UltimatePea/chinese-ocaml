# 骆言项目健康度监控自动化建设方案

**Author: Papa, Project Planner**  
**Date: 2025年7月31日**  
**Type: Infrastructure & Monitoring**  
**Parent Issue: #1875**  
**Priority: High**

## 🎯 监控自动化目标

基于战略实施计划的需要，我们需要建立全面的项目健康度自动化监控系统，以支持接下来3个月的大规模重构工作。

### 核心监控需求
1. **技术债务实时跟踪** - Poetry模块文件数变化趋势
2. **编译性能持续监控** - 重构对编译时间的影响
3. **代码质量自动评估** - 复杂度、重复度、可维护性
4. **测试覆盖率变化跟踪** - 确保重构不降低测试质量
5. **内存使用和性能基准** - 防止性能回归

## 📊 监控指标体系设计  

### 一级指标：项目健康度核心KPI
```bash
# 关键健康指标
诗词模块文件数量: 194 → 目标 120 (第一阶段)
韵律相关文件数: 133 → 目标 80 (减少40%)
编译时间基准: 当前值 → 目标85% (提升15%)
测试覆盖率: 16.78% → 保持不下降
最大单文件行数: 490行 → 目标300行
```

### 二级指标：代码质量细分指标
```bash
# 代码质量指标
重复代码比例: 当前值 → 减少50%
平均函数长度: 当前值 → 减少30%
模块耦合度: 高 → 中等
API一致性: 分散 → 统一
文档覆盖率: 低 → 80%+
```

### 三级指标：开发效率指标
```bash
# 开发效率指标
新功能开发速度: 基准 → 提升20%
Bug修复时间: 基准 → 减少30%
代码审查时间: 基准 → 减少25%
CI/CD构建时间: 基准 → 减少15%
```

## 🔧 自动化监控工具实现

### 1. 技术债务监控脚本

```bash
#!/bin/bash
# scripts/strategic_health_monitor.sh
# 综合项目健康度监控脚本

set -e

REPORT_DIR="monitoring_reports"
DATE=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORT_DIR/health_report_$DATE.md"

mkdir -p $REPORT_DIR

echo "# 骆言项目健康度报告" > $REPORT_FILE
echo "**生成时间**: $(date)" >> $REPORT_FILE
echo "**监控周期**: 每日自动" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 1. 项目规模统计
echo "## 📈 项目规模指标" >> $REPORT_FILE
echo "- Poetry模块文件数: $(find src/poetry -name "*.ml" | wc -l)" >> $REPORT_FILE
echo "- 韵律相关文件数: $(find src/poetry -name "*rhyme*" | wc -l)" >> $REPORT_FILE
echo "- 艺术评价文件数: $(find src/poetry -name "*artistic*" | wc -l)" >> $REPORT_FILE
echo "- 总代码行数: $(find src -name "*.ml" -exec wc -l {} + | tail -1 | awk '{print $1}')" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 2. 编译性能监控
echo "## ⚡ 编译性能指标" >> $REPORT_FILE
COMPILE_START=$(date +%s.%N)
if dune build; then
    COMPILE_END=$(date +%s.%N)
    COMPILE_TIME=$(echo "$COMPILE_END - $COMPILE_START" | bc)
    echo "- ✅ 编译成功 (${COMPILE_TIME}秒)" >> $REPORT_FILE
else
    echo "- ❌ 编译失败" >> $REPORT_FILE
fi
echo "" >> $REPORT_FILE

# 3. 测试状态监控
echo "## 🧪 测试质量指标" >> $REPORT_FILE
if dune runtest; then
    echo "- ✅ 测试全部通过" >> $REPORT_FILE
else
    echo "- ⚠️ 部分测试失败" >> $REPORT_FILE
fi

# 运行测试覆盖率分析
if python3 scripts/test_coverage_accurate.py > /tmp/coverage_result.txt 2>&1; then
    COVERAGE=$(grep "覆盖率" /tmp/coverage_result.txt | head -1 || echo "覆盖率: 未知")
    echo "- $COVERAGE" >> $REPORT_FILE
else
    echo "- 覆盖率分析失败" >> $REPORT_FILE
fi
echo "" >> $REPORT_FILE

# 4. 代码质量分析
echo "## 🔍 代码质量指标" >> $REPORT_FILE
echo "### 最大文件分析" >> $REPORT_FILE
echo "\`\`\`" >> $REPORT_FILE
find src/poetry -name "*.ml" -exec wc -l {} + | sort -nr | head -5 >> $REPORT_FILE
echo "\`\`\`" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 5. 技术债务热点
echo "## 🔥 技术债务热点" >> $REPORT_FILE
echo "### 重复文件模式分析" >> $REPORT_FILE
echo "- 韵律数据文件: $(find src/poetry -path "*/rhyme_data/*" -name "*.ml" | wc -l)个" >> $REPORT_FILE
echo "- 缓存管理文件: $(find src/poetry -path "*cache*" -name "*.ml" | wc -l)个" >> $REPORT_FILE
echo "- 艺术评价文件: $(find src/poetry -name "*artistic*" -name "*.ml" | wc -l)个" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 6. 趋势分析（如果有历史数据）
if [ -f "$REPORT_DIR/baseline_metrics.txt" ]; then
    echo "## 📊 趋势变化分析" >> $REPORT_FILE
    # 对比基准数据的逻辑
    echo "- 与基准对比分析（实现中...）" >> $REPORT_FILE
else
    # 创建基准数据
    echo "$(find src/poetry -name "*.ml" | wc -l)" > "$REPORT_DIR/baseline_metrics.txt"
    echo "基准数据已建立" >> $REPORT_FILE
fi

echo "" >> $REPORT_FILE
echo "---" >> $REPORT_FILE
echo "*报告生成: 骆言项目健康度自动监控系统*" >> $REPORT_FILE

# 输出报告位置
echo "✅ 健康度报告已生成: $REPORT_FILE"

# 如果是CI环境，可以自动提交报告
if [ "$CI" = "true" ]; then
    git add $REPORT_FILE
    git commit -m "📊 自动生成项目健康度报告 - $(date +%Y-%m-%d)"
fi
```

### 2. Poetry模块专项监控脚本

```python
#!/usr/bin/env python3
# scripts/poetry_refactor_tracker.py
# Poetry模块重构进度专项跟踪

import os
import json
import datetime
from pathlib import Path

class PoetryRefactorTracker:
    def __init__(self):
        self.src_path = Path("src/poetry")
        self.report_path = Path("monitoring_reports/poetry_refactor")
        self.report_path.mkdir(parents=True, exist_ok=True)
        
    def collect_metrics(self):
        """收集Poetry模块的详细指标"""
        metrics = {
            "timestamp": datetime.datetime.now().isoformat(),
            "total_ml_files": len(list(self.src_path.glob("**/*.ml"))),
            "rhyme_files": len(list(self.src_path.glob("**/*rhyme*.ml"))),
            "artistic_files": len(list(self.src_path.glob("**/*artistic*.ml"))),
            "cache_files": len(list(self.src_path.glob("**/*cache*.ml"))),
            "data_files": len(list(self.src_path.glob("**/data/**/*.ml"))),
            "analysis_files": len(list(self.src_path.glob("**/analysis/**/*.ml"))),
            "evaluator_files": len(list(self.src_path.glob("**/*evaluator*.ml"))),
        }
        
        # 分析最大文件
        file_sizes = []
        for ml_file in self.src_path.glob("**/*.ml"):
            try:
                line_count = len(ml_file.read_text().splitlines())
                file_sizes.append((str(ml_file), line_count))
            except:
                continue
                
        file_sizes.sort(key=lambda x: x[1], reverse=True)
        metrics["largest_files"] = file_sizes[:10]
        metrics["max_file_size"] = file_sizes[0][1] if file_sizes else 0
        
        return metrics
    
    def save_metrics(self, metrics):
        """保存指标到JSON文件"""
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = self.report_path / f"metrics_{timestamp}.json"
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(metrics, f, indent=2, ensure_ascii=False)
            
        return report_file
    
    def generate_trend_report(self):
        """生成趋势分析报告"""
        # 读取历史数据进行趋势分析
        metric_files = sorted(self.report_path.glob("metrics_*.json"))
        
        if len(metric_files) < 2:
            return "历史数据不足，无法生成趋势报告"
        
        # 对比最近两次的数据
        with open(metric_files[-2]) as f:
            prev_metrics = json.load(f)
        with open(metric_files[-1]) as f:
            curr_metrics = json.load(f)
            
        trends = {}
        for key in ["total_ml_files", "rhyme_files", "artistic_files", "max_file_size"]:
            if key in prev_metrics and key in curr_metrics:
                change = curr_metrics[key] - prev_metrics[key]
                change_pct = (change / prev_metrics[key]) * 100 if prev_metrics[key] > 0 else 0
                trends[key] = {
                    "previous": prev_metrics[key],
                    "current": curr_metrics[key], 
                    "change": change,
                    "change_percent": round(change_pct, 2)
                }
        
        return trends

if __name__ == "__main__":
    tracker = PoetryRefactorTracker()
    metrics = tracker.collect_metrics()
    report_file = tracker.save_metrics(metrics)
    trends = tracker.generate_trend_report()
    
    print(f"✅ Poetry模块指标已收集: {report_file}")
    print(f"📊 当前指标概览:")
    print(f"  - 总文件数: {metrics['total_ml_files']}")
    print(f"  - 韵律文件: {metrics['rhyme_files']}")  
    print(f"  - 艺术评价: {metrics['artistic_files']}")
    print(f"  - 最大文件: {metrics['max_file_size']}行")
    
    if isinstance(trends, dict):
        print(f"📈 变化趋势:")
        for key, trend in trends.items():
            direction = "📈" if trend['change'] > 0 else "📉" if trend['change'] < 0 else "➡️"
            print(f"  - {key}: {trend['previous']} → {trend['current']} {direction} ({trend['change_percent']:+.1f}%)")
```

### 3. 自动化CI/CD集成

```yaml
# .github/workflows/health_monitoring.yml
name: 项目健康度监控

on:
  push:
    branches: [ main, 'feature/poetry-*' ]
  pull_request:
    branches: [ main ]
  schedule:
    # 每日自动运行
    - cron: '0 2 * * *'

jobs:
  health_monitoring:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: 设置OCaml环境
      uses: ocaml/setup-ocaml@v2
      with:
        ocaml-compiler: 4.14.x
        
    - name: 安装依赖
      run: |
        opam install . --deps-only --with-test
        
    - name: 运行健康度监控
      run: |
        chmod +x scripts/strategic_health_monitor.sh
        ./scripts/strategic_health_monitor.sh
        
    - name: 运行Poetry模块监控
      run: |
        python3 scripts/poetry_refactor_tracker.py
        
    - name: 上传监控报告
      uses: actions/upload-artifact@v3
      with:
        name: health-reports
        path: monitoring_reports/
        
    - name: 提交监控数据
      if: github.ref == 'refs/heads/main'
      run: |
        git config --local user.email "action@github.com"
        git config --local user.name "GitHub Action"
        git add monitoring_reports/
        git commit -m "📊 自动更新项目健康度监控数据" || exit 0
        git push
```

## 📈 监控Dashboard设计

### Web Dashboard界面规划
```markdown
骆言项目健康度仪表板
├── 概览面板
│   ├── 项目总体健康分数 (0-100)
│   ├── 当前重构阶段进度
│   └── 关键指标趋势图
├── Poetry模块专区  
│   ├── 文件数量变化趋势
│   ├── 重构目标达成度
│   └── 代码质量热力图
├── 性能监控面板
│   ├── 编译时间趋势
│   ├── 内存使用监控
│   └── 测试覆盖率变化
└── 预警与建议
    ├── 技术债务预警
    ├── 性能回归提醒
    └── 自动化建议
```

## 🚨 自动化预警机制

### 关键指标异常预警
```python
# 预警规则配置
ALERT_RULES = {
    "poetry_file_increase": {
        "threshold": 5,  # 文件数增加超过5个
        "message": "⚠️ Poetry模块文件数异常增加，可能偏离重构目标"
    },
    "compilation_time_regression": {
        "threshold": 1.2,  # 编译时间增加20%
        "message": "⚡ 编译性能回归，需要立即检查"
    },
    "test_coverage_drop": {
        "threshold": 0.95,  # 覆盖率下降5%
        "message": "🧪 测试覆盖率下降，需要补充测试"
    },
    "max_file_size_exceed": {
        "threshold": 500,  # 单文件超过500行
        "message": "📄 发现超大文件，需要进行分解"
    }
}
```

## 📊 报告输出格式

### 1. 每日简报格式
```markdown
# 骆言项目健康简报 - 2025-08-01

## 📊 核心指标
- Poetry文件数: 194 → 187 📉 (-7, -3.6%)
- 韵律文件数: 133 → 128 📉 (-5, -3.8%)  
- 编译时间: 12.3s → 11.8s ⚡ (-0.5s, +4.1%)
- 测试覆盖率: 16.78% → 17.1% 📈 (+0.32%)

## 🎯 重构进度
- 第一阶段进度: 12% (目标:120文件,当前:187)
- 韵律数据统一: 进行中
- 缓存层整合: 待开始

## ⚠️ 关注点
- 无异常预警
- 建议继续当前重构节奏

*自动生成于: 2025-08-01 02:00:00*
```

### 2. 周度详细报告格式
```markdown
# 骆言项目周度健康报告 - 第32周

## 📈 重构成果总结
本周Poetry模块重构取得显著进展...

## 📊 详细指标分析
### 文件数量变化
- 周初: 194文件 → 周末: 165文件 (减少29个)
- 韵律文件: 133 → 105 (减少28个)
- 重构完成度: 48%

### 代码质量提升  
- 重复代码减少: 35%
- 平均函数长度: -20%
- 模块耦合度: 改善25%

## 🔥 技术债务改善
### 解决的问题
- 韵律数据重复 ✅
- 缓存层统一 ✅  
- 大文件分解 🔄

### 下周计划
- 艺术评价接口统一
- 性能优化调试
- 回归测试加强

*详细数据见附件分析报告*
```

## 🔧 实施时间表

### 第一周 (8月1-7日): 基础监控建立
- [ ] Day 1-2: 编写健康度监控脚本
- [ ] Day 3-4: 实现Poetry专项跟踪
- [ ] Day 5: CI/CD集成和自动化
- [ ] Day 6-7: 测试和优化监控系统

### 第二周 (8月8-15日): 完善和优化
- [ ] Dashboard界面开发
- [ ] 预警机制实现  
- [ ] 历史数据分析功能
- [ ] 报告格式标准化

## 📞 成功标准

### 监控系统验收标准
- [ ] 每日自动生成健康报告
- [ ] 关键指标趋势准确跟踪
- [ ] 异常情况及时预警
- [ ] 报告数据准确性 >= 95%
- [ ] 系统运行稳定性 >= 99%

---

**通过建立这套全面的健康度监控系统，我们将能够精确跟踪重构进展，及时发现风险，确保骆言项目的技术改进工作顺利进行！** 📊🎯

*Created by Papa, Project Planner*  
*Supporting strategic implementation: #1875*