(** 通用诗词评价框架模块接口 - 诗词艺术性评价的核心基础设施

    本模块提供所有诗词形式评价器共用的基础工具和评价框架， 实现评价逻辑的标准化和复用。主要功能包括权重配置、 分维度评分计算、综合等级判定和评价结果构建。

    这是整个诗词评价系统的核心基础模块，确保不同诗词形式 的评价结果具有可比性和一致性。 *)

(** {1 核心类型定义} *)

type evaluation_weights = {
  rhyme_weight : float;  (** 韵律和谐度权重 *)
  tone_weight : float;  (** 声调平衡性权重 *)
  parallelism_weight : float;  (** 对仗工整度权重 *)
  imagery_weight : float;  (** 意象丰富度权重 *)
  rhythm_weight : float;  (** 节奏美感权重 *)
  elegance_weight : float;  (** 典雅程度权重 *)
}
(** 评价权重配置类型

    定义诗词评价的六个核心维度的权重分配，用于计算 综合评价分数和等级。不同诗词形式可以使用不同的 权重配置以反映其艺术特征的侧重点。 *)

(** {1 评分计算函数} *)

val calculate_tone_scores : string array -> bool list array option -> float
(** 计算声调得分

    基于预期的声调模式计算诗句的声调符合度得分。 支持灵活的声调模式匹配，适用于不同格律要求。

    @param verses 诗句数组，每句将独立进行声调分析
    @param expected_patterns 可选的预期声调模式数组， 每个元素对应一句诗的预期声调模式。 如果为None或模式不足，则使用默认声调评价
    @return 0.0-1.0范围内的声调得分，表示整体声调质量 *)

val calculate_parallelism_scores : string array -> (int * int) list -> float
(** 计算对仗得分

    根据指定的对仗句对计算整体对仗工整度得分。 用于律诗、排律等需要对仗的诗词形式。

    @param verses 诗句数组
    @param parallelism_pairs 对仗句对的索引列表， 每个元素为(i,j)表示第i句和第j句应该对仗
    @return 0.0-1.0范围内的对仗得分，表示对仗工整度 *)

val calculate_overall_grade :
  evaluation_weights ->
  float * float * float * float * float * float ->
  Artistic_types.evaluation_grade
(** 计算整体等级

    基于权重配置和各维度得分计算综合评价等级。 这是评价系统的核心算法，确保评价结果的公正性和一致性。

    @param weights 评价权重配置
    @param scores 六元组形式的各维度得分： (韵律, 声调, 对仗, 意象, 节奏, 典雅)
    @return
      综合评价等级：
      - Excellent (优秀): ≥0.8分
      - Good (良好): ≥0.7分
      - Fair (一般): ≥0.6分
      - Poor (较差): <0.6分 *)

(** {1 评价结果构建函数} *)

val create_evaluation_result :
  string ->
  float * float * float * float * float * float ->
  string list ->
  Artistic_types.artistic_report
(** 创建标准评价结果

    基于各维度得分和建议创建标准格式的艺术性评价报告。 提供统一的评价结果构建接口。

    @param verse 被评价的诗词内容字符串
    @param scores 六元组形式的各维度得分
    @param suggestions 改进建议字符串列表
    @return 完整的艺术性评价报告，overall_grade字段需要后续设置 *)

val create_error_evaluation : string array -> string -> Artistic_types.artistic_report
(** 创建错误评价结果

    当诗词格式不符合要求或出现其他错误时，创建包含 错误信息的评价结果。确保系统的鲁棒性。

    @param verses 原始诗句数组
    @param error_message 错误描述信息
    @return 错误状态的评价报告，所有得分为0.0，等级为Poor， suggestions包含错误信息 *)
