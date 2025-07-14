(** 详细调试关键字匹配问题 *)

open Yyocamlc_lib.Lexer

let debug_step_by_step input =
  Printf.printf "=== 分步调试: %s ===\n" input;
  let rec analyze_tokens state acc step =
    let pos = { line = state.current_line; column = state.current_column; filename = state.filename } in
    Printf.printf "\n步骤 %d: 当前位置 %d (行%d 列%d)\n" step state.position pos.line pos.column;

    if state.position >= state.length then (
      Printf.printf "已到达文件末尾\n";
      List.rev acc
    ) else (
      let char_at_pos = if state.position < state.length then state.input.[state.position] else ' ' in
      Printf.printf "当前字符: '%c' (字节值: %d)\n" char_at_pos (Char.code char_at_pos);

      let (token, pos, new_state) = next_token state in
      Printf.printf "识别的词元: %s\n" (show_token token);
      Printf.printf "新位置: %d\n" new_state.position;

      match token with
      | EOF -> List.rev ((token, pos) :: acc)
      | _ -> analyze_tokens new_state ((token, pos) :: acc) (step + 1)
    )
  in
  let initial_state = create_lexer_state input "debug.luo" in
  let tokens = analyze_tokens initial_state [] 1 in
  Printf.printf "\n最终词元列表:\n";
  List.iteri (fun i (token, pos) ->
    Printf.printf "%d: %s (行%d 列%d)\n" i (show_token token) pos.line pos.column
  ) tokens

let () =
  debug_step_by_step "设数值为42";