(* 艺术模板管理模块 *)

open Artistic_core_types

(** {1 模板推荐和管理} *)

let suggest_template_for_context (context : string) : artistic_template list query_result =
  let context_template_map = [
    ("山水", {name = "山水模板"; category = Nature; pattern = "山...水..."; examples = []; effectiveness = 0.8});
    ("花鸟", {name = "花鸟模板"; category = Nature; pattern = "花...鸟..."; examples = []; effectiveness = 0.7});
  ] in
  let matching_templates = List.filter_map (fun (ctx, template) ->
    if String.contains context (String.get ctx 0) then Some template else None
  ) context_template_map in
  if matching_templates = [] then NotFound else Found matching_templates

let evaluate_template_effectiveness (template_name : string) : float query_result =
  if String.length template_name > 0 then
    Found 0.75
  else
    Found 0.0

(** {1 模板查询接口} *)

let get_templates (category : word_category) : artistic_template list query_result =
  Artistic_query_engine.get_artistic_templates category