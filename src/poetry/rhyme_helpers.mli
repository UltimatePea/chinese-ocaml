(** 音韵数据辅助函数模块接口 - Rhyme Data Helper Functions Interface *)

(** {1 概述}
    
    音韵数据辅助函数模块提供统一的韵律数据构造工具，用于消除代码重复。
    本模块是骆言诗词编程特性的核心组件，支持中国古典诗词的韵律分析和处理。
    
    主要功能：
    - 韵律数据快速构造
    - 声调分组处理
    - 韵组批量创建
    - 韵律数据验证
    - 诗词专用构造器
    
    设计目标：
    - 减少 rhyme_data.ml 中的重复模式
    - 提供类型安全的韵律数据构造
    - 支持中国古典诗词的各种韵律规则
    - 便于韵律数据的维护和扩展
    
    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-19 *)

open Rhyme_types

(** {2 韵律数据构造辅助函数} *)

val make_ping_sheng_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list
(** 创建平声韵字符组
    
    将字符列表批量转换为平声韵数据元组。平声是中国古典诗词中的基础声调，
    通常用于诗句的偶数位置（如律诗的二、四、六、八字位）。
    
    @param rhyme_group 韵部类型（如东韵、江韵等）
    @param chars 需要标记为平声的字符列表
    @return (字符, PingSheng, 韵部) 元组列表
    
    示例：
    {[
      let dong_ping = make_ping_sheng_group DongRhyme ['东'; '中'; '终']
      (* 结果：[('东', PingSheng, DongRhyme); ('中', PingSheng, DongRhyme); ('终', PingSheng, DongRhyme)] *)
    ]} *)

val make_shang_sheng_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list
(** 创建上声韵字符组
    
    将字符列表标记为上声调。上声是仄声的一种，声调短促上扬，
    在诗词中与平声形成对比，增强韵律节奏感。
    
    @param rhyme_group 韵部类型
    @param chars 字符列表
    @return (字符, ShangSheng, 韵部) 元组列表 *)

val make_qu_sheng_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list
(** 创建去声韵字符组
    
    将字符列表标记为去声调。去声是仄声的一种，声调由高降低，
    在诗词中提供强烈的音韵变化效果。
    
    @param rhyme_group 韵部类型
    @param chars 字符列表
    @return (字符, QuSheng, 韵部) 元组列表 *)

val make_ru_sheng_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list
(** 创建入声韵字符组
    
    将字符列表标记为入声调。入声是古汉语特有的声调，现代汉语中已消失，
    但在古典诗词格律中仍然重要，属于仄声范畴。
    
    @param rhyme_group 韵部类型
    @param chars 字符列表
    @return (字符, RuSheng, 韵部) 元组列表 *)

val make_ze_sheng_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list
(** 创建仄声韵字符组
    
    将字符列表标记为通用仄声。仄声是上声、去声、入声的总称，
    与平声相对，是诗词格律的基础分类。
    
    @param rhyme_group 韵部类型
    @param chars 字符列表
    @return (字符, ZeSheng, 韵部) 元组列表 *)

val make_mixed_tone_group : rhyme_group -> (string * rhyme_category) list -> (string * rhyme_category * rhyme_group) list
(** 创建混合声调韵字符组
    
    处理同一韵组中包含多种声调的复杂情况。在实际韵律数据中，
    某些韵部可能包含不同声调的字符，此函数提供灵活的处理方式。
    
    @param rhyme_group 韵部类型
    @param char_rhyme_category_pairs (字符, 声调) 元组列表
    @return (字符, 声调, 韵部) 元组列表
    
    示例：
    {[
      let mixed_group = make_mixed_rhyme_category_group JiangRhyme [('江', PingSheng); ('讲', ShangSheng)]
    ]} *)

(** {3 批量韵组构造器} *)

val make_multiple_ping_sheng_groups : rhyme_group -> string list list -> (string * rhyme_category * rhyme_group) list
(** 创建多个平声韵组
    
    批量处理同一韵部的多个字符组，适用于大规模韵律数据构建。
    将嵌套的字符列表展平为统一的韵律数据格式。
    
    @param rhyme_group 韵部类型
    @param char_groups 字符组列表（每个组是一个字符列表）
    @return 展平后的 (字符, PingSheng, 韵部) 元组列表 *)

(** {4 诗词专用构造器模块} *)

(** 诗词韵组构造器
    
    专门针对中国古典诗词特点设计的韵组构造器集合，
    提供常见诗词主题的韵律数据快速构建功能。 *)
module Poetry_group_builder : sig
  
  val make_poetry_core : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list
  (** 创建诗词核心韵组
      
      处理诗词中最常用的核心字符，如"诗时知思"等高频韵脚字。
      这些字符在古典诗词中使用频率极高，是韵律分析的重点。
      
      @param rhyme_group 韵部类型
      @param core_chars 核心字符列表
      @return 平声韵数据列表 *)
  
  val make_direction_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list
  (** 创建方位韵组
      
      专门处理表示方位的字符，如"东西南北中"等。
      方位词在古典诗词中具有空间意象，常用于营造意境。
      
      @param rhyme_group 韵部类型
      @param direction_chars 方位字符列表
      @return 平声韵数据列表 *)
  
  val make_nature_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list
  (** 创建自然韵组
      
      处理自然景物相关字符，如"山水云月"等。
      自然意象是中国古典诗词的重要组成部分，体现人与自然的和谐关系。
      
      @param rhyme_group 韵部类型
      @param nature_chars 自然字符列表
      @return 平声韵数据列表 *)
  
  val make_emotion_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list
  (** 创建情感韵组
      
      处理情感表达相关字符，如"喜怒哀乐"等。
      情感词汇是诗词抒情功能的载体，在韵律分析中需要特别关注。
      
      @param rhyme_group 韵部类型
      @param emotion_chars 情感字符列表
      @return 平声韵数据列表 *)
      
end

(** {5 韵组处理工具} *)

val merge_rhyme_groups : (string * rhyme_category * rhyme_group) list list -> (string * rhyme_category * rhyme_group) list
(** 合并多个韵组为单一列表
    
    将分散的韵组数据合并为统一的韵律数据列表，便于后续处理和分析。
    在构建复杂韵律数据库时经常使用此函数。
    
    @param groups 韵组列表（每个组是韵律数据列表）
    @return 合并后的韵律数据列表 *)

val group_by_rhyme : (string * rhyme_category * rhyme_group) list -> (rhyme_group * (string * rhyme_category) list) list
(** 按韵部分组韵字
    
    将韵律数据按韵部重新组织，便于分析特定韵部的字符分布和声调特征。
    返回的结果以韵部为键，字符-声调对列表为值。
    
    @param rhyme_data 韵律数据列表
    @return (韵部, (字符, 声调) 列表) 关联列表 *)

(** {6 韵律验证工具} *)

val validate_rhyme_group : (string * rhyme_category * rhyme_group) list -> bool
(** 验证韵组一致性
    
    检查韵组中所有字符是否属于同一韵部，确保韵律数据的正确性。
    在韵律数据构建和维护过程中提供质量保证。
    
    @param group 待验证的韵组
    @return 如果韵组一致则返回 true，否则返回 false *)

val check_duplicate_chars : (string * rhyme_category * rhyme_group) list -> string list
(** 检查重复字符
    
    扫描韵律数据中的重复字符，防止数据冗余和不一致。
    返回所有重复出现的字符列表。
    
    @param rhyme_data 韵律数据列表
    @return 重复字符列表（如果没有重复则返回空列表） *)

(** {7 设计理念}
    
    本模块体现了骆言诗词编程的核心理念：
    
    1. **传统文化保护**: 精确建模中国古典诗词的韵律规则
    2. **现代技术融合**: 使用现代编程技术处理传统文化数据
    3. **代码复用**: 通过辅助函数消除重复，提高维护效率
    4. **类型安全**: 利用OCaml类型系统确保韵律数据的正确性
    5. **易于扩展**: 模块化设计支持新韵律规则的添加
    
    使用建议：
    - 构建韵律数据时优先使用本模块的辅助函数
    - 定期使用验证工具检查数据质量
    - 根据具体诗词类型选择合适的构造器
    - 保持韵律数据的文档化和注释完整性 *)