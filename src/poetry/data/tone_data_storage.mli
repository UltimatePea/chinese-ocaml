(** 声调数据存储模块接口 - 数据外化重构
    
    提供声调数据的标准接口，支持平声、上声、去声、入声等
    中文汉字声调分类数据的访问。
    
    @author 骆言诗词编程团队
    @version 1.0 - 数据外化重构
    @since 2025-07-18
*)

(** 平声字符数据列表 - 124个平声汉字 *)
val ping_sheng_list : string list

(** 上声字符数据列表 - 76个上声汉字 *)  
val shang_sheng_list : string list

(** 去声字符数据列表 - 42个去声汉字 *)
val qu_sheng_list : string list

(** 入声字符数据列表 - 47个入声汉字 *)
val ru_sheng_list : string list