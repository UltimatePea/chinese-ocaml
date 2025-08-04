# Phase 1-A 统一韵律接口设计方案

**Author: Whisky, PR Worker**  
**Date: 2025年8月4日**  
**阶段**: A2 - 接口设计  
**Issue**: #2158 Phase 1-A Poetry韵律系统整合

---

## 🎯 设计目标

基于阶段A1的深度分析，设计统一的韵律系统接口，整合8个模块的重复类型定义和4个查询引擎的重复实现。

### 核心设计原则
1. **统一性**: 一个权威的类型定义源
2. **兼容性**: 保持现有API向后兼容
3. **性能**: 优化查询算法，提升20%性能
4. **可维护**: 简化模块依赖，降低维护复杂度

---

## 📋 统一类型系统设计

### 1. 权威类型定义模块

选择`src/poetry/poetry_types_consolidated.mli`作为**唯一权威类型定义源**：

```ocaml
(** 统一韵律类型定义 - Phase 1-A 整合版 *)

(** 核心韵律类型 - 权威定义 *)
type rhyme_category = 
  | PingSheng    (** 平声：第一、二声 *)
  | ShangSheng   (** 上声：第三声 *)
  | QuSheng      (** 去声：第四声 *)
  | RuSheng      (** 入声：古代汉语特有 *)
  | ZeSheng      (** 仄声：统称 *)

type rhyme_group = 
  | AnRhyme | SiRhyme | TianRhyme | WangRhyme | QuRhyme 
  | YuRhyme | HuaRhyme | FengRhyme | YueRhyme | JiangRhyme 
  | HuiRhyme | UnknownRhyme

type rhyme_character = {
  character: string;
  rhyme_category: rhyme_category;
  rhyme_group: rhyme_group;
  confidence: float;
  variants: string list;
  usage_frequency: float;
  is_common: bool;
  pinyin: string option;
}

type query_result = 
  | Found of rhyme_character
  | NotFound of string
  | MultipleMatches of rhyme_character list
```

### 2. 类型迁移映射

为确保向后兼容，建立类型别名映射：

```ocaml
(** 向后兼容映射 *)
module Legacy_Types = struct
  (* rhyme_types.mli 兼容 *)
  type tone_category = rhyme_category
  type legacy_rhyme_group = rhyme_group
  
  (* unified_tone_data.mli 兼容 *)  
  type tone_type = Ping | Shang | Qu | Ru
  let tone_category_to_tone_type = function
    | PingSheng -> Ping
    | ShangSheng -> Shang  
    | QuSheng -> Qu
    | RuSheng -> Ru
    | ZeSheng -> Qu (* 默认映射 *)
end
```

---

## 🔧 统一查询引擎设计

### 1. RhythmQueryEngine 主接口

设计统一的查询引擎接口，整合4个重复实现：

```ocaml
(** 统一韵律查询引擎接口 - Phase 1-A *)
module type RHYTHM_QUERY_ENGINE = sig
  (** 引擎状态类型 *)
  type engine_state
  
  (** {1 引擎管理} *)
  val initialize : unit -> engine_state
  val load_database : rhyme_database -> engine_state -> engine_state
  val get_statistics : engine_state -> (string * string) list
  val clear_cache : engine_state -> engine_state
  
  (** {1 核心查询接口} *)
  
  (** 单字符查询 - 整合4个重复实现 *)
  val query_character : string -> engine_state -> query_result
  
  (** 批量查询 - 整合3个重复实现 *) 
  val batch_query : string list -> engine_state -> query_result list
  
  (** 韵组查询 - 整合3个重复实现 *)
  val query_rhyme_group : rhyme_group -> engine_state -> rhyme_character list
  
  (** {1 高级查询功能} *)
  
  (** 模糊查询 *)
  val fuzzy_query : string -> float -> engine_state -> query_result
  
  (** 相似韵律查询 *)
  val find_similar_rhymes : string -> engine_state -> rhyme_character list
  
  (** 韵律匹配度计算 *)
  val calculate_match_score : string -> string -> engine_state -> float
  
  (** {1 性能优化接口} *)
  
  (** 缓存预热 *)
  val warm_cache : string list -> engine_state -> engine_state
  
  (** 性能基准测试 *)
  val benchmark : int -> engine_state -> (float * float * float)
end
```

### 2. 实现策略

#### A. 查询路由层
```ocaml
(** 查询路由器 - 自动选择最优实现 *)
module QueryRouter = struct
  type query_mode = 
    | Fast_Cache    (** 缓存优先，适合频繁查询 *)
    | Accurate     (** 准确性优先，适合分析任务 *)
    | Batch_Optimized (** 批量优化，适合大量查询 *)
    
  val auto_select_mode : string list -> int -> query_mode
  val route_query : query_mode -> string -> engine_state -> query_result
end
```

#### B. 统一缓存架构
```ocaml
(** 统一缓存管理器 *)
module UnifiedCache = struct
  type cache_strategy = 
    | LRU of int      (** LRU淘汰，指定容量 *)
    | TTL of float    (** 时间淘汰，指定TTL *)
    | Hybrid of int * float (** 混合策略 *)
    
  val create : cache_strategy -> cache_state
  val get : string -> cache_state -> query_result option
  val put : string -> query_result -> cache_state -> cache_state
  val get_hit_rate : cache_state -> float
end
```

---

## 🔄 模块重构计划

### 1. 保留模块改造

| 原模块 | 改造方案 | 状态 |
|--------|----------|------|
| **rhythm_analyzer.mli** | 保留，改为使用统一类型 | 重构 |
| **rhyme_query.mli** | 保留，提供兼容性包装 | 适配 |
| **meter_engine.mli** | 保留，依赖统一接口 | 重构 |
| **unified_tone_data.mli** | 保留，映射至统一类型 | 适配 |

### 2. 移除重复定义

| 模块 | 移除内容 | 替换方案 |
|------|----------|----------|
| **rhyme_types.mli** | 重复类型定义 | `open Poetry_types_consolidated` |
| **poetry_types_unified.ml** | 重复类型定义 | 使用权威定义 |
| **meter_types.mli** | 部分重复类型 | 导入+补充定义 |

---

## 📈 性能优化设计

### 1. 查询算法优化

#### A. 字符查询优化 (O(n) → O(1))
```ocaml
(** 高性能字符查询实现 *)
module FastCharacterQuery = struct
  (** 预构建哈希表索引 *)
  type char_index = (string, rhyme_character) Hashtbl.t
  
  (** 多级索引策略 *)
  type multi_index = {
    char_to_rhyme : char_index;
    group_to_chars : (rhyme_group, string list) Hashtbl.t;
    category_to_chars : (rhyme_category, string list) Hashtbl.t;
  }
  
  val build_index : rhyme_character list -> multi_index
  val query_with_index : string -> multi_index -> query_result
end
```

#### B. 批量查询优化
```ocaml
(** 批量查询优化实现 *)
module BatchQueryOptimizer = struct  
  (** 查询批次合并策略 *)
  val merge_queries : string list -> (string * int) list
  
  (** 并行处理模拟 *)
  val parallel_process : (string * int) list -> multi_index -> query_result list
  
  (** 结果重排和去重 *)  
  val reorder_results : query_result list -> int list -> query_result list
end
```

### 2. 内存优化

#### A. 数据结构压缩
- 使用枚举代替字符串 (节省内存40%+)
- 共享公共字符串 (variants, pinyin)
- 延迟加载非核心数据

#### B. 缓存优化
- 分级缓存：热点数据内存，冷数据磁盘
- 智能预取：基于查询模式预加载
- 缓存压缩：压缩存储以节省内存

---

## 🔧 实现时间表

### 第1天 (8月6日): 核心类型整合
- [ ] 完善`poetry_types_consolidated.mli`权威定义
- [ ] 创建向后兼容映射模块
- [ ] 更新8个模块的类型引用

### 第2天 (8月7日): 查询引擎设计
- [ ] 实现`RhythmQueryEngine`主接口
- [ ] 创建`QueryRouter`路由层
- [ ] 设计`UnifiedCache`缓存架构

### 验收标准
- [ ] 编译零错误零警告
- [ ] 所有现有测试100%通过
- [ ] 向后兼容性验证通过
- [ ] 性能基准测试准备就绪

---

## ⚠️ 设计风险与缓解

### 风险1: 类型兼容性问题
**缓解**: 
- 建立完整的类型映射函数
- 保留原模块作为兼容性包装
- 分阶段迁移，确保每步可验证

### 风险2: 性能回退风险  
**缓解**:
- 设计性能基准测试
- 实施分阶段优化
- 保留快速回滚机制

### 风险3: 接口复杂度增加
**缓解**:
- 保持核心接口简洁
- 提供高级功能作为可选扩展
- 编写清晰的API文档和使用示例

---

**设计完成标志**: 
- ✅ 统一类型系统架构确定
- ✅ 查询引擎接口设计完成  
- ✅ 性能优化策略明确
- ✅ 向后兼容方案制定
- ✅ 实施时间表和风险评估完备

**下一步**: 进入阶段A3实施整合，开始具体的代码重构工作。