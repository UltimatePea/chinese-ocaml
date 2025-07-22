(** 诗词形式评价器模块接口 - 专业化诗词体裁评价函数集合

    本模块提供针对不同诗词体裁的专门评价函数，每个函数都根据 对应诗词形式的传统格律要求和艺术特征进行了优化设计。

    支持的评价体裁包括：
    - 五言律诗：严格的八句格律诗，注重声律对仗
    - 七言绝句：精炼的四句短诗，讲究起承转合
    - 四言骈体：古典骈文，注重音韵美感
    - 词牌格律：各种词牌的格律要求
    - 现代诗：自由体诗歌，重在意象和情感
    - 四言排律：对偶结构的古典排律 *)

(** {1 古典诗词评价函数} *)

val evaluate_wuyan_lushi : string array -> Artistic_types.artistic_report
(** 五言律诗艺术性评价函数

    专门评价五言律诗的综合艺术性，严格按照律诗格律要求进行评判。 评价维度包括韵律合规性、声调平仄、颔颈联对仗、意象深度等。

    @param verses 诗句数组，必须为8句（标准律诗长度）
    @return
      完整的艺术性评价报告，包含：
      - 各项分维度评分（韵律、声调、对仗、意象、节奏、雅致）
      - 基于律诗标准的综合评价等级
      - 针对律诗写作的具体改进建议
    @raise Invalid_argument 当诗句数量不等于8句时 *)

val evaluate_qiyan_jueju : string array -> Artistic_types.artistic_report
(** 七言绝句艺术性评价函数

    专门评价七言绝句的艺术特征，按照绝句的"起承转合"结构要求 和声韵规律进行综合评判。

    @param verses 诗句数组，必须为4句（标准绝句长度）
    @return
      完整的艺术性评价报告，包含：
      - 绝句特有的韵律和声调评分
      - 起承转合结构的完整性评估
      - 意象鲜明度和情感表达力评分
      - 针对绝句创作的专业建议
    @raise Invalid_argument 当诗句数量不等于4句时 *)

val evaluate_siyan_pianti : string array -> Artistic_types.artistic_report
(** 四言骈体评价专用函数

    评价四言骈体文的音韵和谐程度，注重传统骈文的典雅风格 和音律美感。

    @param verses 骈体内容数组，支持多段骈文
    @return
      骈体艺术性评价报告，侧重：
      - 音韵和谐度（最重要指标）
      - 声调平衡性
      - 用词典雅程度
      - 骈文传统美学符合度 *)

(** {1 特殊体裁评价函数} *)

val evaluate_cipai : 'a -> string array -> Artistic_types.artistic_report
(** 词牌格律评价专用函数

    根据指定词牌的格律要求评价词作的合规性和艺术性。 当前版本提供基础评价框架，后续将扩展支持具体词牌。

    @param cipai_type 词牌类型标识符
    @param verses 词句内容数组
    @return
      词牌格律评价报告，目前提供：
      - 基础的韵律和声调评估
      - 词牌格律的初步符合度检查
      - 词作改进的通用建议

    @since 当前版本为开发中功能，将逐步完善各词牌的专门评价 *)

val evaluate_modern_poetry : string array -> Artistic_types.artistic_report
(** 现代诗评价专用函数

    评价现代自由体诗歌的艺术性，不拘泥于传统格律， 重点关注意象表达、情感传达和语言创新。

    @param verses 现代诗句数组，不限制句数
    @return
      现代诗艺术性评价报告，专注：
      - 意象丰富度和独创性（权重40%）
      - 语言节奏感和音乐美（权重30%）
      - 艺术表达的雅致程度（权重30%）
      - 个性化表达和创新性建议 *)

val evaluate_siyan_parallel_prose : string array -> Artistic_types.artistic_report
(** 四言排律评价函数

    专门评价四言排律的对仗结构和平仄声律，要求句数为偶数 以形成完整的对偶结构。

    @param verses 排律诗句数组，句数必须为偶数
    @return
      排律艺术性评价报告，突出：
      - 对仗工整度（最重要指标）
      - 平仄声律的规范性
      - 韵律和谐与音乐美感
      - 排律传统格式的符合度
    @raise Invalid_argument 当句数为奇数时 *)
