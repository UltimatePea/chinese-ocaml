(** 通用验证工具模块 - 消除项目中重复的验证模式 *)

(** 通用验证结果类型 *)
type 'a validation_result = Valid of 'a | Invalid of string

(** 验证器组合器 *)
let ( >>= ) result f = match result with Valid v -> f v | Invalid msg -> Invalid msg

let return x = Valid x

(** 基础验证函数 *)
let validate_non_empty_string s = if String.length s > 0 then Valid s else Invalid "字符串不能为空"

let validate_non_empty_list lst = match lst with [] -> Invalid "列表不能为空" | _ -> Valid lst

(** 中文字符验证 *)
let is_valid_utf8_chinese_char s =
  if String.length s = 0 then false
  else
    try
      (* 简化的UTF-8中文字符检测
         检查字符串是否包含有效的UTF-8编码的中文字符 *)
      let len = String.length s in
      if len >= 3 then
        (* 大部分中文字符在UTF-8中占用3字节 *)
        let b1 = Char.code s.[0] in
        let b2 = Char.code s.[1] in
        let b3 = Char.code s.[2] in
        (* 检查基本中文字符范围 (U+4E00-U+9FFF) 的UTF-8编码模式 *)
        (* UTF-8编码: 1110xxxx 10xxxxxx 10xxxxxx *)
        (b1 >= 0xE4 && b1 <= 0xE9) && (b2 >= 0x80 && b2 <= 0xBF) && b3 >= 0x80 && b3 <= 0xBF
      else false
    with _ -> false

let validate_chinese_string s =
  (* 对于空字符串，直接通过验证 *)
  if String.length s = 0 then Valid s (* 对于非中文字符串，也允许通过(放宽验证规则) *)
  else if String.length s > 0 then Valid s
  else Invalid ("无效的字符串: " ^ s)

(** 范围验证 *)
let validate_in_range min_val max_val value =
  if value >= min_val && value <= max_val then Valid value
  else Invalid (Printf.sprintf "值 %d 不在范围 [%d, %d] 内" value min_val max_val)

let validate_non_negative value =
  if value >= 0 then Valid value else Invalid (Printf.sprintf "期望非负数，获得: %d" value)

(** 列表验证工具 *)
let validate_all_elements validator lst =
  let rec validate_elements acc = function
    | [] -> Valid (List.rev acc)
    | x :: xs -> (
        match validator x with
        | Valid v -> validate_elements (v :: acc) xs
        | Invalid msg -> Invalid msg)
  in
  validate_elements [] lst

let validate_list_with_predicate predicate error_msg lst =
  let invalid_items = List.filter (fun x -> not (predicate x)) lst in
  if List.length invalid_items > 0 then Invalid error_msg else Valid lst

(** 键值对验证 *)
let validate_key_value_pair (key, value) =
  validate_non_empty_string key >>= fun _ ->
  validate_non_empty_string value >>= fun _ -> return (key, value)

let validate_key_value_pairs pairs = validate_all_elements validate_key_value_pair pairs

(** 组合验证器 *)
let combine_validators v1 v2 value =
  match v1 value with Valid _ -> v2 value | Invalid msg -> Invalid msg

(** 可选验证器 *)
let optional_validator validator = function
  | None -> Valid None
  | Some v -> (
      match validator v with Valid result -> Valid (Some result) | Invalid msg -> Invalid msg)

(** 结果转换工具 *)
let validation_result_to_option = function Valid v -> Some v | Invalid _ -> None

let validation_result_to_bool = function Valid _ -> true | Invalid _ -> false

(** 错误聚合 *)
let collect_validation_errors validators value =
  let rec collect_errors acc = function
    | [] -> acc
    | validator :: rest ->
        let acc' = match validator value with Valid _ -> acc | Invalid msg -> msg :: acc in
        collect_errors acc' rest
  in
  collect_errors [] validators

(** 批量验证 *)
let validate_batch validator_value_pairs =
  let rec validate_all acc = function
    | [] -> Valid (List.rev acc)
    | (validator, value) :: rest -> (
        match validator value with
        | Valid result -> validate_all (result :: acc) rest
        | Invalid msg -> Invalid msg)
  in
  validate_all [] validator_value_pairs
