#!/usr/bin/env python3
"""
覆盖率数据验证器
用于确保覆盖率数据的准确性并防止虚假报告

Author: Whisky, PR Worker
"""

import os
import re
import subprocess
import json
from datetime import datetime
from typing import Dict, List, Optional, Tuple


class CoverageDataValidator:
    """覆盖率数据验证器"""
    
    def __init__(self, project_root: str = "."):
        self.project_root = project_root
        self.coverage_data_file = os.path.join(project_root, "coverage_reports/data/latest_coverage.txt")
        self.validation_history = os.path.join(project_root, "coverage_reports/data/validation_history.json")
    
    def get_real_coverage_from_bisect(self) -> Optional[Tuple[float, str]]:
        """从bisect-ppx获取真实覆盖率数据"""
        try:
            # 检查是否有覆盖率文件
            coverage_files = subprocess.run(
                ["find", "_build", "-name", "*.coverage"],
                capture_output=True, text=True, cwd=self.project_root
            )
            
            if not coverage_files.stdout.strip():
                return None
                
            # 获取覆盖率报告
            result = subprocess.run([
                "dune", "exec", "--", "bisect-ppx-report", "summary", 
                "--coverage-path=_build/default/test"
            ], capture_output=True, text=True, cwd=self.project_root)
            
            if result.returncode != 0:
                return None
                
            # 解析覆盖率数据
            output = result.stdout.strip()
            match = re.search(r'Coverage:\s*(\d+)/(\d+)\s*\(([0-9.]+)%\)', output)
            if match:
                covered = int(match.group(1))
                total = int(match.group(2))
                percentage = float(match.group(3))
                return percentage, f"{covered}/{total}"
            
            return None
            
        except Exception as e:
            print(f"❌ 获取bisect覆盖率数据失败: {e}")
            return None
    
    def get_stored_coverage(self) -> Optional[float]:
        """获取存储的覆盖率数据"""
        try:
            if not os.path.exists(self.coverage_data_file):
                return None
                
            with open(self.coverage_data_file, 'r') as f:
                content = f.read().strip()
                return float(content)
                
        except Exception as e:
            print(f"❌ 读取存储覆盖率数据失败: {e}")
            return None
    
    def validate_coverage_consistency(self) -> Dict:
        """验证覆盖率数据一致性"""
        validation_result = {
            "timestamp": datetime.now().isoformat(),
            "status": "unknown",
            "real_coverage": None,
            "stored_coverage": None,
            "difference": None,
            "issues": []
        }
        
        # 获取真实覆盖率
        real_data = self.get_real_coverage_from_bisect()
        if real_data:
            real_coverage, coverage_fraction = real_data
            validation_result["real_coverage"] = real_coverage
            validation_result["coverage_fraction"] = coverage_fraction
        else:
            validation_result["issues"].append("无法获取bisect-ppx实时覆盖率数据")
        
        # 获取存储覆盖率
        stored_coverage = self.get_stored_coverage()
        if stored_coverage is not None:
            validation_result["stored_coverage"] = stored_coverage
        else:
            validation_result["issues"].append("无法读取存储的覆盖率数据")
        
        # 比较数据
        if real_data and stored_coverage is not None:
            real_coverage = real_data[0]
            difference = abs(real_coverage - stored_coverage)
            validation_result["difference"] = difference
            
            if difference < 0.1:  # 允许0.1%的误差
                validation_result["status"] = "consistent"
            elif difference < 1.0:  # 1%以内警告
                validation_result["status"] = "warning"
                validation_result["issues"].append(f"覆盖率数据存在{difference:.2f}%的差异")
            else:  # 超过1%为错误
                validation_result["status"] = "error"
                validation_result["issues"].append(f"覆盖率数据严重不一致，差异{difference:.2f}%")
        else:
            validation_result["status"] = "incomplete"
            validation_result["issues"].append("无法完成数据一致性验证")
        
        return validation_result
    
    def save_validation_history(self, result: Dict):
        """保存验证历史"""
        try:
            history = []
            if os.path.exists(self.validation_history):
                with open(self.validation_history, 'r') as f:
                    history = json.load(f)
            
            history.append(result)
            
            # 只保留最近50条记录
            history = history[-50:]
            
            os.makedirs(os.path.dirname(self.validation_history), exist_ok=True)
            with open(self.validation_history, 'w') as f:
                json.dump(history, f, indent=2, ensure_ascii=False)
                
        except Exception as e:
            print(f"❌ 保存验证历史失败: {e}")
    
    def update_coverage_data_if_needed(self, validation_result: Dict):
        """如果需要，更新覆盖率数据"""
        if (validation_result["status"] == "error" and 
            validation_result["real_coverage"] is not None):
            
            try:
                os.makedirs(os.path.dirname(self.coverage_data_file), exist_ok=True)
                with open(self.coverage_data_file, 'w') as f:
                    f.write(f"{validation_result['real_coverage']:.2f}")
                
                print(f"🔄 已更新覆盖率数据: {validation_result['real_coverage']:.2f}%")
                
            except Exception as e:
                print(f"❌ 更新覆盖率数据失败: {e}")
    
    def run_validation(self) -> bool:
        """运行完整验证"""
        print("🔍 开始覆盖率数据验证...")
        
        result = self.validate_coverage_consistency()
        self.save_validation_history(result)
        
        # 输出验证结果
        print(f"📊 验证状态: {result['status']}")
        
        if result.get("real_coverage"):
            print(f"📈 实际覆盖率: {result['real_coverage']:.2f}%")
        
        if result.get("stored_coverage"):
            print(f"💾 存储覆盖率: {result['stored_coverage']:.2f}%")
        
        if result.get("difference") is not None:
            print(f"📊 数据差异: {result['difference']:.2f}%")
        
        if result["issues"]:
            print("⚠️  发现问题:")
            for issue in result["issues"]:
                print(f"   - {issue}")
        
        # 如果数据不一致，尝试修复
        if result["status"] == "error":
            print("🔧 尝试修复数据不一致问题...")
            self.update_coverage_data_if_needed(result)
        
        print("✅ 覆盖率数据验证完成")
        return result["status"] in ["consistent", "warning"]


def main():
    """主函数"""
    import argparse
    
    parser = argparse.ArgumentParser(description="覆盖率数据验证器")
    parser.add_argument("--project-root", default=".", help="项目根目录")
    parser.add_argument("--auto-fix", action="store_true", help="自动修复不一致数据")
    
    args = parser.parse_args()
    
    validator = CoverageDataValidator(args.project_root)
    success = validator.run_validation()
    
    exit(0 if success else 1)


if __name__ == "__main__":
    main()