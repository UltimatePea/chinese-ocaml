(** 韵律验证模块 - 骆言诗词编程特性

    盖古之诗者，音韵为要。声韵调谐，方称佳构。 此模块专司韵律验证和质量评估，提供押韵检测、格律验证、错误检查等功能。 凡诗词编程，必先验证韵律，方能确保诗词之美。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-17 *)

(** {1 验证结果类型} *)

type poem_structure_result = {
  verse_count : int;  (** 诗句数量 *)
  rhyme_consistency : bool;  (** 韵律一致性 *)
  rhyme_quality : float;  (** 韵律质量评分（0.0-1.0） *)
  tone_balance : float;  (** 声调平衡度评分（0.0-1.0） *)
  overall_score : float;  (** 总体评分（0.0-1.0） *)
}
(** 诗词结构验证结果类型

    包含诗词整体结构验证的详细结果信息。 *)

(** {1 基础押韵检测函数} *)

val chars_rhyme : char -> char -> bool
(** 检查两个字符是否押韵
    
    判断二字是否可以押韵。同韵可押，异韵不可。
    
    @param char1 第一个字符
    @param char2 第二个字符
    @return 押韵则返回true，否则返回false
    
    @example [chars_rhyme '山' '间'] 返回 [true]
*)

val strings_rhyme : string -> string -> bool
(** 检查两个字符串是否押韵
    
    通过检测字符串的韵组来判断押韵关系。
    
    @param string1 第一个字符串
    @param string2 第二个字符串
    @return 押韵则返回true，否则返回false
    
    @example [strings_rhyme "春山" "闲"] 返回 [true]
*)

(** {1 韵律一致性验证函数} *)

val validate_rhyme_consistency : string list -> bool
(** 验证韵脚一致性
    
    检查多句诗词的韵脚是否和谐。诗词之美在于韵律，韵脚一致方显音律之美。
    
    @param verses 诗句列表
    @return 韵脚一致则返回true，否则返回false
    
    @example [validate_rhyme_consistency ["春山"; "闲"]] 返回 [true]
*)

val validate_rhyme_scheme : string list -> char list -> bool
(** 验证韵律方案
    
    依传统诗词格律检验韵律。按图索骥，验证韵律方案。
    
    @param verses 诗句列表
    @param rhyme_scheme 韵律方案（韵脚字符列表）
    @return 符合韵律方案则返回true，否则返回false
    
    @example [validate_rhyme_scheme ["春山"; "闲"] ['山'; '间']] 返回 [true]
*)

(** {1 韵律质量评估函数} *)

val evaluate_rhyme_quality : string list -> float
(** 检测押韵质量
    
    评估韵脚的和谐程度。押韵有工拙之分，此函评估韵脚和谐程度。
    
    @param verses 诗句列表
    @return 韵律质量评分（0.0-1.0），1.0表示完美押韵
    
    @example [evaluate_rhyme_quality ["春山"; "闲"]] 返回 [1.0]
*)

(** {1 平仄格律验证函数} *)

val validate_ping_ze_pattern : string -> bool list -> bool
(** 验证平仄格律
    
    检查诗句的平仄是否符合要求。
    
    @param verse 诗句字符串
    @param expected_pattern 期望的平仄模式（true为平声，false为仄声）
    @return 符合平仄格律则返回true，否则返回false
    
    @example [validate_ping_ze_pattern "春山" [true; true]] 返回 [true]
*)

val check_tone_balance : string -> float
(** 检查诗句的声调平衡
    
    计算平声和仄声的比例平衡度。
    
    @param verse 诗句字符串
    @return 声调平衡度评分（0.0-1.0），1.0表示完美平衡
    
    @example [check_tone_balance "春山月下"] 返回 [0.75]
*)

(** {1 综合验证函数} *)

val validate_poem_structure : string list -> poem_structure_result
(** 验证诗词整体结构
    
    对整首诗词进行综合验证，返回详细的结构验证结果。
    
    @param verses 诗句列表
    @return 包含诗句数量、韵律一致性、韵律质量、声调平衡和总体评分的结构体
    
    @example [validate_poem_structure ["春山"; "闲"]] 返回包含完整验证结果的记录
*)

(** {1 错误检查与建议函数} *)

val check_rhyme_errors : string list -> string list
(** 检查韵律错误
    
    检查诗词中的韵律错误，返回错误信息列表。
    
    @param verses 诗句列表
    @return 错误信息列表，包括韵组不一致、未知韵组和空韵脚等问题
    
    @example [check_rhyme_errors ["春山"; "不押韵"]] 返回 [["韵组不一致"]]
*)

val generate_rhyme_suggestions : string list -> string list
(** 生成韵律建议
    
    基于韵律一致性、质量和声调平衡提供改进建议。
    
    @param verses 诗句列表
    @return 改进建议列表
    
    @example [generate_rhyme_suggestions ["春山"; "不押韵"]] 返回包含改进建议的列表
*)
