#!/usr/bin/env python3
"""
手动清理剩余ASCII字符的脚本
"""

import re
import glob

def clean_remaining_ascii(content):
    """清理剩余的ASCII字符"""
    
    # 保护注释和字符串内容
    lines = content.split('\n')
    cleaned_lines = []
    
    for line in lines:
        # 跳过注释行
        if line.strip().startswith('#') or line.strip().startswith('//') or line.strip().startswith('*'):
            cleaned_lines.append(line)
            continue
            
        # 针对性替换剩余的ASCII字符
        new_line = line
        
        # 替换常见的单字母变量
        new_line = re.sub(r'\bpr整数f\b', '打印格式化', new_line)
        new_line = re.sub(r'\bvoid\b', '无返回', new_line)
        new_line = re.sub(r'\bchar\b', '字符', new_line)
        new_line = re.sub(r'\bint\b', '整数', new_line)
        new_line = re.sub(r'\bfloat\b', '浮点', new_line)
        new_line = re.sub(r'\bdouble\b', '双精度', new_line)
        new_line = re.sub(r'\bconst\b', '常量', new_line)
        new_line = re.sub(r'\bstatic\b', '静态', new_line)
        new_line = re.sub(r'\bextern\b', '外部', new_line)
        new_line = re.sub(r'\binline\b', '内联', new_line)
        new_line = re.sub(r'\bstruct\b', '结构', new_line)
        new_line = re.sub(r'\bunion\b', '联合', new_line)
        new_line = re.sub(r'\benum\b', '枚举', new_line)
        new_line = re.sub(r'\btypedef\b', '类型定义', new_line)
        new_line = re.sub(r'\bsizeof\b', '大小', new_line)
        new_line = re.sub(r'\breturn\b', '返回', new_line)
        new_line = re.sub(r'\bif\b', '如果', new_line)
        new_line = re.sub(r'\belse\b', '否则', new_line)
        new_line = re.sub(r'\bwhile\b', '当', new_line)
        new_line = re.sub(r'\bfor\b', '循环', new_line)
        new_line = re.sub(r'\bdo\b', '做', new_line)
        new_line = re.sub(r'\bbreak\b', '跳出', new_line)
        new_line = re.sub(r'\bcontinue\b', '继续', new_line)
        new_line = re.sub(r'\bswitch\b', '选择', new_line)
        new_line = re.sub(r'\bcase\b', '情况', new_line)
        new_line = re.sub(r'\bdefault\b', '默认', new_line)
        new_line = re.sub(r'\bgoto\b', '跳转', new_line)
        
        # 替换标识符
        new_line = re.sub(r'\bast\b', '抽象语法树', new_line)
        new_line = re.sub(r'\bAST\b', '抽象语法树', new_line)
        new_line = re.sub(r'\bid\b', '标识', new_line)
        new_line = re.sub(r'\bID\b', '标识', new_line)
        new_line = re.sub(r'\blst\b', '列表', new_line)
        new_line = re.sub(r'\blst1\b', '列表一', new_line)
        new_line = re.sub(r'\blst2\b', '列表二', new_line)
        new_line = re.sub(r'\bs1\b', '字符串一', new_line)
        new_line = re.sub(r'\bs2\b', '字符串二', new_line)
        new_line = re.sub(r'\bn1\b', '数字一', new_line)
        new_line = re.sub(r'\bn2\b', '数字二', new_line)
        new_line = re.sub(r'\bf\b', '函数', new_line)
        new_line = re.sub(r'\bg\b', '函数二', new_line)
        new_line = re.sub(r'\bi\b', '索引', new_line)
        new_line = re.sub(r'\bj\b', '索引二', new_line)
        new_line = re.sub(r'\bk\b', '索引三', new_line)
        new_line = re.sub(r'\bn\b', '数量', new_line)
        new_line = re.sub(r'\bm\b', '数量二', new_line)
        new_line = re.sub(r'\bx\b', '变量甲', new_line)
        new_line = re.sub(r'\by\b', '变量乙', new_line)
        new_line = re.sub(r'\bz\b', '变量丙', new_line)
        new_line = re.sub(r'\ba\b', '参数甲', new_line)
        new_line = re.sub(r'\bb\b', '参数乙', new_line)
        new_line = re.sub(r'\bc\b', '参数丙', new_line)
        
        # 替换 C 语言相关
        new_line = re.sub(r'\bC\b', '丙语言', new_line)
        new_line = re.sub(r'\bc\b', '丙', new_line) 
        
        # 替换类型相关
        new_line = re.sub(r'\bT\b', '类型参数', new_line)
        new_line = re.sub(r'\bE\b', '错误类型', new_line)
        
        # 替换其他常见词
        new_line = re.sub(r'\bnot\b', '非', new_line)
        new_line = re.sub(r'\band\b', '且', new_line)
        new_line = re.sub(r'\bor\b', '或', new_line)
        new_line = re.sub(r'\bof\b', '之', new_line)
        new_line = re.sub(r'\ball\b', '全部', new_line)
        new_line = re.sub(r'\ball2\b', '全部二', new_line)
        new_line = re.sub(r'\bsortedlst\b', '已排序列表', new_line)
        
        # 替换特定的函数或标识符名
        new_line = re.sub(r'\blabel\b', '标签', new_line)
        
        # 替换格式字符串中的字符
        new_line = re.sub(r'百分丁', '百分整数', new_line)
        new_line = re.sub(r'百分串', '百分字符串', new_line)
        
        # 替换Unicode相关
        new_line = re.sub(r'0x四千八百', '四千八百十六进制', new_line)
        new_line = re.sub(r'0编码九千九百九十九', '九千九百九十九十六进制', new_line)
        
        # 第N个中的N
        new_line = re.sub(r'第N个', '第n个', new_line)
        
        cleaned_lines.append(new_line)
    
    return '\n'.join(cleaned_lines)

def main():
    """主函数"""
    ly_files = glob.glob('./**/*.ly', recursive=True)
    
    modified_count = 0
    for file_path in ly_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()
            
            cleaned_content = clean_remaining_ascii(original_content)
            
            if cleaned_content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(cleaned_content)
                print(f"已清理: {file_path}")
                modified_count += 1
            else:
                print(f"无需清理: {file_path}")
                
        except Exception as e:
            print(f"处理文件失败 {file_path}: {e}")
    
    print(f"\n完成，共修改了 {modified_count} 个文件")

if __name__ == '__main__':
    main()