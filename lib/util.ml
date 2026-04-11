(** 骆言工具模块 — UTF-8 解码、码点分类、标识符编码、关键字表、文件读取 *)

(* ===== UTF-8 解码 ===== *)

let decode_utf8 s i n =
  if i >= n then (0, 0)
  else
    let b0 = Char.code s.[i] in
    if b0 < 0x80 then (b0, 1)
    else if b0 < 0xC0 then (b0, 1)
    else if b0 < 0xE0 then
      if i + 1 < n then
        (((b0 land 0x1F) lsl 6) lor (Char.code s.[i+1] land 0x3F), 2)
      else (b0, 1)
    else if b0 < 0xF0 then
      if i + 2 < n then
        let b1 = Char.code s.[i+1] and b2 = Char.code s.[i+2] in
        (((b0 land 0x0F) lsl 12) lor ((b1 land 0x3F) lsl 6) lor (b2 land 0x3F), 3)
      else (b0, 1)
    else
      if i + 3 < n then
        let b1 = Char.code s.[i+1] and b2 = Char.code s.[i+2] and b3 = Char.code s.[i+3] in
        (((b0 land 0x07) lsl 18) lor ((b1 land 0x3F) lsl 12)
         lor ((b2 land 0x3F) lsl 6) lor (b3 land 0x3F), 4)
      else (b0, 1)

(* ===== 码点分类 ===== *)

let is_cjk cp =
  cp <> 0x4E4B &&
  ((cp >= 0x4E00 && cp <= 0x9FFF)
   || (cp >= 0x3400 && cp <= 0x4DBF)
   || (cp >= 0x20000 && cp <= 0x2A6DF)
   || (cp >= 0xF900 && cp <= 0xFAFF))

(* ===== 标识符编码 ===== *)

let has_non_ascii s =
  let n = String.length s in
  let i = ref 0 in
  while !i < n && Char.code s.[!i] < 0x80 do incr i done;
  !i < n

let mangle name =
  if has_non_ascii name then begin
    let buf = Buffer.create (6 + String.length name * 2) in
    Buffer.add_string buf "luo__";
    String.iter (fun c -> Printf.bprintf buf "%02x" (Char.code c)) name;
    Buffer.contents buf
  end else
    name

let mangle_module name =
  if has_non_ascii name then begin
    let buf = Buffer.create (6 + String.length name * 2) in
    Buffer.add_string buf "Luo__";
    String.iter (fun c -> Printf.bprintf buf "%02x" (Char.code c)) name;
    Buffer.contents buf
  end else if String.length name > 0 then
    String.make 1 (Char.uppercase_ascii name.[0])
    ^ String.sub name 1 (String.length name - 1)
  else
    name

(* ===== 关键字表 ===== *)

let keywords =
  let tbl = Hashtbl.create 128 in
  List.iter (fun (k, v) -> Hashtbl.add tbl k v) [
    (* 绑定 *)
    "让",   "let";    "递归", "rec";    "在",   "in";    "以及", "and";
    (* 控制流 *)
    "如果", "if";     "那么", "then";   "否则", "else";
    (* 函数与模式匹配 *)
    "函数", "fun";    "匹配", "match";  "与",   "with";  "当",   "when";
    (* 等号 *)
    "是",   "=";
    (* 类型系统 *)
    "类型", "type";   "的",   "of";     "可变", "mutable"; "约束", "constraint";
    (* 异常 *)
    "异常", "exception"; "尝试", "try";  "抛出", "raise";
    (* 布尔 *)
    "真",   "true";   "假",   "false";
    (* 模块系统 *)
    "模块", "module"; "函子", "functor"; "结构", "struct"; "签名", "sig";
    "结束", "end";    "开始", "begin";   "打开", "open";   "包含", "include";
    "外部", "external";
    (* 其他 *)
    "为",     "as";       "断言",   "assert";   "延迟",   "lazy";
    "值",     "val";      "方法",   "method";   "对象",   "object";
    "类",     "class";    "新建",   "new";      "虚拟",   "virtual";
    "私有",   "private";  "继承",   "inherit";  "初始化", "initializer";
    (* 构造子 *)
    "有",  "Some";   "无",  "None";
    (* 逻辑 *)
    "且",  "&&";     "或",  "||";     "非",  "not";
    (* 模式/箭头 *)
    "案",  "|";      "则",  "->";     "赋",  "<-";     "设",  ":=";
    (* 算术 *)
    "加",  "+";      "减",  "-";      "乘",  "*";      "除",  "/";     "余",  "mod";
    (* 比较 *)
    "小于", "<";     "大于", ">";      "不超", "<=";     "不低", ">=";    "不等", "<>";
    (* 其他运算符 *)
    "空",  "_";      "连",  "^";      "接",  "::";     "取",  "!";     "追",  "@";
  ];
  tbl

(* ===== 文件读取 ===== *)

let read_file path =
  let ic = open_in_bin path in
  let len = in_channel_length ic in
  let s = Bytes.create len in
  really_input ic s 0 len;
  close_in ic;
  Bytes.to_string s
