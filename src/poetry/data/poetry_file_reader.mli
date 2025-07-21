(** 诗词数据文件读取器 - 专门负责文件系统操作

    提供文件读取和路径管理功能，处理IO相关的异常情况。 支持项目内数据文件的标准化访问。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 *)

exception FileReadError of string
(** 文件读取异常类型 *)

val read_file_content : string -> string
(** 读取文件全部内容
    @param filename 文件名
    @return 文件内容字符串
    @raise FileReadError 文件不存在或读取失败时抛出异常 *)

val get_data_path : string -> string
(** 获取数据文件的完整路径 基于项目根目录构建数据文件的绝对路径
    @param relative_path 相对于data目录的路径
    @return 数据文件的完整路径 *)
