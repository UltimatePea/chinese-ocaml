(** 诗词艺术性评价模块接口 - 骆言诗词编程特性

    本模块提供了古典诗词编程中的艺术性评价功能，包括音韵和谐度、声调平衡度、 对仗工整度、意象深度、节奏感、雅致程度等多维度评价。

    承古典诗词品评之传统，融现代程序分析之技术，为诗词编程提供全面的艺术性指导。 不仅求格律之正，更求意境之美，助力程序员创作出既有技术深度又有艺术美感的代码。

    注：核心类型定义已重构至Artistic_types模块，格律标准已重构至Poetry_standards模块 *)

open Artistic_types
(** 从Artistic_types模块导入核心类型定义 *)

(** 从Poetry_standards模块导入的四言骈体标准 预定义的四言骈体评价标准，供直接使用。 *)

val evaluate_rhyme_harmony : string -> float
(** 评价韵律和谐度

    检查诗句的音韵是否和谐，基于韵组分析和韵脚质量评价。 韵律和谐是诗词艺术性的重要指标之一。

    @param string 诗句字符串
    @return 韵律和谐度得分（0.0-1.0） *)

val evaluate_tonal_balance : string -> bool list option -> float
(** 评价声调平衡度

    检查平仄搭配是否合理，基于声调模式匹配和声调多样性评价。 声调平衡是古典诗词格律的核心要求。

    @param string 诗句字符串
    @param bool list 期望的平仄模式
    @return 声调平衡度得分（0.0-1.0） *)

val evaluate_parallelism : string -> string -> float
(** 评价对仗工整度

    检查对仗的工整程度，包括字数对应、声调对应、韵律对应等。 对仗工整是骈体文和律诗的重要特征。

    @param string 左联诗句
    @param string 右联诗句
    @return 对仗工整度得分（0.0-1.0） *)

val evaluate_imagery : string -> float
(** 评价意象深度

    通过关键词分析评价意象的深度和丰富程度。 意象深度体现了诗词的艺术内涵和表现力。

    @param string 诗句字符串
    @return 意象深度得分（0.0-1.0） *)

val evaluate_rhythm : string -> float
(** 评价节奏感

    基于字数和声调变化评价诗句的节奏感。 节奏感是诗词音律美感的重要组成部分。

    @param string 诗句字符串
    @return 节奏感得分（0.0-1.0） *)

val evaluate_elegance : string -> float
(** 评价雅致程度

    基于用词和意境的雅致程度进行评价。 雅致程度体现了诗词的文化品位和艺术修养。

    @param string 诗句字符串
    @return 雅致程度得分（0.0-1.0） *)

val determine_overall_grade : artistic_scores -> evaluation_grade
(** 综合评价等级

    根据各项得分确定总体评价等级。 综合考虑所有艺术性维度，给出客观的等级评价。

    @param artistic_report 艺术性评价报告
    @return 总体评价等级 *)

val generate_improvement_suggestions : artistic_report -> string list
(** 生成改进建议

    根据评价结果提供具体的改进建议。 针对评分较低的维度，提供有针对性的改进建议。

    @param artistic_report 艺术性评价报告
    @return 改进建议列表 *)

val comprehensive_artistic_evaluation : string -> bool list option -> artistic_report
(** 全面艺术性评价

    为诗句提供全面的艺术性分析，包含所有评价维度。 这是本模块的核心功能，提供完整的艺术性评价报告。

    @param string 诗句字符串
    @param bool list option 期望的平仄模式（None表示不检查平仄）
    @return 全面的艺术性评价报告 *)

val evaluate_siyan_parallel_prose : string array -> artistic_report
(** 四言骈体专项评价

    专门针对四言骈体的艺术性评价。 考虑四言骈体的特殊格律要求，提供专业的评价结果。

    @param string array 四言骈体诗句数组
    @return 四言骈体专项评价报告 *)

val poetic_critique : string -> poetry_form -> artistic_report
(** 诗词品评

    传统诗词品评方式的现代实现。 模仿古代文人品评诗词的风格，提供雅致的评价文字。

    @param string 诗句字符串
    @param poetry_form 诗词类型
    @return 艺术性评价报告 *)

val poetic_aesthetics_guidance : string -> poetry_form -> artistic_report
(** 诗词美学指导系统

    根据诗词类型和内容提供专门的美学指导。 针对不同诗词形式的特点，提供有针对性的创作建议。

    @param string 诗句字符串
    @param poetry_form 诗词类型（四言骈体、五言律诗、七言绝句等）
    @return 美学指导分析报告 *)

(** 诗词形式定义 - 支持多种经典诗词格式 *)

(** 注：诗词形式类型和标准类型已重构至Artistic_types和Poetry_standards模块 *)

val evaluate_wuyan_lushi : string array -> artistic_report
(** 五言律诗专项评价

    专门针对五言律诗的艺术性评价。 考虑五言律诗的特殊格律要求，提供专业的评价结果。

    @param string array 五言律诗八句诗句数组
    @return 五言律诗专项评价报告 *)

val evaluate_qiyan_jueju : string array -> artistic_report
(** 七言绝句专项评价

    专门针对七言绝句的艺术性评价。 考虑七言绝句的特殊格律要求，提供专业的评价结果。

    @param string array 七言绝句四句诗句数组
    @return 七言绝句专项评价报告 *)

val evaluate_poetry_by_form : poetry_form -> string array -> artistic_report
(** 根据诗词形式进行相应的艺术性评价

    统一的诗词评价接口，根据不同的诗词形式自动选择合适的评价方法。

    @param poetry_form 诗词形式
    @param string array 诗句数组
    @return 对应形式的艺术性评价报告 *)
