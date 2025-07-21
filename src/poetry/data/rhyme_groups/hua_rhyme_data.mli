(** 花韵组数据模块接口 - 骆言诗词编程特性

    花霞家茶，春花秋月韵味深。花韵组提供丰富的韵律字符数据， 依《平水韵》传统分类，适合描写自然美景和生活情趣。 *)

open Rhyme_group_types

(** {1 花韵组核心字符数据} *)

val hua_yun_basic_chars : (string * rhyme_category * rhyme_group) list
(** 花韵基础字组 - "花、霞、家、茶"等核心字 *)

val hua_yun_che_group : (string * rhyme_category * rhyme_group) list
(** 花韵车遮组 - "车、遮、蔗、者"等字符 *)

val hua_yun_xie_group : (string * rhyme_category * rhyme_group) list
(** 花韵协叶组 - "叶、协、胁、挟"等字符 *)

val hua_yun_ya_group : (string * rhyme_category * rhyme_group) list
(** 花韵牙芽组 - "牙、芽、崖、涯"等字符 *)

val hua_yun_yan_group : (string * rhyme_category * rhyme_group) list
(** 花韵烟盐组 - "烟、盐、严、颜"等字符 *)

val hua_yun_yan_second_group : (string * rhyme_category * rhyme_group) list
(** 花韵验艳组 - "验、艳、焰、宴"等字符 *)

val hua_yun_cha_group : (string * rhyme_category * rhyme_group) list
(** 花韵查茶组 - "姹、杈、楂、槎"等字符 *)

(** {1 花韵组数据合成} *)

val hua_yun_ping_sheng : (string * rhyme_category * rhyme_group) list
(** 花韵组平声韵数据 - 完整的花韵平声韵数据 *)

(** {1 花韵组统计信息} *)

val hua_yun_char_count : int
(** 获取花韵组字符总数 *)

val hua_yun_basic_count : int
(** 获取花韵组基础字符数量 *)

val hua_yun_che_count : int
(** 获取花韵组车遮系列字符数量 *)

val hua_yun_xie_count : int
(** 获取花韵组协叶系列字符数量 *)

val hua_yun_ya_count : int
(** 获取花韵组牙芽系列字符数量 *)

val hua_yun_yan_count : int
(** 获取花韵组烟盐系列字符数量 *)

val hua_yun_yan_second_count : int
(** 获取花韵组验艳系列字符数量 *)

val hua_yun_cha_count : int
(** 获取花韵组查茶系列字符数量 *)
