(** 词法分析器关键字处理模块 *)

(** 将Token_mapping.Token_definitions_unified.token转换为Lexer_tokens.token 使用模块化设计替代原来的144行巨型函数 *)
let convert_token = Lexer_token_converter.convert_token

(** 将关键字变体转换为对应的token *)
let variant_to_token variant =
  try
    (* 尝试基础关键字映射 *)
    let mapped_token = Token_mapping.Basic_token_mapping.map_basic_variant variant in
    convert_token mapped_token
  with Token_mapping.Basic_token_mapping.TokenMappingError _ -> (
    try
      (* 尝试类型关键字映射 *)
      Token_mapping.Type_token_mapping.map_type_variant variant |> convert_token
    with Invalid_argument _ -> (
      try
        (* 尝试文言文关键字映射 *)
        Token_mapping.Classical_token_mapping.map_wenyan_variant variant |> convert_token
      with Invalid_argument _ -> (
        try
          (* 尝试古雅体关键字映射 *)
          Token_mapping.Classical_token_mapping.map_ancient_variant variant |> convert_token
        with Invalid_argument _ -> (
          try
            (* 尝试自然语言关键字映射 *)
            Token_mapping.Classical_token_mapping.map_natural_language_variant variant
            |> convert_token
          with Invalid_argument _ -> (
            try
              (* 尝试特殊关键字映射 *)
              Token_mapping.Special_token_mapping.map_special_variant variant |> convert_token
            with Invalid_argument _ ->
              raise
                (Invalid_argument
                   ("Unknown keyword variant: " ^ (Obj.repr variant |> Obj.tag |> string_of_int))))))))

(** 查找关键字 *)
let find_keyword str =
  match Keyword_tables.Keywords.find_keyword str with
  | Some variant -> Some (variant_to_token variant)
  | None -> None
