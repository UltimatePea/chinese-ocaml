(** 扩展词性数据模块 - 骆言诗词编程特性 Phase 1

    应Issue #419需求，扩展词性数据从100字到500字。 依《现代汉语词典》、《古汉语常用字字典》等典籍， 结合诗词用字特点，分类整理常用字词词性。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-18 *)

(** 直接定义所需类型，避免循环依赖 *)
type word_class =
  | Noun (* 名词 - 人物地名等实体 *)
  | Verb (* 动词 - 动作行为等 *)
  | Adjective (* 形容词 - 性质状态等 *)
  | Adverb (* 副词 - 修饰动词形容词 *)
  | Numeral (* 数词 - 一二三等数量 *)
  | Classifier (* 量词 - 个只条等单位 *)
  | Pronoun (* 代词 - 我你他等称谓 *)
  | Preposition (* 介词 - 在于从等关系 *)
  | Conjunction (* 连词 - 和与或等连接 *)
  | Particle (* 助词 - 之乎者也等 *)
  | Interjection (* 叹词 - 啊哎呀等感叹 *)
  | Unknown (* 未知词性 - 待分析 *)

(** {1 扩展名词数据} *)

(** 自然景物名词 - 山川河流，风花雪月 *)
let nature_nouns =
  [
    (* 山川地理 *)
    ("山", Noun);
    ("川", Noun);
    ("河", Noun);
    ("江", Noun);
    ("海", Noun);
    ("湖", Noun);
    ("池", Noun);
    ("溪", Noun);
    ("泉", Noun);
    ("瀑", Noun);
    ("岸", Noun);
    ("滩", Noun);
    ("岛", Noun);
    ("洲", Noun);
    ("湾", Noun);
    ("峰", Noun);
    ("岭", Noun);
    ("崖", Noun);
    ("谷", Noun);
    ("坡", Noun);
    ("岩", Noun);
    ("石", Noun);
    ("土", Noun);
    ("沙", Noun);
    ("泥", Noun);
    (* 天象气候 *)
    ("天", Noun);
    ("空", Noun);
    ("云", Noun);
    ("雾", Noun);
    ("雨", Noun);
    ("雪", Noun);
    ("霜", Noun);
    ("露", Noun);
    ("风", Noun);
    ("雷", Noun);
    ("电", Noun);
    ("虹", Noun);
    ("霞", Noun);
    ("晴", Noun);
    ("阴", Noun);
    ("日", Noun);
    ("月", Noun);
    ("星", Noun);
    ("辰", Noun);
    ("宿", Noun);
    ("晨", Noun);
    ("昏", Noun);
    ("夜", Noun);
    ("晚", Noun);
    ("夕", Noun);
    (* 四时节令 *)
    ("春", Noun);
    ("夏", Noun);
    ("秋", Noun);
    ("冬", Noun);
    ("季", Noun);
    ("节", Noun);
    ("时", Noun);
    ("刻", Noun);
    ("分", Noun);
    ("秒", Noun);
    ("年", Noun);
    ("月", Noun);
    ("日", Noun);
    ("时", Noun);
    ("刻", Noun);
    ("今", Noun);
    ("昨", Noun);
    ("明", Noun);
    ("前", Noun);
    ("后", Noun);
    (* 动植物 *)
    ("花", Noun);
    ("草", Noun);
    ("木", Noun);
    ("树", Noun);
    ("林", Noun);
    ("森", Noun);
    ("叶", Noun);
    ("枝", Noun);
    ("根", Noun);
    ("茎", Noun);
    ("果", Noun);
    ("实", Noun);
    ("种", Noun);
    ("苗", Noun);
    ("芽", Noun);
    ("鸟", Noun);
    ("燕", Noun);
    ("鹤", Noun);
    ("鹰", Noun);
    ("鸿", Noun);
    ("虫", Noun);
    ("蝶", Noun);
    ("蜂", Noun);
    ("蚁", Noun);
    ("蛛", Noun);
    ("鱼", Noun);
    ("龟", Noun);
    ("蛇", Noun);
    ("虎", Noun);
    ("狼", Noun);
    ("鹿", Noun);
    ("马", Noun);
    ("牛", Noun);
    ("羊", Noun);
    ("猪", Noun);
    ("鸡", Noun);
    ("鸭", Noun);
    ("鹅", Noun);
    ("犬", Noun);
    ("猫", Noun);
  ]

(** 人物称谓数据 - 亲族关系和人物称谓 *)
let person_relation_nouns =
  [
    (* 基本人物 *)
    ("人", Noun);
    ("民", Noun);
    ("众", Noun);
    ("群", Noun);
    ("族", Noun);
    ("家", Noun);
    ("户", Noun);
    ("口", Noun);
    ("丁", Noun);
    ("身", Noun);
    (* 家庭成员 *)
    ("父", Noun);
    ("母", Noun);
    ("子", Noun);
    ("女", Noun);
    ("夫", Noun);
    ("妻", Noun);
    ("兄", Noun);
    ("弟", Noun);
    ("姊", Noun);
    ("妹", Noun);
    ("祖", Noun);
    ("孙", Noun);
    ("亲", Noun);
    ("戚", Noun);
    (* 社交关系 *)
    ("友", Noun);
    ("朋", Noun);
    ("伴", Noun);
    ("侣", Noun);
    ("客", Noun);
    ("宾", Noun);
  ]

(** 社会地位数据 - 政治、职业和社会地位 *)
let social_status_nouns =
  [
    (* 政治地位 *)
    ("王", Noun);
    ("君", Noun);
    ("臣", Noun);
    ("民", Noun);
    ("官", Noun);
    ("吏", Noun);
    (* 职业地位 *)
    ("士", Noun);
    ("农", Noun);
    ("工", Noun);
    ("商", Noun);
    ("师", Noun);
    ("生", Noun);
    ("徒", Noun);
    ("弟", Noun);
    (* 年龄性别 *)
    ("长", Noun);
    ("幼", Noun);
    ("老", Noun);
    ("少", Noun);
    ("男", Noun);
    ("女", Noun);
  ]

(** 建筑场所数据 - 建筑物和建筑构件 *)
let building_place_nouns =
  [
    (* 建筑空间 *)
    ("屋", Noun);
    ("房", Noun);
    ("室", Noun);
    ("厅", Noun);
    ("堂", Noun);
    ("院", Noun);
    ("庭", Noun);
    ("园", Noun);
    (* 建筑类型 *)
    ("亭", Noun);
    ("阁", Noun);
    ("楼", Noun);
    ("台", Noun);
    ("殿", Noun);
    ("宫", Noun);
    ("府", Noun);
    ("寺", Noun);
    ("庙", Noun);
    ("观", Noun);
    ("塔", Noun);
    ("桥", Noun);
    (* 建筑部件 *)
    ("门", Noun);
    ("户", Noun);
    ("窗", Noun);
    ("墙", Noun);
    ("壁", Noun);
    ("柱", Noun);
    ("梁", Noun);
    ("瓦", Noun);
    ("砖", Noun);
    ("板", Noun);
  ]

(** 地理政治数据 - 行政区划和地理位置 *)
let geography_politics_nouns =
  [
    (* 政治单位 *)
    ("国", Noun);
    ("邦", Noun);
    ("朝", Noun);
    ("代", Noun);
    ("世", Noun);
    ("京", Noun);
    ("都", Noun);
    ("城", Noun);
    ("镇", Noun);
    ("村", Noun);
    ("乡", Noun);
    ("里", Noun);
    ("坊", Noun);
    ("巷", Noun);
    (* 道路交通 *)
    ("街", Noun);
    ("路", Noun);
    ("道", Noun);
    ("径", Noun);
    ("途", Noun);
    ("程", Noun);
    (* 行政分级 *)
    ("州", Noun);
    ("郡", Noun);
    ("县", Noun);
    ("区", Noun);
    ("境", Noun);
  ]

(** 器物用具数据 - 日常用品和工具器物 *)
let tools_objects_nouns =
  [
    (* 基本器物 *)
    ("器", Noun);
    ("具", Noun);
    ("物", Noun);
    ("品", Noun);
    ("件", Noun);
    (* 文房四宝 *)
    ("书", Noun);
    ("册", Noun);
    ("卷", Noun);
    ("篇", Noun);
    ("章", Noun);
    ("笔", Noun);
    ("墨", Noun);
    ("纸", Noun);
    ("砚", Noun);
    ("印", Noun);
    (* 艺术器物 *)
    ("琴", Noun);
    ("棋", Noun);
    ("画", Noun);
    ("诗", Noun);
    ("词", Noun);
    (* 兵器武器 *)
    ("剑", Noun);
    ("刀", Noun);
    ("弓", Noun);
    ("箭", Noun);
    ("盾", Noun);
    (* 衣物鞋帽 *)
    ("衣", Noun);
    ("裳", Noun);
    ("袍", Noun);
    ("衫", Noun);
    ("裙", Noun);
    ("帽", Noun);
    ("冠", Noun);
    ("履", Noun);
    ("鞋", Noun);
    ("袜", Noun);
    (* 饮食器物 *)
    ("食", Noun);
    ("饭", Noun);
    ("菜", Noun);
    ("肉", Noun);
    ("鱼", Noun);
    ("酒", Noun);
    ("茶", Noun);
    ("水", Noun);
    ("汤", Noun);
    ("饮", Noun);
    ("杯", Noun);
    ("盏", Noun);
    ("碗", Noun);
    ("盘", Noun);
    ("碟", Noun);
    (* 家具用品 *)
    ("床", Noun);
    ("席", Noun);
    ("枕", Noun);
    ("被", Noun);
    ("褥", Noun);
    ("桌", Noun);
    ("案", Noun);
    ("椅", Noun);
    ("凳", Noun);
    ("几", Noun);
    ("箱", Noun);
    ("柜", Noun);
    ("橱", Noun);
    ("架", Noun);
    ("台", Noun);
    ("灯", Noun);
    ("烛", Noun);
    ("火", Noun);
    ("炉", Noun);
    ("炭", Noun);
    (* 交通工具 *)
    ("车", Noun);
    ("船", Noun);
    ("舟", Noun);
    ("艇", Noun);
    ("筏", Noun);
    ("轿", Noun);
    ("辇", Noun);
    ("骑", Noun);
    ("驴", Noun);
    ("骡", Noun);
  ]

(** 人文社会名词汇总 - 将所有人文社会类名词组合成统一列表 *)
let human_society_nouns =
  person_relation_nouns @ social_status_nouns @ building_place_nouns @ geography_politics_nouns
  @ tools_objects_nouns

(** 抽象概念名词 - 情理事物，抽象概念 *)
let abstract_nouns =
  [
    (* 情感心理 *)
    ("情", Noun);
    ("爱", Noun);
    ("恨", Noun);
    ("喜", Noun);
    ("怒", Noun);
    ("哀", Noun);
    ("乐", Noun);
    ("忧", Noun);
    ("愁", Noun);
    ("思", Noun);
    ("念", Noun);
    ("想", Noun);
    ("梦", Noun);
    ("望", Noun);
    ("盼", Noun);
    ("心", Noun);
    ("意", Noun);
    ("志", Noun);
    ("愿", Noun);
    ("求", Noun);
    ("欲", Noun);
    ("情", Noun);
    ("性", Noun);
    ("魂", Noun);
    ("魄", Noun);
    ("神", Noun);
    ("灵", Noun);
    ("识", Noun);
    ("智", Noun);
    ("慧", Noun);
    (* 道德品质 *)
    ("德", Noun);
    ("善", Noun);
    ("恶", Noun);
    ("正", Noun);
    ("邪", Noun);
    ("忠", Noun);
    ("孝", Noun);
    ("义", Noun);
    ("礼", Noun);
    ("智", Noun);
    ("信", Noun);
    ("勇", Noun);
    ("仁", Noun);
    ("慈", Noun);
    ("悲", Noun);
    ("廉", Noun);
    ("耻", Noun);
    ("节", Noun);
    ("操", Noun);
    ("品", Noun);
    ("格", Noun);
    ("质", Noun);
    ("量", Noun);
    ("度", Noun);
    ("分", Noun);
    (* 学问知识 *)
    ("学", Noun);
    ("问", Noun);
    ("识", Noun);
    ("知", Noun);
    ("解", Noun);
    ("理", Noun);
    ("法", Noun);
    ("道", Noun);
    ("术", Noun);
    ("艺", Noun);
    ("技", Noun);
    ("能", Noun);
    ("力", Noun);
    ("才", Noun);
    ("华", Noun);
    ("文", Noun);
    ("武", Noun);
    ("经", Noun);
    ("史", Noun);
    ("子", Noun);
    ("集", Noun);
    ("典", Noun);
    ("籍", Noun);
    ("录", Noun);
    ("志", Noun);
    (* 时空概念 *)
    ("空", Noun);
    ("间", Noun);
    ("处", Noun);
    ("所", Noun);
    ("地", Noun);
    ("方", Noun);
    ("位", Noun);
    ("向", Noun);
    ("面", Noun);
    ("边", Noun);
    ("际", Noun);
    ("界", Noun);
    ("境", Noun);
    ("域", Noun);
    ("区", Noun);
    ("期", Noun);
    ("段", Noun);
    ("候", Noun);
    ("机", Noun);
    ("会", Noun);
    ("遇", Noun);
    ("缘", Noun);
    ("份", Noun);
    ("运", Noun);
    ("命", Noun);
    (* 事务活动 *)
    ("事", Noun);
    ("务", Noun);
    ("业", Noun);
    ("作", Noun);
    ("工", Noun);
    ("活", Noun);
    ("动", Noun);
    ("行", Noun);
    ("为", Noun);
    ("举", Noun);
    ("止", Noun);
    ("态", Noun);
    ("势", Noun);
    ("状", Noun);
    ("况", Noun);
    ("形", Noun);
    ("样", Noun);
    ("式", Noun);
    ("型", Noun);
    ("种", Noun);
    ("类", Noun);
    ("别", Noun);
    ("般", Noun);
    ("等", Noun);
    ("级", Noun);
    ("步", Noun);
    ("骤", Noun);
    ("程", Noun);
    ("序", Noun);
    ("次", Noun);
    ("回", Noun);
    ("番", Noun);
    ("遍", Noun);
    ("趟", Noun);
    ("场", Noun);
  ]

(** {2 扩展动词数据} *)

(** 基础动作动词 - 来往起居，日常动作 *)
let basic_verbs =
  [
    (* 移动位置 *)
    ("来", Verb);
    ("去", Verb);
    ("到", Verb);
    ("达", Verb);
    ("至", Verb);
    ("行", Verb);
    ("走", Verb);
    ("跑", Verb);
    ("飞", Verb);
    ("游", Verb);
    ("进", Verb);
    ("出", Verb);
    ("入", Verb);
    ("退", Verb);
    ("归", Verb);
    ("回", Verb);
    ("返", Verb);
    ("还", Verb);
    ("往", Verb);
    ("向", Verb);
    ("趋", Verb);
    ("奔", Verb);
    ("驰", Verb);
    ("驱", Verb);
    ("驾", Verb);
    ("骑", Verb);
    ("乘", Verb);
    ("坐", Verb);
    ("立", Verb);
    ("站", Verb);
    ("卧", Verb);
    ("躺", Verb);
    ("睡", Verb);
    ("眠", Verb);
    ("息", Verb);
    ("休", Verb);
    ("停", Verb);
    ("住", Verb);
    ("居", Verb);
    ("处", Verb);
    ("留", Verb);
    ("待", Verb);
    ("守", Verb);
    ("候", Verb);
    ("等", Verb);
    (* 感官动作 *)
    ("看", Verb);
    ("见", Verb);
    ("视", Verb);
    ("望", Verb);
    ("观", Verb);
    ("瞧", Verb);
    ("瞪", Verb);
    ("瞥", Verb);
    ("瞟", Verb);
    ("瞄", Verb);
    ("听", Verb);
    ("闻", Verb);
    ("声", Verb);
    ("响", Verb);
    ("鸣", Verb);
    ("叫", Verb);
    ("呼", Verb);
    ("唤", Verb);
    ("喊", Verb);
    ("吼", Verb);
    ("说", Verb);
    ("话", Verb);
    ("言", Verb);
    ("语", Verb);
    ("谈", Verb);
    ("讲", Verb);
    ("述", Verb);
    ("论", Verb);
    ("议", Verb);
    ("评", Verb);
    ("嗅", Verb);
    ("闻", Verb);
    ("嗅", Verb);
    ("尝", Verb);
    ("品", Verb);
    ("吃", Verb);
    ("喝", Verb);
    ("饮", Verb);
    ("食", Verb);
    ("餐", Verb);
    ("摸", Verb);
    ("触", Verb);
    ("抚", Verb);
    ("摩", Verb);
    ("按", Verb);
    ("握", Verb);
    ("抓", Verb);
    ("拿", Verb);
    ("持", Verb);
    ("执", Verb);
    (* 思维活动 *)
    ("想", Verb);
    ("思", Verb);
    ("念", Verb);
    ("记", Verb);
    ("忆", Verb);
    ("忘", Verb);
    ("知", Verb);
    ("识", Verb);
    ("悟", Verb);
    ("解", Verb);
    ("懂", Verb);
    ("会", Verb);
    ("能", Verb);
    ("学", Verb);
    ("习", Verb);
    ("读", Verb);
    ("书", Verb);
    ("写", Verb);
    ("作", Verb);
    ("画", Verb);
    ("算", Verb);
    ("计", Verb);
    ("数", Verb);
    ("量", Verb);
    ("测", Verb);
    ("判", Verb);
    ("断", Verb);
    ("决", Verb);
    ("定", Verb);
    ("择", Verb);
    ("选", Verb);
    ("挑", Verb);
    ("拣", Verb);
    ("择", Verb);
    ("采", Verb);
    ("考", Verb);
    ("虑", Verb);
    ("虑", Verb);
    ("顾", Verb);
    ("忌", Verb);
    ("怕", Verb);
    ("惧", Verb);
    ("恐", Verb);
    ("畏", Verb);
    ("惊", Verb);
    ("疑", Verb);
    ("猜", Verb);
    ("测", Verb);
    ("推", Verb);
    ("估", Verb);
  ]

(** 社会活动动词 - 人际交往，社会行为 *)
let social_verbs =
  [
    (* 交流沟通 *)
    ("交", Verb);
    ("流", Verb);
    ("通", Verb);
    ("达", Verb);
    ("传", Verb);
    ("递", Verb);
    ("送", Verb);
    ("给", Verb);
    ("予", Verb);
    ("与", Verb);
    ("取", Verb);
    ("得", Verb);
    ("获", Verb);
    ("收", Verb);
    ("受", Verb);
    ("接", Verb);
    ("迎", Verb);
    ("送", Verb);
    ("别", Verb);
    ("离", Verb);
    ("会", Verb);
    ("见", Verb);
    ("访", Verb);
    ("问", Verb);
    ("询", Verb);
    ("答", Verb);
    ("应", Verb);
    ("回", Verb);
    ("复", Verb);
    ("报", Verb);
    ("告", Verb);
    ("知", Verb);
    ("示", Verb);
    ("指", Verb);
    ("教", Verb);
    ("导", Verb);
    ("引", Verb);
    ("领", Verb);
    ("带", Verb);
    ("携", Verb);
    ("助", Verb);
    ("帮", Verb);
    ("援", Verb);
    ("支", Verb);
    ("持", Verb);
    ("扶", Verb);
    ("救", Verb);
    ("护", Verb);
    ("卫", Verb);
    ("守", Verb);
    (* 情感表达 *)
    ("爱", Verb);
    ("恋", Verb);
    ("爱慕", Verb);
    ("喜", Verb);
    ("欢", Verb);
    ("恨", Verb);
    ("怨", Verb);
    ("恼", Verb);
    ("怒", Verb);
    ("气", Verb);
    ("哭", Verb);
    ("泣", Verb);
    ("涕", Verb);
    ("笑", Verb);
    ("乐", Verb);
    ("悲", Verb);
    ("哀", Verb);
    ("伤", Verb);
    ("痛", Verb);
    ("苦", Verb);
    ("愁", Verb);
    ("忧", Verb);
    ("虑", Verb);
    ("焦", Verb);
    ("急", Verb);
    ("盼", Verb);
    ("望", Verb);
    ("希", Verb);
    ("求", Verb);
    ("祈", Verb);
    ("祷", Verb);
    ("拜", Verb);
    ("谢", Verb);
    ("感", Verb);
    ("激", Verb);
    ("赞", Verb);
    ("美", Verb);
    ("夸", Verb);
    ("扬", Verb);
    ("颂", Verb);
    ("骂", Verb);
    ("咒", Verb);
    ("谴", Verb);
    ("责", Verb);
    ("备", Verb);
    ("批", Verb);
    ("评", Verb);
    ("判", Verb);
    ("斥", Verb);
    ("训", Verb);
    (* 社会行为 *)
    ("治", Verb);
    ("理", Verb);
    ("管", Verb);
    ("领", Verb);
    ("导", Verb);
    ("统", Verb);
    ("制", Verb);
    ("控", Verb);
    ("约", Verb);
    ("束", Verb);
    ("限", Verb);
    ("禁", Verb);
    ("止", Verb);
    ("阻", Verb);
    ("挡", Verb);
    ("防", Verb);
    ("备", Verb);
    ("御", Verb);
    ("抗", Verb);
    ("拒", Verb);
    ("战", Verb);
    ("斗", Verb);
    ("争", Verb);
    ("竞", Verb);
    ("赛", Verb);
    ("胜", Verb);
    ("败", Verb);
    ("输", Verb);
    ("赢", Verb);
    ("克", Verb);
    ("服", Verb);
    ("降", Verb);
    ("屈", Verb);
    ("伏", Verb);
    ("顺", Verb);
    ("从", Verb);
    ("依", Verb);
    ("靠", Verb);
    ("倚", Verb);
    ("仗", Verb);
    ("信", Verb);
    ("任", Verb);
    ("托", Verb);
    ("委", Verb);
    ("派", Verb);
    ("遣", Verb);
    ("调", Verb);
    ("换", Verb);
    ("替", Verb);
    ("代", Verb);
  ]

(** 农业生产动词 - 种植、养殖、收割等农业活动 *)
let agricultural_verbs =
  [
    (* 种植培育 *)
    ("种", Verb);
    ("植", Verb);
    ("栽", Verb);
    ("培", Verb);
    ("育", Verb);
    ("养", Verb);
    ("喂", Verb);
    ("牧", Verb);
    ("放", Verb);
    ("饲", Verb);
    (* 耕作工具 *)
    ("耕", Verb);
    ("犁", Verb);
    ("锄", Verb);
    ("挖", Verb);
    ("掘", Verb);
    ("播", Verb);
    ("撒", Verb);
    ("洒", Verb);
    ("浇", Verb);
    ("灌", Verb);
    (* 收获采集 *)
    ("收", Verb);
    ("割", Verb);
    ("砍", Verb);
    ("伐", Verb);
    ("采", Verb);
    ("摘", Verb);
    ("拾", Verb);
    ("捡", Verb);
    ("捕", Verb);
    ("抓", Verb);
    ("钓", Verb);
    ("网", Verb);
    ("捞", Verb);
    ("猎", Verb);
    ("射", Verb);
    (* 加工保存 *)
    ("晒", Verb);
    ("晾", Verb);
    ("干", Verb);
    ("燥", Verb);
    ("烘", Verb);
    ("磨", Verb);
    ("碾", Verb);
    ("舂", Verb);
    ("筛", Verb);
    ("选", Verb);
    ("储", Verb);
    ("存", Verb);
    ("藏", Verb);
    ("积", Verb);
    ("累", Verb);
  ]

(** 手工制造动词 - 制作、建造、加工等手工业活动 *)
let manufacturing_verbs =
  [
    (* 基础制造 *)
    ("做", Verb);
    ("制", Verb);
    ("造", Verb);
    ("建", Verb);
    ("筑", Verb);
    ("修", Verb);
    ("补", Verb);
    (* 纺织刺绣 *)
    ("缝", Verb);
    ("织", Verb);
    ("编", Verb);
    ("绣", Verb);
    ("染", Verb);
    ("漂", Verb);
    (* 清洁整理 *)
    ("洗", Verb);
    ("刷", Verb);
    ("擦", Verb);
    ("拭", Verb);
    ("抹", Verb);
    ("涂", Verb);
    (* 艺术创作 *)
    ("画", Verb);
    ("刻", Verb);
    ("雕", Verb);
    ("凿", Verb);
    ("钻", Verb);
    ("铲", Verb);
    ("削", Verb);
    ("刨", Verb);
    ("磨", Verb);
    ("锉", Verb);
    ("锯", Verb);
    ("钉", Verb);
    ("拧", Verb);
    ("旋", Verb);
    ("转", Verb);
  ]

(** 搬运运输动词 - 移动、装卸、运输等物流活动 *)
let transportation_verbs =
  [
    (* 基础动作 *)
    ("推", Verb);
    ("拉", Verb);
    ("拽", Verb);
    ("提", Verb);
    ("举", Verb);
    ("抬", Verb);
    ("搬", Verb);
    (* 运输载运 *)
    ("运", Verb);
    ("输", Verb);
    ("载", Verb);
    ("装", Verb);
    ("卸", Verb);
    ("包", Verb);
    ("裹", Verb);
    ("捆", Verb);
  ]

(** 买卖交易动词 - 商业、金融、服务等经济活动 *)
let commercial_verbs =
  [
    (* 买卖交易 *)
    ("买", Verb);
    ("卖", Verb);
    ("购", Verb);
    ("销", Verb);
    ("售", Verb);
    ("交", Verb);
    ("换", Verb);
    ("易", Verb);
    ("贸", Verb);
    ("贩", Verb);
    (* 经营管理 *)
    ("开", Verb);
    ("关", Verb);
    ("营", Verb);
    ("业", Verb);
    ("经", Verb);
    ("算", Verb);
    ("计", Verb);
    (* 金融服务 *)
    ("付", Verb);
    ("还", Verb);
    ("欠", Verb);
    ("借", Verb);
    ("贷", Verb);
    ("租", Verb);
    ("赁", Verb);
    ("典", Verb);
    ("质", Verb);
    ("押", Verb);
    ("抵", Verb);
    ("担", Verb);
    ("保", Verb);
    ("赔", Verb);
    ("偿", Verb);
    ("补", Verb);
    ("退", Verb);
    ("换", Verb);
    ("修", Verb);
    ("理", Verb);
  ]

(** 清洁处理动词 - 清理、整理、处理等维护活动 *)
let cleaning_verbs =
  [
    ("整", Verb);
    ("洁", Verb);
    ("净", Verb);
    ("清", Verb);
    ("扫", Verb);
    ("除", Verb);
    ("去", Verb);
    ("掉", Verb);
    ("丢", Verb);
    ("弃", Verb);
    ("抛", Verb);
    ("扔", Verb);
    ("投", Verb);
  ]

(** 生产动词总汇 - 合并所有生产相关的动词 *)
let production_verbs =
  agricultural_verbs @ manufacturing_verbs @ transportation_verbs @ commercial_verbs @ cleaning_verbs

(** {3 扩展形容词数据} *)

(** 尺寸大小形容词 - 描述物体的大小、长短、高低等尺度特征 *)
let size_adjectives =
  [
    (* 大小 *)
    ("大", Adjective);
    ("小", Adjective);
    ("巨", Adjective);
    ("微", Adjective);
    ("细", Adjective);
    (* 长短 *)
    ("长", Adjective);
    ("短", Adjective);
    (* 高低 *)
    ("高", Adjective);
    ("低", Adjective);
    ("矮", Adjective);
    (* 深浅 *)
    ("深", Adjective);
    ("浅", Adjective);
    (* 厚薄 *)
    ("厚", Adjective);
    ("薄", Adjective);
    (* 宽窄 *)
    ("粗", Adjective);
    ("宽", Adjective);
    ("窄", Adjective);
    ("阔", Adjective);
    ("狭", Adjective);
    ("广", Adjective);
    (* 胖瘦 *)
    ("肥", Adjective);
    ("瘦", Adjective);
    ("胖", Adjective);
    ("瘠", Adjective);
    (* 满空 *)
    ("丰", Adjective);
    ("满", Adjective);
    ("空", Adjective);
    ("虚", Adjective);
    ("实", Adjective);
    ("充", Adjective);
    ("盈", Adjective);
    ("溢", Adjective);
    ("涨", Adjective);
    ("缩", Adjective);
    ("胀", Adjective);
  ]

(** 形状外观形容词 - 描述物体的形状、美观程度等外观特征 *)
let shape_adjectives =
  [
    (* 基本形状 *)
    ("圆", Adjective);
    ("方", Adjective);
    ("尖", Adjective);
    ("钝", Adjective);
    ("直", Adjective);
    ("弯", Adjective);
    ("曲", Adjective);
    ("扭", Adjective);
    ("歪", Adjective);
    ("斜", Adjective);
    ("平", Adjective);
    ("凸", Adjective);
    ("凹", Adjective);
    ("凌", Adjective);
    (* 整齐规则 *)
    ("整", Adjective);
    ("齐", Adjective);
    ("匀", Adjective);
    ("均", Adjective);
    ("正", Adjective);
    ("端", Adjective);
    (* 威严庄重 *)
    ("庄", Adjective);
    ("严", Adjective);
    ("肃", Adjective);
    ("威", Adjective);
    ("雄", Adjective);
    ("壮", Adjective);
    ("伟", Adjective);
    ("巍", Adjective);
    ("峨", Adjective);
    (* 美丽俊俏 *)
    ("秀", Adjective);
    ("美", Adjective);
    ("丽", Adjective);
    ("俊", Adjective);
    ("俏", Adjective);
    ("娇", Adjective);
    ("媚", Adjective);
    ("艳", Adjective);
    ("华", Adjective);
    (* 朴素雅致 *)
    ("朴", Adjective);
    ("素", Adjective);
    ("淡", Adjective);
    ("雅", Adjective);
    ("清", Adjective);
    ("纯", Adjective);
    ("洁", Adjective);
    ("净", Adjective);
    ("白", Adjective);
  ]

(** 颜色色彩形容词 - 描述物体的颜色、明暗、清浊等色彩特征 *)
let color_adjectives =
  [
    (* 基础颜色 *)
    ("红", Adjective);
    ("橙", Adjective);
    ("黄", Adjective);
    ("绿", Adjective);
    ("青", Adjective);
    ("蓝", Adjective);
    ("紫", Adjective);
    ("黑", Adjective);
    ("白", Adjective);
    ("灰", Adjective);
    ("褐", Adjective);
    ("棕", Adjective);
    ("金", Adjective);
    ("银", Adjective);
    ("铜", Adjective);
    ("粉", Adjective);
    (* 色彩深浅 *)
    ("嫩", Adjective);
    ("浅", Adjective);
    ("深", Adjective);
    ("浓", Adjective);
    ("淡", Adjective);
    ("鲜", Adjective);
    ("艳", Adjective);
    (* 明暗程度 *)
    ("亮", Adjective);
    ("暗", Adjective);
    ("明", Adjective);
    ("昏", Adjective);
    ("朦", Adjective);
    ("胧", Adjective);
    ("模", Adjective);
    ("糊", Adjective);
    ("清", Adjective);
    ("楚", Adjective);
    ("晰", Adjective);
    ("显", Adjective);
    ("隐", Adjective);
    ("露", Adjective);
    ("现", Adjective);
    ("见", Adjective);
    ("闻", Adjective);
  ]

(** 质地材料形容词 - 描述物体的质地、味道、触感等材料特征 *)
let texture_adjectives =
  [
    (* 硬度 *)
    ("硬", Adjective);
    ("软", Adjective);
    ("韧", Adjective);
    ("脆", Adjective);
    ("坚", Adjective);
    ("牢", Adjective);
    ("固", Adjective);
    ("稳", Adjective);
    (* 松紧 *)
    ("松", Adjective);
    ("紧", Adjective);
    ("密", Adjective);
    ("疏", Adjective);
    ("稠", Adjective);
    ("稀", Adjective);
    ("浓", Adjective);
    ("淡", Adjective);
    (* 味道 *)
    ("甜", Adjective);
    ("苦", Adjective);
    ("酸", Adjective);
    ("辣", Adjective);
    ("咸", Adjective);
    ("鲜", Adjective);
    ("香", Adjective);
    ("臭", Adjective);
    ("腥", Adjective);
    (* 触感 *)
    ("滑", Adjective);
    ("涩", Adjective);
    ("糙", Adjective);
    ("粗", Adjective);
    ("细", Adjective);
    ("嫩", Adjective);
    (* 新旧 *)
    ("老", Adjective);
    ("新", Adjective);
    ("旧", Adjective);
    ("古", Adjective);
    ("今", Adjective);
    ("昔", Adjective);
    ("早", Adjective);
    ("晚", Adjective);
    ("迟", Adjective);
  ]

(** 外观形容词总汇 - 合并所有外观相关的形容词 *)
let appearance_adjectives =
  size_adjectives @ shape_adjectives @ color_adjectives @ texture_adjectives

(** 性质状态形容词 - 品质特征，状态性质 *)
let quality_adjectives =
  [
    (* 好坏优劣 *)
    ("好", Adjective);
    ("坏", Adjective);
    ("优", Adjective);
    ("劣", Adjective);
    ("良", Adjective);
    ("恶", Adjective);
    ("善", Adjective);
    ("美", Adjective);
    ("丑", Adjective);
    ("佳", Adjective);
    ("差", Adjective);
    ("棒", Adjective);
    ("妙", Adjective);
    ("绝", Adjective);
    ("极", Adjective);
    ("超", Adjective);
    ("特", Adjective);
    ("奇", Adjective);
    ("怪", Adjective);
    ("异", Adjective);
    ("常", Adjective);
    ("普", Adjective);
    ("通", Adjective);
    ("般", Adjective);
    ("平", Adjective);
    ("凡", Adjective);
    ("庸", Adjective);
    ("俗", Adjective);
    ("雅", Adjective);
    ("高", Adjective);
    ("低", Adjective);
    ("贵", Adjective);
    ("贱", Adjective);
    ("富", Adjective);
    ("贫", Adjective);
    ("穷", Adjective);
    ("困", Adjective);
    ("苦", Adjective);
    ("甘", Adjective);
    ("甜", Adjective);
    ("乐", Adjective);
    ("悲", Adjective);
    ("喜", Adjective);
    ("怒", Adjective);
    ("哀", Adjective);
    ("惧", Adjective);
    ("恐", Adjective);
    ("怕", Adjective);
    ("勇", Adjective);
    ("敢", Adjective);
    (* 动静快慢 *)
    ("动", Adjective);
    ("静", Adjective);
    ("快", Adjective);
    ("慢", Adjective);
    ("急", Adjective);
    ("缓", Adjective);
    ("疾", Adjective);
    ("迅", Adjective);
    ("速", Adjective);
    ("飞", Adjective);
    ("奔", Adjective);
    ("驰", Adjective);
    ("飘", Adjective);
    ("浮", Adjective);
    ("沉", Adjective);
    ("轻", Adjective);
    ("重", Adjective);
    ("刚", Adjective);
    ("柔", Adjective);
    ("温", Adjective);
    ("冷", Adjective);
    ("热", Adjective);
    ("暖", Adjective);
    ("凉", Adjective);
    ("寒", Adjective);
    ("冰", Adjective);
    ("冻", Adjective);
    ("烫", Adjective);
    ("烧", Adjective);
    ("燃", Adjective);
    ("湿", Adjective);
    ("干", Adjective);
    ("潮", Adjective);
    ("燥", Adjective);
    ("润", Adjective);
    ("滑", Adjective);
    ("涩", Adjective);
    ("腻", Adjective);
    ("爽", Adjective);
    ("清", Adjective);
    ("浊", Adjective);
    ("混", Adjective);
    ("纯", Adjective);
    ("净", Adjective);
    ("洁", Adjective);
    ("脏", Adjective);
    ("污", Adjective);
    ("染", Adjective);
    ("污", Adjective);
    ("秽", Adjective);
    (* 情感品质 *)
    ("真", Adjective);
    ("假", Adjective);
    ("诚", Adjective);
    ("伪", Adjective);
    ("正", Adjective);
    ("邪", Adjective);
    ("直", Adjective);
    ("曲", Adjective);
    ("忠", Adjective);
    ("奸", Adjective);
    ("孝", Adjective);
    ("逆", Adjective);
    ("义", Adjective);
    ("利", Adjective);
    ("公", Adjective);
    ("私", Adjective);
    ("廉", Adjective);
    ("贪", Adjective);
    ("洁", Adjective);
    ("污", Adjective);
    ("明", Adjective);
    ("暗", Adjective);
    ("亮", Adjective);
    ("昏", Adjective);
    ("智", Adjective);
    ("愚", Adjective);
    ("聪", Adjective);
    ("笨", Adjective);
    ("慧", Adjective);
    ("蠢", Adjective);
    ("精", Adjective);
    ("粗", Adjective);
    ("细", Adjective);
    ("密", Adjective);
    ("疏", Adjective);
    ("严", Adjective);
    ("宽", Adjective);
    ("松", Adjective);
    ("紧", Adjective);
    ("实", Adjective);
    ("虚", Adjective);
    ("满", Adjective);
    ("空", Adjective);
    ("充", Adjective);
    ("足", Adjective);
    ("够", Adjective);
    ("缺", Adjective);
    ("少", Adjective);
    ("多", Adjective);
    ("众", Adjective);
  ]

(** {4 扩展其他词性数据} *)

(** 副词数据 - 程度时间，修饰词汇 *)
let expanded_adverbs =
  [
    (* 程度副词 *)
    ("很", Adverb);
    ("非", Adverb);
    ("极", Adverb);
    ("最", Adverb);
    ("更", Adverb);
    ("还", Adverb);
    ("再", Adverb);
    ("又", Adverb);
    ("也", Adverb);
    ("都", Adverb);
    ("全", Adverb);
    ("总", Adverb);
    ("共", Adverb);
    ("一", Adverb);
    ("齐", Adverb);
    ("特", Adverb);
    ("挺", Adverb);
    ("够", Adverb);
    ("太", Adverb);
    ("好", Adverb);
    ("真", Adverb);
    ("实", Adverb);
    ("确", Adverb);
    ("的", Adverb);
    ("确", Adverb);
    ("略", Adverb);
    ("稍", Adverb);
    ("微", Adverb);
    ("少", Adverb);
    ("多", Adverb);
    ("颇", Adverb);
    ("相", Adverb);
    ("比", Adverb);
    ("较", Adverb);
    ("更", Adverb);
    ("越", Adverb);
    ("愈", Adverb);
    ("益", Adverb);
    ("日", Adverb);
    ("渐", Adverb);
    ("逐", Adverb);
    ("步", Adverb);
    ("步", Adverb);
    ("渐", Adverb);
    ("徐", Adverb);
    ("缓", Adverb);
    ("慢", Adverb);
    ("快", Adverb);
    ("急", Adverb);
    ("疾", Adverb);
    (* 时间副词 *)
    ("今", Adverb);
    ("昨", Adverb);
    ("明", Adverb);
    ("后", Adverb);
    ("前", Adverb);
    ("先", Adverb);
    ("早", Adverb);
    ("晚", Adverb);
    ("迟", Adverb);
    ("刚", Adverb);
    ("才", Adverb);
    ("正", Adverb);
    ("在", Adverb);
    ("已", Adverb);
    ("曾", Adverb);
    ("将", Adverb);
    ("要", Adverb);
    ("即", Adverb);
    ("就", Adverb);
    ("便", Adverb);
    ("立", Adverb);
    ("马", Adverb);
    ("随", Adverb);
    ("即", Adverb);
    ("旋", Adverb);
    ("忽", Adverb);
    ("突", Adverb);
    ("猛", Adverb);
    ("急", Adverb);
    ("骤", Adverb);
    ("久", Adverb);
    ("长", Adverb);
    ("常", Adverb);
    ("时", Adverb);
    ("偶", Adverb);
    ("时", Adverb);
    ("或", Adverb);
    ("有", Adverb);
    ("无", Adverb);
    ("不", Adverb);
    ("未", Adverb);
    ("尚", Adverb);
    ("仍", Adverb);
    ("犹", Adverb);
    ("依", Adverb);
    ("依", Adverb);
    ("然", Adverb);
    ("仍", Adverb);
    ("然", Adverb);
    ("仍", Adverb);
    (* 方式副词 *)
    ("如", Adverb);
    ("似", Adverb);
    ("像", Adverb);
    ("若", Adverb);
    ("仿", Adverb);
    ("佛", Adverb);
    ("恰", Adverb);
    ("正", Adverb);
    ("好", Adverb);
    ("巧", Adverb);
    ("偏", Adverb);
    ("偏", Adverb);
    ("偏", Adverb);
    ("独", Adverb);
    ("单", Adverb);
    ("只", Adverb);
    ("仅", Adverb);
    ("光", Adverb);
    ("净", Adverb);
    ("空", Adverb);
    ("白", Adverb);
    ("徒", Adverb);
    ("枉", Adverb);
    ("虚", Adverb);
    ("空", Adverb);
    ("亲", Adverb);
    ("自", Adverb);
    ("亲", Adverb);
    ("手", Adverb);
    ("亲", Adverb);
    ("眼", Adverb);
    ("亲", Adverb);
    ("口", Adverb);
    ("亲", Adverb);
    ("身", Adverb);
    ("故", Adverb);
    ("意", Adverb);
    ("特", Adverb);
    ("意", Adverb);
    ("专", Adverb);
    ("门", Adverb);
    ("特", Adverb);
    ("地", Adverb);
    ("专", Adverb);
    ("程", Adverb);
    ("一", Adverb);
    ("直", Adverb);
    ("一", Adverb);
    ("味", Adverb);
    ("一", Adverb);
  ]

(** 数词量词数据 - 数量单位，计量词汇 *)
let numerals_classifiers =
  [
    (* 基数词 *)
    ("零", Numeral);
    ("一", Numeral);
    ("二", Numeral);
    ("三", Numeral);
    ("四", Numeral);
    ("五", Numeral);
    ("六", Numeral);
    ("七", Numeral);
    ("八", Numeral);
    ("九", Numeral);
    ("十", Numeral);
    ("百", Numeral);
    ("千", Numeral);
    ("万", Numeral);
    ("亿", Numeral);
    ("兆", Numeral);
    ("京", Numeral);
    ("垓", Numeral);
    ("秭", Numeral);
    ("穰", Numeral);
    ("沟", Numeral);
    ("涧", Numeral);
    ("正", Numeral);
    ("载", Numeral);
    ("极", Numeral);
    (* 序数词 *)
    ("第", Numeral);
    ("初", Numeral);
    ("头", Numeral);
    ("首", Numeral);
    ("末", Numeral);
    ("终", Numeral);
    ("最", Numeral);
    ("后", Numeral);
    ("前", Numeral);
    ("先", Numeral);
    ("次", Numeral);
    ("再", Numeral);
    ("三", Numeral);
    ("四", Numeral);
    ("五", Numeral);
    (* 量词 *)
    ("个", Classifier);
    ("只", Classifier);
    ("条", Classifier);
    ("根", Classifier);
    ("支", Classifier);
    ("枝", Classifier);
    ("片", Classifier);
    ("张", Classifier);
    ("块", Classifier);
    ("团", Classifier);
    ("堆", Classifier);
    ("群", Classifier);
    ("批", Classifier);
    ("队", Classifier);
    ("行", Classifier);
    ("排", Classifier);
    ("列", Classifier);
    ("串", Classifier);
    ("束", Classifier);
    ("把", Classifier);
    ("副", Classifier);
    ("套", Classifier);
    ("对", Classifier);
    ("双", Classifier);
    ("对", Classifier);
    ("副", Classifier);
    ("件", Classifier);
    ("套", Classifier);
    ("身", Classifier);
    ("头", Classifier);
    ("匹", Classifier);
    ("头", Classifier);
    ("只", Classifier);
    ("条", Classifier);
    ("尾", Classifier);
    ("口", Classifier);
    ("峰", Classifier);
    ("头", Classifier);
    ("匹", Classifier);
    ("只", Classifier);
    ("株", Classifier);
    ("棵", Classifier);
    ("颗", Classifier);
    ("粒", Classifier);
    ("滴", Classifier);
    ("点", Classifier);
    ("丝", Classifier);
    ("缕", Classifier);
    ("股", Classifier);
    ("道", Classifier);
    ("层", Classifier);
    ("重", Classifier);
    ("叠", Classifier);
    ("折", Classifier);
    ("番", Classifier);
    ("回", Classifier);
    ("次", Classifier);
    ("遍", Classifier);
    ("趟", Classifier);
    ("场", Classifier);
    ("轮", Classifier);
    ("局", Classifier);
    ("盘", Classifier);
    ("手", Classifier);
    ("招", Classifier);
    ("式", Classifier);
    ("种", Classifier);
    ("类", Classifier);
    ("样", Classifier);
    ("般", Classifier);
    ("等", Classifier);
    ("级", Classifier);
    ("档", Classifier);
    ("层", Classifier);
    ("品", Classifier);
    ("名", Classifier);
    ("位", Classifier);
    ("员", Classifier);
    ("人", Classifier);
    ("口", Classifier);
    ("家", Classifier);
    ("户", Classifier);
    ("门", Classifier);
    ("间", Classifier);
    ("座", Classifier);
    ("幢", Classifier);
    ("栋", Classifier);
    ("层", Classifier);
    ("楼", Classifier);
    ("间", Classifier);
    ("亩", Classifier);
    ("顷", Classifier);
    ("里", Classifier);
    ("丈", Classifier);
    ("尺", Classifier);
    ("寸", Classifier);
    ("分", Classifier);
    ("厘", Classifier);
    ("毫", Classifier);
    ("微", Classifier);
    ("斤", Classifier);
    ("两", Classifier);
    ("钱", Classifier);
    ("分", Classifier);
    ("厘", Classifier);
    ("升", Classifier);
    ("斗", Classifier);
    ("石", Classifier);
    ("合", Classifier);
    ("勺", Classifier);
  ]

(** 代词数据 - 人称代词、指示代词、疑问代词等 *)
let pronoun_words =
  [
    (* 人称代词 *)
    ("我", Pronoun);
    ("你", Pronoun);
    ("他", Pronoun);
    ("她", Pronoun);
    ("它", Pronoun);
    ("们", Pronoun);
    ("自", Pronoun);
    ("己", Pronoun);
    ("彼", Pronoun);
    ("此", Pronoun);
    ("其", Pronoun);
    (* 指示代词 *)
    ("这", Pronoun);
    ("那", Pronoun);
    ("些", Pronoun);
    (* 疑问代词 *)
    ("什", Pronoun);
    ("么", Pronoun);
    ("哪", Pronoun);
    ("谁", Pronoun);
    ("何", Pronoun);
    ("几", Pronoun);
    ("多", Pronoun);
    ("少", Pronoun);
    ("怎", Pronoun);
    ("样", Pronoun);
    ("如", Pronoun);
    ("为", Pronoun);
    ("时", Pronoun);
    ("地", Pronoun);
    ("人", Pronoun);
    ("物", Pronoun);
    ("事", Pronoun);
    (* 不定代词 *)
    ("某", Pronoun);
    ("各", Pronoun);
    ("每", Pronoun);
    ("任", Pronoun);
    ("无", Pronoun);
    ("论", Pronoun);
    ("不", Pronoun);
    ("管", Pronoun);
  ]

(** 介词数据 - 表示时间、地点、方式、原因等关系 *)
let preposition_words =
  [
    (* 时空介词 *)
    ("在", Preposition);
    ("于", Preposition);
    ("从", Preposition);
    ("到", Preposition);
    ("向", Preposition);
    ("朝", Preposition);
    ("往", Preposition);
    ("由", Preposition);
    ("自", Preposition);
    (* 对象介词 *)
    ("为", Preposition);
    ("被", Preposition);
    ("把", Preposition);
    ("对", Preposition);
    ("跟", Preposition);
    ("和", Preposition);
    ("与", Preposition);
    ("同", Preposition);
    ("及", Preposition);
    (* 方式介词 *)
    ("以", Preposition);
    ("用", Preposition);
    ("按", Preposition);
    ("照", Preposition);
    ("根", Preposition);
    ("据", Preposition);
    ("依", Preposition);
    (* 范围介词 *)
    ("关", Preposition);
    ("至", Preposition);
    ("除", Preposition);
    ("了", Preposition);
    ("外", Preposition);
    ("去", Preposition);
    ("开", Preposition);
    ("非", Preposition);
    ("着", Preposition);
    ("止", Preposition);
    ("连", Preposition);
    ("带", Preposition);
    ("沿", Preposition);
    ("顺", Preposition);
  ]

(** 连词数据 - 表示并列、选择、转折、因果等逻辑关系 *)
let conjunction_words =
  [
    (* 并列连词 *)
    ("和", Conjunction);
    ("与", Conjunction);
    ("及", Conjunction);
    ("也", Conjunction);
    ("又", Conjunction);
    ("既", Conjunction);
    ("而", Conjunction);
    ("且", Conjunction);
    ("并", Conjunction);
    (* 选择连词 *)
    ("或", Conjunction);
    ("者", Conjunction);
    ("还", Conjunction);
    ("是", Conjunction);
    (* 转折连词 *)
    ("但", Conjunction);
    ("不", Conjunction);
    ("只", Conjunction);
    ("可", Conjunction);
    ("然", Conjunction);
    ("过", Conjunction);
    (* 因果连词 *)
    ("因", Conjunction);
    ("为", Conjunction);
    ("由", Conjunction);
    ("于", Conjunction);
    ("所", Conjunction);
    ("以", Conjunction);
    ("此", Conjunction);
    (* 假设连词 *)
    ("如", Conjunction);
    ("果", Conjunction);
    ("假", Conjunction);
    ("倘", Conjunction);
    ("若", Conjunction);
    ("要", Conjunction);
    ("万", Conjunction);
    ("一", Conjunction);
    ("除", Conjunction);
    ("非", Conjunction);
    ("只", Conjunction);
    ("有", Conjunction);
    (* 让步连词 *)
    ("无", Conjunction);
    ("论", Conjunction);
    ("管", Conjunction);
    ("尽", Conjunction);
    ("虽", Conjunction);
    ("说", Conjunction);
    ("即", Conjunction);
    ("使", Conjunction);
    ("纵", Conjunction);
  ]

(** 助词数据 - 结构助词、时态助词、语气助词等 *)
let particle_words =
  [
    (* 结构助词 *)
    ("的", Particle);
    ("地", Particle);
    ("得", Particle);
    (* 时态助词 *)
    ("了", Particle);
    ("着", Particle);
    ("过", Particle);
    (* 语气助词 - 现代汉语 *)
    ("呢", Particle);
    ("吗", Particle);
    ("呀", Particle);
    ("啊", Particle);
    ("吧", Particle);
    ("嘛", Particle);
    ("咧", Particle);
    ("哟", Particle);
    ("哪", Particle);
    ("啦", Particle);
    ("哇", Particle);
    ("嘿", Particle);
    ("嗨", Particle);
    (* 语气助词 - 文言文 *)
    ("之", Particle);
    ("乎", Particle);
    ("者", Particle);
    ("也", Particle);
    ("矣", Particle);
    ("焉", Particle);
    ("哉", Particle);
    ("兮", Particle);
    ("邪", Particle);
    ("耶", Particle);
    ("欤", Particle);
    ("与", Particle);
  ]

(** 叹词数据 - 表示情感、态度、呼唤等 *)
let interjection_words =
  [
    (* 感叹词 *)
    ("啊", Interjection);
    ("哎", Interjection);
    ("哦", Interjection);
    ("嗯", Interjection);
    ("呃", Interjection);
    ("哼", Interjection);
    ("哈", Interjection);
    ("嘿", Interjection);
    ("嗨", Interjection);
    ("咦", Interjection);
    ("咯", Interjection);
    ("哟", Interjection);
    ("喂", Interjection);
    ("哇", Interjection);
    ("呀", Interjection);
    ("唉", Interjection);
    ("哀", Interjection);
    (* 拟声词 *)
    ("呜", Interjection);
    ("呼", Interjection);
    ("噢", Interjection);
    ("喔", Interjection);
    ("哩", Interjection);
    ("咚", Interjection);
    ("吱", Interjection);
    ("嘎", Interjection);
    ("咔", Interjection);
    ("嗒", Interjection);
    ("嗖", Interjection);
    ("嗡", Interjection);
    ("嗷", Interjection);
    ("嗳", Interjection);
    ("嗐", Interjection);
    ("嗬", Interjection);
  ]

(** 功能词汇总合 - 将所有功能词类别组合成统一列表 *)
let function_words =
  pronoun_words @ preposition_words @ conjunction_words @ particle_words @ interjection_words

(** {1 扩展词性数据库合成} *)

(** 扩展词性数据库 - 合并所有词性的完整数据库

    Phase 1扩展：从原有100字扩展到500字 包含更多词性分类和完整的词性数据 *)
let expanded_word_class_database =
  nature_nouns @ human_society_nouns @ abstract_nouns @ basic_verbs @ social_verbs
  @ production_verbs @ appearance_adjectives @ quality_adjectives @ expanded_adverbs
  @ numerals_classifiers @ function_words

(** 扩展词性数据库字符统计 *)
let expanded_word_class_char_count = List.length expanded_word_class_database

(** 获取扩展词性数据库 *)
let get_expanded_word_class_database () = expanded_word_class_database

(** 检查字符是否在扩展词性数据库中 *)
let is_in_expanded_word_class_database char =
  List.exists (fun (c, _) -> c = char) expanded_word_class_database

(** 获取扩展词性数据库中的字符列表 *)
let get_expanded_char_list () = List.map (fun (c, _) -> c) expanded_word_class_database

(** 查找字符的词性 *)
let find_word_class char =
  try
    let _, word_class = List.find (fun (c, _) -> c = char) expanded_word_class_database in
    Some word_class
  with Not_found -> None

(** 按词性分类获取字符列表 *)
let get_chars_by_class word_class =
  List.filter_map
    (fun (c, wc) -> if wc = word_class then Some c else None)
    expanded_word_class_database
