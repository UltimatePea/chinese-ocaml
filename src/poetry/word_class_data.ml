(* 词性数据模块 - 骆言诗词编程特性
   夫对仗分析，需词性数据。此模块专司词性数据存储，
   与业务逻辑分离，便于维护扩展。
   词性分类依传统诗词理论，收录常用汉字词性。
*)

(* 词性分类：依传统诗词理论分类词性
   名词实词，动词虚词，形容词状语，各有所归。
   此分类用于对仗分析，确保词性相对。
*)
type word_class =
  | Noun          (* 名词 - 人物地名等实体 *)
  | Verb          (* 动词 - 动作行为等 *)
  | Adjective     (* 形容词 - 性质状态等 *)
  | Adverb        (* 副词 - 修饰动词形容词 *)
  | Numeral       (* 数词 - 一二三等数量 *)
  | Classifier    (* 量词 - 个只条等单位 *)
  | Pronoun       (* 代词 - 我你他等称谓 *)
  | Preposition   (* 介词 - 在于从等关系 *)
  | Conjunction   (* 连词 - 和与或等连接 *)
  | Particle      (* 助词 - 之乎者也等 *)
  | Interjection  (* 叹词 - 啊哎呀等感叹 *)
  | Unknown       (* 未知词性 - 待分析 *)

(* 词性数据库：收录常用汉字词性
   依《现代汉语词典》、《古汉语常用字字典》等典籍，
   结合诗词用字特点，分类整理。
*)
let word_class_database = [
  (* 名词 *)
  ("人", Noun); ("天", Noun); ("地", Noun); ("山", Noun); ("水", Noun);
  ("日", Noun); ("月", Noun); ("星", Noun); ("云", Noun); ("风", Noun);
  ("雨", Noun); ("雪", Noun); ("花", Noun); ("草", Noun); ("木", Noun);
  ("树", Noun); ("林", Noun); ("石", Noun); ("土", Noun); ("火", Noun);
  ("光", Noun); ("影", Noun); ("声", Noun); ("音", Noun); ("色", Noun);
  ("春", Noun); ("夏", Noun); ("秋", Noun); ("冬", Noun); ("年", Noun);
  ("时", Noun); ("刻", Noun); ("分", Noun); ("秒", Noun); ("钟", Noun);
  ("心", Noun); ("意", Noun); ("情", Noun); ("思", Noun); ("念", Noun);
  ("梦", Noun); ("愿", Noun); ("望", Noun); ("爱", Noun); ("恨", Noun);
  ("道", Noun); ("路", Noun); ("门", Noun); ("窗", Noun); ("房", Noun);
  ("家", Noun); ("国", Noun); ("城", Noun); ("村", Noun); ("镇", Noun);
  ("江", Noun); ("河", Noun); ("湖", Noun); ("海", Noun); ("川", Noun);
  ("峰", Noun); ("岭", Noun); ("谷", Noun); ("沟", Noun); ("原", Noun);
  ("野", Noun); ("田", Noun); ("园", Noun); ("林", Noun); ("竹", Noun);
  ("梅", Noun); ("兰", Noun); ("竹", Noun); ("菊", Noun); ("松", Noun);
  ("柏", Noun); ("桃", Noun); ("李", Noun); ("杏", Noun); ("梨", Noun);
  
  (* 动词 *)
  ("是", Verb); ("有", Verb); ("来", Verb); ("去", Verb); ("看", Verb);
  ("听", Verb); ("说", Verb); ("想", Verb); ("知", Verb); ("会", Verb);
  ("能", Verb); ("行", Verb); ("走", Verb); ("跑", Verb); ("飞", Verb);
  ("游", Verb); ("坐", Verb); ("立", Verb); ("躺", Verb); ("睡", Verb);
  ("醒", Verb); ("起", Verb); ("落", Verb); ("升", Verb); ("降", Verb);
  ("开", Verb); ("关", Verb); ("进", Verb); ("出", Verb); ("入", Verb);
  ("回", Verb); ("归", Verb); ("返", Verb); ("达", Verb); ("到", Verb);
  ("过", Verb); ("经", Verb); ("历", Verb); ("遇", Verb); ("遭", Verb);
  ("得", Verb); ("失", Verb); ("成", Verb); ("败", Verb); ("胜", Verb);
  ("负", Verb); ("赢", Verb); ("输", Verb); ("胜", Verb); ("败", Verb);
  ("爱", Verb); ("恨", Verb); ("喜", Verb); ("怒", Verb); ("悲", Verb);
  ("欢", Verb); ("乐", Verb); ("愁", Verb); ("忧", Verb); ("思", Verb);
  ("望", Verb); ("盼", Verb); ("等", Verb); ("待", Verb); ("求", Verb);
  ("问", Verb); ("答", Verb); ("教", Verb); ("学", Verb); ("读", Verb);
  ("写", Verb); ("画", Verb); ("唱", Verb); ("跳", Verb); ("笑", Verb);
  ("哭", Verb); ("叫", Verb); ("喊", Verb); ("呼", Verb); ("唤", Verb);
  
  (* 形容词 *)
  ("大", Adjective); ("小", Adjective); ("长", Adjective); ("短", Adjective);
  ("高", Adjective); ("低", Adjective); ("深", Adjective); ("浅", Adjective);
  ("宽", Adjective); ("窄", Adjective); ("厚", Adjective); ("薄", Adjective);
  ("粗", Adjective); ("细", Adjective); ("重", Adjective); ("轻", Adjective);
  ("快", Adjective); ("慢", Adjective); ("早", Adjective); ("晚", Adjective);
  ("新", Adjective); ("旧", Adjective); ("老", Adjective); ("少", Adjective);
  ("多", Adjective); ("少", Adjective); ("好", Adjective); ("坏", Adjective);
  ("美", Adjective); ("丑", Adjective); ("亮", Adjective); ("暗", Adjective);
  ("明", Adjective); ("暗", Adjective); ("清", Adjective); ("浊", Adjective);
  ("净", Adjective); ("脏", Adjective); ("干", Adjective); ("湿", Adjective);
  ("热", Adjective); ("冷", Adjective); ("温", Adjective); ("凉", Adjective);
  ("暖", Adjective); ("寒", Adjective); ("苦", Adjective); ("甜", Adjective);
  ("酸", Adjective); ("辣", Adjective); ("咸", Adjective); ("淡", Adjective);
  ("香", Adjective); ("臭", Adjective); ("香", Adjective); ("臭", Adjective);
  ("硬", Adjective); ("软", Adjective); ("脆", Adjective); ("韧", Adjective);
  ("滑", Adjective); ("粗", Adjective); ("光", Adjective); ("毛", Adjective);
  ("尖", Adjective); ("钝", Adjective); ("锋", Adjective); ("利", Adjective);
  ("圆", Adjective); ("方", Adjective); ("直", Adjective); ("弯", Adjective);
  ("平", Adjective); ("斜", Adjective); ("正", Adjective); ("歪", Adjective);
  ("真", Adjective); ("假", Adjective); ("实", Adjective); ("虚", Adjective);
  ("空", Adjective); ("满", Adjective); ("穷", Adjective); ("富", Adjective);
  ("贫", Adjective); ("贵", Adjective); ("贱", Adjective); ("雅", Adjective);
  ("俗", Adjective); ("古", Adjective); ("今", Adjective); ("新", Adjective);
  
  (* 数词 *)
  ("一", Numeral); ("二", Numeral); ("三", Numeral); ("四", Numeral);
  ("五", Numeral); ("六", Numeral); ("七", Numeral); ("八", Numeral);
  ("九", Numeral); ("十", Numeral); ("百", Numeral); ("千", Numeral);
  ("万", Numeral); ("亿", Numeral); ("零", Numeral); ("半", Numeral);
  ("双", Numeral); ("单", Numeral); ("首", Numeral); ("第", Numeral);
  
  (* 量词 *)
  ("个", Classifier); ("只", Classifier); ("条", Classifier); ("根", Classifier);
  ("支", Classifier); ("枝", Classifier); ("片", Classifier); ("张", Classifier);
  ("块", Classifier); ("颗", Classifier); ("粒", Classifier); ("滴", Classifier);
  ("杯", Classifier); ("盘", Classifier); ("碗", Classifier); ("瓶", Classifier);
  ("袋", Classifier); ("包", Classifier); ("箱", Classifier); ("车", Classifier);
  ("船", Classifier); ("架", Classifier); ("台", Classifier); ("座", Classifier);
  ("栋", Classifier); ("层", Classifier); ("间", Classifier); ("套", Classifier);
  ("副", Classifier); ("双", Classifier); ("对", Classifier); ("群", Classifier);
  ("队", Classifier); ("班", Classifier); ("组", Classifier); ("批", Classifier);
  ("种", Classifier); ("类", Classifier); ("样", Classifier); ("回", Classifier);
  ("次", Classifier); ("遍", Classifier); ("趟", Classifier); ("场", Classifier);
  ("局", Classifier); ("轮", Classifier); ("阵", Classifier); ("阵", Classifier);
  
  (* 代词 *)
  ("我", Pronoun); ("你", Pronoun); ("他", Pronoun); ("她", Pronoun);
  ("它", Pronoun); ("这", Pronoun); ("那", Pronoun); ("哪", Pronoun);
  ("什", Pronoun); ("么", Pronoun); ("谁", Pronoun); ("何", Pronoun);
  ("此", Pronoun); ("彼", Pronoun); ("其", Pronoun); ("自", Pronoun);
  
  (* 介词 *)
  ("在", Preposition); ("从", Preposition); ("到", Preposition); ("向", Preposition);
  ("往", Preposition); ("于", Preposition); ("为", Preposition); ("对", Preposition);
  ("给", Preposition); ("替", Preposition); ("按", Preposition); ("照", Preposition);
  ("依", Preposition); ("据", Preposition); ("凭", Preposition); ("靠", Preposition);
  ("关", Preposition); ("由", Preposition); ("因", Preposition); ("为", Preposition);
  ("被", Preposition); ("让", Preposition); ("叫", Preposition); ("使", Preposition);
  ("令", Preposition); ("把", Preposition); ("将", Preposition); ("拿", Preposition);
  
  (* 连词 *)
  ("和", Conjunction); ("与", Conjunction); ("或", Conjunction); ("及", Conjunction);
  ("以", Conjunction); ("而", Conjunction); ("且", Conjunction); ("并", Conjunction);
  ("又", Conjunction); ("还", Conjunction); ("也", Conjunction); ("都", Conjunction);
  ("既", Conjunction); ("即", Conjunction); ("就", Conjunction); ("便", Conjunction);
  ("则", Conjunction); ("然", Conjunction); ("但", Conjunction); ("可", Conjunction);
  ("却", Conjunction); ("不", Conjunction); ("非", Conjunction); ("无", Conjunction);
  ("若", Conjunction); ("如", Conjunction); ("似", Conjunction); ("像", Conjunction);
  ("虽", Conjunction); ("尽", Conjunction); ("纵", Conjunction); ("假", Conjunction);
  ("设", Conjunction); ("倘", Conjunction); ("若", Conjunction); ("要", Conjunction);
  
  (* 助词 *)
  ("的", Particle); ("了", Particle); ("着", Particle); ("过", Particle);
  ("呢", Particle); ("吗", Particle); ("呀", Particle); ("吧", Particle);
  ("啊", Particle); ("哎", Particle); ("嗯", Particle); ("哦", Particle);
  ("之", Particle); ("乎", Particle); ("者", Particle); ("也", Particle);
  ("焉", Particle); ("哉", Particle); ("矣", Particle); ("耳", Particle);
  
  (* 叹词 *)
  ("啊", Interjection); ("哎", Interjection); ("呀", Interjection); ("嗯", Interjection);
  ("哦", Interjection); ("哇", Interjection); ("嘿", Interjection); ("嗨", Interjection);
  ("唉", Interjection); ("咦", Interjection); ("咋", Interjection); ("哟", Interjection);
  ("呦", Interjection); ("嘘", Interjection); ("嗬", Interjection); ("嚯", Interjection);
]