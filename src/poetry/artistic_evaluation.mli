(** 诗词艺术性评价模块接口 - 骆言诗词编程特性

    本模块提供了古典诗词编程中的艺术性评价功能，包括音韵和谐度、声调平衡度、 对仗工整度、意象深度、节奏感、雅致程度等多维度评价。

    承古典诗词品评之传统，融现代程序分析之技术，为诗词编程提供全面的艺术性指导。 不仅求格律之正，更求意境之美，助力程序员创作出既有技术深度又有艺术美感的代码。 *)

(** 艺术性评价维度

    诗词艺术性的多个评价维度，涵盖音韵、声调、对仗、意象、节奏、雅致等方面。 每个维度都有相应的评价标准和计算方法。 *)
type artistic_dimension =
  | RhymeHarmony (* 韵律和谐 - 音韵是否协调悦耳 *)
  | TonalBalance (* 声调平衡 - 平仄搭配是否合理 *)
  | Parallelism (* 对仗工整 - 对偶结构是否工整 *)
  | Imagery (* 意象深度 - 诗句意象是否丰富深刻 *)
  | Rhythm (* 节奏感 - 诗句节奏是否优美 *)
  | Elegance (* 雅致程度 - 用词是否雅致高贵 *)

(** 评价等级

    依传统诗词品评标准，将诗词作品分为四个等级。 上品为意境高远之佳作，下品为需要改进之作品。 *)
type evaluation_grade =
  | Excellent (* 上品 - 意境高远，韵律和谐，可称佳作 *)
  | Good (* 中品 - 格律工整，音韵协调，颇具水准 *)
  | Fair (* 下品 - 基本合格，略有瑕疵，尚可改进 *)
  | Poor (* 不入流 - 格律错乱，音韵不谐，需重修 *)

type artistic_report = {
  verse : string; (* 原诗句 *)
  rhyme_score : float; (* 韵律得分 *)
  tone_score : float; (* 声调得分 *)
  parallelism_score : float; (* 对仗得分 *)
  imagery_score : float; (* 意象得分 *)
  rhythm_score : float; (* 节奏得分 *)
  elegance_score : float; (* 雅致得分 *)
  overall_grade : evaluation_grade; (* 总体评价 *)
  suggestions : string list; (* 改进建议 *)
}
(** 艺术性评价报告

    全面分析诗词的艺术特征，包含各维度得分、总体评价等级和改进建议。 每个得分范围为0.0到1.0，总体评价等级基于各维度得分综合确定。 *)

type siyan_artistic_standards = {
  char_count : int; (* 字数标准：每句四字 *)
  tone_pattern : bool list; (* 声调模式：平仄相对 *)
  parallelism_required : bool; (* 是否要求对仗 *)
  rhythm_weight : float; (* 节奏权重 *)
}
(** 四言骈体艺术性评价标准

    专门针对四言骈体的评价标准，包含字数要求、声调模式、对仗要求等。 四言骈体要求每句四字，平仄相对，对仗工整。 *)

val siyan_standards : siyan_artistic_standards
(** 四言骈体标准实例

    预定义的四言骈体评价标准，供直接使用。 *)

val evaluate_rhyme_harmony : string -> float
(** 评价韵律和谐度

    检查诗句的音韵是否和谐，基于韵组分析和韵脚质量评价。 韵律和谐是诗词艺术性的重要指标之一。

    @param string 诗句字符串
    @return 韵律和谐度得分（0.0-1.0） *)

val evaluate_tonal_balance : string -> bool list -> float
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

val determine_overall_grade : artistic_report -> evaluation_grade
(** 综合评价等级

    根据各项得分确定总体评价等级。 综合考虑所有艺术性维度，给出客观的等级评价。

    @param artistic_report 艺术性评价报告
    @return 总体评价等级 *)

val generate_improvement_suggestions : artistic_report -> string list
(** 生成改进建议

    根据评价结果提供具体的改进建议。 针对评分较低的维度，提供有针对性的改进建议。

    @param artistic_report 艺术性评价报告
    @return 改进建议列表 *)

val comprehensive_artistic_evaluation : string -> bool list -> artistic_report
(** 全面艺术性评价

    为诗句提供全面的艺术性分析，包含所有评价维度。 这是本模块的核心功能，提供完整的艺术性评价报告。

    @param string 诗句字符串
    @param bool list 期望的平仄模式
    @return 全面的艺术性评价报告 *)

val evaluate_siyan_parallel_prose : string list -> artistic_report
(** 四言骈体专项评价

    专门针对四言骈体的艺术性评价。 考虑四言骈体的特殊格律要求，提供专业的评价结果。

    @param string list 四言骈体诗句列表
    @return 四言骈体专项评价报告 *)

val poetic_critique : string -> string -> string
(** 诗词品评

    传统诗词品评方式的现代实现。 模仿古代文人品评诗词的风格，提供雅致的评价文字。

    @param string 诗句字符串
    @param string 诗词类型
    @return 传统风格的品评文字 *)

val poetic_aesthetics_guidance : string -> string -> string
(** 诗词美学指导系统

    根据诗词类型和内容提供专门的美学指导。 针对不同诗词形式的特点，提供有针对性的创作建议。

    @param string 诗句字符串
    @param string 诗词类型（如"四言骈体"、"五言律诗"、"七言绝句"）
    @return 美学指导分析报告 *)
