#!/usr/bin/env python3
"""
Token系统重组迁移脚本

基于Delta专员Issue #1359的分析，将分散的token相关文件整合到统一的目录结构中

Author: Alpha, 主要实现专员
"""

import os
import shutil
import glob
from pathlib import Path

# 项目根目录
PROJECT_ROOT = Path(__file__).parent.parent
SRC_DIR = PROJECT_ROOT / "src"
NEW_TOKEN_DIR = SRC_DIR / "token_system_unified"

def ensure_dir(path):
    """确保目录存在"""
    path.mkdir(parents=True, exist_ok=True)

def migrate_token_files():
    """迁移分散的token文件到统一目录结构"""
    
    print("🚀 开始Token系统重组迁移...")
    
    # 确保新目录结构存在
    for subdir in ["core", "conversion", "mapping", "utils"]:
        ensure_dir(NEW_TOKEN_DIR / subdir)
    
    # 迁移计划
    migration_plan = {
        # 核心Token定义和类型 -> core/
        "core": [
            "src/token_types.ml",
            "src/token_types.mli", 
            "src/unified_token_core.ml",
            "src/unified_token_core.mli",
            "src/token_types_core.ml",
            "src/token_types_core.mli",
            "src/tokens/core/*",
            "src/token_system/core/*"
        ],
        
        # Token转换和兼容性 -> conversion/
        "conversion": [
            "src/token_conversion_*.ml",
            "src/token_conversion_*.mli",
            "src/token_compatibility*.ml", 
            "src/token_compatibility*.mli",
            "src/tokens/conversion/*",
            "src/token_system/conversion/*",
            "src/token_system/compatibility/*"
        ],
        
        # Token映射和注册 -> mapping/
        "mapping": [
            "src/lexer/token_mapping/*",
            "src/tokens/mapping/*",
            "src/unified_token_registry.ml",
            "src/unified_token_registry.mli"
        ],
        
        # Token工具和辅助功能 -> utils/
        "utils": [
            "src/token_string_converter.ml",
            "src/token_string_converter.mli",
            "src/token_utils_core.ml", 
            "src/token_utils_core.mli",
            "src/token_dispatcher.ml",
            "src/parser_expressions_token_reducer.ml",
            "src/parser_expressions_token_reducer.mli",
            "src/tokens/delimiter_tokens.ml",
            "src/tokens/delimiter_tokens.mli",
            "src/tokens/identifier_tokens.ml",
            "src/tokens/identifier_tokens.mli",
            "src/tokens/keyword_tokens.ml",
            "src/tokens/keyword_tokens.mli",
            "src/tokens/literal_tokens.ml",
            "src/tokens/literal_tokens.mli",
            "src/tokens/operator_tokens.ml",
            "src/tokens/operator_tokens.mli",
            "src/tokens/natural_language_tokens.ml",
            "src/tokens/natural_language_tokens.mli",
            "src/tokens/poetry_tokens.ml",
            "src/tokens/poetry_tokens.mli",
            "src/tokens/wenyan_tokens.ml",
            "src/tokens/wenyan_tokens.mli",
            "src/tokens/unified_tokens.ml",
            "src/tokens/unified_tokens.mli",
            "src/token_system/utils/*"
        ]
    }
    
    # 记录迁移情况
    migration_log = []
    
    for target_dir, patterns in migration_plan.items():
        target_path = NEW_TOKEN_DIR / target_dir
        print(f"\n📁 迁移到 {target_dir}/")
        
        for pattern in patterns:
            # 处理通配符模式
            if "*" in pattern:
                files = glob.glob(str(PROJECT_ROOT / pattern))
            else:
                files = [str(PROJECT_ROOT / pattern)]
            
            for file_path in files:
                if os.path.exists(file_path) and os.path.isfile(file_path):
                    filename = os.path.basename(file_path)
                    target_file = target_path / filename
                    
                    # 避免重复文件
                    if target_file.exists():
                        print(f"   ⚠️  跳过已存在文件: {filename}")
                        continue
                    
                    try:
                        shutil.copy2(file_path, target_file)
                        migration_log.append(f"MOVED: {file_path} -> {target_file}")
                        print(f"   ✅ {filename}")
                    except Exception as e:
                        print(f"   ❌ 迁移失败 {filename}: {e}")
                        migration_log.append(f"ERROR: {file_path} -> {e}")
    
    # 保存迁移日志
    log_file = PROJECT_ROOT / "doc" / "migration_log.txt"
    with open(log_file, "w", encoding="utf-8") as f:
        f.write("Token系统重组迁移日志\n")
        f.write("=" * 50 + "\n\n")
        for entry in migration_log:
            f.write(entry + "\n")
    
    print(f"\n📝 迁移日志已保存到: {log_file}")
    
    # 创建新的dune配置
    create_unified_dune_configs()
    
    print("\n🎉 Token系统重组迁移完成！")

def create_unified_dune_configs():
    """创建统一的dune配置文件"""
    
    # 主token_system_unified dune配置
    main_dune = """(library
 (public_name chinese-ocaml.token_system_unified)
 (name token_system_unified)
 (libraries 
   token_system_unified.core
   token_system_unified.conversion
   token_system_unified.mapping
   token_system_unified.utils))
"""
    
    # core子模块dune配置
    core_dune = """(library
 (public_name chinese-ocaml.token_system_unified.core)
 (name token_system_unified_core)
 (libraries))
"""
    
    # conversion子模块dune配置
    conversion_dune = """(library
 (public_name chinese-ocaml.token_system_unified.conversion)
 (name token_system_unified_conversion)  
 (libraries token_system_unified.core))
"""
    
    # mapping子模块dune配置
    mapping_dune = """(library
 (public_name chinese-ocaml.token_system_unified.mapping)
 (name token_system_unified_mapping)
 (libraries token_system_unified.core))
"""
    
    # utils子模块dune配置
    utils_dune = """(library
 (public_name chinese-ocaml.token_system_unified.utils)
 (name token_system_unified_utils)
 (libraries 
   token_system_unified.core
   token_system_unified.conversion
   token_system_unified.mapping))
"""
    
    # 写入dune配置文件
    configs = {
        NEW_TOKEN_DIR / "dune": main_dune,
        NEW_TOKEN_DIR / "core" / "dune": core_dune,
        NEW_TOKEN_DIR / "conversion" / "dune": conversion_dune,
        NEW_TOKEN_DIR / "mapping" / "dune": mapping_dune,
        NEW_TOKEN_DIR / "utils" / "dune": utils_dune
    }
    
    for path, content in configs.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, "w") as f:
            f.write(content)
        print(f"   ✅ 创建dune配置: {path}")

def analyze_current_structure():
    """分析当前token文件分布情况"""
    print("🔍 分析当前Token文件分布...")
    
    token_files = []
    for root, dirs, files in os.walk(SRC_DIR):
        for file in files:
            if "token" in file.lower() and (file.endswith(".ml") or file.endswith(".mli")):
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, PROJECT_ROOT)
                token_files.append(rel_path)
    
    print(f"📊 发现 {len(token_files)} 个token相关文件")
    
    # 按目录分组
    by_directory = {}
    for file_path in token_files:
        directory = os.path.dirname(file_path)
        if directory not in by_directory:
            by_directory[directory] = []
        by_directory[directory].append(os.path.basename(file_path))
    
    print("\n📁 目录分布:")
    for directory, files in sorted(by_directory.items()):
        print(f"   {directory}/ ({len(files)} files)")
        for file in sorted(files)[:3]:  # 只显示前3个文件
            print(f"     - {file}")
        if len(files) > 3:
            print(f"     - ... 还有 {len(files)-3} 个文件")

if __name__ == "__main__":
    print("🚀 Token系统重组迁移脚本")
    print("=" * 50)
    
    # 首先分析当前结构
    analyze_current_structure()
    
    # 自动执行迁移
    print("\n🚀 自动执行迁移...")
    migrate_token_files()