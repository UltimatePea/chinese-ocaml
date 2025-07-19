(** 扩展词性数据模块 - 骆言诗词编程特性 Phase 1

    应Issue #419需求，扩展词性数据从100字到500字。 依《现代汉语词典》、《古汉语常用字字典》等典籍， 结合诗词用字特点，分类整理常用字词词性。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-18 
    @updated 2025-07-19 Phase 12: 使用统一词性类型定义 *)

(** 使用统一的词性类型定义，消除重复 *)
open Word_class_types

(** {1 数据生成辅助函数} *)

(** 词性数据生成辅助函数 - 消除代码重复的核心函数 *)
let make_word_class_list words word_class =
  List.map (fun word -> (word, word_class)) words


(** {1 扩展名词数据} *)

(** 引入词性数据存储模块 *)
module WordClassStorage = Word_class_data_storage

(** 自然景物名词 - 山川河流，风花雪月 
    重构：从原来的113行硬编码数据改为使用数据存储模块 *)
let nature_nouns =
  List.map (fun word -> (word, Noun)) WordClassStorage.nature_nouns_list

(** 人物称谓数据 - 亲族关系和人物称谓 *)
let person_relation_nouns =
  make_word_class_list [
    (* 基本人物 *)
    "人"; "民"; "众"; "群"; "族"; "家"; "户"; "口"; "丁"; "身";
    (* 家庭成员 *)
    "父"; "母"; "子"; "女"; "夫"; "妻"; "兄"; "弟"; "姊"; "妹"; "祖"; "孙"; "亲"; "戚";
    (* 社交关系 *)
    "友"; "朋"; "伴"; "侣"; "客"; "宾";
  ] Noun

(** 社会地位数据 - 政治、职业和社会地位 *)
let social_status_nouns =
  make_word_class_list [
    (* 政治地位 *)
    "王"; "君"; "臣"; "民"; "官"; "吏";
    (* 职业地位 *)
    "士"; "农"; "工"; "商"; "师"; "生"; "徒"; "弟";
    (* 年龄性别 *)
    "长"; "幼"; "老"; "少"; "男"; "女";
  ] Noun

(** 建筑场所数据 - 建筑物和建筑构件 *)
let building_place_nouns =
  make_word_class_list [
    (* 建筑空间 *)
    "屋"; "房"; "室"; "厅"; "堂"; "院"; "庭"; "园";
    (* 建筑类型 *)
    "亭"; "阁"; "楼"; "台"; "殿"; "宫"; "府"; "寺"; "庙"; "观"; "塔"; "桥";
    (* 建筑部件 *)
    "门"; "户"; "窗"; "墙"; "壁"; "柱"; "梁"; "瓦"; "砖"; "板";
  ] Noun

(** 地理政治数据 - 行政区划和地理位置 *)
let geography_politics_nouns =
  make_word_class_list [
    (* 政治单位 *)
    "国"; "邦"; "朝"; "代"; "世"; "京"; "都"; "城"; "镇"; "村"; "乡"; "里"; "坊"; "巷";
    (* 道路交通 *)
    "街"; "路"; "道"; "径"; "途"; "程";
    (* 行政分级 *)
    "州"; "郡"; "县"; "区"; "境";
  ] Noun

(** 器物用具数据 - 日常用品和工具器物 *)
let tools_objects_nouns =
  make_word_class_list [
    (* 基本器物 *)
    "器"; "具"; "物"; "品"; "件";
    (* 文房四宝 *)
    "书"; "册"; "卷"; "篇"; "章";
    "笔"; "墨"; "纸"; "砚"; "印";
    (* 艺术器物 *)
    "琴"; "棋"; "画"; "诗"; "词";
    (* 兵器武器 *)
    "剑"; "刀"; "弓"; "箭"; "盾";
    (* 衣物鞋帽 *)
    "衣"; "裳"; "袍"; "衫"; "裙";
    "帽"; "冠"; "履"; "鞋"; "袜";
    (* 饮食器物 *)
    "食"; "饭"; "菜"; "肉"; "鱼";
    "酒"; "茶"; "水"; "汤"; "饮";
    "杯"; "盏"; "碗"; "盘"; "碟";
    (* 家具用品 *)
    "床"; "席"; "枕"; "被"; "褥";
    "桌"; "案"; "椅"; "凳"; "几";
    "箱"; "柜"; "橱"; "架"; "台";
    "灯"; "烛"; "火"; "炉"; "炭";
    (* 交通工具 *)
    "车"; "船"; "舟"; "艇"; "筏";
    "轿"; "辇"; "骑"; "驴"; "骡";
  ] Noun

(** 人文社会名词汇总 - 将所有人文社会类名词组合成统一列表 *)
let human_society_nouns =
  person_relation_nouns @ social_status_nouns @ building_place_nouns @ geography_politics_nouns
  @ tools_objects_nouns

(** 情感心理名词 - 内心世界，情绪感受 *)
let emotional_psychological_nouns =
  make_word_class_list [
    (* 基础情感 *)
    "情"; "爱"; "恨"; "喜"; "怒"; "哀"; "乐"; "忧"; "愁";
    (* 思维意志 *)
    "思"; "念"; "想"; "梦"; "望"; "盼"; "心"; "意"; "志"; "愿"; "求"; "欲";
    (* 精神灵魂 *)
    "情"; "性"; "魂"; "魄"; "神"; "灵"; "识"; "智"; "慧";
  ] Noun

(** 道德品质名词 - 人格修养，德行品格 *)
let moral_virtue_nouns =
  [
    (* 基础道德 *)
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
    (* 仁慈悲廉 *)
    ("仁", Noun);
    ("慈", Noun);
    ("悲", Noun);
    ("廉", Noun);
    ("耻", Noun);
    ("节", Noun);
    ("操", Noun);
    (* 品格质量 *)
    ("品", Noun);
    ("格", Noun);
    ("质", Noun);
    ("量", Noun);
    ("度", Noun);
    ("分", Noun);
  ]

(** 学问知识名词 - 文化传承，学术研究 *)
let knowledge_learning_nouns =
  [
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
    (* 能力才华 *)
    ("技", Noun);
    ("能", Noun);
    ("力", Noun);
    ("才", Noun);
    ("华", Noun);
    ("文", Noun);
    ("武", Noun);
    (* 经史子集 *)
    ("经", Noun);
    ("史", Noun);
    ("子", Noun);
    ("集", Noun);
    ("典", Noun);
    ("籍", Noun);
    ("录", Noun);
    ("志", Noun);
  ]

(** 时空概念名词 - 时间空间，处所位置 *)
let time_space_nouns =
  make_word_class_list [
    (* 空间概念 *)
    "空"; "间"; "处"; "所"; "地"; "方"; "位"; "向"; "面"; "边";
    "际"; "界"; "境"; "域"; "区";
    (* 时间概念 *)
    "期"; "段"; "候"; "机"; "会"; "遇"; "缘"; "份"; "运"; "命";
  ] Noun

(** 事务活动名词 - 事业工作，行为活动 *)
let affairs_activity_nouns =
  make_word_class_list [
    (* 事务业务 *)
    "事"; "务"; "业"; "作"; "工"; "活"; "动"; "行"; "为"; "举"; "止";
    (* 态势状况 *)
    "态"; "势"; "状"; "况"; "形"; "样"; "式"; "型";
    (* 种类别等 *)
    "种"; "类"; "别"; "般"; "等"; "级";
    (* 步骤程序 *)
    "步"; "骤"; "程"; "序"; "次"; "回"; "番"; "遍"; "趟"; "场";
  ] Noun

(** 抽象名词集合 - 汇聚所有抽象类名词 *)
let abstract_nouns =
  emotional_psychological_nouns @ moral_virtue_nouns @ knowledge_learning_nouns @ 
  time_space_nouns @ affairs_activity_nouns

(** {2 扩展动词数据} *)

(** 移动位置动词 - 空间移动、位置变化 *)
let movement_position_verbs =
  make_word_class_list [
    (* 空间移动 *)
    "来"; "去"; "到"; "达"; "至"; "行"; "走"; "跑"; "飞"; "游";
    "进"; "出"; "入"; "退"; "归"; "回"; "返"; "还"; "往"; "向";
    "趋"; "奔"; "驰"; "驱"; "驾"; "骑"; "乘";
    (* 位置状态 *)
    "坐"; "立"; "站"; "卧"; "躺"; "睡"; "眠"; "息"; "休"; "停";
    "住"; "居"; "处"; "留"; "待"; "守"; "候"; "等";
  ] Verb

(** 感官动作动词 - 感知感受、身体动作 *)
let sensory_action_verbs =
  make_word_class_list [
    (* 视觉感知 *)
    "看"; "见"; "视"; "望"; "观"; "瞧"; "瞪"; "瞥"; "瞟"; "瞄";
    (* 听觉表达 *)
    "听"; "闻"; "声"; "响"; "鸣"; "叫"; "呼"; "唤"; "喊"; "吼";
    "说"; "话"; "言"; "语"; "谈"; "讲"; "述"; "论"; "议"; "评";
    (* 嗅觉味觉 *)
    "嗅"; "闻"; "嗅"; "尝"; "品"; "吃"; "喝"; "饮"; "食"; "餐";
    (* 触觉动作 *)
    "摸"; "触"; "抚"; "摩"; "按"; "握"; "抓"; "拿"; "持"; "执";
  ] Verb

(** 思维活动动词 - 认知思考、情感表达 *)
let cognitive_activity_verbs =
  make_word_class_list [
    (* 认知思考 *)
    "想"; "思"; "念"; "记"; "忆"; "忘"; "知"; "识"; "悟"; "解"; "懂"; "会"; "能";
    (* 学习创作 *)
    "学"; "习"; "读"; "书"; "写"; "作"; "画"; "算"; "计"; "数"; "量"; "测";
    (* 判断决策 *)
    "判"; "断"; "决"; "定"; "择"; "选"; "挑"; "拣"; "择"; "采"; "考"; "虑"; "虑"; "顾";
    (* 情感表达 *)
    "忌"; "怕"; "惧"; "恐"; "畏"; "惊"; "疑"; "猜"; "测"; "推"; "估";
  ] Verb

(** 基础动词 - 移动位置、感官动作、思维活动的动词集合 *)
let basic_verbs =
  movement_position_verbs @ sensory_action_verbs @ cognitive_activity_verbs

(** 社交沟通动词 - 交流互动，信息传递 *)
let social_communication_verbs =
  [
    (* 沟通交流 *)
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
    (* 会面访问 *)
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
    (* 教导帮助 *)
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
  ]

(** 情感表达动词 - 喜怒哀乐，情绪抒发 *)
let emotional_expression_verbs =
  [
    (* 爱恋喜悦 *)
    ("爱", Verb);
    ("恋", Verb);
    ("爱慕", Verb);
    ("喜", Verb);
    ("欢", Verb);
    ("笑", Verb);
    ("乐", Verb);
    (* 恨怒怨恼 *)
    ("恨", Verb);
    ("怨", Verb);
    ("恼", Verb);
    ("怒", Verb);
    ("气", Verb);
    (* 悲哀痛苦 *)
    ("哭", Verb);
    ("泣", Verb);
    ("涕", Verb);
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
    (* 希望祈求 *)
    ("盼", Verb);
    ("望", Verb);
    ("希", Verb);
    ("求", Verb);
    ("祈", Verb);
    ("祷", Verb);
    ("拜", Verb);
    (* 感谢赞美 *)
    ("谢", Verb);
    ("感", Verb);
    ("激", Verb);
    ("赞", Verb);
    ("美", Verb);
    ("夸", Verb);
    ("扬", Verb);
    ("颂", Verb);
    (* 责备批评 *)
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
  ]

(** 社会行为动词 - 治理统制，竞争合作 *)
let social_behavior_verbs =
  [
    (* 管理治理 *)
    ("治", Verb);
    ("理", Verb);
    ("管", Verb);
    ("领", Verb);
    ("导", Verb);
    ("统", Verb);
    ("制", Verb);
    ("控", Verb);
    (* 约束限制 *)
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
    (* 竞争斗争 *)
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
    (* 服从依托 *)
    ("降", Verb);
    ("屈", Verb);
    ("伏", Verb);
    ("顺", Verb);
    ("从", Verb);
    ("依", Verb);
    ("靠", Verb);
    ("倚", Verb);
    ("仗", Verb);
    (* 信任委托 *)
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

(** 社会动词集合 - 汇聚所有社会类动词 *)
let social_verbs =
  social_communication_verbs @ emotional_expression_verbs @ social_behavior_verbs

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

(** 品质评价形容词 - 好坏优劣，价值判断 *)
let value_judgment_adjectives =
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
    (* 奇异平凡 *)
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
    (* 高低贵贱 *)
    ("高", Adjective);
    ("低", Adjective);
    ("贵", Adjective);
    ("贱", Adjective);
    ("富", Adjective);
    ("贫", Adjective);
    ("穷", Adjective);
    ("困", Adjective);
  ]

(** 情感状态形容词 - 喜怒哀乐，情绪感受 *)
let emotional_state_adjectives =
  [
    (* 苦乐甘甜 *)
    ("苦", Adjective);
    ("甘", Adjective);
    ("甜", Adjective);
    ("乐", Adjective);
    (* 喜怒哀乐 *)
    ("悲", Adjective);
    ("喜", Adjective);
    ("怒", Adjective);
    ("哀", Adjective);
    (* 恐惧勇敢 *)
    ("惧", Adjective);
    ("恐", Adjective);
    ("怕", Adjective);
    ("勇", Adjective);
    ("敢", Adjective);
  ]

(** 运动状态形容词 - 动静快慢，速度节奏 *)
let motion_state_adjectives =
  [
    (* 动静缓急 *)
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
    (* 轻重浮沉 *)
    ("飘", Adjective);
    ("浮", Adjective);
    ("沉", Adjective);
    ("轻", Adjective);
    ("重", Adjective);
    ("刚", Adjective);
    ("柔", Adjective);
  ]

(** 温度湿度形容词 - 冷热干湿，触感体验 *)
let temperature_texture_adjectives =
  [
    (* 冷热温凉 *)
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
    (* 干湿润燥 *)
    ("湿", Adjective);
    ("干", Adjective);
    ("潮", Adjective);
    ("燥", Adjective);
    ("润", Adjective);
    (* 滑涩腻爽 *)
    ("滑", Adjective);
    ("涩", Adjective);
    ("腻", Adjective);
    ("爽", Adjective);
  ]

(** 纯净污浊形容词 - 清洁程度，纯度品质 *)
let purity_cleanliness_adjectives =
  [
    (* 清浊纯混 *)
    ("清", Adjective);
    ("浊", Adjective);
    ("混", Adjective);
    ("纯", Adjective);
    ("净", Adjective);
    ("洁", Adjective);
    (* 脏污染秽 *)
    ("脏", Adjective);
    ("污", Adjective);
    ("染", Adjective);
    ("秽", Adjective);
  ]

(** 道德品质形容词 - 真假善恶，人格品格 *)
let moral_character_adjectives =
  [
    (* 真假诚伪 *)
    ("真", Adjective);
    ("假", Adjective);
    ("诚", Adjective);
    ("伪", Adjective);
    (* 正邪直曲 *)
    ("正", Adjective);
    ("邪", Adjective);
    ("直", Adjective);
    ("曲", Adjective);
    (* 忠奸孝逆 *)
    ("忠", Adjective);
    ("奸", Adjective);
    ("孝", Adjective);
    ("逆", Adjective);
    (* 义利公私 *)
    ("义", Adjective);
    ("利", Adjective);
    ("公", Adjective);
    ("私", Adjective);
    (* 廉贪洁污 *)
    ("廉", Adjective);
    ("贪", Adjective);
    ("洁", Adjective);
    ("污", Adjective);
  ]

(** 智慧明暗形容词 - 聪明愚笨，光明黑暗 *)
let wisdom_brightness_adjectives =
  [
    (* 明暗亮昏 *)
    ("明", Adjective);
    ("暗", Adjective);
    ("亮", Adjective);
    ("昏", Adjective);
    (* 智愚聪笨 *)
    ("智", Adjective);
    ("愚", Adjective);
    ("聪", Adjective);
    ("笨", Adjective);
    ("慧", Adjective);
    ("蠢", Adjective);
  ]

(** 精密程度形容词 - 粗细密疏，精确度量 *)
let precision_degree_adjectives =
  [
    (* 精粗细密 *)
    ("精", Adjective);
    ("粗", Adjective);
    ("细", Adjective);
    ("密", Adjective);
    ("疏", Adjective);
    (* 严宽松紧 *)
    ("严", Adjective);
    ("宽", Adjective);
    ("松", Adjective);
    ("紧", Adjective);
    (* 实虚满空 *)
    ("实", Adjective);
    ("虚", Adjective);
    ("满", Adjective);
    ("空", Adjective);
    (* 充足够缺 *)
    ("充", Adjective);
    ("足", Adjective);
    ("够", Adjective);
    ("缺", Adjective);
    ("少", Adjective);
    ("多", Adjective);
    ("众", Adjective);
  ]

(** 品质形容词集合 - 汇聚所有品质类形容词 *)
let quality_adjectives =
  value_judgment_adjectives @ emotional_state_adjectives @ motion_state_adjectives @ 
  temperature_texture_adjectives @ purity_cleanliness_adjectives @ moral_character_adjectives @ 
  wisdom_brightness_adjectives @ precision_degree_adjectives

(** {4 扩展其他词性数据} *)

(** 程度副词 - 强度程度、比较级别 *)
let degree_adverbs =
  [
    (* 强度程度 *)
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
    
    (* 程度轻重 *)
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
  ]

(** 时间副词 - 时序关系、时间状态 *)
let temporal_adverbs =
  [
    (* 时序关系 *)
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
    
    (* 时间状态 *)
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
  ]

(** 方式副词 - 行为方式、动作状态 *)
let manner_adverbs =
  [
    (* 比较方式 *)
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
    
    (* 动作方式 *)
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

(** 扩展副词 - 程度、时间、方式副词的集合 *)
let expanded_adverbs =
  degree_adverbs @ temporal_adverbs @ manner_adverbs

(** 基数词 - 数量表示、计数单位 *)
let cardinal_numbers =
  [
    (* 基本数字 *)
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
    
    (* 数位单位 *)
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
  ]

(** 序数词 - 顺序表示、位次标记 *)
let ordinal_numbers =
  [
    (* 序次标记 *)
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
  ]

(** 量词数据 - 计量词汇，区分数量单位 
    重构：从原来的113行硬编码数据改为使用数据存储模块 *)
let measuring_classifiers =
  List.map (fun word -> (word, Classifier)) WordClassStorage.measuring_classifiers_list

(** 数词量词 - 基数词、序数词、量词的集合 *)
let numerals_classifiers =
  cardinal_numbers @ ordinal_numbers @ measuring_classifiers

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
