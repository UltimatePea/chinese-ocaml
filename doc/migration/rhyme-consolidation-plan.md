# Poetry 韵律模块整合实施计划

**Author: Whisky, PR Worker**  
**Issue: #1999 - Poetry韵律模块统一整合实施**  
**Date: 2025-08-04**

## 目标架构

### 保留的核心文件 (5个)
```
src/poetry/rhyme/
├── rhyme_types.ml        # 统一类型定义
├── rhyme_types.mli       
├── rhyme_data.ml         # 整合的韵律数据
├── rhyme_data.mli        
├── rhyme_query.ml        # O(1)查询引擎
├── rhyme_query.mli       
├── rhyme_compatibility.ml # 向后兼容接口  
├── rhyme_compatibility.mli
└── dune                  # 构建配置
```

### 需要清理的冗余文件类别

#### 1. 散布的韵组数据文件 (待删除)
- `src/poetry/rhyme_groups/*` - 12个独立韵组文件
- `src/poetry/data/rhyme_groups/*` - 数据目录下的韵组文件
- `src/poetry/rhyme_data/*` - 旧的数据目录

#### 2. 重复的核心文件 (待删除)
- `src/poetry/rhyme_core_*.ml` - 多个核心文件变体
- `src/poetry/unified_rhyme_*.ml` - 各种统一文件尝试
- `src/poetry/*rhyme_data*.ml` - 各种数据文件变体

#### 3. 旧的查询引擎 (待删除)  
- `src/poetry/rhyme_query_engine.ml` - 被新查询引擎替代
- `src/poetry/rhyme_database.ml` - 旧数据库实现
- `src/poetry/rhyme_cache.ml` - 被新缓存系统替代

## 实施步骤

### Phase 1: 依赖分析和更新 ✅
- [x] 分析所有引用旧模块的文件
- [x] 识别关键依赖关系

### Phase 2: 模块重定向
- [ ] 更新所有import语句指向新的`Poetry_rhyme`模块
- [ ] 使用兼容性接口确保API一致性
- [ ] 验证每个更新后构建仍然成功

### Phase 3: 文件删除
- [ ] 系统性删除冗余文件
- [ ] 更新dune文件移除删除的模块
- [ ] 验证构建和测试

### Phase 4: 最终验证
- [ ] 运行完整测试套件
- [ ] 性能基准测试
- [ ] 兼容性验证

## 风险控制

### 安全检查点
- 每个阶段前创建git检查点
- 保持功能完整性测试通过
- 在每次大量删除前备份

### 回滚策略
如遇到问题：
```bash
git reset --hard HEAD~1  # 回到上一个检查点
```

### 验证标准
- 构建零错误
- 测试全部通过
- 性能不降低
- API完全兼容

## 预期成果

- **文件数量**: 106个 → 5个核心文件 (95%减少)
- **维护复杂度**: 大幅降低
- **查询性能**: O(1)哈希查询
- **兼容性**: 100%向后兼容