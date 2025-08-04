(** 诗词艺术评估兼容性模块接口
 *
 * 此模块提供不同API版本之间的兼容性支持，确保向后兼容性，
 * 允许旧版本的代码在新系统中正常运行。
 *
 * 主要功能：
 * - 多版本API支持（V1.0、V2.0、V3.0）
 * - 兼容性模式配置
 * - 版本间数据格式转换
 * - 函数名称映射
 * - 迁移助手工具
 * - 兼容性测试
 *
 * @author Whisky, PR Worker
 *)

(** {1 版本兼容性类型} *)

(** API版本枚举 *)
type api_version = 
  | V1_0  (** 初始版本 *)
  | V2_0  (** 模块化版本 *)
  | V3_0  (** 整合版本 - 当前版本 *)

(** 兼容性模式 *)
type compatibility_mode =
  | Strict      (** 严格模式：只支持当前版本API *)
  | Compatible  (** 兼容模式：支持旧版本API转换 *)
  | Legacy      (** 遗留模式：保持完全向后兼容 *)

(** 当前API版本 *)
val current_api_version : api_version

(** {1 V1.0 API 兼容接口} *)

module V1_API : sig
  (** 旧版本的评价结果类型 *)
  type old_evaluation_result = {
    score : float;           (** 评分 *)
    grade : string;          (** 等级 *)
    comments : string list;  (** 评价意见 *)
  }
  
  (** 旧版本的简单评价函数
      @param poem_text 诗词文本
      @return 旧格式的评价结果 *)
  val simple_evaluate : string -> old_evaluation_result
  
  (** 转换到V3.0格式
      @param old_result 旧格式结果
      @return V3.0格式的结果元组 *)
  val convert_to_v3 :
    old_evaluation_result -> float * (string * float) list * string list
end

(** {1 V2.0 API 兼容接口} *)

module V2_API : sig
  (** V2.0的模块化评价结果 *)
  type modular_result = {
    overall_score : float;                    (** 总体评分 *)
    dimension_scores : (string * float) list; (** 各维度评分 *)
    evaluation_details : string;              (** 评价详情 *)
    suggestions : string list;                (** 建议 *)
    metadata : (string * string) list;       (** 元数据 *)
  }
  
  (** V2.0的评价引擎接口
      @param poem_text 诗词文本
      @return V2.0格式的评价结果 *)
  val modular_evaluate : string -> modular_result
  
  (** 转换到V3.0格式
      @param v2_result V2.0格式结果
      @return V3.0格式的结果元组 *)
  val convert_to_v3 :
    modular_result ->
    float * (string * float) list * string list *
    [> `Advanced | `Beginner | `Intermediate | `Master ]
end

(** {1 兼容性转换函数} *)

(** 自动检测输入格式并转换
    @param input 输入数据
    @return 转换后的数据 *)
val auto_convert_result : 'a -> 'a

(** V1.0 兼容包装器
    @param poem_text 诗词文本
    @return V3.0格式的评价结果 *)
val v1_compatible_evaluate :
  string -> float * (string * float) list * string list

(** V2.0 兼容包装器
    @param poem_text 诗词文本
    @return V3.0格式的评价结果（包含艺术水平） *)
val v2_compatible_evaluate :
  string ->
  float * (string * float) list * string list *
  [> `Advanced | `Beginner | `Intermediate | `Master ]

(** {1 API兼容性检查} *)

(** 检查API版本兼容性
    @param requested_version 请求的API版本
    @return 是否兼容 *)
val check_api_compatibility : api_version -> bool

(** 获取支持的API版本列表
    @return 当前模式下支持的版本列表 *)
val get_supported_versions : unit -> api_version list

(** {1 函数名称映射} *)

(** 旧函数名到新函数名的映射表 *)
val function_name_mapping : (string * string) list

(** 查找新函数名
    @param old_name 旧函数名
    @return 新函数名选项 *)
val find_new_function_name : string -> string option

(** 转换旧格式参数到新格式
    @param old_params 旧格式参数
    @return 新格式参数 *)
val convert_parameters : 'a -> 'a

(** {1 错误处理兼容性} *)

(** 旧版本评价错误异常 *)
exception Legacy_Evaluation_Error of string

(** 旧版本解析错误异常 *)
exception Legacy_Parse_Error of string

(** 新版本错误转换为旧版本异常
    @param error_msg 错误消息
    @raise Legacy_Evaluation_Error 或 Legacy_Parse_Error *)
val convert_error_to_legacy : string -> 'a

(** {1 配置管理} *)

(** 设置兼容性模式
    @param mode 要设置的兼容性模式 *)
val set_compatibility_mode : compatibility_mode -> unit

(** 获取当前兼容性模式
    @return 当前的兼容性模式 *)
val get_compatibility_mode : unit -> compatibility_mode

(** 兼容性模式转为字符串
    @param mode 兼容性模式
    @return 模式的字符串表示 *)
val compatibility_mode_to_string : compatibility_mode -> string

(** API版本转为字符串
    @param version API版本
    @return 版本的字符串表示 *)
val api_version_to_string : api_version -> string

(** {1 兼容性报告} *)

(** 生成兼容性报告
    @return 包含兼容性信息的键值对列表 *)
val generate_compatibility_report : unit -> (string * string) list

(** {1 迁移助手} *)

(** 检查代码是否使用了废弃的API
    @param code_text 要检查的代码文本
    @return 发现的废弃函数名列表 *)
val check_deprecated_usage : string -> string list

(** 建议迁移步骤
    @param deprecated_functions 废弃函数名列表
    @return 迁移建议列表 *)
val suggest_migration_steps : string list -> string list

(** {1 测试兼容性} *)

(** 测试V1.0兼容性
    @return 测试结果选项 *)
val test_v1_compatibility :
  unit -> (string * (float * (string * float) list * string list)) option

(** 测试V2.0兼容性
    @return 测试结果选项 *)
val test_v2_compatibility :
  unit ->
  (string *
   (float * (string * float) list * string list *
    [> `Advanced | `Beginner | `Intermediate | `Master ]))
  option