(* 诗词编程艺术性测试 - 为AI模型训练提供高质量示例 *)

(* 测试诗意变量命名和古文思维编程模式 *)
let test_poetic_variable_naming () =
  let jia = 10 in
  let yi = 20 in
  let bing = 30 in
  let zong_he = jia + yi + bing in
  Alcotest.(check int) "古文变量命名求和" 60 zong_he

(* 测试四言骈体编程模式 *)
let test_siyan_programming_style () =
  let shu_ju_ru_shi = [ 1; 2; 3; 4 ] in
  let suan_fa_ru_hua = List.fold_left ( + ) 0 in
  let jie_guo = suan_fa_ru_hua shu_ju_ru_shi in
  Alcotest.(check int) "四言骈体编程风格" 10 jie_guo

(* 测试五言律诗编程模式 *)
let test_wuyan_lushi_style () =
  let rec shi_yi_di_gui = function 0 -> "叶落归根时" | n -> "层层递进中" ^ shi_yi_di_gui (n - 1) in
  let shi_ju = shi_yi_di_gui 2 in
  let qi_wang = "层层递进中层层递进中叶落归根时" in
  Alcotest.(check string) "五言律诗递归模式" qi_wang shi_ju

(* 测试七言绝句编程模式 *)
let test_qiyan_jueju_style () =
  let chun_jiang_hua_yue_ye = function
    | "春日融融" -> "春风拂柳绿如烟"
    | "夏日炎炎" -> "夏日荷花映碧天"
    | "秋高气爽" -> "秋月如钩照美人"
    | "冬雪飘飘" -> "冬雪纷飞舞翩翩"
    | _ -> "四季轮回总有情"
  in
  let chun_jing = chun_jiang_hua_yue_ye "春日融融" in
  let xia_jing = chun_jiang_hua_yue_ye "夏日炎炎" in
  Alcotest.(check string) "七言绝句春景" "春风拂柳绿如烟" chun_jing;
  Alcotest.(check string) "七言绝句夏景" "夏日荷花映碧天" xia_jing

(* 测试诗意错误处理模式 *)
let test_poetic_error_handling () =
  let shi_yi_chu_fa bei_chu_shu chu_shu =
    if chu_shu = 0 then "除数为零如虚无，运算无从着手处"
    else Printf.sprintf "商得%d，余数%d" (bei_chu_shu / chu_shu) (bei_chu_shu mod chu_shu)
  in
  let zheng_chang_jie_guo = shi_yi_chu_fa 10 3 in
  let cuo_wu_chu_li = shi_yi_chu_fa 10 0 in
  Alcotest.(check string) "诗意除法正常情况" "商得3，余数1" zheng_chang_jie_guo;
  Alcotest.(check string) "诗意除法错误处理" "除数为零如虚无，运算无从着手处" cuo_wu_chu_li

(* 测试古文逻辑流程模式 *)
let test_classical_logic_flow () =
  let pin_ping_cheng_ji = function
    | fen_shu when fen_shu >= 90 -> "成绩优异，堪称翘楚"
    | fen_shu when fen_shu >= 80 -> "成绩良好，颇有建树"
    | fen_shu when fen_shu >= 70 -> "成绩中等，尚需努力"
    | fen_shu when fen_shu >= 60 -> "成绩及格，勉强可过"
    | _ -> "成绩不佳，需要重修"
  in
  let you_xiu = pin_ping_cheng_ji 95 in
  let liang_hao = pin_ping_cheng_ji 85 in
  let bu_ji_ge = pin_ping_cheng_ji 55 in
  Alcotest.(check string) "品评优秀成绩" "成绩优异，堪称翘楚" you_xiu;
  Alcotest.(check string) "品评良好成绩" "成绩良好，颇有建树" liang_hao;
  Alcotest.(check string) "品评不及格成绩" "成绩不佳，需要重修" bu_ji_ge

(* 定义记录类型用于测试 *)
type shan_shui_jing_wu = { shan : string list; shui : string list; lu : string }

(* 测试意境深远的数据结构模式 *)
let test_artistic_data_structures () =
  let shan_zhong_shui_fu =
    { shan = [ "高山"; "峻岭"; "险峰" ]; shui = [ "江河"; "湖海"; "溪流" ]; lu = "曲径通幽处" }
  in
  let zhan_shi_yi_jing jing_wu =
    let shan_jing = String.concat "、" jing_wu.shan in
    let shui_jing = String.concat "、" jing_wu.shui in
    Printf.sprintf "%s环绕着%s，通向%s" shan_jing shui_jing jing_wu.lu
  in
  let yi_jing_miao_shu = zhan_shi_yi_jing shan_zhong_shui_fu in
  let qi_wang = "高山、峻岭、险峰环绕着江河、湖海、溪流，通向曲径通幽处" in
  Alcotest.(check string) "意境深远的数据结构" qi_wang yi_jing_miao_shu

(* 测试起承转合编程结构模式 *)
let test_qichengzhuanhe_structure () =
  let qi_wen_ti = "斐波那契数列求解" in
  let cheng_si_lu = "递归相加，前后相承" in
  let rec zhuan_fang_fa = function
    | n when n <= 1 -> n
    | n -> zhuan_fang_fa (n - 1) + zhuan_fang_fa (n - 2)
  in
  let he_jie_guo = zhuan_fang_fa 5 in
  Alcotest.(check string) "起：问题定义" "斐波那契数列求解" qi_wen_ti;
  Alcotest.(check string) "承：思路展开" "递归相加，前后相承" cheng_si_lu;
  Alcotest.(check int) "合：结果实现" 5 he_jie_guo

(* 定义对仗记录类型 *)
type shi_lian = { qing_shan : string; lv_shui : string }

(* 测试音韵对仗编程模式 *)
let test_rhyme_antithesis_programming () =
  let shang_lian = { qing_shan = "程序之美"; lv_shui = "算法之妙" } in
  let shi_yi_dui_zhang lian_ju = lian_ju.qing_shan ^ "与" ^ lian_ju.lv_shui ^ "相映成趣" in
  let shang_lian_jie_guo = shi_yi_dui_zhang shang_lian in
  let qi_wang = "程序之美与算法之妙相映成趣" in
  Alcotest.(check string) "音韵对仗编程模式" qi_wang shang_lian_jie_guo

let () =
  let open Alcotest in
  run "诗词编程艺术性测试"
    [
      ("诗意变量命名", [ test_case "古文变量命名" `Quick test_poetic_variable_naming ]);
      ("四言骈体编程", [ test_case "四言骈体风格" `Quick test_siyan_programming_style ]);
      ("五言律诗编程", [ test_case "五言律诗风格" `Quick test_wuyan_lushi_style ]);
      ("七言绝句编程", [ test_case "七言绝句风格" `Quick test_qiyan_jueju_style ]);
      ("诗意错误处理", [ test_case "诗意错误处理" `Quick test_poetic_error_handling ]);
      ("古文逻辑流程", [ test_case "古文逻辑流程" `Quick test_classical_logic_flow ]);
      ("意境数据结构", [ test_case "意境深远的数据结构" `Quick test_artistic_data_structures ]);
      ("起承转合结构", [ test_case "起承转合编程结构" `Quick test_qichengzhuanhe_structure ]);
      ("音韵对仗编程", [ test_case "音韵对仗编程模式" `Quick test_rhyme_antithesis_programming ]);
    ]
