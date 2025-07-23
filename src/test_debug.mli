(** 测试调试模块接口 提供字符串处理功能的测试接口 *)

val test_luoyan_with_correct_quotes : unit -> unit
(** 测试骆言字符串处理（使用正确的中文引号『』） *)

val test_luoyan_with_wrong_quotes : unit -> unit
(** 测试骆言字符串处理（使用错误的英文引号''） *)

val test_english_strings : unit -> unit
(** 测试英文字符串处理（使用双引号""） *)
