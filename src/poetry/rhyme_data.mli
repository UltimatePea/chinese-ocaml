(** 音韵数据存储模块 - 骆言诗词编程特性

    盖古之诗者，音韵为要。此模块专司音韵数据存储， 收录三千余字音韵分类，与逻辑模块分离。 依《广韵》、《集韵》等韵书传统，分类整理。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-17 *)

open Rhyme_types

(** {1 音韵数据存储} *)

val rhyme_database : (string * rhyme_category * rhyme_group) list
(** 音韵数据库
    
    包含汉字音韵分类的完整数据，以(字符, 韵类, 韵组)三元组形式存储。
    数据依据《广韵》、《集韵》等传统韵书，收录常用汉字的音韵分类。
    
    此数据库包含：
    - 平声韵：安韵、思韵、天韵等
    - 仄声韵：上声、去声、入声各韵组
    - 三千余字的完整音韵分类
    
    @note 此为纯数据模块，不包含查询逻辑
*)

(** {2 Phase 1 Enhancement - 扩展音韵数据库} *)

val expanded_rhyme_database : (string * rhyme_category * rhyme_group) list
(** 扩展音韵数据库 - Issue #419 Phase 1实现

    从原有300字扩展到1000+字，支持更广泛的诗词韵律分析。 包含所有原有数据 + 新增扩展韵组数据。

    新增韵组包括：
    - 鱼韵组：鱼书居虚等
    - 花韵组：花霞家茶等
    - 风韵组：风送中东等
    - 月韵组：月雪节切等
    - 江韵组：江窗双庄等
    - 灰韵组：灰回推开等

    @since 2025-07-18 *)

val expanded_rhyme_char_count : int
(** 扩展音韵数据库字符总数 *)

val get_expanded_rhyme_database : unit -> (string * rhyme_category * rhyme_group) list
(** 获取扩展音韵数据库 *)

val is_in_expanded_rhyme_database : string -> bool
(** 检查字符是否在扩展音韵数据库中 *)
