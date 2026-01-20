import {FestivalDetailInfo,FestivalCustom,FestivalOrigin} from '../pages/Model/FestivalDetailInfo'

export let FestivalDetailData : Record<string,FestivalDetailInfo> = {};

//元旦
let festivalName = '元旦节';
let festivalEnglishName = "New Year's Day";
let simpleIntroduction = '元旦是公历新年的第一天，象征着一年新的开始。人们在这一天通过庆祝、祝福和回顾过去，迎接未来，寄托对美好生活的期待。';
let fullDescription = '元旦，指公历一月一日，是世界上大多数国家通用的新年起点。“元”意为开始，“旦”意为清晨，合起来表示“新的一天开始了”。\n' +
  '\n' +
  '在中国，元旦最早并非专指公历新年，而是泛指一年之始。随着历法制度的演变，公历逐渐成为社会通用历法，元旦也被固定为公历一月一日，用以区别于传统农历新年（春节）。\n' +
  '\n' +
  '作为一年之始，元旦承载着辞旧迎新、展望未来的象征意义。现代社会中，元旦既是法定节假日，也是重要的时间节点，人们常在这一天制定新年计划、互致祝福，并通过各种文体活动迎接新一年的到来。\n' +
  '\n' +
  '虽然元旦不像春节那样拥有丰富而系统的传统礼俗，但它以其开放性和现代性，成为连接传统文化与现代生活的重要节日。'
let originPeriod = '古代历法时期起源，近代（清末民初）确立为公历新年';
let originStory = '“元旦”一词最早可追溯至中国古代文献。《晋书》中已有“正旦”“元旦”之说，用来指代一年开始的日子，但具体日期因朝代和历法不同而变化。\n' +
  '\n' +
  '古代中国以农历为主，不同朝代对“岁首”的规定并不一致，如夏代以正月为岁首，商代以十二月为岁首，周代以十一月为岁首。\n' +
  '\n' +
  '1912 年，中华民国政府正式采用公历，并将公历一月一日定为“元旦”，同时将农历新年称为“春节”。这一制度延续至今，使“元旦”成为现代意义上的新年第一天。';
let originBackground = '元旦的形成与历法制度的演进密切相关。随着社会治理、对外交往和科学技术的发展，公历因其稳定性和国际通用性逐渐取代传统历法，成为国家和社会运行的重要时间标准。\n' +
  '\n' +
  '在这一背景下，元旦逐渐从“泛指岁首”的概念，演变为特指公历新年的固定节日，承担起时间分界和社会节奏调整的功能。';
let keyFigures = [
  "古代历法制定者",
  "汉武帝（太初历）",
  "近代历法改革推动者"
]
let origin : FestivalOrigin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);
let custom : Array<FestivalCustom> = [];
let customName1 = '辞旧迎新';
let customIntroduction1 = '元旦象征一年新的开始，人们常在这一天回顾过去一年的经历，总结得失，并以积极的心态迎接新的一年。';
custom.push(new FestivalCustom(customName1,customIntroduction1));
let customName2 = '互致新年祝福';
let customIntroduction2 = '在元旦期间，人们通过短信、电话、社交媒体或面对面的方式互致祝福，表达对亲友平安、幸福和顺利的美好祝愿。';
custom.push(new FestivalCustom(customName2,customIntroduction2));
let customName3 = '制定新年计划';
let customIntroduction3 = '许多人会在元旦制定新年目标，如学习计划、工作规划或生活习惯调整，希望在新的一年中实现自我提升。';
custom.push(new FestivalCustom(customName3,customIntroduction3));
let customName4 = '文体庆祝活动';
let customIntroduction4 = '各地常在元旦举办文艺演出、音乐会、跨年晚会、升旗仪式、群众体育活动等，以热烈的方式迎接新年的到来。';
custom.push(new FestivalCustom(customName4,customIntroduction4));
let customName5 = '家庭聚会';
let customIntroduction5 = '元旦假期虽短，但不少家庭仍会利用时间聚餐或短途出游，增强家庭成员之间的情感联系。';
custom.push(new FestivalCustom(customName5,customIntroduction5));
let culturalSignificance = '元旦不仅是时间意义上的一年之始，更具有重要的社会和文化价值。\n' +
  '\n' +
  '它标志着社会运行周期的重新开始，是制定计划、调整目标和重塑秩序的重要节点。元旦所体现的“更新”“希望”“起点”观念，与人类普遍的时间意识高度契合。\n' +
  '\n' +
  '在中国文化语境中，元旦还承担着传统与现代之间的过渡角色：一方面，它源自古代“岁首”的概念；另一方面，又以公历制度为基础，体现出现代社会的理性与秩序。\n' +
  '\n' +
  '正因如此，元旦虽形式相对简约，却在精神层面具有广泛而深远的影响。';
let festivalDetailInfo : FestivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Yuandan.png'), festivalName,
  festivalEnglishName,simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['元旦节'] = festivalDetailInfo;
custom = [];

//腊八
festivalName = '腊八节';
festivalEnglishName = 'Laba Festival';
simpleIntroduction = '腊八节是中国传统节日，时间为农历十二月初八，标志着年终岁末的到来。人们在这一天通过祭祀、祈福和食用腊八粥，迎接新年的临近。';
fullDescription = '腊八节是中国传统节日之一，通常在农历十二月初八举行。“腊”指岁终祭祀，“八”为日期，因此腊八节本质上是年终祭祀与祈福活动的重要节点。\n' +
  '\n' +
  '在古代社会，腊八节是连接农耕生活与宗教信仰的重要节日，人们通过祭祀祖先和神灵，感谢一年来的庇佑，并祈求来年风调雨顺、五谷丰登。\n' +
  '\n' +
  '随着佛教在中国的传播，腊八节逐渐与佛教文化相融合，形成了“腊八佛成道”的说法，使这一节日兼具民俗与宗教色彩。\n' +
  '\n' +
  '时至今日，腊八节虽不再是大型法定节日，但“喝腊八粥”的习俗依然广泛流传，象征着团圆、温暖和对新一年的美好期待，同时也被视为春节的重要序章。';
originPeriod = '先秦时期形成雏形，汉代定型，后与佛教文化相融合';
originStory = '腊八节最早源于古代“腊祭”。在先秦时期，人们在岁末举行盛大的祭祀活动，用以祭祀祖先和百神，感谢神灵一年来的庇护。\n' +
  '\n' +
  '“腊”本意为冬季狩猎后祭祀神灵，后来逐渐演变为农历十二月的统称。腊月初八作为重要的祭祀日，被固定下来，形成了腊八节。\n' +
  '\n' +
  '另一种广为流传的说法与佛教有关。相传释迦牟尼在腊月初八悟道成佛，因此佛教寺院在这一天熬制杂粮粥供僧众和信众食用，称为“腊八粥”。这一习俗逐渐传入民间，成为节日的重要标志。';
originBackground = '腊八节的形成与农耕社会的生产节律密切相关。岁末农事结束，人们有条件进行集中祭祀和庆祝活动。\n' +
  '\n' +
  '同时，佛教文化在汉魏之后广泛传播，使原本以祭祀为主的腊八节融入了宗教意义，形成了兼具民俗信仰、宗教仪式和生活习俗的复合型节日。';
keyFigures = [
  "释迦牟尼",
  "古代祭祀先民",
  "佛教僧侣"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);
customName1 = '喝腊八粥';
customIntroduction1 = '腊八粥是腊八节最具代表性的饮食习俗，通常由多种谷物、豆类和干果熬制而成，寓意五谷丰登、家庭和睦、生活富足。';
custom.push(new FestivalCustom(customName1,customIntroduction1));
customName2 = '祭祀祈福';
customIntroduction2 = '在部分地区，人们会在腊八节祭祀祖先和神灵，感谢一年的庇佑，并祈求来年平安顺遂。';
custom.push(new FestivalCustom(customName2,customIntroduction2));
customName3 = '寺院施粥';
customIntroduction3 = '许多佛教寺院会在腊八节当天向僧众和百姓施舍腊八粥，象征慈悲、布施与功德。';
custom.push(new FestivalCustom(customName3,customIntroduction3));
customName4 = '准备年获';
customIntroduction4 = '民间有“过了腊八就是年”的说法，腊八节后，人们开始陆续打扫房屋、置办年货，为春节做准备。';
custom.push(new FestivalCustom(customName4,customIntroduction4));
customName5 = '泡腊八蒜';
customIntroduction5 = '在北方部分地区，人们会在腊八这一天把大蒜浸泡在醋中，制成腊八蒜，寓意来年精打细算、日子红火。';
custom.push(new FestivalCustom(customName5,customIntroduction5));
culturalSignificance = '腊八节在中国传统节日体系中具有承前启后的重要意义。它既是对过去一年辛勤劳作的总结，也是春节到来前的重要心理准备阶段。\n' +
  '\n' +
  '通过祭祀、施粥和家庭饮食等方式，腊八节强化了人与自然、人与社会以及人与信仰之间的联系，体现了中国传统文化中感恩、祈福与共享的价值观。\n' +
  '\n' +
  '即便在现代社会，腊八节仍以温暖、朴素的方式存在于人们的生活中，成为岁末时节最具人情味的节日之一。';
festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Laba.png'),festivalName,festivalEnglishName,
simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['腊八节'] = festivalDetailInfo;
custom = [];

//情人节
//情人节
festivalName = '情人节';
festivalEnglishName = "Valentine's Day";
simpleIntroduction = '情人节通常指每年2月14日的节日，是表达爱意与浪漫的日子。人们会通过送花、巧克力、礼物、约会或写卡片等方式向恋人、伴侣或心仪的人表达情感，也逐渐延伸为对亲情与友情的温暖表达。';
fullDescription = '情人节（Valentine\'s Day）在每年2月14日，是世界范围内广为流行的浪漫节日。它常被视为表达爱情、传递心意的重要时刻，人们会用鲜花、巧克力、贺卡、礼物以及精心安排的约会来表达“我在乎你”。\n' +
  '\n' +
  '在现代语境中，情人节的意义早已不局限于恋人之间：许多地方也会把它视作表达感谢与关怀的契机，比如向伴侣说一声辛苦、向家人表达爱、向朋友表达珍惜。与此同时，不同文化与地区也形成了各自的庆祝方式：有的更重视送花，有的更强调写卡片和情书，有的则会把它当作一次认真沟通、增进亲密关系的“仪式感”节点。\n' +
  '\n' +
  '需要注意的是，情人节并不是衡量感情的唯一标准，但它为忙碌的生活提供了一个“停下来好好表达”的机会。无论是隆重的浪漫安排，还是一句真诚的祝福、一顿家常饭，都可以成为这一天最动人的部分。';
originPeriod = '古罗马时期的传说与习俗背景，后在中世纪欧洲逐渐发展为“爱情纪念日”，近现代全球化传播并商业化普及';
originStory = '关于情人节的起源，民间最常见的说法与“圣瓦伦丁（Saint Valentine）”有关。相传在古罗马时期，有一位名叫瓦伦丁的神父（或主教）因坚持信仰与善行而闻名。传说中他曾帮助有情人、鼓励真挚的婚恋与承诺，因此在被处决后，人们以他的纪念日来象征忠贞与爱情。\n' +
  '\n' +
  '此外，情人节也常被认为与古罗马的春季庆典传统存在关联：在冬末春初，人们通过节庆活动迎接新生与希望，这种“春天与爱情相连”的观念在欧洲文化中长期存在。\n' +
  '\n' +
  '到了中世纪，欧洲文学与民俗进一步强化了2月与“求偶、爱恋”的联系，写情书、交换信物等做法逐渐流行。进入近现代后，印刷贺卡、巧克力与鲜花等礼赠形式让情人节更易被大众参与，并随着文化传播在全球范围内广泛流行。';
originBackground = '情人节的形成既与宗教纪念传说有关，也与欧洲地区春季来临时对“生命复苏、爱情萌发”的文化想象相联系。随着城市生活与商业体系发展，情人节逐渐从区域性节庆演变为大众化的情感表达节日。\n' +
  '\n' +
  '在现代社会，情人节更多承担“情感沟通的时间节点”功能：它提醒人们在快节奏生活里主动表达爱与感谢。与此同时，媒体与消费文化也推动了鲜花、巧克力、贺卡、餐饮与旅行等场景的发展，使情人节在社会生活中形成稳定的仪式感与消费习惯。';
keyFigures = [
  "圣瓦伦丁（Saint Valentine）",
  "古罗马时期的民间传说人物",
  "中世纪欧洲的文学与民俗传播者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '赠送鲜花';
customIntroduction1 = '情人节赠送鲜花是最经典的表达方式之一，其中玫瑰最具代表性。不同颜色的花常被赋予不同含义：红玫瑰象征热烈的爱，粉色更偏温柔与心动，白色寓意纯洁与真诚。很多人会在花束中附上一张手写卡片，用更私人、更具体的话表达心意，让礼物不只是“形式”，而是有温度的情感传递。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '送巧克力与甜点';
customIntroduction2 = '巧克力在情人节常被视为“甜蜜与心动”的象征，尤其适合作为轻量但有仪式感的礼物。人们会挑选对方喜欢的口味，或选择礼盒装、定制刻字等方式提升独特性。除了巧克力，手作甜点、饼干、蛋糕也很受欢迎——亲手制作本身就是一种用时间与心意表达爱的方法。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '写贺卡或情书';
customIntroduction3 = '写贺卡、情书是情人节最“走心”的传统之一。相比模板化的祝福语，一段回忆、一个细节、一次认真表达更能让人感到被重视。很多人会在卡片里写下相识的故事、欣赏对方的原因、对未来的期待，甚至把平时难以开口的话在这一天说出来，让情感沟通更坦诚、更有力量。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '约会与仪式感安排';
customIntroduction4 = '情人节的约会常见形式包括共进晚餐、看电影、散步、逛展、短途旅行等。很多人会在这一天提前做一些“仪式感”的准备：预订餐厅、安排惊喜、准备小礼物、拍纪念照。其实仪式感不一定昂贵，关键在于“专注陪伴”——认真留出时间、好好倾听、一起创造新的回忆，往往比任何礼物都更珍贵。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '表达感谢与关怀';
customIntroduction5 = '在现代语境中，情人节也逐渐被一些人当作表达“感谢与关怀”的日子：对伴侣说一句辛苦了，对家人表达爱，对朋友表达珍惜。有人会选择做一顿饭、写一段感谢的话、送一本书或一份小小的心意。它的核心并不在于形式，而在于让关系变得更温暖、更有回应，让爱不仅停留在心里，也能被对方真实感受到。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '情人节的文化意义在于为情感表达提供了一个被社会共同认可的时间节点。它提醒人们在日常忙碌中停下来，认真表达爱、欣赏与感谢，让亲密关系获得“被看见”的机会。\n' +
  '\n' +
  '从更广的层面看，情人节也反映了现代社会对情感价值的重视：通过礼物、语言与行动，人们学习更直接、更积极地沟通需求与感受，建立更健康的关系边界与相处方式。\n' +
  '\n' +
  '同时，情人节也具有一定的公共文化属性——它让“浪漫”成为一种可被讨论与实践的生活方式。无论是恋人之间的郑重承诺，还是对家人朋友的真诚关怀，情人节最终指向的，都是对爱与连接的肯定。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Qingren.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['情人节'] = festivalDetailInfo;
custom = [];

//除夕
festivalName = '除夕';
festivalEnglishName = "Chinese New Year's Eve";
simpleIntroduction = '除夕是农历一年的最后一天，是辞旧迎新的重要时刻，也是春节庆祝活动的高潮开端。人们在这一天团圆守岁、贴春联、吃年夜饭、祭祖祈福，以最隆重的仪式感迎接新年的到来。';
fullDescription = '除夕，指农历腊月的最后一天，是一年岁末的“收官日”，也是春节庆祝活动中最具仪式感与情感温度的一天。“除”有去旧之意，“夕”指夜晚，合起来就是“辞旧迎新之夜”。\n' +
  '\n' +
  '在传统观念里，除夕不仅仅是一个日期，更像是一道重要的时间门槛：过去一年的辛劳、收获与遗憾在这一天得到总结；而对来年的期盼、祝福与愿望也在这一天集中表达。家家户户忙着扫尘收拾、张贴春联与福字、备办年夜饭，空气里充满“要过年了”的热闹与期待。\n' +
  '\n' +
  '除夕最核心的活动是“团圆”与“守岁”。年夜饭把一家人聚在同一张桌上，象征团圆、和睦与丰盛；守岁则是用灯火与陪伴迎接新年到来，寓意延年益寿、驱邪避灾。许多家庭还会在除夕祭祖或祭神，表达对祖先的追思与对来年平安的祈愿。\n' +
  '\n' +
  '现代生活方式让除夕的形式有所变化，但它承载的情感并没有变：无论是在家团聚、视频连线，还是异地相聚的短暂重逢，除夕始终是中国人心里最重的“团圆夜”。';
originPeriod = '上古岁末祭祀与年终礼俗逐渐形成，秦汉以后相关习俗更加稳定并代代相传';
originStory = '除夕的习俗源远流长，与中国古代“岁末祭祀、驱疫逐鬼、迎接新岁”的礼俗传统密切相关。古人认为一年将尽之时，既要感谢天地神灵与祖先的庇佑，也要通过仪式驱除旧年的不祥，迎接新年的吉庆。\n' +
  '\n' +
  '关于“年”的民间传说也常与除夕联系在一起。相传有一种叫“年”的怪兽会在岁末出没，伤人毁物。后来人们发现“年”惧怕红色、火光与巨响，于是便在除夕张贴红色饰物、点灯燃火、敲锣打鼓（后来发展为爆竹烟火），以此驱赶不祥、祈求平安。这一传说虽属民间想象，却形象解释了“贴红、守岁、爆竹”等习俗背后的心理与象征。\n' +
  '\n' +
  '随着历代节日体系逐渐完善，除夕作为春节的前夜被固定下来，并成为家庭团聚、祭祖祈福、辞旧迎新的核心时间点，延续至今。';
originBackground = '除夕的形成与农耕社会的时间节律高度一致：一年农事完成、储粮入仓、家计盘点，人们在岁末集中进行祭祀与庆祝活动，以表达感恩、祈愿与团结。\n' +
  '\n' +
  '同时，古代社会重视家族与宗法秩序，岁末团圆与祭祖能强化家族凝聚力与身份认同。加之“驱疫避邪、迎祥纳福”的传统信仰，除夕逐渐发展为集“团聚、祭祀、礼仪、娱乐”于一体的综合性节俗。即便进入现代，除夕仍承担着强烈的情感功能：让离散的人回家，让关系重新靠近，让新年从“团圆”开始。';
keyFigures = [
  "古代先民（岁末祭祀与驱疫传统）",
  "民间传说中的“年”",
  "历代家庭与宗族（团圆祭祖的实践者）"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '吃年夜饭';
customIntroduction1 = '年夜饭是除夕最重要的家庭活动之一，讲究“团圆”和“丰盛”。一家人围坐一桌，共享一年的成果，也在饭桌上完成情感的回归与确认。不同地区的年夜饭各有特色：北方常见饺子，寓意“更岁交子”；南方可能有年糕、鱼、鸡鸭等菜肴，象征“年年高”“年年有余”“大吉大利”。很多家庭还会特意留下一些菜不吃完，寓意新一年有剩余、有积累。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '贴春联与福字';
customIntroduction2 = '除夕贴春联、贴福字是迎新纳福的标志性仪式。春联多写在红纸上，表达对新年的祝愿与期盼；“福”字则象征福气与好运，有些地方会把“福”倒着贴，取“福到了”的谐音。张贴的过程本身也很有仪式感：擦干净门框、对齐位置、从上到下抹平，仿佛把一年的好运认真“贴”进家门。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '守岁';
customIntroduction3 = '守岁是除夕夜的传统习俗，指一家人熬夜迎接新年到来。传统观念认为守岁能“辞旧迎新、延年益寿”，也象征家人团聚不散。守岁的方式可以很丰富：聊天叙旧、看春晚、玩牌下棋、吃零食水果、给孩子讲故事等。对很多人来说，守岁最动人的不是一定要熬到很晚，而是“大家都在一起”的陪伴感。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '祭祖祈福';
customIntroduction4 = '在不少地区，除夕会进行祭祖或祭神仪式，表达对祖先的追思与敬意，也祈求家宅平安、来年顺利。祭祀形式因地而异，可能包括摆供品、上香、敬酒、行礼等。对现代家庭而言，这既是一种传统延续，也是一种情感连接：提醒家人不忘来处，珍惜当下团圆，并把对未来的愿望郑重托付给新年的开始。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '放爆竹与迎新';
customIntroduction5 = '放爆竹（或鸣放烟花）是除夕夜常见的迎新方式，寓意用“红火与响亮”驱赶晦气、迎来吉祥。过去爆竹多用于“驱邪避灾”的象征，如今更多是节日氛围与庆祝表达。部分城市会有禁放规定，很多家庭会改用电子鞭炮、灯笼、音乐或倒计时等方式营造氛围——无论形式如何变化，“迎新”的快乐与祝福是相同的。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '除夕在中国节日文化中具有独特的核心地位：它把“时间的结束与开始”浓缩在同一夜晚，让人们以最隆重的方式告别旧岁、迎接新年。\n' +
  '\n' +
  '从家庭层面看，除夕是团圆与修复关系的时刻。人们跨越距离回到同一张饭桌前，用陪伴与分享重新连接彼此；从社会层面看，除夕是共同的文化记忆与情感坐标，它让不同地区、不同年龄的人在同一时间点产生共鸣。\n' +
  '\n' +
  '除夕还承载着中国传统文化中的“感恩与祈愿”精神：感谢过去一年的庇佑，祈求来年顺遂安康。即使生活方式不断改变，除夕依然以“团圆夜”的形式，延续着中国人对家、对亲情、对新生活的深情期待。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Chuxi.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['除夕'] = festivalDetailInfo;
custom = [];

//春节
festivalName = '春节';
festivalEnglishName = 'Spring Festival';
simpleIntroduction = '春节是中国最重要、最隆重的传统节日，通常指农历正月初一及其前后的一系列庆祝活动。它象征着辞旧迎新、阖家团圆和新的开始，是中国人情感与文化认同最集中的节日。';
fullDescription = '春节，又称农历新年，是中国传统节日体系中的核心节日，通常从除夕开始，一直延续到正月十五元宵节结束。春节不仅是时间意义上的一年之始，更是一整套涵盖祭祀、礼仪、饮食、娱乐与社交的综合性节日体系。\n' +
  '\n' +
  '在传统社会中，春节标志着旧岁结束、新岁开启，是农耕社会最重要的时间节点之一。人们在春节期间通过贴春联、放鞭炮、吃年夜饭、拜年、祭祖等方式，集中表达对过去一年的总结、对祖先的敬意以及对未来生活的美好期盼。\n' +
  '\n' +
  '春节最突出的主题是“团圆”。无论身在何处，人们都尽力在春节前返乡，与家人共度佳节。这种跨越地域的回归，使春节成为中国社会中规模最大、情感最浓厚的集体性节日。\n' +
  '\n' +
  '随着时代发展，春节的庆祝方式不断变化，但其核心精神始终未变：珍视家庭、重视亲情、祈求平安、迎接希望。正因如此，春节不仅是一个节日，更是一种深植于中国人心中的文化记忆与生活方式。';
originPeriod = '上古农耕社会形成雏形，汉代以后逐渐定型并成为岁首最重要的节日';
originStory = '春节的起源可以追溯到上古时期的岁首祭祀活动。古人根据农事周期，在一年结束和新一轮生产开始之际，举行祭祀天地、祖先和神灵的仪式，以祈求来年风调雨顺、五谷丰登。\n' +
  '\n' +
  '关于春节的民间传说中，“年”的故事流传最广。相传“年”是一种在岁末出没的怪兽，会危害人畜。后来人们发现它惧怕红色、火光和巨响，于是在春节期间贴红纸、点灯火、放爆竹，以此驱赶“年”。这一传说虽带有神话色彩，却生动解释了春节诸多习俗的象征意义。\n' +
  '\n' +
  '随着历法的统一和礼制的发展，春节逐渐被固定为农历正月初一，并在历代演变中不断吸收新的习俗内容，最终形成今天这样内容丰富、周期较长的传统节日体系。';
originBackground = '春节的形成与中国传统农耕社会的生产方式密切相关。农历新年位于冬去春来的关键节点，既是农事休整期，也是筹划新一年生产的重要时刻。\n' +
  '\n' +
  '同时，中国社会长期以家族和宗族为核心，春节期间的祭祖、团圆和拜年活动，有助于巩固家庭结构与社会关系网络。加之对吉凶祸福的民间信仰，春节逐渐发展为集时间更新、情感凝聚和文化传承于一体的综合性节日。';
keyFigures = [
  "古代先民（岁首祭祀的实践者）",
  "民间传说中的“年”",
  "历代家庭与宗族成员"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '贴春联和年画';
customIntroduction1 = '贴春联和年画是春节最具象征意义的习俗之一。春联多书写在红纸上，内容以祈福、纳吉、迎新为主题，表达对新一年的祝愿；年画则常描绘吉祥人物、丰收场景或民间故事。张贴这些装饰不仅能增添节日气氛，也象征着把美好愿望“请”进家门，让新的一年从视觉与心理上都焕然一新。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '拜年';
customIntroduction2 = '拜年是春节期间重要的社交礼俗，人们会在正月初一开始走亲访友，向长辈、亲友和邻里表达新年的祝福。拜年时讲究吉利话，避免不祥之言，以示对新一年的尊重与期待。通过拜年，亲情、友情与邻里关系得以重新连接和巩固，是春节维系社会关系的重要方式。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '发压岁钱';
customIntroduction3 = '压岁钱是春节期间长辈赠予晚辈的红包，寓意驱邪避灾、保佑平安。传统观念中，压岁钱象征着长辈对晚辈的祝福与关爱。随着时代变化，压岁钱的形式从铜钱、纸币发展到电子红包，但其背后的情感内涵依然是关心、祝愿与传承。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '放鞭炮和烟花';
customIntroduction4 = '放鞭炮和烟花是春节期间极具节庆气氛的活动，寓意驱邪避灾、迎祥纳福。震耳的声响和绚丽的火光象征着新年的红火与兴旺。尽管现代城市对燃放有所限制，但人们依然通过倒计时、灯光秀或电子鞭炮等方式延续“迎新”的仪式感。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '祭祖';
customIntroduction5 = '春节期间祭祖是许多家庭的重要仪式，人们通过上香、供奉食物和行礼，表达对祖先的怀念与敬意。祭祖不仅是对家族历史的回顾，也是提醒后代不忘根本、珍惜团圆的一种文化实践，使春节成为连接过去、现在与未来的重要纽带。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '春节在中国文化中具有无可替代的地位，它是时间更新、情感凝聚和文化传承的集中体现。\n' +
  '\n' +
  '从个体层面看，春节是回家与团圆的象征，让人们在忙碌生活中重新确认家庭与亲情的重要性；从社会层面看，春节通过统一的节奏和习俗，增强了群体认同感和文化归属感。\n' +
  '\n' +
  '更深层次上，春节承载着中国人对“新开始”的理解：在辞旧迎新的仪式中，人们学会告别过去、修复关系、重建希望。正因如此，春节不仅是一个节日，更是一种延续千年的生活哲学。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Chunjie.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['春节'] = festivalDetailInfo;
custom = [];

//元宵节
festivalName = '元宵节';
festivalEnglishName = 'Lantern Festival';
simpleIntroduction = '元宵节是中国传统节日之一，时间为农历正月十五，是春节庆祝活动的收官之日。人们通过赏花灯、吃元宵、猜灯谜等方式，表达对团圆、美满和幸福生活的祝愿。';
fullDescription = '元宵节，又称上元节、小正月，是农历新年的第一个月圆之夜，通常在正月十五举行。作为春节节庆周期中的最后一个重要节日，元宵节既承接了春节的喜庆氛围，也象征着新一年生活逐步回归日常。\n' +
  '\n' +
  '在传统观念中，“月圆”寓意着团圆与圆满，因此元宵节自古以来就与家庭团聚、美好祝愿紧密相连。夜晚张灯结彩、灯火通明，使这一节日具有鲜明的夜间庆祝特征，也让元宵节在众多传统节日中显得格外热闹与浪漫。\n' +
  '\n' +
  '元宵节的活动内容丰富多样，既有民间娱乐，也包含宗教与礼俗因素。赏灯、猜灯谜体现了智慧与趣味的结合；吃元宵则寄托了人们对团圆和甜美生活的向往。随着历史演变，元宵节逐渐发展为全民参与的综合性节日。\n' +
  '\n' +
  '即便在现代社会，元宵节依然保留着强烈的节日氛围。它不仅是春节的结束标志，也是一种温和而喜庆的过渡，让人们在欢庆中开启新一年的生活节奏。';
originPeriod = '汉代形成并逐渐定型，唐宋时期达到兴盛并广泛流传';
originStory = '关于元宵节的起源，历史上有多种说法。其中一种观点认为，元宵节与汉代的宫廷祭祀活动有关。汉武帝时期，人们在正月十五祭祀“太一神”，并在夜间张灯以示隆重，这种活动逐渐传入民间，形成赏灯习俗。\n' +
  '\n' +
  '另一种说法认为，元宵节与佛教文化的传播有关。佛教中有正月十五燃灯供佛的传统，随着佛教在中国的发展，这一习俗与民间节庆相结合，演变为张灯结彩的节日活动。\n' +
  '\n' +
  '在民间传说中，也有关于天帝、灯火与祈福的故事，用以解释元宵节张灯、庆祝的由来。尽管说法不一，但都反映了人们通过灯火与仪式祈求平安、吉祥的共同愿望。';
originBackground = '元宵节的形成与中国古代社会的时间观念和宗教信仰密切相关。正月十五处于春节之后、农事尚未全面展开之前，是适合举行集体庆祝和娱乐活动的时期。\n' +
  '\n' +
  '同时，夜间张灯既具有驱邪避灾、祈福纳吉的象征意义，也满足了民众在节庆期间社交、娱乐和情感交流的需求。随着城市发展和市井文化兴盛，元宵节逐渐演变为全民参与的灯会与娱乐盛会。';
keyFigures = [
  "汉武帝（宫廷祭祀背景）",
  "佛教僧侣（燃灯习俗传播者）",
  "民间节俗的传承者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '赏花灯';
customIntroduction1 = '赏花灯是元宵节最具代表性的活动之一。节日期间，大街小巷张灯结彩，各式各样的彩灯高悬或陈列，有动物造型、人物故事、吉祥图案等。灯火通明不仅营造出热闹喜庆的氛围，也象征着光明、希望与新一年生活的红火开局。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '吃元宵（汤圆）';
customIntroduction2 = '元宵节食用元宵或汤圆，寓意团圆和美满。元宵多为甜馅，外圆内实，象征家庭完整、感情圆融。不同地区在称呼和做法上略有差异，但“圆圆满满”的祝愿是共同的文化内涵。许多家庭会在这一天一起煮元宵、共进晚餐，使节日更具家庭温度。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '猜灯谜';
customIntroduction3 = '猜灯谜是元宵节富有趣味性和文化气息的传统活动。人们将谜语写在纸条上悬挂于彩灯之下，供大家竞猜。灯谜内容涵盖文字、历史、生活常识等，不仅增加节日互动性，也体现了中华传统文化中对智慧与才思的欣赏。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '民俗表演';
customIntroduction4 = '在一些地区，元宵节还会举行舞龙舞狮、踩高跷、扭秧歌等民俗表演。这些活动通常在夜晚进行，与花灯相互映衬，场面热闹非凡。民俗表演既是节日娱乐的重要组成部分，也承载着祈福、驱邪和庆祝丰收的象征意义。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '走亲访友';
customIntroduction5 = '元宵节期间，人们常会走亲访友，互致节日祝福。作为春节后的最后一个重要节日，这种走动既是对节庆的延续，也让亲情与友情在轻松、欢乐的氛围中得到巩固，为新一年的社交生活奠定良好开端。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '元宵节在中国传统节日体系中具有“收官”和“圆满”的象征意义。它以月圆、灯明和团聚为主题，为春节画上温暖而喜庆的句号。\n' +
  '\n' +
  '从文化层面看，元宵节体现了中国人对圆满、和谐与共享欢乐的追求。通过赏灯、猜谜和家庭聚会，人们在轻松愉快的氛围中完成从节庆到日常生活的过渡。\n' +
  '\n' +
  '即使在现代社会，元宵节依然保有浓厚的人情味和参与感。它提醒人们珍惜团圆、享受当下，也为新一年的生活注入明亮而温和的希望。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Yuanxiao.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['元宵节'] = festivalDetailInfo;
custom = [];

//妇女节
festivalName = '妇女节';
festivalEnglishName = "International Women's Day";
simpleIntroduction = '妇女节是每年3月8日的国际性节日，旨在肯定女性在社会、家庭与历史发展中的贡献，并倡导性别平等与女性全面发展。';
fullDescription = '妇女节，全称国际劳动妇女节，是一个具有深刻社会意义的节日。它起源于20世纪初女性争取平等权利的社会运动，最初关注劳动条件、政治权利和社会地位，后来逐渐发展为全球共同纪念的节日。\n' +
  '\n' +
  '在当代社会，妇女节不仅是对女性历史贡献的回顾，也是对现实处境的关注。女性在家庭、职场和社会中承担着多重角色，这一天为她们的付出提供了一个被认真看见和肯定的时刻。\n' +
  '\n' +
  '同时，妇女节也提醒社会持续思考性别平等、尊重差异与机会公平的问题。它既是一种祝福性的节日，也是一种具有现实意义的公共议题节点。';
originPeriod = '20世纪初国际妇女运动时期';
originStory = '妇女节起源于20世纪初欧美国家的妇女运动。1908年前后，女性工人和社会活动家为争取合理劳动条件、选举权和社会尊重而发起集会和示威。1910年，国际社会主义妇女大会正式提出设立妇女节的倡议。\n' +
  '\n' +
  '1911年起，多个国家开始在固定日期举行妇女节纪念活动。随后，3月8日逐渐被国际社会广泛接受，成为全球性的妇女节。';
originBackground = '工业化进程中，女性在劳动、教育和政治参与方面长期处于不利地位。妇女节正是在争取平等权利、改善社会结构的背景下诞生的，具有鲜明的时代特征和现实意义。\n' +
  '\n' +
  '在现代社会，妇女节也承担着公共讨论的功能：它提醒人们关注女性在职场发展、家庭分工、教育机会与健康保障等方面的现实问题，推动更公平、更友好的社会环境。';
keyFigures = [
  "克拉拉·蔡特金",
  "早期妇女运动参与者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '表达尊重与祝福';
customIntroduction1 = '妇女节当天，人们通常会向身边的女性表达祝福与尊重，例如送花、写祝福卡或送上一句真诚的问候。这种表达不仅是一种节日形式，更是对女性在家庭和社会中长期付出的认可。\n' +
  '\n' +
  '很多时候，礼物的价值不在于价格，而在于是否“走心”。一句具体的感谢（比如感谢她过去一年做过的某件事）、一次认真倾听、一次温柔的拥抱，都可能比任何礼物更让人感到被看见、被理解。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '单位或组织关怀活动';
customIntroduction2 = '在妇女节期间，许多单位和组织会为女性安排关怀活动，如健康讲座、心理减压活动、主题座谈、团建体验或发放节日福利。这类活动既能营造尊重女性的氛围，也让女性在忙碌工作之余获得放松和支持。\n' +
  '\n' +
  '一些组织还会在这一天开展“女性成长”主题分享，邀请不同岗位的女性交流经验，帮助更多人获得职业与生活的启发，形成互相支持的正向社区。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '关注女性健康与成长';
customIntroduction3 = '妇女节也是关注女性身心健康与自我成长的重要节点。媒体和社会机构常围绕女性健康管理、心理关怀、职业规划、家庭关系等话题开展宣传与科普，引导女性更重视自我关照。\n' +
  '\n' +
  '对个人而言，这一天也很适合做一次“自我复盘”：比如给自己安排体检、学习一个新技能、整理生活计划，或者只是好好休息一晚，把时间留给自己——这同样是一种对自己的尊重。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '家庭中的感谢与分担';
customIntroduction4 = '在家庭层面，妇女节也常被视为表达感谢与理解的机会。家人可以通过分担家务、照顾孩子、准备一顿饭或安排一次轻松出行，让女性感受到被支持与被体贴。\n' +
  '\n' +
  '更重要的是，这种分担不应只停留在节日当天。很多家庭会把妇女节当作一个提醒：重新讨论家庭分工、尊重彼此的劳动与时间，让关系更平等、更可持续。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '公益倡导与女性议题讨论';
customIntroduction5 = '一些地方会在妇女节开展公益活动或女性议题倡导，比如反家暴宣传、女性教育支持、就业平等倡议等。通过讨论与行动，让更多人理解“尊重女性”不仅是口号，更需要制度、观念与日常行为的共同改变。\n' +
  '\n' +
  '这类活动也让妇女节超越“送礼祝福”的层面，回到它更深的社会意义：让每个人都能在更公平、更安全的环境里生活与发展。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '妇女节的文化意义不仅在于庆祝，更在于提醒社会持续关注女性价值与性别平等。它让女性的付出被看见，也促使社会反思制度与观念中仍然存在的不平等现象。\n' +
  '\n' +
  '从更长远的角度看，妇女节象征着社会文明的进步方向：尊重个体、承认差异、追求公平。它既是对过去奋斗的纪念，也是对未来持续努力的提醒。\n' +
  '\n' +
  '在日常生活中，妇女节也提供了一个温柔而具体的契机：让我们更认真地表达感谢、更主动地分担责任、更坚定地支持每一位女性成为自己想成为的人。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Funv.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['妇女节'] = festivalDetailInfo;
custom = [];

//植树节
festivalName = '植树节';
festivalEnglishName = 'Arbor Day';
simpleIntroduction = '植树节是倡导植树造林、保护生态环境的重要节日，提醒人们通过实际行动改善自然环境、推动人与自然和谐共生。';
fullDescription = '植树节是以植树造林和生态保护为主题的节日，在中国定于每年3月12日。这一节日通过倡导全民参与植树活动，增强公众的环保意识，推动绿色发展理念深入人心。\n' +
  '\n' +
  '在传统农业社会中，人们早已认识到树木在保持水土、调节气候和提供资源方面的重要作用。进入现代社会后，随着工业化和城市化进程加快，生态环境问题逐渐凸显，植树节的现实意义愈发突出。\n' +
  '\n' +
  '植树节不仅关注“种树”这一行为本身，更强调长期保护、科学养护和可持续利用。它提醒人们：生态环境的改善并非一朝一夕之功，而需要持续的投入与责任意识。';
originPeriod = '近代生态保护意识兴起时期（20世纪初）';
originStory = '中国植树节的设立与孙中山先生倡导的植树造林思想密切相关。孙中山十分重视森林资源保护，曾多次提出通过植树改善生态环境的主张。\n' +
  '\n' +
  '为纪念孙中山先生对国家建设和生态保护的贡献，后来将其逝世日3月12日确定为中国的植树节，并逐步推广为全民参与的环保节日。';
originBackground = '随着近代工业发展和人口增长，森林资源破坏、水土流失等问题日益突出。植树节正是在这一背景下产生，旨在通过制度化的节日形式，唤起社会对生态保护和可持续发展的重视。';
keyFigures = [
  "孙中山",
  "近代生态保护倡导者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '植树造林活动';
customIntroduction1 = '植树造林是植树节最核心的习俗。人们在这一天参与种树活动，通过亲手挖坑、栽苗、培土和浇水，将“绿色”真正种进土地之中。对许多人来说，这不仅是一项体力劳动，更是一种参与公共事务、为未来环境负责的象征性行动。\n' +
  '\n' +
  '在集体植树中，人们也能直观感受到合作的重要性：一棵树的成长需要时间，而一片森林的形成更离不开长期坚持和群体努力。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '环保宣传与生态教育';
customIntroduction2 = '植树节期间，学校、社区和媒体常会开展环保主题宣传与生态教育活动，通过讲座、展览、科普文章等形式，向公众普及森林生态系统的重要性。\n' +
  '\n' +
  '这些活动不仅帮助人们理解植树造林在防风固沙、保持水土、改善空气质量方面的作用，也引导公众反思日常生活中的资源消耗行为，从而形成更加绿色、低碳的生活方式。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '认养与长期养护树木';
customIntroduction3 = '在一些地区，植树节还衍生出“认养树木”的习俗。个人或家庭可以认养一棵树，定期进行浇水、修剪和养护，使植树行为从“一次性活动”转变为长期责任。\n' +
  '\n' +
  '这种方式强化了人与自然之间的情感连接，让人们在树木的成长过程中感受到时间与生命的延续，也更容易在日常生活中形成珍惜自然、保护环境的自觉意识。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '绿色生活实践';
customIntroduction4 = '植树节也被视为反思和调整生活方式的契机。许多人会在这一天开始实践更加环保的行为，如减少一次性用品使用、进行垃圾分类、选择公共交通或参与志愿环保活动。\n' +
  '\n' +
  '虽然这些行为看似与“种树”并不直接相关，但它们共同指向一个目标：通过改变个人选择，减少对环境的长期压力，让绿色理念真正融入日常生活。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

culturalSignificance = '植树节的文化意义在于强调人与自然的责任关系。它通过具体、可参与的行动，让生态保护不再停留在口号层面，而是落实到每个人的实践之中。\n' +
  '\n' +
  '从更广的视角看，植树节体现了现代社会对可持续发展的共识：经济发展不应以破坏环境为代价，而应在尊重自然规律的基础上实现长期繁荣。\n' +
  '\n' +
  '因此，植树节不仅是一个环保主题的节日，更是一种面向未来的生活态度提醒。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Zhishu.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['植树节'] = festivalDetailInfo;
custom = [];

//龙头节
festivalName = '龙头节';
festivalEnglishName = 'Dragon Head-Raising Day';
simpleIntroduction = '龙头节是中国传统民俗节日，时间为农历二月初二，民间称为“二月二”。人们认为这一天龙抬头、春回大地，象征万物复苏和一年农事的开始。';
fullDescription = '龙头节，又称“二月二”，在中国传统农耕文化中具有重要意义。民间相信龙主掌降雨，二月初二龙抬头，意味着雨水渐多、气候转暖，适宜春耕生产，因此被视为农事活动的重要起点。\n' +
  '\n' +
  '在长期的民俗发展过程中，龙头节逐渐形成了丰富多样的习俗内容，既包含对自然节律的敬畏，也融入了人们对生活吉祥、事业顺遂的美好期待。与春节相比，龙头节的气氛更加贴近生活，强调顺时而作、踏实开启新一年的劳作。\n' +
  '\n' +
  '即便在现代社会，龙头节依然以朴素而具体的方式存在于民间生活之中，成为连接传统农耕观念与当代生活节奏的重要节日节点。';
originPeriod = '古代农耕社会时期形成，历代民俗中不断丰富';
originStory = '关于龙头节的起源，民间普遍流传“龙抬头”的说法。相传龙在冬季潜伏休养，到了农历二月初二，随着春雷乍响，龙从沉睡中苏醒并抬头升天，开始行云布雨，滋养万物。\n' +
  '\n' +
  '因此，人们将这一天视为新一年农业生产和生活运势的转折点，通过各种象征性的习俗活动，祈求风调雨顺、五谷丰登。';
originBackground = '在传统农业社会中，生产活动高度依赖降水和气候变化。龙作为掌管风雨的神兽形象，承载了人们对自然力量的想象与敬畏。龙头节正是在这种农耕文化与自然信仰的背景下逐渐形成并流传下来。';
keyFigures = [
  "民间传说中的龙",
  "古代农耕社会的劳动者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '理发剃龙头';
customIntroduction1 = '龙头节理发被称为“剃龙头”，被认为可以去旧迎新、带来好运。民间有“正月不剃头，二月二剃龙头”的说法，象征告别春节期间的旧状态，正式开启新一年的生活与工作。\n' +
  '\n' +
  '这一习俗不仅带有祈吉避凶的意味，也在现实层面上标志着从节日状态回归日常节奏，具有鲜明的时间节点意义。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '吃“龙食”';
customIntroduction2 = '在龙头节，许多地方会通过饮食来寄托吉祥寓意，如吃面条称为“吃龙须”，吃饺子称为“吃龙耳”，吃春饼称为“吃龙鳞”。\n' +
  '\n' +
  '这些称呼虽然带有象征意味，但本质上是借助日常饮食表达对健康、顺遂和丰收的祝愿，让节日氛围融入普通家庭的一日三餐之中。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '引龙祈雨';
customIntroduction3 = '在一些传统地区，龙头节曾有“引龙”或“祭龙”的习俗，通过简单的仪式或象征性活动，祈求龙神行云布雨，保佑农作物生长。\n' +
  '\n' +
  '尽管现代社会已不再依赖此类仪式，但这一习俗反映了古人顺应自然、尊重自然规律的思想，也体现了人与自然之间的精神联系。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '开始春耕与劳作';
customIntroduction4 = '龙头节在民间常被视为春耕的象征性起点。过了这一天，人们开始准备农具、整理田地，正式投入到新一年的劳作之中。\n' +
  '\n' +
  '即使在非农业社会环境中，龙头节依然被一些人当作“行动起来”的提醒，象征结束冬日的停歇状态，重新投入学习、工作和生活计划。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

culturalSignificance = '龙头节在中国传统节日体系中体现了浓厚的农耕文化特征。它通过“龙抬头”的象征形象，将自然变化、生产节律和人们的生活愿望紧密联系在一起。\n' +
  '\n' +
  '从文化层面看，龙头节强调顺应天时、脚踏实地地开启新一年。这种观念在现代社会依然具有现实意义：尊重自然规律，合理安排节奏，才能实现长期稳定的发展。\n' +
  '\n' +
  '因此，龙头节不仅是一个民俗节日，更是一种关于时间、自然与生活态度的文化提醒。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Longtou.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['龙头节'] = festivalDetailInfo;
custom = [];

//愚人节
festivalName = '愚人节';
festivalEnglishName = "April Fools' Day";
simpleIntroduction = '愚人节是每年4月1日的趣味性节日，人们在这一天通过善意的玩笑和幽默互动，为生活增添轻松与欢乐的氛围。';
fullDescription = '愚人节，又称万愚节，是一个以幽默和玩笑为主题的节日，时间固定在每年的4月1日。与许多具有严肃历史背景的节日不同，愚人节本身并不强调纪念意义，而更侧重于情绪调节和社交互动。\n' +
  '\n' +
  '在愚人节这一天，人们会通过设计玩笑、制造“误会”或发布假消息来捉弄他人，但前提通常是无伤大雅、点到为止。这种行为在一定程度上打破了日常生活中的严肃感，使人与人之间的交流更加轻松。\n' +
  '\n' +
  '随着媒体和互联网的发展，愚人节的形式也不断变化，从个人之间的小玩笑，扩展到品牌、媒体甚至公共机构参与的创意互动。尽管形式多样，但愚人节的核心精神始终是幽默、善意和娱乐，而非欺骗或伤害。';
originPeriod = '中世纪欧洲时期';
originStory = '关于愚人节的起源，历史上并没有统一定论。一种较为流行的说法认为，它与欧洲历法改革有关。当新年日期调整后，仍沿用旧习的人被戏称为“愚人”，并逐渐演变为玩笑传统。\n' +
  '\n' +
  '另一种观点认为，愚人节源于欧洲民间的春季庆祝活动，人们在春天到来之际通过嬉戏和玩笑表达对新生活的期待。这些习俗在长期流传中逐渐固定为4月1日的节日形式。';
originBackground = '在欧洲传统社会中，节庆往往兼具娱乐和社交功能。愚人节正是在这种强调民间娱乐、释放压力的文化背景下逐渐形成，并随着文化交流传播到世界各地。';
keyFigures = [
  "欧洲民间传统",
  "中世纪节庆参与者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '开善意玩笑';
customIntroduction1 = '愚人节最典型的习俗是向亲友或同事开一些善意的玩笑。这些玩笑通常不会涉及人身攻击或严重误导，而是通过夸张、反转或出其不意的方式制造幽默效果。\n' +
  '\n' +
  '在合适的范围内，这类玩笑可以拉近人与人之间的距离，让日常交流变得更加轻松，也为紧张的工作和学习生活带来短暂的放松。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '创意恶作剧';
customIntroduction2 = '除了语言上的玩笑，一些人还会在愚人节设计小型恶作剧，例如调换物品位置、设置无害的小“陷阱”或制作虚假的提示信息。\n' +
  '\n' +
  '这类恶作剧强调创意和趣味性，而非造成困扰。成功的愚人节恶作剧往往让被捉弄的人在意识到真相后也能会心一笑，从而成为一段轻松的回忆。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '媒体与品牌玩笑';
customIntroduction3 = '在现代社会，媒体和品牌也常在愚人节发布创意十足的“假新闻”或趣味产品介绍。这些内容通常设计巧妙，既具有娱乐性，又不会真正误导公众。\n' +
  '\n' +
  '这种参与方式让愚人节从私人互动扩展到公共文化层面，也体现了幽默在传播和沟通中的积极作用。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '提醒适度与尊重';
customIntroduction4 = '虽然愚人节鼓励幽默和玩笑，但民间也逐渐形成了“玩笑要有分寸”的共识。避免涉及隐私、恐惧、健康或重大公共事件，是现代愚人节被广泛接受的重要前提。\n' +
  '\n' +
  '这种对边界的强调，使愚人节在保持趣味性的同时，也能体现对他人感受的尊重，让欢乐建立在善意之上。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

culturalSignificance = '愚人节的文化意义在于为社会提供一个合法、被默许的“幽默出口”。它让人们在既定规则之外，短暂体验轻松、玩笑和情绪释放。\n' +
  '\n' +
  '从更广的角度看，愚人节体现了幽默在社会关系中的调节作用。适度的玩笑有助于缓解压力、拉近距离，也提醒人们在忙碌与严肃之外，保留对生活的轻松态度。\n' +
  '\n' +
  '因此，愚人节虽不宏大，却以一种温和的方式丰富了现代社会的节日文化。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Yuren.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['愚人节'] = festivalDetailInfo;
custom = [];

//清明节
festivalName = '清明节';
festivalEnglishName = 'Qingming Festival';
simpleIntroduction = '清明节是中国重要的传统节日之一，兼具节气与节日的双重属性。人们在这一天祭祖扫墓、追思先人，同时踏青出游，感受春回大地的生机。';
fullDescription = '清明节通常在公历4月4日至6日之间，是二十四节气之一“清明”所在的时间节点，也逐渐演变为重要的传统节日。它既承载着慎终追远、缅怀先人的情感内涵，也体现了顺应自然、亲近自然的生活态度。\n' +
  '\n' +
  '在中国传统文化中，清明被视为阴阳交替、万物生长的时节。此时天气转暖、草木萌发，人们在祭祖之后外出踏青，形成了“哀而不伤、肃而不悲”的节日气质，使清明节在众多传统节日中显得格外克制而深沉。\n' +
  '\n' +
  '随着历史发展，清明节逐渐固定为全民性的祭祖节日，并在现代社会中成为法定节假日。它不仅是家庭记忆和家族情感的延续，也是一种对生命、时间与自然循环的集体思考。';
originPeriod = '周代节气文化基础上逐步形成，唐宋时期发展为固定节日';
originStory = '清明节最早源于二十四节气中的“清明”，后来与寒食节习俗逐渐融合。寒食节相传与春秋时期晋国忠臣介子推有关，人们在寒食节禁火冷食，以示纪念。\n' +
  '\n' +
  '随着时间推移，寒食节的纪念内容逐渐并入清明节，形成以祭祖扫墓为核心的节日形态，使清明节兼具节气意义与人文情感。';
originBackground = '在农耕社会中，人们高度重视节气变化，以指导生产和生活。清明时节正值春耕前后，是适合进行祭祀与出行的时期。\n' +
  '\n' +
  '同时，中国传统文化强调家族传承与祖先崇敬，清明节在这样的社会背景下逐渐成为集中表达追思与感恩的重要时间节点。';
keyFigures = [
  "介子推",
  "历代先民"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '祭祖扫墓';
customIntroduction1 = '祭祖扫墓是清明节最核心、最具代表性的习俗。人们会前往祖先墓地清理杂草、培土修整，并献上鲜花、供品或焚香，以表达对先人的追思与敬意。\n' +
  '\n' +
  '这一过程不仅是对逝者的纪念，也是一次家族记忆的重温。通过讲述祖辈故事、回顾家族历史，年轻一代得以理解自身的来处，从而增强对家庭与血缘的认同感。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '踏青出游';
customIntroduction2 = '踏青是清明节的重要习俗之一。祭祖之后，人们常选择到郊外或公园散步、赏花，感受春天的气息。踏青既是顺应自然时令的活动，也在情感上起到调节作用。\n' +
  '\n' +
  '这种“由哀转喜”的节日节奏，使清明节在追思之外多了一份生命的延续感，提醒人们在缅怀过去的同时，也要珍惜当下的生活。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '放风筝';
customIntroduction3 = '放风筝是清明节期间广受欢迎的民俗活动之一。传统上，人们认为风筝可以带走晦气与烦恼，有的地方还会在风筝上写下疾病或不顺之事，待风筝飞远后剪断线绳，寓意放下不幸、迎接新生。\n' +
  '\n' +
  '在现代生活中，放风筝更多成为亲近自然、增进亲子互动的方式，为清明节增添了轻松而温暖的生活气息。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '食用清明时令食品';
customIntroduction4 = '清明节期间，各地有食用时令食品的习俗，如青团、寒食糕等。这些食物多以当季植物为原料，口味清新，象征春天的到来。\n' +
  '\n' +
  '通过饮食与节气相结合，人们在日常生活中感知自然变化，也让节日文化融入一日三餐，形成稳定而持久的民俗传承。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

culturalSignificance = '清明节在中国传统节日体系中具有独特的精神气质。它通过祭祖扫墓，体现了慎终追远、感恩先人的价值观；通过踏青与春游，又表达了对生命延续与自然生机的珍视。\n' +
  '\n' +
  '这种“纪念与新生并存”的节日结构，使清明节成为思考生命意义的重要时刻。它提醒人们尊重过去、珍惜现在，并在时间的循环中寻找内心的平衡。\n' +
  '\n' +
  '在现代社会，清明节不仅是家族情感的纽带，也是连接个体与历史、人与自然的重要文化桥梁。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Qingming.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['清明节'] = festivalDetailInfo;
custom = [];

//劳动节
festivalName = '劳动节';
festivalEnglishName = 'International Workers’ Day';
simpleIntroduction = '劳动节是纪念劳动者、弘扬劳动精神的重要节日，旨在肯定劳动创造价值、劳动者推动社会进步的核心地位。';
fullDescription = '劳动节，定于每年5月1日，是世界上许多国家共同庆祝的重要节日。它起源于19世纪国际工人运动，最初是劳动者为争取合理工作时间和劳动权益而进行的集体行动的纪念日。\n' +
  '\n' +
  '随着社会的发展，劳动节逐渐从单纯的工人纪念日，演变为全社会共同尊重劳动、致敬劳动者的节日。在现代语境中，劳动节既强调劳动权利与社会公平，也肯定各行各业普通劳动者在日常生活中的默默付出。\n' +
  '\n' +
  '在中国，劳动节被设立为法定节假日，不仅具有纪念意义，也为人们提供了休息调整和反思劳动价值的时间空间。';
originPeriod = '19世纪后期国际工人运动时期';
originStory = '劳动节起源于19世纪美国芝加哥的工人运动。当时，工人们为争取八小时工作制而举行大规模罢工和示威活动。这一行动虽经历冲突和牺牲，但对全球劳动制度改革产生了深远影响。\n' +
  '\n' +
  '后来，国际工人组织将5月1日定为劳动者的共同纪念日，用以纪念工人争取权益的斗争精神，并逐渐在世界范围内传播开来。';
originBackground = '工业革命后，劳动强度大、工作时间长、劳动保障不足成为普遍问题。劳动节正是在这样的社会背景下产生，反映了劳动者对尊严、公平和合理制度的追求。';
keyFigures = [
  "国际工人运动参与者",
  "芝加哥工人代表"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '休息与调整';
customIntroduction1 = '劳动节期间，人们通常会暂时放下繁忙的工作，进行休息和调整。通过睡眠、出游或简单放松，让身体和心理从长期的工作压力中得到恢复。\n' +
  '\n' +
  '这种休息不仅是对个人健康的关照，也体现了劳动节“合理劳动、适度休息”的核心理念。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '致敬劳动者';
customIntroduction2 = '在劳动节期间，社会各界会通过表彰大会、媒体报道或主题活动，向优秀劳动者和基层工作者致敬。这些活动让平凡岗位上的付出被看见，增强劳动者的荣誉感与社会认同感。\n' +
  '\n' +
  '通过讲述真实的劳动故事，劳动节强化了“劳动光荣、创造伟大”的价值观。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '家庭与个人劳动实践';
customIntroduction3 = '不少人在劳动节会选择进行家庭劳动或个人实践活动，如整理居住环境、动手维修、参与志愿服务等。这些行为让人们重新感受劳动带来的成就感和秩序感。\n' +
  '\n' +
  '通过亲身劳动，人们更能体会劳动成果的来之不易，也有助于培养尊重他人劳动的意识。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '学习劳动精神';
customIntroduction4 = '劳动节也是回顾劳动历史、学习劳动精神的重要契机。通过参观纪念馆、观看纪录片或参与主题教育活动，人们能够更深入地理解劳动在社会发展中的基础性作用。\n' +
  '\n' +
  '这种学习有助于引导年轻一代树立正确的劳动观，尊重劳动成果，珍惜来之不易的生活条件。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

culturalSignificance = '劳动节的文化意义在于肯定劳动的价值，并提醒社会关注劳动者的权利与尊严。它通过纪念历史斗争和现实实践，让“尊重劳动、尊重劳动者”成为广泛共识。\n' +
  '\n' +
  '从个人层面看，劳动节鼓励人们在努力工作的同时关注身心平衡；从社会层面看，它推动制度不断向更加公平和人性化的方向发展。\n' +
  '\n' +
  '因此，劳动节不仅是一个休息的节日，更是一种关于责任、尊严与价值创造的文化宣言。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Laodong.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['劳动节'] = festivalDetailInfo;
custom = [];

//青年节
festivalName = '青年节';
festivalEnglishName = 'Youth Day';
simpleIntroduction = '青年节是纪念青年奋斗精神的重要节日，旨在弘扬青春理想、社会责任与时代担当，鼓励青年积极投身国家与社会的发展。';
fullDescription = '青年节在中国定于每年5月4日，源于具有重要历史意义的五四运动。它不仅是一个纪念性的节日，更是一种精神象征，代表着青年群体在社会变革和国家发展中的先锋力量。\n' +
  '\n' +
  '在五四运动中，广大青年学生以强烈的爱国热情和社会责任感，推动了思想解放和社会进步。从那时起，“青年”不再只是年龄概念，而被赋予了理想、进步、勇敢和担当的精神内涵。\n' +
  '\n' +
  '在当代社会，青年节依然具有现实意义。它鼓励青年在学习、工作和生活中保持独立思考的能力，勇于创新、积极实践，在时代发展中找到属于自己的位置和价值。';
originPeriod = '1919年五四运动时期';
originStory = '青年节的设立源于1919年爆发的五四运动。面对民族危机和社会变革的关键时刻，青年学生走上街头，表达爱国诉求，推动思想启蒙和社会变革。\n' +
  '\n' +
  '为纪念五四运动中青年群体展现出的爱国精神与进步力量，后来将5月4日定为中国青年节，用以激励一代又一代青年继承和发扬五四精神。';
originBackground = '20世纪初，中国社会正处于剧烈变革时期。民族危机、思想碰撞与社会转型并存，青年成为最活跃、最具行动力的群体。青年节正是在这样的时代背景下诞生，承载着启蒙与奋斗的历史使命。';
keyFigures = [
  "五四运动中的青年学生",
  "新文化运动的倡导者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '纪念与学习五四精神';
customIntroduction1 = '青年节期间，学校和社会组织常通过主题团日、纪念活动或专题学习，回顾五四运动的历史背景和精神内涵。通过学习爱国、进步、民主和科学的理念，引导青年在现实生活中思考责任与使命。\n' +
  '\n' +
  '这种纪念并非停留在历史回顾层面，而是强调将五四精神转化为当代青年的行动力量。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '青年主题活动与交流';
customIntroduction2 = '各类青年论坛、座谈会和分享活动常在青年节前后举行，为不同领域的青年提供交流思想和经验的平台。通过讨论学习、就业、创新和社会参与等话题，帮助青年拓宽视野，增强自我认同感。\n' +
  '\n' +
  '这些活动也促进了青年之间的互相支持和合作，形成积极向上的青年社群氛围。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '志愿服务与社会实践';
customIntroduction3 = '青年节也是参与志愿服务和社会实践的重要节点。许多青年会在这一时期参与公益活动、社区服务或基层调研，将个人成长与社会需求相结合。\n' +
  '\n' +
  '通过实际行动服务社会，青年不仅能够提升自身能力，也能更深刻地理解责任、奉献和公共价值的意义。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '树立理想与自我规划';
customIntroduction4 = '对不少青年而言，青年节也是一次自我反思和规划的契机。人们会在这一天重新审视自己的学习目标、职业方向和人生规划，思考如何在时代发展中实现个人价值。\n' +
  '\n' +
  '这种对理想与未来的思考，使青年节不仅具有纪念意义，也具有现实指导意义。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

culturalSignificance = '青年节的文化意义在于肯定青年在社会发展中的独特价值，并激励青年承担起时代赋予的责任。它将青春与理想、奋斗与担当紧密联系在一起，形成具有持续影响力的精神传统。\n' +
  '\n' +
  '在快速变化的现代社会中，青年节提醒人们：青年不仅是社会的未来，也是当下最具活力和创造力的力量。通过不断学习与实践，青年可以在时代洪流中书写属于自己的篇章。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Qingnian.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['青年节'] = festivalDetailInfo;
custom = [];

//母亲节
festivalName = '母亲节';
festivalEnglishName = "Mother's Day";
simpleIntroduction = '母亲节是表达对母亲感恩与爱的节日，通常在每年5月的第二个星期日。人们通过陪伴、礼物与真诚的感谢，向母亲传递关怀与敬意。';
fullDescription = '母亲节是一个以“感恩母爱”为核心主题的节日，现代意义上的母亲节通常定在每年5月的第二个星期日。它提醒人们在忙碌生活中停下来，把爱与感谢更明确地说出来、做出来。\n' +
  '\n' +
  '母亲在家庭中往往承担着照顾、支持和情感连接的角色，但这份付出常常被习以为常。母亲节的意义并不在于形式化的仪式，而在于让母亲被看见、被理解、被尊重：一句真诚的感谢、一段专注的陪伴、一份贴心的分担，都能成为母亲节最温暖的表达。\n' +
  '\n' +
  '随着时代变化，母亲节也逐渐成为表达亲情的公共节日。它不仅让人们重新思考母亲的价值与辛劳，也鼓励家庭关系更平等、更有回应，让爱不只停留在心里。';
originPeriod = '20世纪初（现代母亲节在美国兴起并传播）';
originStory = '现代母亲节普遍认为起源于美国。安娜·贾维斯为了纪念自己的母亲，并倡导设立一个表达对母亲感恩的纪念日，她推动相关活动逐步扩大影响。\n' +
  '\n' +
  '随后，母亲节在社会各界的传播下成为被广泛接受的节日，并逐渐传播到世界各地。虽然各国庆祝方式有所不同，但“感谢母亲、表达爱意”的核心精神相近。';
originBackground = '随着现代社会节奏加快，人们的家庭陪伴时间相对减少，母亲节以一种被社会共同认可的形式，提醒人们重视家庭情感连接。\n' +
  '\n' +
  '同时，母亲节也反映出社会对家庭劳动与情感劳动价值的关注，让“照顾与付出”获得更多尊重与回应。';
keyFigures = [
  "安娜·贾维斯",
  "母亲节倡导者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '送花与礼物表达心意';
customIntroduction1 = '在母亲节，人们常通过送花、礼物来表达对母亲的爱与感谢。康乃馨在许多地区被视为母亲节的象征花，代表温柔、敬意与感恩。\n' +
  '\n' +
  '礼物的意义并不在于贵重，而在于贴合母亲的真实需求：一件她一直舍不得买的物品、一次舒适的按摩体验、一本她喜欢的书，或一份手工制作的小物，都能让母亲感受到“你被认真放在心上”。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '陪伴与家庭聚餐';
customIntroduction2 = '很多家庭会在母亲节安排聚餐或一起度过一天，把时间留给母亲。对许多母亲来说，最珍贵的不是隆重的仪式，而是家人愿意放下手机、认真聊天、分享近况的陪伴感。\n' +
  '\n' +
  '无论是一顿家常饭、一次短途散步，还是一起看一场电影，只要是“专注的相处”，都能让母亲节变得温暖而有意义。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '写贺卡或表达感谢';
customIntroduction3 = '写贺卡、写信或当面表达感谢，是母亲节最“走心”的习俗之一。许多人平时不太善于表达情绪，而母亲节给了一个自然的机会，把爱说清楚。\n' +
  '\n' +
  '一段具体的感谢往往更打动人：比如感谢她某次默默的支持、某段艰难时期的陪伴、某个日常细节的照顾。让母亲知道她的付出被看见、被记得，会比千篇一律的祝福更有力量。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '分担家务与关怀行动';
customIntroduction4 = '母亲节也常被视为“用行动表达爱”的日子。家人会主动分担家务、照顾孩子、安排母亲休息，或者带母亲做一次体检、购买健康用品等，把关怀落实在具体细节里。\n' +
  '\n' +
  '更重要的是，这种分担最好不只停留在节日当天。母亲节可以成为一次提醒：让家庭里的劳动更公平，让母亲得到长期的理解、支持与喘息空间。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '线上祝福与远程陪伴';
customIntroduction5 = '对于异地工作或学习的人来说，母亲节常通过电话、视频、红包或线上祝福来表达心意。一次耐心的通话、一次认真倾听母亲的分享，往往能弥补距离带来的缺席感。\n' +
  '\n' +
  '很多人会提前准备小惊喜，例如寄一束花、订一份蛋糕、安排同城家人代为送达，让母亲在普通的一天里感受到被惦记与被爱。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '母亲节的文化意义在于提醒人们重视亲情与感恩，把对母亲的爱从“心里有”变成“说出来、做出来”。它让家庭中常被忽略的情感劳动与照料劳动得到更多认可。\n' +
  '\n' +
  '从更深层看，母亲节也推动家庭关系向更平等、更有回应的方向发展：母亲不仅是付出者，也需要被理解、被支持、被照顾。\n' +
  '\n' +
  '无论庆祝方式如何变化，母亲节最终指向的，是对爱、陪伴与家庭连接的珍惜。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Muqing.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['母亲节'] = festivalDetailInfo;
custom = [];

//儿童节
festivalName = '儿童节';
festivalEnglishName = "Children's Day";
simpleIntroduction = '儿童节是关爱儿童、尊重儿童成长的重要节日，旨在保障儿童权益、关注儿童身心健康，让孩子们在快乐与关怀中度过属于自己的节日。';
fullDescription = '儿童节在中国定于每年6月1日，是专属于儿童的节日。它不仅是孩子们期待的欢乐日子，也是社会集中关注儿童成长环境、教育条件和身心发展的重要时间节点。\n' +
  '\n' +
  '在儿童节这一天，学校、家庭和社会通常会围绕“快乐、关爱与成长”展开各类活动，让孩子们在轻松的氛围中感受到被重视与被保护。对孩子而言，儿童节意味着玩耍、礼物和欢笑；对成人而言，它则是一种提醒——儿童需要理解、尊重和陪伴，而不仅是管理与要求。\n' +
  '\n' +
  '随着时代发展，儿童节的内涵也不断丰富。它不仅关注物质条件，更强调心理健康、人格尊重和创造力培养，让孩子在安全、包容和鼓励的环境中成长。';
originPeriod = '20世纪中期（现代国际儿童保护运动时期）';
originStory = '现代儿童节的设立与国际社会对儿童权益的关注密切相关。20世纪中期，世界各国开始重视儿童在战争、贫困和社会变革中所面临的问题，并推动制定保护儿童权利的国际共识。\n' +
  '\n' +
  '1949年，国际民主妇女联合会提议设立国际儿童节，以引起全社会对儿童生存、教育和健康问题的重视。随后，6月1日逐渐被多个国家采纳为儿童节。';
originBackground = '在战争和社会动荡背景下，儿童群体的安全和发展问题日益凸显。儿童节正是在保护儿童权益、改善成长环境的社会背景下产生，体现了社会文明进步的方向。';
keyFigures = [
  "国际民主妇女联合会",
  "儿童权益倡导者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '学校庆祝活动';
customIntroduction1 = '儿童节期间，学校通常会组织丰富多彩的庆祝活动，如文艺汇演、游园会、运动比赛或主题班会。这些活动让孩子们在展示自我和参与集体活动中获得成就感与快乐。\n' +
  '\n' +
  '通过舞台表演、游戏竞赛等形式，孩子们不仅能够释放天性，也能在合作与交流中培养自信心和团队意识。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '家庭陪伴与亲子活动';
customIntroduction2 = '在家庭层面，儿童节是家长放慢节奏、专注陪伴孩子的重要时刻。家长可能会陪孩子玩游戏、读绘本、外出游玩或一起完成手工活动，让孩子感受到被认真对待的陪伴。\n' +
  '\n' +
  '这种高质量的亲子互动，有助于增强孩子的安全感和信任感，也是儿童节最珍贵的礼物之一。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '赠送礼物与鼓励';
customIntroduction3 = '在儿童节，赠送礼物是常见的表达方式之一。礼物可以是玩具、书籍、学习用品或体验类活动，重点在于激发兴趣、鼓励探索，而非单纯满足物质需求。\n' +
  '\n' +
  '通过礼物和语言上的鼓励，孩子能够感受到认可和支持，从而更加勇敢地表达自己、尝试新事物。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '关注儿童权益与成长';
customIntroduction4 = '儿童节也是社会集中宣传儿童权益的重要节点。媒体和公益组织会围绕儿童教育公平、心理健康、网络安全等议题展开讨论，提醒社会为儿童提供更安全、更友好的成长环境。\n' +
  '\n' +
  '这种关注有助于推动制度和观念的改善，让儿童不仅在节日里被关爱，也能在日常生活中获得持续的保护与尊重。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '保留童真与快乐记忆';
customIntroduction5 = '儿童节不仅属于孩子，也唤起成年人对童年的回忆。许多家庭会在这一天为孩子拍照、记录成长瞬间，留下珍贵的童年记忆。\n' +
  '\n' +
  '这些记忆在孩子成长过程中具有重要意义，让他们在未来回望童年时，依然能够感受到被爱、被尊重和被鼓励的力量。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '儿童节的文化意义在于提醒社会：儿童不是附属群体，而是独立的个体，拥有应被尊重和保护的权利。通过节日形式，让“以儿童为本”的理念更加具体可感。\n' +
  '\n' +
  '从家庭层面看，儿童节强化了陪伴与理解的重要性；从社会层面看，它推动制度和环境朝着更有利于儿童成长的方向发展。\n' +
  '\n' +
  '因此，儿童节不仅是一个充满欢笑的节日，更是一种面向未来的责任承诺。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Ertong.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['儿童节'] = festivalDetailInfo;
custom = [];

//端午节
festivalName = '端午节';
festivalEnglishName = 'Dragon Boat Festival';
simpleIntroduction = '端午节是中国重要的传统节日之一，时间为农历五月初五。它以纪念爱国诗人屈原为核心，同时融合了祈福避疫、顺应时令等丰富的民俗文化内涵。';
fullDescription = '端午节是中国传统节日体系中历史悠久、文化内涵十分丰富的节日之一，通常在农历五月初五举行。由于农历五月在古代被视为“毒月”，端午节在纪念人物的同时，也承担着驱邪避疫、祈求平安的重要功能。\n' +
  '\n' +
  '在流传最广的说法中，端午节与战国时期爱国诗人屈原密切相关。屈原投汨罗江殉国后，百姓以投粽子、划船寻找的方式寄托哀思，这些行为逐渐演变为赛龙舟和吃粽子的节俗。\n' +
  '\n' +
  '随着历史演变，端午节不断吸收各地民俗元素，形成集纪念、祈福、饮食、竞技于一体的综合性节日。即便在现代社会，端午节依然通过家庭团聚和民俗活动，延续着深厚的文化情感。';
originPeriod = '战国时期形成核心传说，汉代以后逐渐定型并广泛流传';
originStory = '关于端午节的起源，最广为人知的是纪念屈原的说法。屈原因忧国忧民、坚持理想而被流放，最终于五月初五投汨罗江殉国。百姓闻讯后划船寻找，并向江中投放米团，以防鱼虾侵害屈原遗体。\n' +
  '\n' +
  '随着时间推移，这些行为逐渐固定为赛龙舟和吃粽子的习俗。此外，也有学者认为端午节与古代夏季祈福、避疫仪式有关，体现了多种文化因素的融合。';
originBackground = '在古代社会，农历五月气候湿热，疫病多发，人们通过佩戴香囊、悬挂艾草等方式祈求健康平安。端午节正是在这种自然环境和社会心理背景下，逐步发展成为兼具纪念意义和实用功能的节日。';
keyFigures = [
  "屈原",
  "汨罗江沿岸百姓",
  "历代民俗传承者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '吃粽子';
customIntroduction1 = '吃粽子是端午节最具代表性的习俗之一。粽子通常以糯米为主料，用竹叶或芦苇叶包裹，再加入红枣、豆沙、鲜肉、咸蛋黄等不同馅料蒸煮而成。\n' +
  '\n' +
  '在传统解释中，粽子象征人们对屈原的纪念；在日常生活中，它也成为家庭团聚的重要节日食品。不同地区的粽子口味和形状各具特色，体现了端午节在地域文化中的多样性。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '赛龙舟';
customIntroduction2 = '赛龙舟是端午节最具观赏性和集体参与感的传统活动之一。龙舟竞渡源于人们划船寻找屈原的传说，后来发展为具有竞技性质的民俗体育活动。\n' +
  '\n' +
  '在比赛中，参赛者齐心协力、步调一致，象征团结协作与奋勇向前的精神。如今，龙舟赛已成为国内外广受欢迎的传统体育项目，也是端午节文化传播的重要载体。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '悬挂艾草与菖蒲';
customIntroduction3 = '端午节期间，人们常在门前悬挂艾草和菖蒲。传统观念认为，这些植物具有特殊气味，能够驱虫避疫、祈求平安。\n' +
  '\n' +
  '这种做法反映了古人应对自然环境的智慧，也让端午节带有浓厚的生活气息。即使在现代，悬挂艾草仍被视为一种具有象征意义的节日装饰。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '佩戴香囊';
customIntroduction4 = '佩戴香囊是端午节常见的民俗之一。香囊通常由布料缝制而成，内装艾叶、雄黄等中草药，既有清香气味，也寓意辟邪纳福。\n' +
  '\n' +
  '香囊常被长辈赠予孩子或亲友，象征关爱与祝福。如今，香囊更多作为文化符号和手工艺品，承载着端午节的传统记忆。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '饮雄黄酒（象征性）';
customIntroduction5 = '在部分地区，端午节有饮雄黄酒的习俗，传统上认为雄黄酒可以驱毒避邪、预防疾病。\n' +
  '\n' +
  '在现代生活中，这一习俗多以象征形式存在，更多体现人们对健康和平安的美好祝愿，而非实际饮用。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '端午节在中国文化中具有多重意义：它既是对爱国诗人屈原的纪念，也是古代社会应对自然环境、祈求健康平安的重要节日。\n' +
  '\n' +
  '通过饮食、竞技和日常习俗，端午节将家国情怀、生命关怀与生活智慧融为一体，形成独特而持久的文化传统。\n' +
  '\n' +
  '在当代社会，端午节依然通过家庭团聚和民俗活动，连接着历史与现实，成为中华文化认同的重要象征之一。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Duanwu.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['端午节'] = festivalDetailInfo;
custom = [];

//父亲节
festivalName = '父亲节';
festivalEnglishName = "Father's Day";
simpleIntroduction = '父亲节是表达对父亲敬意与感恩的节日，通常在每年6月的第三个星期日。人们通过陪伴、关怀与实际行动，向父亲传递理解与感谢。';
fullDescription = '父亲节是一个以“致敬父爱”为主题的节日。与母亲节相比，父亲节的情感表达往往更为内敛，但同样深沉而重要。它提醒人们关注父亲在家庭中承担的责任、付出与支持，让平时不善表达的情感有一个被认真说出口的机会。\n' +
  '\n' +
  '在许多家庭中，父亲常常以行动而非言语表达关爱，例如默默承担家庭经济责任、在关键时刻给予指导与支持。父亲节的意义，不在于形式上的隆重，而在于让这种长期而稳定的付出被看见、被理解。\n' +
  '\n' +
  '随着社会观念变化，父亲节也逐渐被赋予更多温情与沟通的色彩。它鼓励父亲与孩子之间建立更开放的交流关系，让家庭情感更加平衡和健康。';
originPeriod = '20世纪初（现代父亲节在美国兴起）';
originStory = '现代父亲节起源于美国。索诺拉·斯马特·多德为了纪念独自抚养子女的父亲，倡议设立一个表达对父亲敬意的节日。\n' +
  '\n' +
  '这一倡议逐渐得到社会认可，父亲节开始在美国各地庆祝，并在随后传播到世界多个国家，成为表达父爱与家庭责任的重要节日。';
originBackground = '随着社会结构变化，人们开始重新认识父亲在家庭中的角色。父亲节正是在强调家庭责任、情感交流和亲职价值的社会背景下逐渐发展起来的。';
keyFigures = [
  "索诺拉·斯马特·多德",
  "父亲节倡导者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '表达感谢与敬意';
customIntroduction1 = '在父亲节，人们会通过言语或行动向父亲表达感谢与敬意。一句真诚的“辛苦了”、一次用心的交流，往往比昂贵礼物更能触动父亲的内心。\n' +
  '\n' +
  '对许多父亲来说，被理解和被认可本身就是最重要的节日意义。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '陪伴与共同活动';
customIntroduction2 = '陪伴是父亲节中极具分量的习俗。子女可能会与父亲一起散步、聊天、看比赛、做饭或参与他感兴趣的活动，让父亲感受到被重视的陪伴。\n' +
  '\n' +
  '这种共同度过的时光，有助于拉近彼此距离，也为家庭留下温暖而真实的回忆。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '赠送实用或贴心礼物';
customIntroduction3 = '在父亲节，赠送礼物是常见的表达方式之一。相比装饰性礼物，实用性或贴合父亲兴趣的礼物往往更受欢迎，例如书籍、工具、衣物或健康相关用品。\n' +
  '\n' +
  '礼物的核心意义不在于价值，而在于“被记得”和“被用心选择”。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '家庭聚餐或仪式感安排';
customIntroduction4 = '一些家庭会在父亲节安排聚餐或小型庆祝活动，通过一顿饭或简单仪式，让父亲感受到家庭的重视和温暖。\n' +
  '\n' +
  '即使形式朴素，只要包含真诚与用心，都能让父亲节成为值得记住的日子。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '反思与沟通亲子关系';
customIntroduction5 = '父亲节也被不少人视为重新审视亲子关系的契机。通过沟通与理解，子女和父亲可以更坦诚地表达想法与感受，减少隔阂，增强情感连接。\n' +
  '\n' +
  '这种情感上的靠近，往往比节日本身更具长期意义。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '父亲节的文化意义在于强调父爱的价值与家庭责任的多样表达方式。它让父亲这一角色从“默默付出者”走向被看见、被理解和被尊重。\n' +
  '\n' +
  '从家庭层面看，父亲节促进了情感沟通与关系平衡；从社会层面看，它强化了对亲职责任和家庭价值的重视。\n' +
  '\n' +
  '因此，父亲节不仅是一个表达感恩的节日，更是一种促进家庭情感健康发展的文化提醒。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Fuqing.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['父亲节'] = festivalDetailInfo;
custom = [];

//建党节
festivalName = '建党节';
festivalEnglishName = 'CPC Founding Day';
simpleIntroduction = '建党节是纪念中国共产党成立的重要纪念日，时间为每年7月1日。它用于回顾党的奋斗历程，弘扬理想信念与使命担当。';
fullDescription = '建党节是为纪念中国共产党成立而设立的重要纪念日。1921年，中国共产党在民族危亡、社会动荡的背景下诞生，从此中国革命和社会发展进入了新的历史阶段。\n' +
  '\n' +
  '在百余年的发展历程中，中国共产党团结带领人民完成了民族独立、国家建设和社会发展的重要任务。建党节不仅是对历史的回顾，也是对初心和使命的再确认。\n' +
  '\n' +
  '在当代社会，建党节已成为开展爱国主义教育、理想信念教育和党史学习的重要时间节点，通过纪念活动引导人们铭记历史、珍惜当下、面向未来。';
originPeriod = '1921年中国共产党成立时期';
originStory = '1921年7月，中国共产党第一次全国代表大会在上海和嘉兴南湖召开，标志着中国共产党的正式成立。这一事件改变了中国历史的发展方向。\n' +
  '\n' +
  '后来，为纪念党的诞生，将7月1日确定为中国共产党成立纪念日，即建党节。';
originBackground = '20世纪初，中国社会处于内忧外患的严峻局势之中。民族危机、社会矛盾和思想变革交织，为中国共产党的成立提供了现实土壤和历史必然性。';
keyFigures = [
  "中国共产党早期创建者",
  "中共一大代表"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '开展纪念活动';
customIntroduction1 = '在建党节期间，各级组织和单位会开展形式多样的纪念活动，如主题大会、宣誓仪式和文艺演出，通过庄重的仪式回顾党的发展历程。\n' +
  '\n' +
  '这些活动不仅具有纪念意义，也有助于增强集体认同感和责任意识。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '党史学习与教育';
customIntroduction2 = '建党节是集中开展党史学习和理想信念教育的重要节点。通过专题讲座、学习交流和资料阅读，人们系统了解党的奋斗历史和重要精神。\n' +
  '\n' +
  '这种学习有助于把历史经验转化为现实动力，引导个人在工作和生活中践行责任与担当。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '重温入党誓词';
customIntroduction3 = '在建党节前后，许多党员会组织重温入党誓词活动。通过庄严宣誓，回顾入党初心，强化身份意识和使命意识。\n' +
  '\n' +
  '这一仪式既是对信念的再次确认，也是一种精神上的自我提醒和激励。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '表彰先进典型';
customIntroduction4 = '一些地区和单位会在建党节期间表彰优秀党员和先进集体，通过树立榜样，激励更多人学习先进、争当先锋。\n' +
  '\n' +
  '这种方式让抽象的精神具体化，有助于形成积极向上的价值导向。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

culturalSignificance = '建党节具有重要的政治与文化意义。它通过集中纪念和学习活动，使党的历史和精神在社会中得到持续传承。\n' +
  '\n' +
  '从文化层面看，建党节强化了集体记忆和价值认同；从现实层面看，它引导人们把理想信念转化为实际行动。\n' +
  '\n' +
  '因此，建党节不仅是一个纪念日，更是一种凝聚力量、明确方向的重要精神坐标。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Jiandang.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['建党节'] = festivalDetailInfo;
custom = [];

//建军节
festivalName = '建军节';
festivalEnglishName = 'Army Day';
simpleIntroduction = '建军节是纪念中国人民解放军成立的重要节日，时间为每年8月1日。它用于缅怀革命历史，致敬军人群体，弘扬爱国主义和奉献精神。';
fullDescription = '建军节是为纪念中国人民解放军的诞生而设立的重要纪念日。1927年8月1日爆发的南昌起义，标志着中国共产党独立领导武装斗争和创建人民军队的开始，中国革命由此进入新的历史阶段。\n' +
  '\n' +
  '在长期的革命、建设和改革历程中，中国人民解放军在维护国家独立、民族尊严和社会稳定方面发挥了重要作用。无论是在战争年代，还是在和平时期的抢险救灾、边防守护和重大任务中，军人始终以高度的责任感和纪律性承担使命。\n' +
  '\n' +
  '建军节不仅是对军队历史的纪念，也是社会集中表达对军人群体尊重与敬意的重要时刻。通过这一节日，人们更加直观地理解“国之大事，在祀与戎”的深刻内涵。';
originPeriod = '1927年中国人民军队创建时期';
originStory = '1927年8月1日，中国共产党领导的南昌起义打响了武装反抗的第一枪，创建了中国共产党领导下的人民军队。这一事件被视为中国人民解放军的诞生标志。\n' +
  '\n' +
  '后来，为纪念这一具有里程碑意义的历史事件，将8月1日定为中国人民解放军建军节。';
originBackground = '20世纪20年代，中国社会矛盾尖锐，革命形势严峻。为争取民族独立和人民解放，必须建立一支由先进思想领导、服务人民的武装力量，建军节正是在这样的历史背景下确立的。';
keyFigures = [
  "南昌起义参与者",
  "中国人民解放军创建者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '纪念与学习建军历史';
customIntroduction1 = '在建军节期间，各地会通过展览、讲座、主题活动等形式，回顾人民军队的发展历程，讲述重要历史事件和英雄事迹。\n' +
  '\n' +
  '这种纪念不仅帮助公众了解军队的历史贡献，也增强对国家安全和国防建设重要性的认识。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '慰问现役军人和退役军人';
customIntroduction2 = '建军节前后，社会各界常开展慰问活动，向现役军人、退役军人及其家属表达关怀和敬意。通过走访、座谈或发放慰问品，让军人感受到来自社会的尊重与支持。\n' +
  '\n' +
  '这些活动有助于增强军人的荣誉感，也拉近军民之间的情感联系。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '军民共建活动';
customIntroduction3 = '一些地区会在建军节组织军民共建活动，如开放军营、联合文体活动或志愿服务。通过互动交流，让公众更直观地了解军队生活和纪律作风。\n' +
  '\n' +
  '这种共建形式有助于增进理解与信任，强化“军爱民、民拥军”的良好氛围。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '向军人致敬的公共表达';
customIntroduction4 = '在建军节当天，媒体和公共空间常通过报道、专题节目和宣传内容，向军人群体致敬，传播正面形象。\n' +
  '\n' +
  '这些公共表达让军人的奉献精神被更多人看见，也在社会中形成尊重军人、支持国防的价值共识。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

culturalSignificance = '建军节在中国社会中具有重要的纪念和教育意义。它通过回顾人民军队的创建和发展历程，强化国家安全意识和集体记忆。\n' +
  '\n' +
  '从文化层面看，建军节弘扬了忠诚、奉献、纪律和担当的精神品质；从现实层面看，它促进军民团结，增强社会凝聚力。\n' +
  '\n' +
  '因此，建军节不仅是一个纪念日，更是一种激励全社会珍惜和平、维护稳定的重要精神象征。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Jianjun.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['建军节'] = festivalDetailInfo;
custom = [];

//七夕节
festivalName = '七夕节';
festivalEnglishName = 'Qixi Festival';
simpleIntroduction = '七夕节是中国传统节日之一，时间为农历七月初七，因牛郎织女的传说而广为人知，被视为象征爱情、忠贞与美好祝愿的节日。';
fullDescription = '七夕节，又称乞巧节、七巧节，是中国最具浪漫色彩的传统节日之一。它源于古老的星宿崇拜与民间爱情传说，后逐渐演变为寄托爱情、家庭幸福和人生祝愿的重要节日。\n' +
  '\n' +
  '在流传最广的故事中，牛郎与织女因相爱却被天河阻隔，只能在每年农历七月初七通过鹊桥相会一次。这个故事表达了人们对忠贞爱情的向往，也赋予七夕节浓厚的情感色彩。\n' +
  '\n' +
  '在传统社会中，七夕节并不只是“爱情节日”，更是女性祈求心灵手巧、婚姻美满和生活幸福的重要日子。随着时代发展，七夕节在保留传统文化内涵的同时，也逐渐融入现代情感表达方式，成为连接古老传说与当代生活的文化纽带。';
originPeriod = '先秦时期星宿崇拜形成雏形，汉代以后逐渐定型并广泛流传';
originStory = '七夕节最著名的起源故事是牛郎织女的传说。相传织女是天帝之女，因私下与凡人牛郎相爱而被罚分隔天河两岸，只允许每年七月初七由喜鹊搭桥相会。\n' +
  '\n' +
  '这一传说在长期流传中不断丰富，逐渐成为七夕节的核心文化象征。同时，七夕节也与古代对织女星、牵牛星的天文观测和星宿崇拜密切相关。';
originBackground = '在古代社会中，星宿运行被视为与人间生活密切相关。农耕文明和家庭生活对女性技艺与婚姻幸福尤为重视，七夕节正是在这种自然观念与社会需求的背景下发展形成的。';
keyFigures = [
  "牛郎",
  "织女",
  "民间传说中的喜鹊"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '乞巧活动';
customIntroduction1 = '乞巧是七夕节最具代表性的传统习俗。古代女子会在七夕夜向织女星祈求心灵手巧，希望自己在刺绣、织布等技艺上更加娴熟。\n' +
  '\n' +
  '常见的乞巧方式包括穿针引线、摆放瓜果供品、在月光下焚香祈愿等。这些活动不仅体现了女性对技艺和生活能力的追求，也反映了传统社会对勤劳与智慧的重视。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '观星与传说讲述';
customIntroduction2 = '在七夕之夜，人们有仰望星空、寻找牵牛星和织女星的习俗。长辈会向孩子讲述牛郎织女的故事，让节日文化通过口耳相传延续下来。\n' +
  '\n' +
  '这种观星与讲故事的方式，使七夕节带有浓厚的想象色彩和情感温度，也让人们在仰望星空的过程中思考爱情、等待与坚持的意义。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '制作与品尝巧果';
customIntroduction3 = '在一些地区，七夕节有制作和食用“巧果”的习俗。巧果通常由面粉、糖和芝麻制成，形状精巧，寓意心灵手巧和生活甜美。\n' +
  '\n' +
  '通过制作巧果，人们把节日祝愿融入日常饮食，使七夕节既有浪漫想象，也带有浓厚的生活气息。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '表达爱情与情感祝福';
customIntroduction4 = '在现代社会，七夕节逐渐成为表达爱情的重要日子。情侣会通过送礼物、写祝福、共同出行等方式表达情感。\n' +
  '\n' +
  '虽然形式发生变化，但核心仍然是对忠诚、陪伴和理解的珍视，使七夕节在现代生活中焕发新的生命力。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '祈愿婚姻与家庭幸福';
customIntroduction5 = '除了爱情，七夕节在传统观念中也包含对婚姻和家庭幸福的祝愿。已婚女性会祈求家庭和睦、子女健康，寄托对未来生活的美好期望。\n' +
  '\n' +
  '这种习俗使七夕节不仅属于年轻人，也成为承载家庭情感和人生愿望的重要节日。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '七夕节在中国传统文化中象征着忠贞不渝的爱情和对美好生活的向往。通过牛郎织女的故事，人们将情感理想投射到星空与时间之中，形成独特的浪漫叙事。\n' +
  '\n' +
  '从文化层面看，七夕节既体现了古代社会对女性技艺与家庭角色的重视，也在现代语境中转化为情感表达和情绪连接的重要节日。\n' +
  '\n' +
  '因此，七夕节不仅是一个爱情节日，更是一种跨越时代的情感象征，连接着传统想象与当代生活。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Qixi.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['七夕节'] = festivalDetailInfo;
custom = [];

//教师节
festivalName = '教师节';
festivalEnglishName = "Teachers' Day";
simpleIntroduction = '教师节是向教师群体表达尊重与感谢的重要节日，在中国定于每年9月10日，用以弘扬尊师重教的社会风尚，肯定教师在教育与社会发展中的重要作用。';
fullDescription = '教师节是一个以“尊师重教”为核心主题的节日，旨在肯定教师在知识传承、人格塑造和社会进步中的重要贡献。教师不仅承担着传授知识的职责，更在学生的价值观形成和人生道路选择中发挥着深远影响。\n' +
  '\n' +
  '在中国传统文化中，教师一直被赋予崇高地位，有“师者，所以传道授业解惑也”的说法。尊敬老师不仅是一种礼仪，更是一种文化传统，体现了对知识、道德与智慧的尊重。\n' +
  '\n' +
  '设立教师节，使这种尊重以制度化、集体化的方式被强化和传承。它既是对教师辛勤付出的肯定，也是对全社会重视教育、支持教育的价值宣示。';
originPeriod = '20世纪80年代中国现代教育体系发展时期';
originStory = '1985年，全国人大常委会正式通过决议，将每年9月10日设立为教师节。这一日期的设立，旨在肯定教师在社会主义现代化建设中的重要作用，并推动形成尊师重教的社会氛围。\n' +
  '\n' +
  '自此，教师节成为全国范围内向教师表达敬意与感谢的重要节日，并逐渐形成多种庆祝与纪念方式。';
originBackground = '随着现代教育体系的不断发展，教师在人才培养和社会进步中的作用日益凸显。设立教师节，有助于提升教师的社会地位和职业荣誉感，同时引导公众更加理解和支持教育事业。';
keyFigures = [
  "教育工作者群体",
  "教师节倡导与制定者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '学生表达感谢与祝福';
customIntroduction1 = '在教师节，学生们通常会通过写贺卡、送祝福、献花或一句真诚的问候，向老师表达感谢之情。这些表达方式虽然朴素，却承载着学生对老师耐心教导和长期付出的真挚感情。\n' +
  '\n' +
  '相比形式上的隆重，发自内心的感谢更容易打动老师，也让师生关系在温暖的互动中得到进一步加深。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '学校组织庆祝与表彰活动';
customIntroduction2 = '许多学校会在教师节前后举办庆祝大会、文艺演出或表彰活动，对优秀教师和先进教育工作者进行表彰。这类活动不仅是对个人成绩的肯定，也体现了学校对教育质量和育人精神的重视。\n' +
  '\n' +
  '通过公开表彰和集体庆祝，教师的职业荣誉感和使命感得到增强，同时也为学生树立尊重教师、重视学习的榜样。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '师生交流与情感互动';
customIntroduction3 = '教师节也是促进师生交流的重要契机。学生可能会在这一天与老师进行更轻松的交流，回顾学习经历，分享成长感受，表达对老师影响的认可。\n' +
  '\n' +
  '这种超越课堂教学的情感互动，有助于构建更加信任、理解和支持的师生关系，让教育不仅停留在知识层面，也包含情感与人格层面的连接。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '社会层面的尊师宣传';
customIntroduction4 = '在教师节期间，媒体和社会机构常通过专题报道、公益宣传等形式，讲述教师的真实故事，展示他们在教育一线的坚守与奉献。\n' +
  '\n' +
  '这些公共表达有助于提升全社会对教师职业的理解和尊重，让“尊师重教”成为被广泛认同的社会共识。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '教师自我反思与专业成长';
customIntroduction5 = '对教师而言，教师节也是一个回顾教学实践、思考专业成长的时间节点。许多教师会在这一天反思过去一年的教学经验，规划未来的学习和发展方向。\n' +
  '\n' +
  '这种自我反思与提升，使教师节不仅是被感谢的日子，也成为持续进步、精进育人能力的重要契机。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '教师节的文化意义在于强化尊师重教这一核心价值观。它通过集中表达敬意与感谢，让教师的付出被社会看见，也让教育的重要性被不断强调。\n' +
  '\n' +
  '从个体层面看，教师节促进了师生之间的情感联结；从社会层面看，它推动形成理解教育、支持教育、尊重教师的良好氛围。\n' +
  '\n' +
  '因此，教师节不仅是一个职业节日，更是一种面向未来的文化承诺：尊重知识、尊重教育、尊重每一位为成长付出心力的教师。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Jiaoshi.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['教师节'] = festivalDetailInfo;
custom = [];

//中秋节
festivalName = '中秋节';
festivalEnglishName = 'Mid-Autumn Festival';
simpleIntroduction = '中秋节是中国重要的传统节日之一，时间为农历八月十五。它以赏月、团圆为核心主题，寄托着人们对家庭团聚、生活圆满的美好祝愿。';
fullDescription = '中秋节，又称月夕、秋节、团圆节，是以“月圆人圆”为精神内核的传统节日。农历八月十五通常是一年中月亮最圆、最明亮的时刻，因此自古以来便被视为象征团圆与圆满的重要日子。\n' +
  '\n' +
  '在传统农业社会中，秋季是收获的时节，中秋节既承载着庆祝丰收的意味，也成为家人团聚、共享成果的重要节点。人们在这一天抬头望月、低头思亲，将自然景象与人伦情感紧密结合。\n' +
  '\n' +
  '随着历史发展，中秋节不断融入文学、艺术和民俗传说，形成了赏月、吃月饼、拜月、赠礼等丰富习俗。即使在现代社会，中秋节依然以其温和而深情的方式，连接着个人、家庭与文化记忆。';
originPeriod = '先秦时期月亮崇拜形成雏形，唐宋时期节日形态逐渐定型';
originStory = '中秋节的形成与古代对月亮的崇拜密切相关。早在先秦时期，人们便有祭月、拜月的活动。到了唐宋时期，赏月逐渐成为文人雅士和普通百姓共同参与的节日活动。\n' +
  '\n' +
  '关于中秋节的民间传说中，最著名的是嫦娥奔月的故事。相传嫦娥为守护灵药而飞升月宫，成为人们仰望明月时寄托思念与想象的重要形象，这一传说也为中秋节增添了浪漫与诗意色彩。';
originBackground = '在农耕社会中，月相变化与生产生活密切相关。秋季月圆既象征丰收，也容易引发思乡与亲情情感。中秋节正是在自然节律、家庭观念和审美情趣共同作用下逐步发展而成。';
keyFigures = [
  "嫦娥",
  "后羿",
  "吴刚"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '赏月';
customIntroduction1 = '赏月是中秋节最核心的习俗。夜幕降临后，人们会在庭院、阳台或户外开阔处观赏明月，感受秋夜的宁静与清朗。\n' +
  '\n' +
  '在赏月过程中，人们常会联想到远方的亲人和朋友，将对团圆的渴望寄托于同一轮明月之上。这种“共月不同地”的情感体验，使赏月成为中秋节最具情感深度的活动之一。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '吃月饼';
customIntroduction2 = '吃月饼是中秋节最具代表性的饮食习俗。月饼通常为圆形，象征团圆与完整，其馅料和制作工艺因地域不同而各具特色。\n' +
  '\n' +
  '在家庭中，一家人分食月饼，寓意分享与团聚；在亲友之间互赠月饼，则表达祝福与思念。月饼不仅是一种食品，更是一种承载情感和文化意义的节日符号。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '家人团聚与共餐';
customIntroduction3 = '中秋节被视为仅次于春节的重要团圆节日。许多家庭会在这一天尽量团聚，共同准备晚餐、共享美食，在轻松的氛围中交流近况。\n' +
  '\n' +
  '这种团聚并不强调隆重形式，而重在情感连接。即使是一顿普通的家常饭，也因中秋的背景而显得格外温暖和有意义。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '赠送节礼';
customIntroduction4 = '中秋节期间，人们常向亲友、长辈和重要往来对象赠送节礼，如月饼、水果或其他应季食品，以表达问候与祝福。\n' +
  '\n' +
  '这种习俗体现了中秋节的社交属性，使节日不仅存在于家庭内部，也成为维系人际关系和情感往来的重要节点。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '吟诗赏月与文化活动';
customIntroduction5 = '在传统文化中，中秋节常伴随着吟诗作赋、赏月抒怀。许多经典诗词都以中秋明月为题材，表达思乡、怀人或人生感悟。\n' +
  '\n' +
  '在现代社会，这一传统延伸为文艺演出、诗会或文化活动，使中秋节在情感之外，也具有浓厚的文化审美价值。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '中秋节在中国文化中象征着团圆、和谐与圆满。它通过“月圆”的自然意象，将家庭情感、人生理想与宇宙秩序联系在一起，形成独特而持久的文化象征。\n' +
  '\n' +
  '从社会层面看，中秋节强化了家庭观念和情感纽带；从个人层面看，它为人们提供了表达思念、感受温情的重要时刻。\n' +
  '\n' +
  '无论时代如何变化，中秋节始终以温柔而稳定的方式，提醒人们珍惜团聚、理解牵挂，守护内心的圆满与安宁。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Zhongqiu.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['中秋节'] = festivalDetailInfo;
custom = [];

//国庆节
festivalName = '国庆节';
festivalEnglishName = 'National Day of China';
simpleIntroduction = '国庆节是纪念中华人民共和国成立的重要节日，时间为每年10月1日。它象征国家独立、民族复兴和人民团结，是最具国家意义的节日之一。';
fullDescription = '国庆节是为纪念中华人民共和国成立而设立的重要节日。1949年10月1日，中华人民共和国中央人民政府成立典礼在北京天安门广场隆重举行，标志着中国进入新的历史阶段。\n' +
  '\n' +
  '国庆节不仅是一个纪念国家诞生的日子，也承载着回顾奋斗历程、展示国家成就和凝聚民族情感的重要功能。随着国家发展，国庆节逐渐形成了集纪念、庆祝、休闲于一体的综合性节日形态。\n' +
  '\n' +
  '在当代社会，国庆节通常伴随较长假期，人们在休息出行的同时，也通过各种方式表达对国家的认同感和自豪感，使节日既庄重又具有生活气息。';
originPeriod = '1949年中华人民共和国成立时期';
originStory = '1949年10月1日，中华人民共和国成立典礼在北京举行，毛泽东在天安门城楼上庄严宣告中华人民共和国成立。这一天被确定为中华人民共和国国庆日。\n' +
  '\n' +
  '自此，每年10月1日成为全国人民共同纪念和庆祝的国家节日，用以铭记国家成立的历史时刻。';
originBackground = '经历长期革命斗争和社会变革，中国终于建立起新的国家政权。国庆节的设立，是对国家独立和人民当家作主的重要历史成果的制度化纪念。';
keyFigures = [
  "中华人民共和国创建者",
  "1949年开国大典参与者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '升旗仪式与纪念活动';
customIntroduction1 = '国庆节期间，各地会举行升国旗仪式、纪念大会和主题活动。升旗仪式庄严肃穆，象征国家尊严和民族精神，是国庆节最具仪式感的活动之一。\n' +
  '\n' +
  '通过参与或观看这些仪式，人们在情感上与国家产生更深层次的连接。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '悬挂国旗与节日装饰';
customIntroduction2 = '在国庆节前后，许多家庭、单位和公共场所会悬挂国旗或进行节日装饰，以表达对国家的祝福和认同。\n' +
  '\n' +
  '街道上随处可见的红色元素，使节日氛围既热烈又庄重，成为国庆节最直观的视觉标志。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '观看国庆庆祝活动与文艺节目';
customIntroduction3 = '国庆节期间，电视和网络平台通常会播出国庆庆祝活动、阅兵画面或主题文艺演出。这些节目通过影像方式展示国家发展成就和时代精神。\n' +
  '\n' +
  '许多家庭会共同观看相关节目，在轻松的氛围中增强对国家历史和现实的理解。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '假期出行与家庭团聚';
customIntroduction4 = '国庆节假期为人们提供了集中休息和出行的时间。不少人选择返乡探亲、家庭聚会或外出旅游，在放松身心的同时增进亲情联系。\n' +
  '\n' +
  '这种结合国家纪念与个人生活的方式，使国庆节既具有宏大的国家叙事，也融入了普通人的日常体验。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '回顾历史与爱国教育';
customIntroduction5 = '国庆节也是开展爱国主义教育的重要时刻。学校和社会组织会通过主题学习、展览或参观纪念场馆，引导公众了解国家历史和发展道路。\n' +
  '\n' +
  '通过回顾历史，人们更加珍惜当下的和平与发展成果，也增强对未来建设国家的责任感。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '国庆节在中国社会中具有高度的象征意义。它集中体现了国家认同、民族团结和历史记忆，是凝聚社会共识的重要节日。\n' +
  '\n' +
  '从文化层面看，国庆节将宏大的国家叙事转化为可参与、可感知的节日体验；从现实层面看，它通过假期和庆祝活动，使国家精神融入普通人的生活之中。\n' +
  '\n' +
  '因此，国庆节不仅是一个纪念国家成立的日子，更是一种持续强化国家认同和社会凝聚力的重要文化载体。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Guoqing.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['国庆节'] = festivalDetailInfo;
custom = [];

//重阳节
festivalName = '重阳节';
festivalEnglishName = 'Double Ninth Festival';
simpleIntroduction = '重阳节是中国传统节日之一，时间为农历九月初九。因“九”为阳数，双九相重，故称重阳。它以登高赏秋、敬老孝亲为核心内涵，寄托健康长寿与家庭和乐的祝愿。';
fullDescription = '重阳节，又称重九节、登高节，是中国传统节日体系中兼具自然时令与人文关怀的重要节日。农历九月初九，因“九”为阳数，两个“九”相逢，古人称之为“重阳”，寓意阳气旺盛、长久长寿。\n' +
  '\n' +
  '从时令上看，重阳节多处于秋高气爽之时，适合登高望远、赏菊饮酒，具有鲜明的季节特征。登高不仅是亲近自然的活动，也寓意避灾祈福、步步高升。\n' +
  '\n' +
  '从文化内涵上看，重阳节在现代社会被赋予“敬老”的核心意义。它提醒人们关爱长辈、重视家庭亲情，使节日从自然节庆逐渐转化为承载伦理情感的重要节点。';
originPeriod = '先秦时期有登高避灾与秋祭雏形，唐宋时期节日形态成熟并广泛流传';
originStory = '关于重阳节的起源，民间流传较广的说法与“登高避灾”有关。相传古时有人在九月初九得仙人指点，全家登高并佩茱萸、饮菊花酒，从而避过灾祸。此后，人们逐渐形成在重阳登高、佩茱萸、饮菊酒的传统。\n' +
  '\n' +
  '同时，重阳节也与古代对“九”这一数字的崇尚有关。“九”在传统观念中象征长久与吉祥，双九相重，更被视为寓意长寿和福运的好日子。';
originBackground = '在传统社会中，人们常将时令变化与吉凶祸福联系起来。秋季气候转凉、万物收敛，人们通过登高、饮酒、佩香等方式祈求健康平安。\n' +
  '\n' +
  '随着社会伦理观念的发展，重阳节逐渐与敬老孝亲结合，成为表达家庭关怀与社会温情的重要节日。';
keyFigures = [
  "民间传说中的仙人指点者",
  "重阳登高避灾传说的主人公",
  "历代节俗传承者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '登高望远';
customIntroduction1 = '登高是重阳节最典型的习俗之一。人们会选择登山、登塔或到高处远眺，欣赏秋日景色。传统观念认为登高具有避灾祈福的寓意，也象征“步步高升”“远离晦气”。\n' +
  '\n' +
  '在现代生活中，登高更多成为一种健康的户外活动。家人结伴出行，在秋高气爽的季节里运动、交流，不仅能强身健体，也能在陪伴中增进亲情。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '赏菊与饮菊花酒';
customIntroduction2 = '重阳时节正值菊花盛开，赏菊成为节日的重要活动。菊花在传统文化中象征高洁、坚韧与长寿，因此与重阳“长久”的寓意相契合。\n' +
  '\n' +
  '部分地区还有饮菊花酒的习俗，古人认为菊花具有清雅与养生之意。如今，很多人会以菊花茶或菊花主题食品替代传统菊花酒，用更日常的方式延续赏菊养生的节日文化。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '佩茱萸';
customIntroduction3 = '佩茱萸是重阳节的传统习俗之一。茱萸气味芳香，古人认为其具有驱虫避邪、祈求平安的作用，因此在重阳这天会将茱萸佩戴在身上或插在门窗上。\n' +
  '\n' +
  '现代城市生活中，佩茱萸的做法已不如过去普遍，但它依然作为传统符号存在于节日文化中，体现了人们对健康平安的朴素愿望。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '吃重阳糕';
customIntroduction4 = '吃重阳糕也是重阳节常见的习俗。重阳糕多为层层叠叠的糕点，寓意“步步高”“登高得福”，与重阳登高的主题相呼应。\n' +
  '\n' +
  '不同地区的重阳糕口味各异，有甜有咸，有的还会点缀红枣、栗子等食材。糕点不仅是节日美食，也让“节日祝愿”通过饮食自然融入家庭生活。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '敬老孝亲';
customIntroduction5 = '在现代社会，重阳节最重要的意义之一是“敬老”。人们会在这一天看望长辈、陪伴老人、为老人准备一顿饭或安排体检，以实际行动表达关心与感谢。\n' +
  '\n' +
  '敬老不仅是一句祝福，更是一种持续的陪伴与尊重。重阳节提供了一个温柔的提醒：在快节奏生活中，也要把时间留给家人，把关怀落实到具体细节里。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '重阳节的文化意义在于把“顺应自然时令”与“家庭伦理情感”结合起来。它通过登高赏秋，让人们亲近自然、强健体魄；通过敬老孝亲，让关怀与陪伴成为节日核心。\n' +
  '\n' +
  '从传统观念看，重阳的“双九”象征长久与长寿，表达了中国人对健康平安、家庭和乐的朴素追求；从现代价值看，重阳节强化了尊老敬老的社会共识，体现社会温度与文明进步。\n' +
  '\n' +
  '因此，重阳节不仅是一个古老节日，也是一种持续提醒人们珍惜亲情、珍惜时间的文化仪式。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Chongyang.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['重阳节'] = festivalDetailInfo;
custom = [];

//万圣节
festivalName = '万圣节';
festivalEnglishName = 'Halloween';
simpleIntroduction = '万圣节是流行于西方国家的传统节日，时间为每年10月31日。它以奇幻、幽默和节日娱乐为特色，人们通过装扮、游戏和互动活动感受节日氛围。';
fullDescription = '万圣节起源于西方传统节日，是一个融合了宗教信仰、民间传说与现代娱乐文化的节日。虽然名称中带有“圣”的含义，但在现代社会，万圣节更多表现为轻松、有趣、富有想象力的民俗节日。\n' +
  '\n' +
  '在万圣节前夜，人们会装饰房屋、点亮南瓜灯、身着各式服装参与庆祝活动。节日氛围以神秘、奇幻和幽默为主，强调“扮演”和“互动”，让参与者暂时跳脱日常身份，体验不同角色。\n' +
  '\n' +
  '随着文化交流的加深，万圣节逐渐在全球范围内流行开来。在许多国家和地区，它已成为年轻人和儿童喜爱的节日，以娱乐、社交和创意表达为主要内容。';
originPeriod = '古代凯尔特时期形成雏形，后在中世纪与基督教传统融合';
originStory = '万圣节的起源可追溯至古代凯尔特人的“萨温节”。凯尔特人认为，10月31日是夏季结束、冬季开始的分界点，这一夜人间与灵界的界限变得模糊。\n' +
  '\n' +
  '后来，基督教将11月1日定为万圣节（诸圣节），前一晚逐渐演变为“万圣节前夜”，即今天的万圣节。随着时间推移，宗教意味逐渐淡化，民俗和娱乐元素不断增强。';
originBackground = '在古代欧洲，人们对自然变化和未知世界充满敬畏。季节更替常被赋予神秘意义，相关节日也承载了驱邪避灾和祈求平安的心理需求。万圣节正是在这种自然观念与民间信仰的背景下逐步形成。';
keyFigures = [
  "古代凯尔特人",
  "中世纪民间信仰传承者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '化装与角色扮演';
customIntroduction1 = '万圣节最具代表性的习俗是化装和角色扮演。人们会穿上各种服装，扮成鬼怪、动画角色、超级英雄或夸张形象，在节日中体验“变身”的乐趣。\n' +
  '\n' +
  '这种装扮并不局限于恐怖风格，更多体现创意和幽默感。通过角色扮演，人们暂时摆脱现实身份，在轻松的氛围中释放压力、展现个性。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '不给糖就捣蛋';
customIntroduction2 = '“不给糖就捣蛋”是万圣节中深受儿童喜爱的传统活动。孩子们会身穿服装，挨家挨户敲门索要糖果，主人则以糖果或小礼物回应。\n' +
  '\n' +
  '这一习俗强调互动和分享，让孩子在游戏中体验社交乐趣，也让社区关系更加活跃和亲近。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '制作南瓜灯';
customIntroduction3 = '制作南瓜灯是万圣节的重要象征性活动。人们会在南瓜上雕刻夸张的表情，并在内部点灯，形成独特的节日装饰。\n' +
  '\n' +
  '南瓜灯最初源于民间传说，象征驱赶邪灵。如今，它更多代表万圣节的趣味和氛围，成为节日中极具辨识度的视觉符号。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '万圣节主题聚会';
customIntroduction4 = '在万圣节期间，朋友或同事常会举办主题派对，通过装扮、游戏和音乐共同庆祝。派对通常结合恐怖、搞怪或卡通主题，让节日氛围更加热闹。\n' +
  '\n' +
  '这种聚会形式增强了节日的社交属性，使万圣节成为增进互动、拉近关系的重要时刻。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '节日装饰与氛围布置';
customIntroduction5 = '万圣节前后，人们会用南瓜、蜘蛛网、幽灵玩偶等装饰房屋和公共空间，营造神秘又欢乐的节日氛围。\n' +
  '\n' +
  '这些装饰不仅增强了视觉效果，也让节日提前“进入状态”，使参与者在日常生活中就能感受到节日的存在感。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '万圣节的文化意义在于为社会提供一个释放想象力和幽默感的节日空间。它通过夸张、扮演和游戏，让人们以轻松的方式面对“恐惧”和未知。\n' +
  '\n' +
  '从现代视角看，万圣节更像是一种文化娱乐节日，强调创意表达、社交互动和情绪释放。它在全球传播过程中不断被本土化，展现出强大的文化包容性。\n' +
  '\n' +
  '因此，万圣节不仅是一个西方传统节日，也逐渐成为现代城市文化中充满趣味与想象力的节庆符号。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Wansheng.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['万圣节'] = festivalDetailInfo;
custom = [];

//感恩节
festivalName = '感恩节';
festivalEnglishName = 'Thanksgiving Day';
simpleIntroduction = '感恩节是起源于西方的传统节日，主要流行于美国和加拿大，用于感谢收获、表达感恩之情，并通过家庭聚会和共享美食增进亲情与友谊。';
fullDescription = '感恩节是一个以“感谢与分享”为核心主题的节日。在美国，感恩节通常定在每年11月的第四个星期四；在加拿大，则定在10月的第二个星期一。尽管日期不同，但节日精神高度一致。\n' +
  '\n' +
  '感恩节最初与早期移民的生存经历和丰收庆祝有关。随着时间推移，它逐渐从宗教与历史纪念活动，发展为强调家庭团聚、情感交流和生活感恩的全民性节日。\n' +
  '\n' +
  '在现代社会，感恩节不再局限于特定信仰背景，而成为一种普遍的生活态度表达。人们借助这一节日，反思一年中的收获与支持来源，向家人、朋友以及社会表达感谢之情。';
originPeriod = '17世纪初北美殖民时期形成雏形，18—19世纪逐渐定型';
originStory = '感恩节的起源通常追溯至17世纪初。相传早期欧洲移民在北美经历了艰难的生存时期，在当地原住民的帮助下成功度过困境并获得丰收。\n' +
  '\n' +
  '为感谢上天的眷顾和他人的帮助，他们举行了丰收宴会，共同分享食物并表达感激之情。这种庆祝方式逐渐演变为感恩节的核心传统。';
originBackground = '在早期移民社会中，自然环境严酷，生存高度依赖合作与互助。感恩节正是在感谢自然馈赠、珍视人与人之间支持关系的社会背景下逐渐形成。';
keyFigures = [
  "早期欧洲移民",
  "北美原住民"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '家庭聚会与共享晚餐';
customIntroduction1 = '感恩节最重要的习俗是家庭成员团聚，共同享用感恩节晚餐。无论居住多远，许多人都会在这一天返回家中，与家人围坐一桌，分享食物和近况。\n' +
  '\n' +
  '这种聚会不仅是饮食上的共享，更是情感上的连接，让节日成为一年中最具家庭氛围的时刻之一。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '享用传统感恩节美食';
customIntroduction2 = '感恩节晚餐通常包括烤火鸡、土豆泥、南瓜派、蔓越莓酱等传统食物。每道菜品都象征着丰收和富足，体现节日的历史渊源。\n' +
  '\n' +
  '准备和分享这些食物的过程，也成为家庭成员共同参与的重要环节，使节日充满仪式感和温暖气息。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '表达感谢与分享感恩之事';
customIntroduction3 = '在感恩节聚会中，人们常会轮流表达自己一年中最感激的人或事情。这种分享有助于增强彼此理解，让感恩从抽象概念转化为具体表达。\n' +
  '\n' +
  '通过说出感谢，参与者更容易意识到生活中被忽略的支持与善意，从而培养积极、珍惜的心态。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '观看感恩节活动与游行';
customIntroduction4 = '在一些国家和地区，感恩节期间会举办大型游行和公共庆祝活动。例如感恩节游行已成为具有代表性的节日活动之一，吸引大量观众观看。\n' +
  '\n' +
  '这些活动增强了节日的公共属性，使感恩节不仅存在于家庭内部，也成为社会共同参与的庆典。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '慈善与公益行动';
customIntroduction5 = '感恩节也是许多人参与慈善和公益活动的时刻。人们会向需要帮助的人捐赠食物、物资或时间，用实际行动分享节日的温暖。\n' +
  '\n' +
  '这种行为延伸了感恩节的精神内涵，让“感恩”不仅停留在语言层面，也转化为对社会的积极回馈。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '感恩节的文化意义在于强化“感谢与分享”的价值观。它通过家庭聚会、食物共享和情感表达，让人们在快节奏生活中重新审视人与人之间的关系。\n' +
  '\n' +
  '从社会层面看，感恩节鼓励互助与慈善，增强社区凝聚力；从个人层面看，它帮助人们培养感恩心态，提升生活的满足感与幸福感。\n' +
  '\n' +
  '因此，感恩节不仅是一个节日，更是一种持续影响人们生活方式和价值取向的文化象征。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Ganeng.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['感恩节'] = festivalDetailInfo;
custom = [];

//平安夜
festivalName = '平安夜';
festivalEnglishName = 'Christmas Eve';
simpleIntroduction = '平安夜是圣诞节前夕的重要节日，时间为每年12月24日。它以“平安、祝福与期待”为主题，人们通过聚会、祝福和仪式感活动，迎接圣诞节的到来。';
fullDescription = '平安夜是圣诞节的前一晚，在西方文化中具有重要意义。相比圣诞节当天的热闹庆祝，平安夜的氛围更加温馨、宁静，强调家庭团聚、内心平安与情感交流。\n' +
  '\n' +
  '在基督教传统中，平安夜被视为耶稣诞生前的夜晚，人们通过祈祷和礼拜迎接圣诞节的到来。“平安”象征着祝福、守护与希望，也寄托了人们对幸福生活的向往。\n' +
  '\n' +
  '随着文化传播与本土化发展，平安夜在许多国家和地区逐渐演变为带有节日娱乐和社交属性的节日。无论是否具有宗教背景，人们都愿意在这一天表达祝福、分享温暖，使平安夜成为一年中富有情感色彩的时刻。';
originPeriod = '公元4世纪后基督教圣诞礼仪体系逐渐形成时期';
originStory = '平安夜源于基督教对耶稣诞生的纪念。相传耶稣诞生之夜，天使向世人报喜，宣告“平安降临人间”，因此这一夜被赋予了特殊的宗教意义。\n' +
  '\n' +
  '随着圣诞节庆祝形式的逐渐固定，12月24日夜晚成为迎接圣诞的重要时刻，并在长期传承中形成平安夜这一节日概念。';
originBackground = '在中世纪欧洲社会，宗教生活占据重要位置，圣诞节逐渐成为年度核心节庆之一。平安夜作为节日前夜，承担着精神准备和情感凝聚的功能。\n' +
  '\n' +
  '进入现代社会后，平安夜逐渐超越宗教范畴，融入节日消费、社交活动和文化娱乐，成为具有广泛参与度的节日。';
keyFigures = [
  "耶稣（宗教传统）",
  "基督教天使报喜传说中的形象"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '互赠平安果';
customIntroduction1 = '在一些地区，尤其是在中国，平安夜有互赠“平安果”的习俗。苹果因与“平安”谐音，被赋予平安祝福的寓意，人们通过赠送苹果表达对亲友健康、顺遂的美好祝愿。\n' +
  '\n' +
  '这种习俗虽非西方传统，却体现了节日本土化的特点，使平安夜在现代生活中更具亲切感和参与感。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '家庭或朋友聚会';
customIntroduction2 = '平安夜常被视为团聚的时刻。家人或朋友会在这一天共进晚餐、聊天交流，分享一年中的经历与感受。\n' +
  '\n' +
  '相比大型庆祝活动，这种小范围、重情感的聚会更突出平安夜的温暖特质，让参与者在轻松的氛围中感受到陪伴与支持。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '参加平安夜礼拜或音乐活动';
customIntroduction3 = '在基督教文化中，平安夜的重要活动之一是参加平安夜礼拜。教堂中会举行诵读圣经、祈祷和合唱圣诗等仪式，营造庄重而安宁的氛围。\n' +
  '\n' +
  '即使不参与宗教活动，许多人也会在平安夜欣赏圣诞音乐会或聆听圣诞歌曲，通过音乐感受节日的宁静与美好。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '布置圣诞装饰';
customIntroduction4 = '平安夜前后，人们会装饰圣诞树、悬挂彩灯和装饰品，为即将到来的圣诞节营造节日氛围。\n' +
  '\n' +
  '装饰过程本身也是一种仪式感体验，让家庭成员在共同准备中感受到期待和喜悦，使节日氛围逐渐升温。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '送上祝福与内心祈愿';
customIntroduction5 = '在平安夜，人们常通过短信、贺卡或面对面的方式互致祝福，表达对彼此平安、幸福和希望的祝愿。\n' +
  '\n' +
  '对许多人而言，平安夜也是一个安静反思的时刻，在忙碌的一年即将结束之际，为自己和他人许下关于健康、平安与未来的美好愿望。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '平安夜的文化意义在于强调“平安”这一普世价值。无论宗教背景如何，人们都渴望安宁、陪伴与希望，而平安夜为这种情感提供了集体表达的时间与空间。\n' +
  '\n' +
  '从家庭层面看，平安夜强化了陪伴与关怀的重要性；从社会层面看，它通过祝福与分享，传递温和、友善的情绪氛围。\n' +
  '\n' +
  '因此，平安夜不仅是圣诞节的前奏，也是一个让人放慢脚步、感受温暖与善意的节日时刻。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Pinganye.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['平安夜'] = festivalDetailInfo;
custom = [];

//圣诞节
festivalName = '圣诞节';
festivalEnglishName = 'Christmas';
simpleIntroduction = '圣诞节是西方重要传统节日，时间为每年12月25日。它以庆祝、祝福与分享为核心主题，人们通过家庭团聚、赠送礼物和节日活动，传递爱与希望。';
fullDescription = '圣诞节起源于基督教传统，用以纪念耶稣的诞生。随着历史发展，它逐渐从宗教节日演变为兼具宗教、文化和社会意义的全球性节日。\n' +
  '\n' +
  '在许多国家和地区，圣诞节是一年中最重要的家庭节日之一。人们在这一天暂别忙碌，回归家庭与亲情，通过聚会、交流和仪式化活动，感受温暖与陪伴。\n' +
  '\n' +
  '在现代社会，圣诞节的内涵更加开放。即使不具备宗教背景，人们也会参与到装饰、聚会和祝福之中，使圣诞节成为跨文化、跨信仰的节日象征。';
originPeriod = '公元4世纪后基督教节庆体系逐渐确立时期';
originStory = '圣诞节源于基督教对耶稣诞生的纪念。相传耶稣诞生在伯利恒，天使向牧羊人报喜，宣告救世主降临。\n' +
  '\n' +
  '后来，教会将12月25日定为圣诞节，用以集中纪念这一事件。随着基督教传播，圣诞节逐渐在欧洲和世界各地流行开来，并不断吸收地方文化元素。';
originBackground = '在中世纪欧洲，宗教节日是社会生活的重要组成部分。圣诞节作为年度核心节庆之一，承担着凝聚信仰与社区情感的功能。\n' +
  '\n' +
  '进入现代社会后，圣诞节逐渐融入商业、文化和娱乐元素，形成今天广泛参与、形式多样的节日形态。';
keyFigures = [
  "耶稣（宗教传统）",
  "圣经记载中的牧羊人",
  "圣诞文化传承者"
]
origin = new FestivalOrigin(originPeriod,originStory,originBackground,keyFigures);

customName1 = '装饰圣诞树';
customIntroduction1 = '装饰圣诞树是圣诞节最具象征性的习俗之一。人们会在家中或公共场所布置圣诞树，悬挂彩灯、彩球和装饰品。\n' +
  '\n' +
  '装饰过程本身就是节日的重要仪式，象征对节日的期待与祝福，也让家庭成员在共同参与中感受到节日的喜悦。';
custom.push(new FestivalCustom(customName1,customIntroduction1));

customName2 = '互赠圣诞礼物';
customIntroduction2 = '赠送礼物是圣诞节的重要习俗之一。人们会为家人、朋友或孩子准备礼物，以表达关心和祝福。\n' +
  '\n' +
  '礼物的意义不在于价值，而在于心意。通过赠送礼物，人们传递爱与感谢，让节日充满温情和惊喜。';
custom.push(new FestivalCustom(customName2,customIntroduction2));

customName3 = '家庭聚餐与圣诞大餐';
customIntroduction3 = '圣诞节当天，许多家庭会准备丰盛的圣诞大餐，如烤火鸡、甜点和特色节日食品。\n' +
  '\n' +
  '一家人围坐在一起共享美食，是圣诞节最重要的时刻之一。这种聚餐强调陪伴与分享，让节日回归家庭本身。';
custom.push(new FestivalCustom(customName3,customIntroduction3));

customName4 = '发送圣诞祝福';
customIntroduction4 = '在圣诞节期间，人们会通过贺卡、短信或社交媒体互致祝福，表达对平安、幸福和美好未来的祝愿。\n' +
  '\n' +
  '这些祝福让节日氛围在家庭之外扩散到朋友、同事和更广泛的社会关系中。';
custom.push(new FestivalCustom(customName4,customIntroduction4));

customName5 = '参加圣诞活动与娱乐';
customIntroduction5 = '圣诞节期间，许多地方会举办圣诞集市、音乐会、表演或主题活动，营造浓厚的节日氛围。\n' +
  '\n' +
  '通过参与这些活动，人们在娱乐和社交中感受节日的欢乐，使圣诞节成为一年中最具活力的时刻之一。';
custom.push(new FestivalCustom(customName5,customIntroduction5));

culturalSignificance = '圣诞节的文化意义在于传递爱、分享与希望的价值观。它通过家庭团聚和节日仪式，让人们在一年结束之际重新关注情感连接。\n' +
  '\n' +
  '从社会层面看，圣诞节促进了人与人之间的关怀与互动；从个人层面看，它为人们提供了放慢脚步、感受温暖的机会。\n' +
  '\n' +
  '因此，圣诞节不仅是一个传统节日，更是一种跨文化的情感表达方式，持续影响着现代社会的节日生活。';

festivalDetailInfo = new FestivalDetailInfo($rawfile('Festival/Shengdan.png'),festivalName,festivalEnglishName,
  simpleIntroduction,fullDescription,origin,custom,culturalSignificance);
FestivalDetailData['圣诞节'] = festivalDetailInfo;
custom = [];