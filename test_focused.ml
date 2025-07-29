let () =
  Printf.printf "Testing rhyme analysis function directly...\n";
  let result = Poetry.Rhyme_unified.Analysis.can_rhyme_together "山" "间" in
  Printf.printf "Result: %b\n" result;
  
  (* Test individual lookups *)
  let group1 = Poetry.Rhyme_unified.Analysis.get_character_rhyme_group "山" in
  let group2 = Poetry.Rhyme_unified.Analysis.get_character_rhyme_group "间" in
  
  Printf.printf "Group for 山: %s\n" (match group1 with 
    | Some g -> Poetry_core.Poetry_types.string_of_rhyme_group g 
    | None -> "None");
  Printf.printf "Group for 间: %s\n" (match group2 with 
    | Some g -> Poetry_core.Poetry_types.string_of_rhyme_group g 
    | None -> "None");
    
  Printf.printf "Groups equal: %b\n" (group1 = group2)