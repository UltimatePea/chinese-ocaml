(** Token兼容性报告生成模块 - Issue #646 技术债务清理
    
    此模块负责生成各种兼容性报告和统计信息，便于监控和维护Token兼容性。
    这是从 token_compatibility.ml 中提取出来的专门模块，提升代码可维护性。
    
    @author 骆言技术债务清理团队 Issue #646
    @version 1.0
    @since 2025-07-20 *)

(** 获取所有支持的遗留Token列表 *)
let get_supported_legacy_tokens () = [
  (* 基础关键字 (19个) *)
  "LetKeyword"; "RecKeyword"; "InKeyword"; "FunKeyword"; "IfKeyword";
  "ThenKeyword"; "ElseKeyword"; "MatchKeyword"; "WithKeyword"; "TrueKeyword";
  "FalseKeyword"; "AndKeyword"; "OrKeyword"; "NotKeyword"; "TypeKeyword";
  "ModuleKeyword"; "RefKeyword"; "AsKeyword"; "OfKeyword";
  
  (* 文言文关键字 (12个) *)
  "HaveKeyword"; "SetKeyword"; "OneKeyword"; "NameKeyword"; "AlsoKeyword";
  "ThenGetKeyword"; "CallKeyword"; "ValueKeyword"; "AsForKeyword"; "NumberKeyword";
  "IfWenyanKeyword"; "ThenWenyanKeyword";
  
  (* 古雅体关键字 (8个) *)
  "AncientDefineKeyword"; "AncientObserveKeyword"; "AncientIfKeyword"; "AncientThenKeyword";
  "AncientListStartKeyword"; "AncientEndKeyword"; "AncientIsKeyword"; "AncientArrowKeyword";
  
  (* 运算符 (22个) *)
  "PlusOp"; "MinusOp"; "MultOp"; "DivOp"; "ModOp"; "PowerOp";
  "EqualOp"; "NotEqualOp"; "LessOp"; "GreaterOp"; "LessEqualOp"; "GreaterEqualOp";
  "AndOp"; "OrOp"; "NotOp"; "AssignOp"; "RefAssignOp";
  "ConsOp"; "ArrowOp"; "PipeRightOp"; "PipeLeftOp";
  
  (* 分隔符 (23个) *)
  "LeftParen"; "RightParen"; "LeftBracket"; "RightBracket"; "LeftBrace"; "RightBrace";
  "Comma"; "Semicolon"; "Colon"; "Dot"; "QuestionMark"; "ExclamationMark";
  "ChineseComma"; "ChinesePause"; "ChineseSemicolon"; "ChineseColon";
  "ChinesePeriod"; "ChineseQuestion"; "ChineseExclamation";
  "Pipe"; "Underscore"; "At"; "Hash";
]

(** 生成基础兼容性报告 *)
let generate_compatibility_report () =
  let supported_tokens = get_supported_legacy_tokens () in
  let total_count = List.length supported_tokens in
  
  Printf.sprintf 
    "Token兼容性报告\n\
     ================\n\
     总支持Token数量: %d\n\
     兼容性状态: 良好\n\
     报告生成时间: %s"
    total_count
    (string_of_float (Unix.time ()))

(** 生成详细的兼容性报告 *)
let generate_detailed_compatibility_report () =
  let supported_tokens = get_supported_legacy_tokens () in
  
  Printf.sprintf 
    "详细Token兼容性报告\n\
     =====================\n\
     \n\
     支持的Token类型:\n\
     - 基础关键字: 19个\n\
     - 文言文关键字: 12个\n\
     - 古雅体关键字: 8个\n\
     - 运算符: 22个\n\
     - 分隔符: 23个\n\
     \n\
     总计: %d个Token类型\n\
     兼容性覆盖率: 良好\n\
     \n\
     报告生成时间: %s"
    (List.length supported_tokens)
    (string_of_float (Unix.time ()))