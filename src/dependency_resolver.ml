(** 骆言包管理系统依赖解析器 - Dependency Resolver Module *)

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
  resolved_packages: (string * string) list;  (* 已解析包: 包名 * 确定版本 *)
  conflicts: (string * string list) list;     (* 冲突: 包名 * 冲突版本列表 *)
  missing: string list;                       (* 缺失: 无法找到的包 *)
}

(** 包配置类型（简化版本，避免循环依赖） *)
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

(** 版本解析和比较函数 *)
let parse_version version =
  let parts = String.split_on_char '.' version in
  try
    let major = int_of_string (List.nth parts 0) in
    let minor = if List.length parts > 1 then int_of_string (List.nth parts 1) else 0 in
    let patch = if List.length parts > 2 then int_of_string (List.nth parts 2) else 0 in
    Ok (major, minor, patch)
  with
  | _ -> Error ("无效的版本格式: " ^ version)

let compare_versions v1 v2 =
  match parse_version v1, parse_version v2 with
  | Ok (maj1, min1, pat1), Ok (maj2, min2, pat2) ->
    if maj1 <> maj2 then compare maj1 maj2
    else if min1 <> min2 then compare min1 min2
    else compare pat1 pat2
  | _ -> String.compare v1 v2

let is_valid_version version =
  match parse_version version with
  | Ok _ -> true
  | Error _ -> false

(** 版本约束解析 *)
let parse_version_constraint constraint_str =
  let trim_str = String.trim constraint_str in
  if String.length trim_str = 0 then 
    Error (InvalidVersionConstraint "空的版本约束")
  else if String.get trim_str 0 = '=' then
    let version = String.sub trim_str 1 (String.length trim_str - 1) |> String.trim in
    if is_valid_version version then Ok (Exact version)
    else Error (InvalidVersionConstraint ("无效版本: " ^ version))
  else if String.get trim_str 0 = '>' then
    if String.length trim_str > 1 && String.get trim_str 1 = '=' then
      let version = String.sub trim_str 2 (String.length trim_str - 2) |> String.trim in
      if is_valid_version version then Ok (GreaterThanOrEqual version)
      else Error (InvalidVersionConstraint ("无效版本: " ^ version))
    else
      let version = String.sub trim_str 1 (String.length trim_str - 1) |> String.trim in
      if is_valid_version version then Ok (GreaterThan version)
      else Error (InvalidVersionConstraint ("无效版本: " ^ version))
  else if String.get trim_str 0 = '<' then
    if String.length trim_str > 1 && String.get trim_str 1 = '=' then
      let version = String.sub trim_str 2 (String.length trim_str - 2) |> String.trim in
      if is_valid_version version then Ok (LessThanOrEqual version)
      else Error (InvalidVersionConstraint ("无效版本: " ^ version))
    else
      let version = String.sub trim_str 1 (String.length trim_str - 1) |> String.trim in
      if is_valid_version version then Ok (LessThan version)
      else Error (InvalidVersionConstraint ("无效版本: " ^ version))
  else if String.get trim_str 0 = '^' then
    let version = String.sub trim_str 1 (String.length trim_str - 1) |> String.trim in
    if is_valid_version version then Ok (Compatible version)
    else Error (InvalidVersionConstraint ("无效版本: " ^ version))
  else if String.contains trim_str '-' then
    let parts = String.split_on_char '-' trim_str in
    if List.length parts = 2 then
      let v1 = String.trim (List.nth parts 0) in
      let v2 = String.trim (List.nth parts 1) in
      if is_valid_version v1 && is_valid_version v2 then
        Ok (Range (v1, v2))
      else
        Error (InvalidVersionConstraint ("无效的版本范围: " ^ constraint_str))
    else
      Error (InvalidVersionConstraint ("无效的版本范围: " ^ constraint_str))
  else if is_valid_version trim_str then
    Ok (Exact trim_str)
  else
    Error (InvalidVersionConstraint ("无法解析版本约束: " ^ constraint_str))

let version_satisfies version version_constraint =
  match version_constraint with
  | Exact v -> compare_versions version v = 0
  | GreaterThan v -> compare_versions version v > 0
  | GreaterThanOrEqual v -> compare_versions version v >= 0
  | LessThan v -> compare_versions version v < 0
  | LessThanOrEqual v -> compare_versions version v <= 0
  | Compatible v -> 
    (* 兼容版本：主版本相同，副版本和补丁版本可以更高 *)
    (match parse_version version, parse_version v with
    | Ok (maj1, min1, pat1), Ok (maj2, min2, pat2) ->
      maj1 = maj2 && (min1 > min2 || (min1 = min2 && pat1 >= pat2))
    | _ -> false)
  | Range (v1, v2) -> 
    compare_versions version v1 >= 0 && compare_versions version v2 <= 0

(** 改进的SAT求解器实现 *)
let create_sat_variable name = Hashtbl.hash name

(** 单元传播优化 *)
let unit_propagate formula assignment =
  let rec propagate formula assignment changed =
    let (new_formula, new_assignment, has_changed) = 
      List.fold_left (fun (acc_formula, acc_assignment, acc_changed) clause ->
        let active_literals = List.filter (fun lit ->
          not (List.exists (fun (var, value) -> 
            (lit > 0 && var = abs lit && value) || 
            (lit < 0 && var = abs lit && not value)
          ) acc_assignment)
        ) clause in
        
        if List.length active_literals = 0 then
          (* 子句已满足 *)
          (acc_formula, acc_assignment, acc_changed)
        else if List.exists (fun lit ->
          List.exists (fun (var, value) -> 
            (lit < 0 && var = abs lit && value) || 
            (lit > 0 && var = abs lit && not value)
          ) acc_assignment
        ) active_literals then
          (* 子句冲突 *)
          ([] :: acc_formula, acc_assignment, true) (* 添加空子句表示冲突 *)
        else if List.length active_literals = 1 then
          (* 单元子句 *)
          let unit_lit = List.hd active_literals in
          let new_assign = (abs unit_lit, unit_lit > 0) in
          if not (List.exists (fun (v, _) -> v = abs unit_lit) acc_assignment) then
            (acc_formula, new_assign :: acc_assignment, true)
          else
            (active_literals :: acc_formula, acc_assignment, acc_changed)
        else
          (active_literals :: acc_formula, acc_assignment, acc_changed)
      ) ([], assignment, false) formula
    in
    if has_changed && not (List.exists (fun clause -> List.length clause = 0) new_formula) then
      propagate new_formula new_assignment true
    else
      (new_formula, new_assignment, has_changed || changed)
  in
  propagate formula assignment false

(** 启发式变量选择 - VSIDS算法简化版 *)
let select_variable formula assignment =
  let var_scores = Hashtbl.create 100 in
  
  (* 统计每个变量在子句中出现的频率 *)
  List.iter (fun clause ->
    List.iter (fun lit ->
      let var = abs lit in
      let current_score = try Hashtbl.find var_scores var with Not_found -> 0 in
      Hashtbl.replace var_scores var (current_score + 1)
    ) clause
  ) formula;
  
  (* 找到未赋值且得分最高的变量 *)
  let assigned_vars = List.map fst assignment in
  let candidates = Hashtbl.fold (fun var score acc ->
    if not (List.mem var assigned_vars) then (var, score) :: acc else acc
  ) var_scores [] in
  
  match List.sort (fun (_, s1) (_, s2) -> compare s2 s1) candidates with
  | (var, _) :: _ -> Some var
  | [] -> None

(** 改进的DPLL算法实现 *)
let solve_sat_formula formula =
  let max_iterations = 10000 in
  let iteration_count = ref 0 in
  
  let rec dpll formula assignment =
    incr iteration_count;
    if !iteration_count > max_iterations then
      None (* 超时保护 *)
    else
      let (propagated_formula, new_assignment, _) = unit_propagate formula assignment in
      
      if List.exists (fun clause -> List.length clause = 0) propagated_formula then
        None  (* 冲突 *)
      else if List.for_all (fun clause -> List.length clause = 0) propagated_formula then
        Some new_assignment  (* 所有子句都满足 *)
      else
        match select_variable propagated_formula new_assignment with
        | None -> Some new_assignment (* 没有更多变量需要赋值 *)
        | Some var ->
          (* 尝试 var = true *)
          let pos_assignment = (var, true) :: new_assignment in
          (match dpll propagated_formula pos_assignment with
           | Some solution -> Some solution
           | None ->
             (* 尝试 var = false *)
             let neg_assignment = (var, false) :: new_assignment in
             dpll propagated_formula neg_assignment)
  in
  
  try
    dpll formula []
  with
  | exc -> 
    raise (DependencyResolutionError (SATSolverFailure (Printexc.to_string exc)))

(** 构建依赖约束的SAT公式 *)
let build_dependency_constraint_formula (packages : simple_package_config list) =
  let formula = ref [] in
  let package_variables = Hashtbl.create 100 in
  
  List.iter (fun config ->
    let pkg_var = create_sat_variable (config.name ^ "@" ^ config.version) in
    Hashtbl.add package_variables (config.name, config.version) pkg_var;
    
    (* 如果选择了这个包，则必须满足其依赖 *)
    List.iter (fun (dep_name, version_constraint) ->
      (* 为每个依赖创建变量 *)
      let dep_var = create_sat_variable (dep_name ^ "@constraint:" ^ version_constraint) in
      (* pkg_var -> dep_var，即 ~pkg_var \/ dep_var *)
      formula := [-pkg_var; dep_var] :: !formula
    ) config.dependencies
  ) packages;
  
  (!formula, package_variables)

(** 循环依赖检测 - 改进的算法 *)
let detect_circular_dependencies deps =
  let graph = Hashtbl.create 100 in
  
  (* 构建依赖图 *)
  List.iter (fun (pkg, deps) ->
    Hashtbl.replace graph pkg deps
  ) deps;
  
  let rec dfs visited path current =
    if List.mem current path then
      Some (List.rev (current :: path)) (* 找到循环 *)
    else if List.mem current visited then
      None (* 已访问过，无循环 *)
    else
      let current_deps = try Hashtbl.find graph current with Not_found -> [] in
      let new_path = current :: path in
      let new_visited = current :: visited in
      
      (* 递归检查所有依赖 *)
      List.fold_left (fun acc dep ->
        match acc with
        | Some cycle -> Some cycle (* 已找到循环 *)
        | None -> dfs new_visited new_path dep
      ) None current_deps
  in
  
  (* 检查所有节点 *)
  let all_packages = Hashtbl.fold (fun pkg deps acc -> 
    pkg :: (deps @ acc)
  ) graph [] |> List.sort_uniq String.compare in
  
  List.fold_left (fun acc pkg ->
    match acc with
    | Some cycle -> Some cycle
    | None -> dfs [] [] pkg
  ) None all_packages

(** 高级依赖解析实现 *)
let advanced_dependency_resolution (configs : simple_package_config list) =
  (* 1. 检查循环依赖 *)
  let dependency_graph = List.map (fun config ->
    (config.name, List.map fst config.dependencies)
  ) configs in
  
  (match detect_circular_dependencies dependency_graph with
   | Some cycle -> Error (CircularDependency cycle)
   | None ->
     
     (* 2. 构建SAT约束公式 *)
     let (formula, variables) = build_dependency_constraint_formula configs in
     
     (* 3. 求解SAT公式 *)
     (match solve_sat_formula formula with
      | None -> Error (ConflictingVersions ("global", ["无法找到满足所有约束的解"]))
      | Some assignment ->
        
        (* 4. 从SAT解中提取包选择 *)
        let resolved_packages = List.fold_left (fun acc (var, value) ->
          if value then
            (* 查找对应的包名和版本 *)
            let package_info = Hashtbl.fold (fun (name, version) v acc ->
              if v = var then Some (name, version) else acc
            ) variables None in
            match package_info with
            | Some (name, version) -> (name, version) :: acc
            | None -> acc
          else acc
        ) [] assignment in
        
        Ok { resolved_packages; conflicts = []; missing = [] }))

(** 简化的依赖解析器 - 用于向后兼容 *)
let simple_dependency_resolution dependencies available_packages =
  let rec resolve_recursive resolved missing conflicts deps =
    match deps with
    | [] -> 
      { resolved_packages = List.rev resolved; 
        missing = List.rev missing; 
        conflicts = List.rev conflicts }
    | (name, version_constraint) :: rest ->
      if List.exists (fun (resolved_name, _) -> resolved_name = name) resolved then
        resolve_recursive resolved missing conflicts rest
      else
        (* 在可用包中查找匹配的包 *)
        let matching_packages = List.filter (fun (pkg_name, pkg_version, _) ->
          pkg_name = name && 
          (match parse_version_constraint version_constraint with
           | Ok constraint_obj -> version_satisfies pkg_version constraint_obj
           | Error _ -> false)
        ) available_packages in
        
        match matching_packages with
        | [] -> resolve_recursive resolved (name :: missing) conflicts rest
        | (_, best_version, pkg_config) :: _ ->
          (* 选择第一个匹配的版本（应该按版本排序） *)
          let has_conflict = List.exists (fun (resolved_name, resolved_ver) ->
            resolved_name = name && compare_versions resolved_ver best_version <> 0
          ) resolved in
          
          if has_conflict then
            let existing_versions = List.fold_left (fun acc (n, v) ->
              if n = name then v :: acc else acc
            ) [] resolved in
            resolve_recursive resolved missing ((name, best_version :: existing_versions) :: conflicts) rest
          else
            (* 递归解析新包的依赖 *)
            let sub_deps = pkg_config.dependencies in
            let sub_resolution = resolve_recursive ((name, best_version) :: resolved) missing conflicts sub_deps in
            resolve_recursive sub_resolution.resolved_packages 
              (missing @ sub_resolution.missing) 
              (conflicts @ sub_resolution.conflicts) rest
  in
  resolve_recursive [] [] [] dependencies

(** 依赖解析性能统计 *)
type resolution_stats = {
  packages_analyzed: int;
  sat_variables: int;
  sat_clauses: int;
  resolution_time_ms: float;
  circular_dependencies_found: int;
}

let create_resolution_stats packages_count variables_count clauses_count time circular_deps =
  {
    packages_analyzed = packages_count;
    sat_variables = variables_count;
    sat_clauses = clauses_count;
    resolution_time_ms = time;
    circular_dependencies_found = circular_deps;
  }

(** 带统计信息的依赖解析 *)
let resolve_dependencies_with_stats configs =
  let start_time = Unix.gettimeofday () in
  let packages_count = List.length configs in
  
  let result = advanced_dependency_resolution configs in
  
  let end_time = Unix.gettimeofday () in
  let resolution_time = (end_time -. start_time) *. 1000.0 in
  
  let (formula, _) = build_dependency_constraint_formula configs in
  let variables_count = List.fold_left (fun acc clause ->
    List.fold_left (fun acc2 lit -> max acc2 (abs lit)) acc clause
  ) 0 formula in
  let clauses_count = List.length formula in
  
  let circular_deps = match detect_circular_dependencies (List.map (fun c -> (c.name, List.map fst c.dependencies)) configs) with
    | Some _ -> 1
    | None -> 0
  in
  
  let stats = create_resolution_stats packages_count variables_count clauses_count resolution_time circular_deps in
  
  (result, stats)