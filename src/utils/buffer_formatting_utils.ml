(** 骆言编译器统一缓冲区格式化工具模块 *)

(** {1 缓冲区大小常量} *)
module BufferSizes = struct
  (** 标识符、标签等微小内容 *)
  let tiny = 16
  
  (** 简单值格式化 *)
  let small = 32
  
  (** 标准容器：列表、数组、元组 *)
  let standard = 64
  
  (** 记录、方法等中等复杂结构 *)
  let medium = 128
  
  (** 小型报告和错误信息 *)
  let large = 256
  
  (** 错误消息、违规报告 *)
  let xlarge = 512
  
  (** 大型报告 *)
  let xxlarge = 1024
  
  (** 超大型报告 *)
  let huge = 2048
end

(** {1 通用格式化函数} *)
module Formatting = struct
  
  (** 格式化列表，使用给定的分隔符 *)
  let format_list ~buffer ~open_delim ~close_delim ~separator ~formatter items =
    Buffer.add_string buffer open_delim;
    (match items with
     | [] -> ()
     | first :: rest ->
         Buffer.add_string buffer (formatter first);
         List.iter (fun item ->
           Buffer.add_string buffer separator;
           Buffer.add_string buffer (formatter item)
         ) rest);
    Buffer.add_string buffer close_delim

  (** 格式化键值对 *)
  let format_pairs ~buffer ~open_delim ~close_delim ~pair_sep ~kv_sep ~key_formatter ~value_formatter pairs =
    Buffer.add_string buffer open_delim;
    (match pairs with
     | [] -> ()
     | (first_key, first_value) :: rest ->
         Buffer.add_string buffer (key_formatter first_key);
         Buffer.add_string buffer kv_sep;
         Buffer.add_string buffer (value_formatter first_value);
         List.iter (fun (key, value) ->
           Buffer.add_string buffer pair_sep;
           Buffer.add_string buffer (key_formatter key);
           Buffer.add_string buffer kv_sep;
           Buffer.add_string buffer (value_formatter value)
         ) rest);
    Buffer.add_string buffer close_delim

  (** {2 OCaml风格容器格式化便利函数} *)
  
  (** 格式化OCaml列表 [elem1; elem2; elem3] *)
  let format_ocaml_list ~formatter items =
    let buffer = Buffer.create BufferSizes.standard in
    format_list ~buffer ~open_delim:"[" ~close_delim:"]" ~separator:"; " ~formatter items;
    Buffer.contents buffer

  (** 格式化OCaml数组 [|elem1; elem2; elem3|] *)
  let format_ocaml_array ~formatter items =
    let buffer = Buffer.create BufferSizes.standard in
    format_list ~buffer ~open_delim:"[|" ~close_delim:"|]" ~separator:"; " ~formatter items;
    Buffer.contents buffer

  (** 格式化OCaml元组 (elem1, elem2, elem3) *)
  let format_ocaml_tuple ~formatter items =
    let buffer = Buffer.create BufferSizes.standard in
    format_list ~buffer ~open_delim:"(" ~close_delim:")" ~separator:", " ~formatter items;
    Buffer.contents buffer

  (** 格式化OCaml记录 {field1 = value1; field2 = value2} *)
  let format_ocaml_record ~key_formatter ~value_formatter pairs =
    let buffer = Buffer.create BufferSizes.medium in
    format_pairs ~buffer ~open_delim:"{" ~close_delim:"}" ~pair_sep:"; " ~kv_sep:" = " ~key_formatter ~value_formatter pairs;
    Buffer.contents buffer
    
  (** 格式化函数参数 (arg1, arg2, arg3) *)
  let format_function_args ~formatter args =
    let buffer = Buffer.create BufferSizes.standard in
    format_list ~buffer ~open_delim:"(" ~close_delim:")" ~separator:", " ~formatter args;
    Buffer.contents buffer

  (** 格式化构造器与参数 Constructor(arg1, arg2) *)
  let format_constructor ~name ~formatter args =
    let buffer = Buffer.create BufferSizes.standard in
    Buffer.add_string buffer name;
    if args <> [] then (
      Buffer.add_char buffer '(';
      format_list ~buffer ~open_delim:"" ~close_delim:"" ~separator:", " ~formatter args;
      Buffer.add_char buffer ')'
    );
    Buffer.contents buffer

  (** {2 类型格式化函数} *)
  
  (** 格式化方法签名列表 *)
  let format_method_list ~key_formatter ~value_formatter methods =
    let buffer = Buffer.create BufferSizes.medium in
    format_pairs ~buffer ~open_delim:"< " ~close_delim:" >" ~pair_sep:"; " ~kv_sep:": " ~key_formatter ~value_formatter methods;
    Buffer.contents buffer

  (** 格式化变体类型 Type1 | Type2 | Type3 *)
  let format_variant_types ~formatter variants =
    let buffer = Buffer.create BufferSizes.standard in
    format_list ~buffer ~open_delim:"" ~close_delim:"" ~separator:" | " ~formatter variants;
    Buffer.contents buffer

  (** 格式化产品类型 Type1 * Type2 * Type3 *)
  let format_product_types ~formatter types =
    let buffer = Buffer.create BufferSizes.standard in
    format_list ~buffer ~open_delim:"" ~close_delim:"" ~separator:" * " ~formatter types;
    Buffer.contents buffer

  (** 格式化函数类型 Type1 -> Type2 -> Type3 *)
  let format_function_type ~formatter types =
    let buffer = Buffer.create BufferSizes.standard in
    format_list ~buffer ~open_delim:"" ~close_delim:"" ~separator:" -> " ~formatter types;
    Buffer.contents buffer
end

(** {1 报告格式化工具} *)
module Reports = struct
  (** 创建报告缓冲区 *)
  let create_report_buffer () = Buffer.create BufferSizes.large
  
  (** 创建大型报告缓冲区 *)
  let create_large_report_buffer () = Buffer.create BufferSizes.xxlarge
  
  (** 添加报告标题 *)
  let add_header ~buffer ~title =
    Buffer.add_string buffer title;
    Buffer.add_char buffer '\n';
    Buffer.add_string buffer (String.make (String.length title) '=');
    Buffer.add_string buffer "\n\n"
    
  (** 添加报告小节 *)
  let add_section ~buffer ~title ~content =
    Buffer.add_string buffer title;
    Buffer.add_char buffer '\n';
    Buffer.add_string buffer content;
    Buffer.add_string buffer "\n\n"

  (** 添加项目列表 *)
  let add_item_list ~buffer ~items =
    List.iter (fun item ->
      Buffer.add_string buffer "- ";
      Buffer.add_string buffer item;
      Buffer.add_char buffer '\n'
    ) items;
    Buffer.add_char buffer '\n'

  (** 添加编号列表 *)
  let add_numbered_list ~buffer ~items =
    List.iteri (fun i item ->
      Buffer.add_string buffer (string_of_int (i + 1));
      Buffer.add_string buffer ". ";
      Buffer.add_string buffer item;
      Buffer.add_char buffer '\n'
    ) items;
    Buffer.add_char buffer '\n'
end

(** {1 高级格式化工具} *)
module Advanced = struct
  (** 创建带缩进的格式化器 *)
  let create_indented_formatter ~indent_size =
    let indent_str = String.make indent_size ' ' in
    fun ~buffer ~content ->
      let lines = String.split_on_char '\n' content in
      List.iteri (fun i line ->
        if i > 0 then Buffer.add_char buffer '\n';
        if line <> "" then Buffer.add_string buffer indent_str;
        Buffer.add_string buffer line
      ) lines

  (** 格式化嵌套结构 *)
  let format_nested ~formatter ~indent_size items =
    let buffer = Buffer.create BufferSizes.large in
    let indented_formatter = create_indented_formatter ~indent_size in
    List.iter (fun item ->
      let formatted = formatter item in
      indented_formatter ~buffer ~content:formatted;
      Buffer.add_char buffer '\n'
    ) items;
    Buffer.contents buffer

  (** 条件格式化 - 仅当列表非空时才格式化 *)
  let format_if_non_empty ~formatter ~empty_message items =
    if items = [] then empty_message
    else formatter items

  (** 限制长度的格式化 *)
  let format_with_limit ~formatter ~limit ~truncate_message items =
    if List.length items <= limit then
      formatter items
    else
      let rec take n lst =
        match (n, lst) with
        | 0, _ | _, [] -> []
        | n, x :: xs -> x :: take (n - 1) xs
      in
      let truncated = take limit items in
      let formatted = formatter truncated in
      formatted ^ truncate_message
end

(** {1 向后兼容性函数} *)

(** 创建标准大小缓冲区 *)
let create_standard_buffer () = Buffer.create BufferSizes.standard

(** 创建中等大小缓冲区 *)
let create_medium_buffer () = Buffer.create BufferSizes.medium

(** 创建大型缓冲区 *)
let create_large_buffer () = Buffer.create BufferSizes.large

(** 格式化简单列表 *)
let format_simple_list _separator formatter items =
  Formatting.format_ocaml_list ~formatter items

(** 格式化简单记录 *)
let format_simple_record key_formatter value_formatter pairs =
  Formatting.format_ocaml_record ~key_formatter ~value_formatter pairs