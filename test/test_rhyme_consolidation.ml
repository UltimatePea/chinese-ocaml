(** Test rhyme module consolidation *)

let test_rhyme_functionality () =
  let stats = Poetry_rhyme.Rhyme_data.get_statistics () in
  Printf.printf "韵律统计: 总字符 %d，总韵组 %d\n" 
    stats.total_characters stats.total_groups;
  
  (* Test basic character lookup *)
  let test_char = "春" in
  match Poetry_rhyme.Rhyme_data.lookup_character test_char with
  | Poetry_rhyme.Rhyme_types.Found rhyme_char ->
      Printf.printf "字符 '%s' 属于 %s\n" 
        test_char 
        (Poetry_rhyme.Rhyme_types.string_of_rhyme_group rhyme_char.rhyme_group)
  | _ -> Printf.printf "字符 '%s' 未找到\n" test_char

let () = test_rhyme_functionality ()