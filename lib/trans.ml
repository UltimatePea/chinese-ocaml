(** 骆言转换器 — 将中文OCaml语法转换为标准OCaml

    词法规则（优先级从高到低）：
    1. 「：...：」           → (* ... *)   注释
    2. 「...」               → ...         用户标识符（去掉括号）
    3. 『...』               → "..."       字符串字面量
    4. (* ... *)             →             OCaml原生注释（原样保留）
    5. "..."                 →             ASCII字符串（原样保留）
    6. '.'                   →             字符字面量或类型变量（原样保留）
    7. 全角括号与运算符      → 对应ASCII符号
    8. CJK汉字序列           → 查关键字表，否则编码为 luo__hex
    9. ASCII字母序列         → 原样输出（OCaml内置名称）
   10. 其他                  → 原样输出
*)

(* ===== 关键字对照表 ===== *)

let keywords =
  let tbl = Hashtbl.create 128 in
  List.iter (fun (k, v) -> Hashtbl.add tbl k v) [
    (* 绑定 *)
    "让",   "let";
    "递归", "rec";
    "在",   "in";
    "以及", "and";
    (* 控制流 *)
    "如果", "if";
    "那么", "then";
    "否则", "else";
    (* 函数与模式匹配 *)
    "函数", "fun";
    "匹配", "match";
    "与",   "with";
    "当",   "when";
    (* 类型系统 *)
    "类型", "type";
    "的",   "of";
    "可变", "mutable";
    "约束", "constraint";
    (* 异常处理 *)
    "异常", "exception";
    "尝试", "try";
    "抛出", "raise";
    (* 布尔值 *)
    "真",   "true";
    "假",   "false";
    (* 模块系统 *)
    "模块", "module";
    "函子", "functor";
    "结构", "struct";
    "签名", "sig";
    "结束", "end";
    "开始", "begin";
    "打开", "open";
    "包含", "include";
    "外部", "external";
    (* 其他语言关键字 *)
    "为",     "as";
    "断言",   "assert";
    "延迟",   "lazy";
    (* 面向对象（完整性） *)
    "值",     "val";
    "方法",   "method";
    "对象",   "object";
    "类",     "class";
    "新建",   "new";
    "虚拟",   "virtual";
    "私有",   "private";
    "继承",   "inherit";
    "初始化", "initializer";
    (* ── 内置类型名（出现在类型表达式中，需要直接替换） ── *)
    "整数",   "int";
    "浮点数", "float";
    "字符串", "string";
    "布尔",   "bool";
    "单元",   "unit";
    "列表",   "list";
    "选项",   "option";
    "字节",   "bytes";
    "字符",   "char";
    (* ── 内置构造子（必须保留：mangling 会产生小写标识符，不能用作构造子） ── *)
    "有",  "Some";
    "无",  "None";
    (* ── 逻辑中缀运算符（替换为 OCaml 运算符） ── *)
    "且",  "&&";
    "或",  "||";
    "非",  "not";
  ];
  tbl

(* ===== 标识符名称处理 ===== *)

(** 判断字符串是否含有非ASCII字节（汉字等） *)
let has_non_ascii s =
  let n = String.length s in
  let i = ref 0 in
  while !i < n && Char.code s.[!i] < 0x80 do incr i done;
  !i < n

(** 将用户标识符转换为合法的OCaml值标识符（小写前缀）。
    - 纯ASCII名称保持不变（如 「x」→ x，「Node」→ Node）
    - 含汉字等非ASCII字符时，编码为 luo__ + 十六进制UTF-8字节
      （如 「斐波那契」→ luo__e69690e6b3a2e982a3e5a591）
    注意：构造子需要大写开头，请用ASCII大写字母命名（如 「Node」「Leaf」）。 *)
let mangle name =
  if has_non_ascii name then begin
    let buf = Buffer.create (6 + String.length name * 2) in
    Buffer.add_string buf "luo__";
    String.iter (fun c -> Printf.bprintf buf "%02x" (Char.code c)) name;
    Buffer.contents buf
  end else
    name

(** 将用户标识符转换为合法的OCaml模块标识符（大写前缀）。
    - 纯ASCII名称首字母大写后返回（如 「list」→ List）
    - 含汉字等非ASCII字符时，编码为 Luo__ + 十六进制UTF-8字节
      （如 「输出」→ Luo__e8be93e587ba）
    OCaml要求模块名以大写字母开头，故前缀用大写 Luo__。 *)
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

(* ===== UTF-8 工具 ===== *)

(** 从字符串 [s] 的位置 [i]（长度为 [n]）解码一个UTF-8码点。
    返回 (码点, 该字符占用的字节数)。
    对于无效字节序列，返回原始字节和长度1。 *)
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

(** 判断码点是否为CJK统一汉字（用于收集关键字词）。
    注意：之（U+4E4B）被排除，因为它用作模块访问符 → . *)
let is_cjk cp =
  cp <> 0x4E4B &&                        (* 之 用作模块访问符，单独处理 *)
  ((cp >= 0x4E00 && cp <= 0x9FFF)        (* CJK统一汉字 *)
   || (cp >= 0x3400 && cp <= 0x4DBF)     (* CJK扩展A *)
   || (cp >= 0x20000 && cp <= 0x2A6DF)   (* CJK扩展B *)
   || (cp >= 0xF900 && cp <= 0xFAFF))    (* CJK兼容汉字 *)

(* ===== 主转换函数 ===== *)

let transpile src =
  let n = String.length src in
  let out = Buffer.create (n + 256) in
  let i = ref 0 in

  let put s  = Buffer.add_string out s in
  let putc c = Buffer.add_char out c in
  let sub () len = String.sub src !i len in

  (* 将位置 !i 处的完整UTF-8字符输出，并推进 i *)
  let emit_char () =
    let (_, len) = decode_utf8 src !i n in
    put (sub () len);
    i := !i + len
  in

  while !i < n do
    let (cp, len) = decode_utf8 src !i n in

    (* ── 1. 角括号：标识符 「...」 或注释 「：...：」 ── *)
    if cp = 0x300C then begin                        (* 「 U+300C *)
      i := !i + len;                                 (* 跳过 「 *)
      if !i < n then begin
        let (cp2, len2) = decode_utf8 src !i n in
        (* 全角冒号 ： U+FF1A 或 ASCII 冒号 : → 注释模式 *)
        if cp2 = 0xFF1A || cp2 = 0x003A then begin
          i := !i + len2;
          put "(* ";
          (try
             while !i < n do
               let (cp3, len3) = decode_utf8 src !i n in
               if (cp3 = 0xFF1A || cp3 = 0x003A) && !i + len3 < n then begin
                 let (cp4, len4) = decode_utf8 src (!i + len3) n in
                 if cp4 = 0x300D then begin           (* 」 U+300D *)
                   i := !i + len3 + len4;
                   raise Exit
                 end else begin
                   put (sub () len3);
                   i := !i + len3
                 end
               end else begin
                 put (sub () len3);
                 i := !i + len3
               end
             done
           with Exit -> ());
          put " *)"
        end else begin
          (* 普通标识符 「name」 *)
          let name_buf = Buffer.create 16 in
          (try
             while !i < n do
               let (cp2, len2) = decode_utf8 src !i n in
               if cp2 = 0x300D then begin             (* 」 U+300D *)
                 i := !i + len2;
                 raise Exit
               end else begin
                 Buffer.add_string name_buf (sub () len2);
                 i := !i + len2
               end
             done
           with Exit -> ());
          let name = Buffer.contents name_buf in
          (* 向前扫描跳过空白，检查下一个字符是否为 之（U+4E4B）*)
          (* 如果是，则此标识符为模块名，使用大写前缀 Luo__ *)
          let j = ref !i in
          while !j < n &&
            (let c = src.[!j] in c = ' ' || c = '\t' || c = '\n' || c = '\r')
          do incr j done;
          let is_mod_access =
            !j < n &&
            (let (cp2, _) = decode_utf8 src !j n in cp2 = 0x4E4B)
          in
          put (if is_mod_access then mangle_module name else mangle name)
        end
      end
    end

    (* ── 2. 中文字符串字面量 『...』 ── *)
    else if cp = 0x300E then begin                   (* 『 U+300E *)
      put "\"";
      i := !i + len;
      (try
         while !i < n do
           let (cp2, len2) = decode_utf8 src !i n in
           if cp2 = 0x300F then begin                (* 』 U+300F *)
             i := !i + len2;
             raise Exit
           end else if cp2 = 0x22 then begin         (* 0x22 双引号，转义输出 *)
             put "\\\"";
             i := !i + len2
           end else if cp2 = 0x5C then begin         (* 0x5C 反斜杠，保留及其后字符 *)
             put (sub () len2);
             i := !i + len2;
             if !i < n then begin
               let (_, len3) = decode_utf8 src !i n in
               put (sub () len3);
               i := !i + len3
             end
           end else begin
             put (sub () len2);
             i := !i + len2
           end
         done
       with Exit -> ());
      put "\""
    end

    (* ── 3. OCaml原生嵌套注释 (* ... *) ── *)
    else if cp = 0x28 && !i + 1 < n && src.[!i + 1] = '*' then begin
      put "(*";
      i := !i + 2;
      let depth = ref 1 in
      while !depth > 0 && !i < n do
        if src.[!i] = '(' && !i + 1 < n && src.[!i + 1] = '*' then begin
          put "(*"; i := !i + 2; incr depth
        end else if src.[!i] = '*' && !i + 1 < n && src.[!i + 1] = ')' then begin
          put "*)"; i := !i + 2; decr depth
        end else begin
          putc src.[!i]; incr i
        end
      done
    end

    (* ── 4. ASCII字符串字面量 "..." ── *)
    else if cp = 0x22 then begin
      putc '"'; incr i;
      let escaped = ref false in
      while !i < n && (src.[!i] <> '"' || !escaped) do
        let c = src.[!i] in
        putc c;
        escaped := (c = '\\' && not !escaped);
        incr i
      done;
      if !i < n then begin putc '"'; incr i end
    end

    (* ── 5. 字符字面量 'x' 或 '\n' 或类型变量 'a ── *)
    else if cp = 0x27 then begin
      if !i + 2 < n && src.[!i + 2] = '\'' then begin
        put (sub () 3); i := !i + 3
      end else if !i + 1 < n && src.[!i + 1] = '\\' && !i + 3 < n && src.[!i + 3] = '\'' then begin
        put (sub () 4); i := !i + 4
      end else begin
        putc '\''; incr i
      end
    end

    (* ── 6. 全角括号 ── *)
    else if cp = 0xFF08 then begin put "("; i := !i + len end  (* （→ ( *)
    else if cp = 0xFF09 then begin put ")"; i := !i + len end  (* ）→ ) *)
    else if cp = 0x3010 then begin put "["; i := !i + len end  (* 【→ [ *)
    else if cp = 0x3011 then begin put "]"; i := !i + len end  (* 】→ ] *)

    (* ── 7. 全角运算符 ── *)
    else if cp = 0xFF1D then begin put "=";  i := !i + len end  (* ＝ *)
    else if cp = 0xFF0B then begin put "+";  i := !i + len end  (* ＋ *)
    else if cp = 0xFF0D then begin put "-";  i := !i + len end  (* － *)
    else if cp = 0xFF0A then begin put "*";  i := !i + len end  (* ＊ *)
    else if cp = 0xFF0F then begin put "/";  i := !i + len end  (* ／ *)
    else if cp = 0xFF1C then begin put "<";  i := !i + len end  (* ＜ *)
    else if cp = 0xFF1E then begin put ">";  i := !i + len end  (* ＞ *)
    else if cp = 0xFF5C then begin put "|";  i := !i + len end  (* ｜ *)
    else if cp = 0xFF3F then begin put "_";  i := !i + len end  (* ＿ *)
    else if cp = 0xFF01 then begin put "!";  i := !i + len end  (* ！*)
    else if cp = 0xFF3E then begin put "^";  i := !i + len end  (* ＾ *)
    else if cp = 0xFF20 then begin put "@";  i := !i + len end  (* ＠ *)
    else if cp = 0xFF5E then begin put "~";  i := !i + len end  (* ～ *)
    else if cp = 0xFF0E then begin put ".";  i := !i + len end  (* ．*)
    else if cp = 0xFF40 then begin put "`";  i := !i + len end  (* ｀多态变体 *)

    (* ── 8. Unicode比较/箭头运算符 ── *)
    else if cp = 0x2192 then begin put "->"; i := !i + len end  (* → *)
    else if cp = 0x2190 then begin put "<-"; i := !i + len end  (* ← *)
    else if cp = 0x2260 then begin put "<>"; i := !i + len end  (* ≠ *)
    else if cp = 0x2264 then begin put "<="; i := !i + len end  (* ≤ *)
    else if cp = 0x2265 then begin put ">="; i := !i + len end  (* ≥ *)

    (* ── 9. 全角标点 ── *)
    else if cp = 0xFF0C then begin put ",";  i := !i + len end  (* ，*)
    else if cp = 0xFF1B then begin put ";";  i := !i + len end  (* ；*)
    else if cp = 0x3002 then begin put ";;"; i := !i + len end  (* 。→ ;; *)
    (* ：：(FF1A FF1A) → ::   单个 ：(FF1A) → : *)
    else if cp = 0xFF1A then begin
      let j = !i + len in
      if j < n then begin
        let (cp2, len2) = decode_utf8 src j n in
        if cp2 = 0xFF1A then begin put "::"; i := j + len2 end
        else begin put ":"; i := !i + len end
      end else begin put ":"; i := !i + len end
    end

    (* ── 10. 之（U+4E4B）→ 模块访问符 . ── *)
    else if cp = 0x4E4B then begin put "."; i := !i + len end

    (* ── 11. CJK汉字序列（不含之）：收集完整词，查关键字表 ── *)
    else if is_cjk cp then begin
      let start = !i in
      while !i < n && (let (cp2, _) = decode_utf8 src !i n in is_cjk cp2) do
        let (_, l) = decode_utf8 src !i n in
        i := !i + l
      done;
      let word = String.sub src start (!i - start) in
      put (match Hashtbl.find_opt keywords word with
           | Some kw -> kw
           | None    -> mangle word)
    end

    (* ── 11. ASCII数字 ── *)
    else if cp >= 0x30 && cp <= 0x39 then begin
      while !i < n && (
        let c = src.[!i] in
        (c >= '0' && c <= '9') || c = '.' || c = 'e' || c = 'E'
        || c = 'x' || c = 'X' || c = 'o' || c = 'O'
        || c = 'b' || c = 'B' || c = '_'
        || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
      ) do
        putc src.[!i]; incr i
      done
    end

    (* ── 12. ASCII标识符：原样输出（OCaml内置名称） ── *)
    else if (cp >= 0x41 && cp <= 0x5A)   (* A-Z *)
         || (cp >= 0x61 && cp <= 0x7A)   (* a-z *)
         || cp = 0x5F then begin          (* _ *)
      while !i < n && (
        let c = src.[!i] in
        (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
        || (c >= '0' && c <= '9') || c = '_' || c = '\''
      ) do
        putc src.[!i]; incr i
      done
    end

    (* ── 13. 其他（空白、ASCII运算符等）原样输出 ── *)
    else
      emit_char ()

  done;

  Buffer.contents out
