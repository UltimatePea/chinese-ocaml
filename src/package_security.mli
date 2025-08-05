(** 骆言包管理系统安全模块接口 - Package Security Module Interface *)

(** Author: Whisky, PR Worker *)

(** 包完整性信息 *)
type package_integrity = {
  sha256: string;
  size: int;
  signature: string option;
}

(** 安全验证错误类型 *)
type security_error = 
  | InvalidPackageName of string
  | PathTraversalAttack of string
  | FileSizeExceeded of int * int
  | IntegrityCheckFailed of string * string
  | SignatureVerificationFailed
  | UnicodeNormalizationAttack
  | HomographAttack of string
  | ReservedNameViolation of string

exception SecurityError of security_error

(** 恶意软件扫描结果 *)
type malware_scan_result = 
  | Clean
  | Suspicious of string
  | Malicious of string

(** 包名验证 - 返回清理后的包名或错误 *)
val sanitize_package_name : string -> (string, security_error) result

(** 路径遍历攻击验证 *)
val validate_path_traversal : string -> (string, security_error) result

(** 文件大小验证 *)
val validate_file_size : int -> (unit, security_error) result

(** 计算真正的SHA256哈希值 *)
val compute_sha256_real : string -> string

(** 生产级SHA256实现 - 使用密码学库 *)
val compute_sha256_with_library : string -> string

(** 计算文件的SHA256哈希值 *)
val compute_file_sha256 : string -> (string, string) result

(** 高级密钥对生成 *)  
val generate_key_pair : unit -> string * string

(** 验证包完整性 *)
val verify_package_integrity : string -> package_integrity -> (unit, security_error) result

(** 数字签名生成 *)
val sign_package : string -> string -> string

(** 数字签名验证 *)
val verify_package_signature : string -> string -> string -> (unit, security_error) result

(** 创建包完整性信息 *)
val create_package_integrity : string -> string option -> package_integrity

(** 审计日志初始化 *)
val init_audit_logging : string -> unit

(** 记录审计日志 *)
val audit_log : string -> string -> unit

(** 设置恶意软件扫描器 *)
val set_malware_scanner : (string -> malware_scan_result) -> unit

(** 恶意软件扫描 *)
val scan_for_malware : string -> (unit, string) result

(** 全面的包安全验证 *)
val comprehensive_package_validation : string -> string -> package_integrity option -> (string, security_error) result

(** Unicode规范化 *)
val normalize_unicode : string -> string

(** 检测同形字符攻击 *)
val detect_homograph_attack : string -> bool