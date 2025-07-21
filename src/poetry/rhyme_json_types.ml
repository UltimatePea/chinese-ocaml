(** 韵律JSON数据类型定义

    定义韵律数据处理所需的所有类型，为其他模块提供统一的类型基础。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-20 - Phase 29 rhyme_json_loader重构 *)

(** 韵类定义 *)
type rhyme_category =
  | PingSheng  (** 平声 *)
  | ZeSheng  (** 仄声 *)
  | ShangSheng  (** 上声 *)
  | QuSheng  (** 去声 *)
  | RuSheng  (** 入声 *)

(** 韵组定义 *)
type rhyme_group =
  | AnRhyme  (** 安韵 *)
  | SiRhyme  (** 思韵 *)
  | TianRhyme  (** 天韵 *)
  | WangRhyme  (** 王韵 *)
  | QuRhyme  (** 曲韵 *)
  | YuRhyme  (** 雨韵 *)
  | HuaRhyme  (** 花韵 *)
  | FengRhyme  (** 风韵 *)
  | YueRhyme  (** 月韵 *)
  | XueRhyme  (** 雪韵 *)
  | JiangRhyme  (** 江韵 *)
  | HuiRhyme  (** 辉韵 *)
  | UnknownRhyme  (** 未知韵 *)

(** {1 JSON解析异常} *)

exception Json_parse_error of string
(** JSON解析错误异常 *)

exception Rhyme_data_not_found of string
(** 韵律数据未找到异常 *)

(** {1 数据类型定义} *)

type rhyme_group_data = {
  category : string;  (** 韵类名称 *)
  characters : string list;  (** 该韵组包含的字符列表 *)
}
(** 韵组数据类型 *)

type rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;  (** 韵组映射 *)
  metadata : (string * string) list;  (** 元数据信息 *)
}
(** 韵律数据文件结构 *)

(** {1 类型转换函数} *)

(** 字符串转韵类 *)
let string_to_rhyme_category = function
  | "平声" | "ping_sheng" -> PingSheng
  | "仄声" | "ze_sheng" -> ZeSheng
  | "上声" | "shang_sheng" -> ShangSheng
  | "去声" | "qu_sheng" -> QuSheng
  | "入声" | "ru_sheng" -> RuSheng
  | _ -> PingSheng (* 默认平声 *)

(** 字符串转韵组 *)
let string_to_rhyme_group = function
  | "安韵" | "an_rhyme" -> AnRhyme
  | "思韵" | "si_rhyme" -> SiRhyme
  | "天韵" | "tian_rhyme" -> TianRhyme
  | "王韵" | "wang_rhyme" -> WangRhyme
  | "曲韵" | "qu_rhyme" -> QuRhyme
  | "雨韵" | "yu_rhyme" -> YuRhyme
  | "花韵" | "hua_rhyme" -> HuaRhyme
  | "风韵" | "feng_rhyme" -> FengRhyme
  | "月韵" | "yue_rhyme" -> YueRhyme
  | "雪韵" | "xue_rhyme" -> XueRhyme
  | "江韵" | "jiang_rhyme" -> JiangRhyme
  | "辉韵" | "hui_rhyme" -> HuiRhyme
  | _ -> UnknownRhyme
