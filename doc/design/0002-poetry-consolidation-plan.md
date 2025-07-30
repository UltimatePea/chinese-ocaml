# Poetry模块整合重构设计方案

**作者：** Alpha，主要工作代理  
**日期：** 2025年7月29日  
**版本：** v1.0

## 1. 重构目标

将Poetry模块从当前的128个文件整合到60个以下，重点解决韵律数据的重复问题。

## 2. 现状分析

### 2.1 文件分布
```
src/poetry/
├── rhyme相关文件: 98个 (76%)
├── artistic相关文件: 15个 (12%)
├── data管理文件: 10个 (8%)
└── 其他文件: 5个 (4%)
```

### 2.2 重复度最高的模块
1. **韵律数据定义** - 20+个文件包含相似的韵组数据
2. **JSON处理逻辑** - 6个不同的rhyme_json_*模块
3. **数据加载机制** - 多个版本的data_loader

## 3. 重构策略

### 3.1 分阶段方法
- **阶段1：** 韵律数据统一化
- **阶段2：** API接口标准化  
- **阶段3：** 模块结构优化

### 3.2 保持向后兼容
- 维护现有API的兼容性层
- 逐步迁移到新的统一接口
- 保留关键功能的测试覆盖

## 4. 具体实施步骤

### 阶段1：韵律数据统一化

#### 目标文件整合
将以下重复文件：
```
- rhyme_data.ml
- poetry_rhyme_data.ml  
- consolidated_rhyme_data.ml
- unified_rhyme_data.ml
- rhyme_core_data.ml
```

整合为：
```
- poetry/core/rhyme_data_unified.ml
- poetry/core/rhyme_api_unified.ml
```

#### 数据结构设计
```ocaml
(* 统一的韵律数据类型 *)
type rhyme_group = {
  name: string;
  tone: tone_type;
  characters: string list;
  pronunciation: string option;
}

type rhyme_database = {
  groups: rhyme_group list;
  index: (string, rhyme_group) Hashtbl.t;
}
```

### 阶段2：API接口标准化

#### 统一API设计
```ocaml
module Rhyme : sig
  type t = rhyme_database
  
  val load : unit -> t
  val find_rhyme : t -> string -> rhyme_group option
  val check_rhyme : t -> string -> string -> bool
  val get_rhyme_group : t -> string -> rhyme_group option
end
```

### 阶段3：模块结构优化

#### 新的目录结构
```
src/poetry/
├── core/
│   ├── types.ml          # 核心类型定义
│   ├── rhyme_data.ml     # 统一韵律数据
│   └── rhyme_api.ml      # 统一API接口
├── analysis/
│   ├── artistic.ml       # 艺术性分析
│   └── rhythm.ml         # 韵律分析
└── data/
    └── loaders.ml        # 数据加载器
```

## 5. 测试策略

### 5.1 回归测试
- 确保所有现有诗词分析功能正常
- 验证韵律检测准确性不降低
- 测试API兼容性

### 5.2 性能测试
- 对比重构前后的编译时间
- 测试运行时性能变化
- 监控内存使用情况

## 6. 风险控制

### 6.1 备份策略
- 创建当前Poetry模块的完整备份
- 分支保护，确保main分支稳定
- 每个阶段完成后创建里程碑

### 6.2 回滚计划
- 如果重构导致功能异常，立即回滚
- 保留原有模块作为兼容性层
- 渐进式迁移，降低风险

## 7. 时间规划

### 第1周：韵律数据统一化
- 设计统一数据结构
- 合并重复的韵律数据文件
- 创建统一API接口

### 第2周：模块整合
- 重构目录结构
- 更新模块依赖关系
- 优化编译配置

### 第3周：测试和优化
- 全面回归测试
- 性能优化
- 文档更新

## 8. 成功指标

- [ ] Poetry模块文件数量减少到60个以下
- [ ] 韵律相关文件减少到30个以下  
- [ ] 编译时间减少20%以上
- [ ] 所有测试通过
- [ ] 无新增编译警告

## 9. 后续计划

重构成功后，Poetry模块将成为项目中结构最清晰、维护最便利的子系统，为其他模块的重构提供最佳实践模板。