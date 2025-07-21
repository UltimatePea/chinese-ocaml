(* 诗词评价上下文管理模块
   
   专门管理评价上下文的创建、维护和查询操作，
   为各种评价器提供统一的数据接口。 *)

open Yyocamlc_lib
open Tone_data
open Artistic_evaluator_types

(* 创建诗词评价上下文 - 预处理诗句，建立高效数据结构
   
   此函数将诗句文本转化为便于分析的数据结构：
   1. 计算UTF-8字符总数，为后续算法提供基础数据
   2. 将诗句拆分为字符列表，便于逐字分析
   3. 构建声调查找哈希表，避免重复查询tone_database
   
   设计思想源于"工欲善其事，必先利其器"，通过预处理
   提高后续各种评价算法的执行效率。 *)
let create_evaluation_context verse =
  let char_count = Utf8_utils.StringUtils.utf8_length verse in
  let char_list = Utf8_utils.StringUtils.utf8_to_char_list verse in

  (* 构建声调查找哈希表 - 将tone_database转换为O(1)查找结构
     古代韵书如《广韵》按韵部分类字音，今以哈希表实现快速查找 *)
  let tone_lookup = Hashtbl.create 64 in
  List.iter (fun (char, tone) -> Hashtbl.replace tone_lookup char tone) tone_database;

  { verse; char_count; char_list; tone_lookup }

(* 获取字符声调 - 快速查询字符的声调属性
   
   使用预建的哈希表查询字符声调，避免每次遍历tone_database。
   声调分类依古代四声传统：平、上、去、入，为诗词格律分析
   提供基础数据。古云"平仄相间，抑扬有致"，此为其技术实现。 *)
let get_char_tone context char =
  try Some (Hashtbl.find context.tone_lookup char) with Not_found -> None

(* 获取上下文基本信息 *)
let get_verse context = context.verse
let get_char_count context = context.char_count
let get_char_list context = context.char_list
