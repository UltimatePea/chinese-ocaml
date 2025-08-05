(** 骆言包管理系统依赖解析器接口 - Dependency Resolver Module Interface *)

(** Author: Whisky, PR Worker *)

(** SAT求解器类型定义 *)
type sat_variable = int
type sat_clause = sat_variable list
type sat_formula = sat_clause list
type sat_assignment = (sat_variable * bool) list

(** 版本约束类型 *)
type version_constraint = 
  | Exact of string
  | GreaterThan of string
  | GreaterThanOrEqual of string
  | LessThan of string
  | LessThanOrEqual of string
  | Compatible of string
  | Range of string * string

(** 依赖解析结果 *)
type dependency_resolution = {
  resolved_packages: (string * string) list;
  conflicts: (string * string list) list;
  missing: string list;
}

(** 简化的包配置类型 *)
type simple_package_config = {
  name: string;
  version: string;
  dependencies: (string * string) list;
}

(** 依赖解析错误类型 *)
type resolution_error =
  | CircularDependency of string list
  | ConflictingVersions of string * string list
  | MissingPackage of string
  | InvalidVersionConstraint of string
  | SATSolverTimeout
  | SATSolverFailure of string

exception DependencyResolutionError of resolution_error

(** 依赖解析性能统计 *)
type resolution_stats = {
  packages_analyzed: int;
  sat_variables: int;
  sat_clauses: int;
  resolution_time_ms: float;
  circular_dependencies_found: int;
}

(** 版本解析和比较 *)
val parse_version : string -> (int * int * int, string) result
val compare_versions : string -> string -> int
val is_valid_version : string -> bool

(** 版本约束处理 *)
val parse_version_constraint : string -> (version_constraint, resolution_error) result
val version_satisfies : string -> version_constraint -> bool

(** SAT求解器 *)
val create_sat_variable : string -> sat_variable
val solve_sat_formula : sat_formula -> sat_assignment option

(** 循环依赖检测 *)
val detect_circular_dependencies : (string * string list) list -> string list option

(** 依赖解析算法 *)
val advanced_dependency_resolution : simple_package_config list -> (dependency_resolution, resolution_error) result

(** 简化的依赖解析（向后兼容） *)
val simple_dependency_resolution : (string * string) list -> (string * string * simple_package_config) list -> dependency_resolution

(** 带统计信息的依赖解析 *)
val resolve_dependencies_with_stats : simple_package_config list -> ((dependency_resolution, resolution_error) result * resolution_stats)

(** 构建SAT约束公式 *)
val build_dependency_constraint_formula : simple_package_config list -> (sat_formula * (string * string, sat_variable) Hashtbl.t)