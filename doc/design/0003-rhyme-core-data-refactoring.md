# 韵律核心数据模块重构设计方案

**Issue**: #1384  
**文件**: `src/poetry/core/rhyme_core_data.ml` (728行)  
**目标**: 将大型数据文件按功能域模块化，提高可维护性

## 当前问题分析

### 文件结构分析
- **总行数**: 728行
- **let绑定数量**: 40个
- **主要内容**: 中文诗词韵律数据定义
- **数据组织**: 按韵组(AnRhyme、SiRhyme等)分类

### 主要问题
1. **单文件过大**: 728行代码难以维护和导航
2. **数据集中**: 所有韵组数据混在一个文件中
3. **缺乏模块边界**: 不同韵组的数据耦合在一起
4. **查找效率**: 需要在大文件中定位特定韵组数据

## 重构设计方案

### 第一阶段：数据分离
按韵组将数据分解为独立模块：

```
src/poetry/core/
├── rhyme_core_data.ml (保留为统一接口)
├── rhyme_groups/
│   ├── an_rhyme_data.ml     (安韵组数据)
│   ├── si_rhyme_data.ml     (思韵组数据) 
│   ├── yu_rhyme_data.ml     (鱼韵组数据)
│   ├── dong_rhyme_data.ml   (东韵组数据)
│   └── dune                 (构建配置)
└── rhyme_core_interface.ml  (统一数据访问接口)
```

### 第二阶段：接口统一
创建统一的数据访问接口：

```ocaml
(* rhyme_core_interface.ml *)
module type RhymeGroupData = sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list  
  val ping_sheng_data : rhyme_data_entry list
  val ze_sheng_data : rhyme_data_entry list
end

module An_Rhyme : RhymeGroupData
module Si_Rhyme : RhymeGroupData
(* ... 其他韵组 *)
```

### 第三阶段：主文件重构
将主文件转换为数据聚合器：

```ocaml
(* rhyme_core_data.ml - 重构后 *)
open Rhyme_core_types
include Rhyme_core_interface

(* 聚合所有韵组数据 *)
let all_rhyme_data = 
  An_Rhyme.ping_sheng_data @ An_Rhyme.ze_sheng_data @
  Si_Rhyme.ping_sheng_data @ Si_Rhyme.ze_sheng_data @
  (* ... 其他韵组数据 *)

(* 保持现有API兼容性 *)
let character_lookup_map = (* 现有实现 *)
let find_character_rhyme_fast = (* 现有实现 *)
```

## 实施计划

### 步骤1：创建韵组模块目录
- 创建 `src/poetry/core/rhyme_groups/` 目录
- 设置dune构建配置

### 步骤2：提取安韵组数据
- 创建 `an_rhyme_data.ml`
- 从原文件迁移安韵组相关数据
- 验证数据完整性

### 步骤3：提取其他韵组
- 按相同模式提取思韵组、鱼韵组等
- 每个韵组独立验证

### 步骤4：重构主文件
- 修改 `rhyme_core_data.ml` 使用新模块
- 保持现有API不变
- 确保向后兼容性

### 步骤5：测试验证
- 运行所有相关测试
- 验证性能无降级
- 确保构建成功

## 预期收益

### 可维护性提升
- **文件大小**: 从728行分解为多个<150行的模块
- **模块职责**: 每个模块只负责一个韵组的数据
- **导航效率**: 开发者可快速定位特定韵组

### 开发效率提升  
- **并行开发**: 不同韵组可并行维护
- **数据更新**: 更新特定韵组不影响其他韵组
- **错误隔离**: 数据错误影响范围限制在单个韵组

### 架构优势
- **模块化设计**: 符合OCaml最佳实践
- **接口统一**: 统一的韵组数据访问模式
- **扩展性**: 新增韵组只需添加新模块

## 风险缓解

### 兼容性风险
- **缓解措施**: 保持原有API不变
- **验证方法**: 所有现有测试必须通过

### 性能风险
- **潜在影响**: 模块加载可能影响启动时间
- **缓解措施**: 使用延迟加载，按需初始化数据

### 构建风险
- **潜在问题**: dune配置可能需要调整
- **缓解措施**: 渐进式迁移，每步验证构建

## 成功标准

1. ✅ 所有现有测试通过
2. ✅ 构建无警告无错误  
3. ✅ 主文件行数减少至<200行
4. ✅ 每个韵组模块<150行
5. ✅ 性能测试无回归
6. ✅ API兼容性100%保持

---

**Author**: Alpha专员, 主要工作代理  
**Date**: 2025-07-26  
**Status**: 设计阶段