import { NaturalAttribute, SolarTermsDetailInfo} from '../pages/Model/SolarTermsDetailInfo'

export let SolarTermsDetailData : Record<string,SolarTermsDetailInfo> = {};

//春分
let name = '春分';
let EnglishName = 'Spring Equinox';
let SolarDateRange = '每年3月20日—22日之间';
let briefIntroduction = '春分是二十四节气之一，标志着春季的中点。这一天昼夜几乎等长，之后白昼逐渐变长，万物进入加速生长阶段。';
let meaning = '“春分”中的“分”有两层含义：\n' +
  '一是昼夜平分，春分这一天太阳直射赤道，全球大部分地区昼夜时间几乎相等；\n' +
  '二是季节平分，春分正处于春季的中间位置，象征春意由“生”转向“盛”。\n' +
  '\n' +
  '在古代农耕社会中，春分是判断气候变化、安排春耕生产的重要时间节点，具有明显的天文和农业指导意义。';
let climateFeatures = '春分前后，气温总体呈明显回升趋势，寒冷逐渐退去，天气由不稳定向温和过渡。\n' +
  '南方地区降水开始增多，春雨频繁；北方地区昼夜温差仍较大，但整体寒意明显减弱。\n' +
  '随着太阳高度升高，光照增强，为植物生长提供了良好条件。';
let phenology = '春分时节，自然界生机显现：\n' +
  '花草迅速生长，桃花、杏花等陆续盛开\n' +
  '草木萌发，新芽明显增多\n' +
  '鸟类活动频繁，鸣叫增多\n' +
  '昆虫逐渐苏醒，田野生气渐盛\n' +
  '古代将春分物候概括为“玄鸟至、雷乃发声、始电”，形象地描绘了自然苏醒的过程。';
let naturalAttributes : NaturalAttribute = new NaturalAttribute(climateFeatures,phenology);
let customs = '春分在民间虽不像春节那样隆重，但仍保留着一些具有节气特色的习俗。\n' +
  '在部分地区，人们有立蛋的传统，认为春分时天地平衡，鸡蛋更容易竖立，象征好运与平衡。\n' +
  '农耕地区则注重春分后的春耕准备，检查农具、翻整土地，为播种创造条件。\n' +
  '此外，还有踏青出游、亲近自然的习惯，人们借助温暖的春光舒展身心，迎接春季的旺盛阶段。';
let solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Chunfen.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
naturalAttributes,customs);
SolarTermsDetailData['春分'] = solarTermsDetailInfo;

//立春
name = '立春';
EnglishName = 'Beginning of Spring';
SolarDateRange = '每年2月3日—5日之间';
briefIntroduction = '立春是二十四节气之首，象征春季开始。虽然天气未必立刻转暖，但自然界的生发之气逐渐增强，万物开始由“藏”转“生”，民间也将其视为新一轮时序的起点。';
meaning = '“立”有开始之意，“春”代表温暖、生长与生机。立春意味着自然从冬季的闭藏状态转向春季的生发阶段，是一年节气循环的开端。\n' +
  '从天文角度看，立春通常出现在太阳到达黄经315°时，标志着太阳运行进入新的区间。\n' +
  '在农耕文化中，立春具有很强的指导意义：它提示人们要开始关注气温回升、土壤解冻、春耕筹备等事项，是安排一年农事的重要时间节点。';
climateFeatures = '立春前后整体仍处于冬末阶段，但气温趋势由“下降”转为“缓慢回升”。\n' +
  '北方：寒意仍重，可能仍有降雪与霜冻，但白昼逐渐变长，冷空气强度开始减弱。\n' +
  '南方：湿润增多，早春阴雨逐渐增多，部分地区开始出现回暖与春雨。\n' +
  '这段时间天气变化较大，容易出现“乍暖还寒”，昼夜温差明显，传统上强调顺应气候变化、注意保暖与调养。'
phenology = '立春的物候变化体现“春气初生”：\n' +
  '冰雪开始消融，河面渐开\n' +
  '草木萌动，树芽逐渐膨大，早春植物开始抽新\n' +
  '鸟类活动增加，鸣叫更频繁\n' +
  '昆虫开始苏醒，虽未大量出现，但自然界“动”的迹象变多\n' +
  '古代物候有概括性说法，如“东风解冻、蛰虫始振、鱼陟负冰”，形象描绘了早春苏醒的变化。'
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '立春在民间有较丰富的迎春习俗。传统上，人们会通过“迎春”“报春”等方式表达对新一年风调雨顺的期盼。\n' +
  '较典型的习俗包括：\n' +
  '咬春：在立春吃萝卜、春饼或生菜等，寓意“咬住春天”，迎接生机，寄托健康与好运的愿望。\n' +
  '打春 / 鞭春牛：部分地区会举行象征性的“鞭春牛”仪式，以春牛代表农耕生产，鞭打寓意催促春耕开始，祈求五谷丰登。\n' +
  '贴春字、挂春幡：有的地方会张贴与“春”相关的字画或装饰，营造迎春氛围。\n' +
  '踏春：天气稍暖时，人们也会出门走走，亲近自然，感受春意初现。'
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Lichun.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
naturalAttributes,customs);
SolarTermsDetailData['立春'] = solarTermsDetailInfo;

//雨水
name = '雨水';
EnglishName = 'Rain Water';
SolarDateRange = '每年2月18日—20日之间';
briefIntroduction = '雨水是二十四节气之一，紧随立春之后，表示降水开始增多、冰雪渐融，天气由寒向暖过渡，万物萌动的迹象更加明显。';
meaning = '“雨水”含义直观，指降雨开始出现并逐渐增多。雨水节气的到来，意味着气温回升、雪渐少而雨渐多，空气湿度增加，春意更浓。\n' +
  '从节气规律看，雨水提示人们顺应季节变化：冬季的闭藏逐步结束，春季的生发开始加速。对农业而言，雨水是春耕筹备的关键信号，预示田间管理、整地备耕将陆续展开。\n' +
  '\n' +
  '虽然各地气候差异明显，但雨水总体象征自然进入一个更适宜生长的阶段，为后续的惊蛰、春分等节气奠定基础。';
climateFeatures = '雨水前后气温继续回升，但冷暖空气交替频繁，天气变化较快，容易出现忽冷忽热的情况。\n' +
  '南方降雨开始增多，常见连绵细雨或间歇性降雨，湿度明显上升；北方虽降水不多，但冰雪逐步消融，风力偏大，空气仍较干冷。\n' +
  '这一时期昼夜温差较大，早晚偏凉，日间相对温和，适合逐步减少厚重衣物但仍需注意保暖防寒。';
phenology = '雨水时节，万物萌动更加明显：\n' +
  '河湖解冻加快，积雪逐步消融\n' +
  '草木返青，新芽更易被观察到\n' +
  '候鸟活动增多，鸟鸣更频繁\n' +
  '部分地区昆虫开始苏醒，田野生气渐起\n' +
  '古代物候常概括为“獭祭鱼、鸿雁来、草木萌动”，用来描述早春生发与动物活动逐渐恢复的过程。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '雨水节气的民俗相对朴素，多围绕祈求风调雨顺、迎接春耕展开。\n' +
  '一些地方有祈雨或祭祀活动，表达对及时雨水和丰收的期望。\n' +
  '在部分地区流行“回娘家”或“送雨水”的习俗，女儿带礼回娘家探望父母，寓意亲情和顺、生活滋润。\n' +
  '农事上，雨水之后人们会开始整地备耕、修整农具、准备种子肥料，为春耕春播做准备。\n' +
  '同时不少人会选择雨水时节踏青散步，感受早春气息，也提醒自己顺应季节调整作息与饮食。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Yushui.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['雨水'] = solarTermsDetailInfo;

//惊蛰
name = '惊蛰';
EnglishName = 'Awakening of Insects';
SolarDateRange = '每年3月5日—7日之间';
briefIntroduction = '惊蛰是二十四节气之一，表示春雷初响、万物复苏，冬眠的昆虫和动物逐渐苏醒，春耕活动也开始进入更忙碌的阶段。';
meaning = '“惊蛰”意为被雷声惊醒的蛰伏之物。“蛰”指冬季潜藏休眠的昆虫和小动物，“惊”则指春雷乍动带来的唤醒。\n' +
  '惊蛰到来，代表气温明显回升，土壤解冻加快，动植物生命活动增强。古人观察到此时雷声增多、虫鸣渐起，便用“惊蛰”来概括这种由静转动的季节变化。\n' +
  '\n' +
  '在农业上，惊蛰意味着春耕春管进入关键时期，许多地区开始播种、育苗、施肥和防治病虫害，为全年收成打下基础。';
climateFeatures = '惊蛰前后气温回升速度加快，冷空气影响减弱，但仍可能出现阶段性降温，天气变化较快。\n' +
  '南方降水增多，常见春雨或阵雨，空气湿润；北方逐步转暖，风力较大，干燥明显缓解但昼夜温差仍较大。\n' +
  '这一时期雷暴活动开始增多，尤其在南方更为明显，提示春季对流天气逐渐活跃。';
phenology = '惊蛰时节，自然界呈现明显的复苏景象：\n' +
  '春雷出现，雷声渐多\n' +
  '昆虫苏醒，开始活动和鸣叫\n' +
  '草木抽芽加快，嫩叶萌发明显\n' +
  '候鸟回归，田野生气更盛\n' +
  '古代物候常概括为“桃始华、仓庚鸣、鹰化为鸠”，描绘了花开、鸟鸣与生物活动增多的早春特征。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '惊蛰的习俗多与迎春祈福、除虫防病有关，体现了人们对健康与丰收的期盼。\n' +
  '一些地方有祭白虎、打小人等民俗活动，寓意驱邪避害、祈求平安顺遂。\n' +
  '也有“炒虫”或“吃梨”的习惯，象征驱虫除害、润燥养生，希望一年少病少灾。\n' +
  '农事方面，惊蛰后不少地区会开始忙春耕，进行播种育苗、施肥松土、清沟排水等田间管理，同时提前做好病虫害预防。\n' +
  '此外，天气转暖后，人们也会选择适度踏青活动，舒展身心，顺应季节调整作息。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Jingzhe.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['惊蛰'] = solarTermsDetailInfo;

//清明
name = '清明';
EnglishName = 'Clear and Bright';
SolarDateRange = '每年4月4日—6日之间';
briefIntroduction = '清明是二十四节气之一，气候温暖、草木繁茂，天气逐渐清朗明净，既是春耕春种的重要时段，也是人们踏青出游和祭祖扫墓的集中时期。';
meaning = '“清明”意为天气清澈明朗。此时气温继续回升，降水增多而不过分寒冷，阳光更充足，天地呈现清新明净的状态。\n' +
  '作为节气，清明是农业生产的重要节点，古人常以“清明前后，种瓜点豆”来概括其对春播的指导意义。\n' +
  '\n' +
  '同时，清明在历史发展中与祭祖扫墓的民俗结合，形成了节气与节日相互交织的独特现象，使“清明”既有自然时令的意义，也承载着追思先人的情感内涵。';
climateFeatures = '清明前后气温明显转暖，冷空气影响进一步减弱，天气整体更稳定，阳光更充足。\n' +
  '南方降水较频繁，常见春雨或间歇性降雨，空气湿润，利于作物生长；北方回暖显著，风力仍可能偏大，昼夜温差逐渐缩小。\n' +
  '总体上此时适合户外活动，但仍需注意早晚偏凉以及降雨带来的湿冷感。';
phenology = '清明时节，草木繁茂，生机旺盛：\n' +
  '柳枝吐绿，花木进入盛开期\n' +
  '田野返青明显，嫩草遍地\n' +
  '鸟类活动频繁，虫鸣渐盛\n' +
  '部分地区雨后空气清新，能见度提升\n' +
  '古代物候常概括为“桐始华、田鼠化为鴽、虹始见”，用来描述花开、动物活动变化和雨后彩虹出现的时令特征。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '清明的习俗与节气特点紧密相关，既有追思纪念，也有亲近自然的内容。\n' +
  '祭祖扫墓是最重要的习俗之一，人们会整理墓地、献花供品、表达追思，以传承家族记忆和感恩之情。\n' +
  '踏青出游也很普遍，春光明媚时，人们到郊外赏花观景、散步休闲，感受万物生长的气息。\n' +
  '此外还有放风筝的传统，一些地方认为风筝可以带走烦恼与不顺，象征迎来清新与顺遂。\n' +
  '在饮食方面，部分地区会食用青团等时令食品，让节气文化融入日常生活。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Qingming.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['清明'] = solarTermsDetailInfo;

//谷雨
name = '谷雨';
EnglishName = 'Grain Rain';
SolarDateRange = '每年4月19日—21日之间';
briefIntroduction = '谷雨是春季最后一个节气，表示降雨增多，有利于谷物生长。此时气温回升明显，春耕春播进入关键阶段，万物生长更为旺盛。';
meaning = '“谷雨”意为“雨生百谷”，强调雨水对庄稼尤其是谷物作物生长的重要作用。谷雨到来，降水增多且更加稳定，能缓解春旱，为播种出苗和作物拔节提供条件。\n' +
  '在节气序列中，谷雨处在春末夏初的过渡阶段，代表春季生发趋于饱满，气候逐步向温热转变。\n' +
  '\n' +
  '农业上常有“谷雨前后，种瓜点豆”的说法，提示人们把握时机完成播种与田间管理，为夏季作物生长打下基础。';
climateFeatures = '谷雨前后气温继续上升，冷空气影响明显减弱，天气逐渐转向温暖甚至偏热。\n' +
  '南方降雨更频繁，湿度增加，常出现连续阴雨或雷阵雨；北方降水也有所增多，但仍需关注阶段性干燥和大风天气。\n' +
  '此时对流活动增强，雷雨天气逐渐多见，气候从春季的多变向初夏的湿热过渡。';
phenology = '谷雨时节，生长进入加速期：\n' +
  '树木枝叶繁茂，花期逐渐进入尾声\n' +
  '田间作物出苗生长快，杂草也更旺\n' +
  '昆虫活动频繁，虫鸣明显增多\n' +
  '雨后空气湿润，山野更显青绿\n' +
  '古代物候常概括为“萍始生、鸣鸠拂其羽、戴胜降于桑”，描绘了水生植物出现、鸟类繁忙与桑树相关的时令变化。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '谷雨的民俗多与祈雨、惜春和农事准备相关，整体氛围偏向务实与应时。\n' +
  '不少地方有采摘春茶的习惯，谷雨前后的茶叶被认为更鲜嫩，民间也常称“谷雨茶”，象征把握春末的好时光。\n' +
  '部分地区会进行春末的农事祭祀或祈福活动，表达对风调雨顺、庄稼丰收的期望。\n' +
  '随着天气转暖，人们也会进行春末踏青赏花，感受春意收尾的景致，有惜春之意。\n' +
  '同时谷雨后田间管理任务加重，农家会忙于播种、间苗、施肥与防治病虫害，为即将到来的夏季生长季做准备。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Guyu.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['谷雨'] = solarTermsDetailInfo;

//立夏
name = '立夏';
EnglishName = 'Beginning of Summer';
SolarDateRange = '每年5月5日—7日之间';
briefIntroduction = '立夏是二十四节气之一，标志夏季开始。气温明显升高，日照增强，雨水增多，万物由春生转入夏长，农事进入繁忙阶段。';
meaning = '“立夏”中的“立”是开始，“夏”代表温热与生长。立夏意味着季节由春转夏，自然界的生长节奏从萌发走向旺盛，进入“长”的阶段。\n' +
  '从天文角度看，立夏通常在太阳到达黄经45°时到来，提示太阳高度进一步升高，光照更强。\n' +
  '\n' +
  '在农耕社会中，立夏是重要的生产提醒：春播作物进入生长期，夏收作物临近成熟，田间管理工作增多，人们需要抓紧时机做好灌溉、除草、施肥与防病虫等工作。';
climateFeatures = '立夏前后气温上升明显，热感增强，白昼变长，日照更充足。\n' +
  '南方降雨逐渐增多，空气湿度上升，常出现阵雨或雷雨，部分地区开始进入雨季特征；北方也逐步转暖，但仍可能出现短暂降温，昼夜温差相对缩小。\n' +
  '总体上天气从春季的多变转向更稳定的温热，但也更容易出现对流天气，需要注意降雨和闷热带来的不适。';
phenology = '立夏时节，万物进入旺盛生长期：\n' +
  '树木枝繁叶茂，草木生长迅速\n' +
  '花期逐渐更替，春花减少，夏花陆续开放\n' +
  '昆虫活动明显增多，虫鸣更常见\n' +
  '鸟类育雏繁忙，田野生机浓烈\n' +
  '古代物候常概括为“蝼蝈鸣、蚯蚓出、王瓜生”，描绘了虫类活跃、土中生物出动和藤蔓植物生长的时令变化。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '立夏的习俗多与迎夏、祈安和饮食应季相关，体现人们对健康与丰收的期待。\n' +
  '一些地方有称体重的传统，认为立夏称重可以了解身体状态，寓意安康，也寄托夏季不生病的愿望。\n' +
  '立夏还有吃应季食物的习惯，如立夏蛋、豌豆饭等，寓意补充体力、迎接夏天的生长旺季。\n' +
  '部分地区会进行简单的迎夏仪式或家庭聚餐，象征季节更替，提醒家人调整作息与饮食。\n' +
  '农事上立夏后田间管理更繁忙，人们会加强灌溉、除草、追肥和防虫，确保作物顺利进入夏季生长阶段。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Lixia.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['立夏'] = solarTermsDetailInfo;

//小满
name = '小满';
EnglishName = 'Grain Buds';
SolarDateRange = '每年5月20日—22日之间';
briefIntroduction = '小满是二十四节气之一，表示夏熟作物的籽粒开始灌浆饱满但尚未成熟。此时气温升高、雨水增多，农事以田间管理和防涝防旱为重点。';
meaning = '“小满”的“满”多指庄稼籽粒的饱满程度。“小”表示尚未达到完全成熟，意为谷物开始饱满但还没有完全灌满。\n' +
  '小满处在春末夏初之后的生长关键期，作物进入快速生长和灌浆阶段，既需要充足水分，也忌讳雨水过多造成涝害。\n' +
  '\n' +
  '从生活层面看，小满也被理解为一种节制与余地的智慧，提醒人们凡事未必求极致，留有余地更利于稳定与长久。';
climateFeatures = '小满前后气温明显升高，体感更偏向初夏，白昼更长，日照增强。\n' +
  '南方降雨增多且更集中，常出现阵雨、雷雨，湿度明显上升，部分地区进入多雨时段；北方也逐渐转热，降水有所增加，但有时仍会出现阶段性干热与大风。\n' +
  '这一时期对流天气活跃，局地强降雨可能增多，需要注意防雷雨和短时强降水带来的影响。';
phenology = '小满时节，自然界生长旺盛：\n' +
  '麦类作物灌浆，籽粒逐渐饱满\n' +
  '草木茂盛，田间杂草生长加快\n' +
  '昆虫活动更频繁，虫鸣明显\n' +
  '雨后湿热感增强，植物生长速度加快\n' +
  '古代物候常概括为“苦菜秀、靡草死、麦秋至”，描绘了野菜生长、部分春草衰败以及麦类逐渐进入成熟前期的特征。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '小满的习俗多与祈求丰收、顺应天气和关注农事有关。\n' +
  '在一些地区，小满前后会祭祀水神或进行祈雨活动，表达对雨水适时适量的期望，希望既能滋养庄稼又不致成灾。\n' +
  '民间也有品尝时令蔬菜或野菜的习惯，如苦菜等，既顺应季节，也有清热解腻的意味。\n' +
  '农事方面，小满是田间管理的关键时期，常见的工作包括追肥灌溉、清沟排水、防治病虫害等，重点在于保障灌浆顺利并防范涝害和干旱。\n' +
  '同时，人们也会根据湿热增多的特点调整起居，注意防潮、通风与合理作息，为进入更热的夏季做准备。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Xiaoman.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['小满'] = solarTermsDetailInfo;

//芒种
name = '芒种';
EnglishName = 'Grain in Ear';
SolarDateRange = '每年6月5日—7日之间';
briefIntroduction = '芒种是二十四节气之一，表示有芒作物成熟、需要抓紧收割，同时也适合播种一些秋收作物。此时气温升高、雨水增多，农事进入一年中最忙碌的阶段之一。';
meaning = '“芒种”中的“芒”指带芒的谷物作物，如小麦、水稻等；“种”既指种子，也指播种。芒种的含义是有芒作物进入成熟期，需要及时收获，同时也要赶快播种下一季作物。\n' +
  '芒种在节气中具有很强的农业指向性，体现了“收与种并重”的时间紧迫感。古人用这一节气提醒人们把握农时，因为一旦错过，可能影响全年收成。\n' +
  '\n' +
  '从季节变化看，芒种标志着天气由初夏向盛夏迈进，湿热加重，对流天气更活跃，生产与生活都需要顺应气候调整节奏。';
climateFeatures = '芒种前后气温明显升高，白昼更长，体感逐渐转为闷热。\n' +
  '南方降雨增多且更集中，常出现强对流天气和雷阵雨，部分地区进入梅雨或接近梅雨特征；北方也进入夏季气候，热感增强，降水较前期增多但分布不均。\n' +
  '这一时期易出现高温、短时强降雨和大风等天气，田间既要防旱也要防涝。';
phenology = '芒种时节，自然界进入旺盛生长期与成熟期交汇：\n' +
  '麦类作物成熟，进入集中收割期\n' +
  '水稻等作物适合播种或移栽，田间更繁忙\n' +
  '草木繁盛，雨后生长加快\n' +
  '昆虫活动旺盛，虫鸣更密集\n' +
  '古代物候常概括为“螳螂生、鵙始鸣、反舌无声”，描绘了昆虫出现、鸟类鸣叫变化以及季节转热后自然声响更替的特点。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '芒种的节气特点非常务实，习俗多与忙农事、顺应时令有关。\n' +
  '在一些农耕地区，芒种被视为“忙种”的标志，人们会举行简单的祈丰或谢田活动，表达对收获的感谢，也祈求后续种植顺利。\n' +
  '不少地方有吃时令食物的习惯，用以补充体力并适应天气转热带来的消耗，如清淡解暑的饮食或应季果蔬。\n' +
  '农事方面，芒种是全年最忙的时段之一，常见工作包括抢收麦子、播种秋粮、插秧、追肥、灌溉、除草和防治病虫害，讲究抓紧农时、衔接紧凑。\n' +
  '同时芒种后湿热明显增多，人们也会注意防暑、防潮和防蚊虫，调整作息，保证体力与精力以应对繁忙阶段。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Mangzhong.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['芒种'] = solarTermsDetailInfo;

//夏至
name = '夏至';
EnglishName = 'Summer Solstice';
SolarDateRange = '每年6月20日—22日之间';
briefIntroduction = '夏至是二十四节气之一，这一天北半球白昼最长、夜晚最短。夏至后白昼逐渐变短，但气温往往继续升高，进入盛夏前的关键过渡阶段。';
meaning = '“夏至”意为夏季到达极点。夏至这一天太阳直射北回归线附近，北半球获得一年中最强的日照，白昼达到最长。\n' +
  '需要注意的是，夏至并不代表最热的时候已经到来。由于地表和海洋的蓄热效应，通常在夏至之后一段时间气温还会继续上升，民间常说“夏至不过不热”。\n' +
  '\n' +
  '在传统社会中，夏至既是重要的天文节点，也与农事安排有关。此时作物生长旺盛，田间管理任务较重，同时也提醒人们进入防暑、防涝、防病虫的阶段。';
climateFeatures = '夏至前后日照强、气温高，湿热感明显增强，部分地区会出现连续高温。\n' +
  '南方多雨且对流活跃，常见雷阵雨或强降雨，湿度大，闷热感突出；北方进入盛夏气候，白天炎热，局地会出现高温干热和阵雨天气并存的情况。\n' +
  '夏至后降雨和高温都可能增多，需要注意防暑降温，同时防范强对流、暴雨和雷电等天气。';
phenology = '夏至时节，万物生长旺盛：\n' +
  '草木枝叶最为繁茂，田间作物进入快速生长期\n' +
  '昆虫数量增多，虫鸣明显，蚊虫开始活跃\n' +
  '部分地区荷花盛开，水域生机浓郁\n' +
  '雨后蒸腾明显，空气湿热感增强\n' +
  '古代物候常概括为“鹿角解、蝉始鸣、半夏生”，描绘了动物生理变化、蝉鸣出现以及药草生长的时令特征。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '夏至的习俗各地差异较大，但多围绕消暑、应时和祈安展开。\n' +
  '一些地方有吃面或吃夏至面食的传统，寓意顺顺当当，也方便在炎热时节补充体力。\n' +
  '也有吃清凉食物的习惯，如瓜果、绿豆类饮食，用以消暑解热，适应高温天气。\n' +
  '部分地区保留祭神祈丰或谢田的活动，感谢作物生长顺利，并祈求后续少灾少病虫。\n' +
  '在生活层面，夏至提醒人们开始重视防暑、防晒与作息调整，如午间适当休息、避免暴晒、注意补水和通风，顺应盛夏将至的节律。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Xiazhi.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['夏至'] = solarTermsDetailInfo;

//小暑
name = '小暑';
EnglishName = 'Minor Heat';
SolarDateRange = '每年7月6日—8日之间';
briefIntroduction = '小暑是二十四节气之一，表示天气开始明显炎热，但尚未到一年中最热的时候。此时高温与降雨增多，湿热感加强，生活与农事都进入防暑防涝的阶段。';
meaning = '“小暑”中的“暑”指炎热，“小”表示热度已显但还未达到顶点。小暑到来后，气温明显升高，进入盛夏的前奏阶段。\n' +
  '小暑在节气序列中提示人们：高温、潮湿、雷雨等夏季特点将更加突出，需要做好防暑降温和防范强对流天气。\n' +
  '\n' +
  '从农业角度看，小暑前后作物生长旺盛但也更容易受高温、暴雨和病虫害影响，因此田间管理重点转向灌溉排水、追肥除草和病虫防治。';
climateFeatures = '小暑前后气温升高明显，白天炎热，夜间也较闷热，湿热感增强。\n' +
  '南方多高温与多雨并存，常出现阵雨、雷雨甚至短时强降雨，空气湿度大，体感闷热；北方也进入较热阶段，可能出现高温干热天气，同时局地有雷阵雨。\n' +
  '这一时期对流活跃，雷电、大风和短时强降水较常见，需注意天气变化带来的影响。';
phenology = '小暑时节，自然界呈现盛夏将至的特征：\n' +
  '草木葱茏，生长旺盛，田间作物快速拔节或灌浆\n' +
  '蝉鸣增多，虫类活动更频繁，蚊虫明显活跃\n' +
  '雨后蒸腾强烈，空气更显潮湿闷热\n' +
  '部分地区荷花盛开，水域生机浓\n' +
  '古代物候常概括为“温风至、蟋蟀居宇、鹰始鸷”，描绘了热风到来、蟋蟀进屋以及猛禽活动变化的时令特征。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '小暑的民俗多围绕消暑解热、养生调整展开，体现人们对盛夏生活节奏的适应。\n' +
  '不少地方有吃清凉食物的习惯，如绿豆汤、凉面、瓜果等，用以解暑补水，缓解闷热带来的不适。\n' +
  '也有人会在小暑前后进行晒衣晒物、通风除湿，防止潮气引发霉变，尤其在多雨地区更常见。\n' +
  '部分地区有饮新茶或吃新米的习惯，寓意应时而食，祈求生活安稳。\n' +
  '同时小暑提醒人们加强防暑和防蚊虫，注意作息规律、避免暴晒、补水通风，保持身体状态以应对更热的时段。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Xiaoshu.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['小暑'] = solarTermsDetailInfo;

//大暑
name = '大暑';
EnglishName = 'Major Heat';
SolarDateRange = '每年7月22日—24日之间';
briefIntroduction = '大暑是二十四节气之一，通常是一年中最炎热的时段。高温、闷热与雷阵雨增多，盛夏特征最明显，人们注重防暑降温，也要防范暴雨与强对流天气。';
meaning = '“大暑”中的“暑”指炎热，“大”表示热到极致。大暑处于小暑之后，热度进一步加深，往往对应一年里最热、最闷的阶段。\n' +
  '从气候规律看，大暑时太阳辐射强、地表蓄热多，加上部分地区湿度高，体感闷热明显。此时也是对流最活跃的阶段之一，容易出现雷雨、大风和短时强降水。\n' +
  '\n' +
  '在农业上，大暑前后作物生长旺盛，但也更易遭遇高温热害、暴雨涝害和病虫害，田间管理需要更精细，更强调防旱排涝与防虫防病并重。';
climateFeatures = '大暑前后高温显著，热浪可能出现，夜间也较闷热，体感容易疲乏。\n' +
  '南方多为高温高湿，雷阵雨频繁，局地强降雨和闷热交替出现；北方也进入一年中炎热期，可能出现高温干热与雷雨并存的天气。\n' +
  '整体上蒸发强、降雨集中，对流旺盛，需注意高温中暑以及雷暴、暴雨带来的影响。';
phenology = '大暑时节，盛夏特征最突出：\n' +
  '草木繁盛但易受高温影响，部分地区出现短时萎蔫\n' +
  '蝉鸣最盛，昆虫活动旺，蚊虫频繁\n' +
  '雨后热气蒸腾明显，空气闷湿\n' +
  '部分地区荷花盛开进入旺期，水域生机浓\n' +
  '古代物候常概括为“腐草为萤、土润溽暑、大雨时行”，描绘了潮湿闷热、萤火出现以及强降雨增多的时令特点。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '大暑的习俗多围绕消暑解热、祈安避暑展开，强调用饮食与生活方式应对酷热。\n' +
  '不少地方有喝凉茶、绿豆汤、酸梅汤或吃瓜果等习惯，用以清热解暑、补充水分，缓解闷热带来的不适。\n' +
  '也有晒伏姜、晒衣物、通风除湿的做法，既应对潮湿天气，也有顺应季节调养的意味。\n' +
  '部分地区会进行简单的祈福或消灾习俗，表达对夏季少病少灾、平安度暑的愿望。\n' +
  '生活上大暑提醒人们避免长时间暴晒，注意午间休息与补水，合理使用降温方式，同时关注天气预报，防范雷雨大风和短时强降雨带来的出行风险。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Dashu.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['大暑'] = solarTermsDetailInfo;

//立秋
name = '立秋';
EnglishName = 'Beginning of Autumn';
SolarDateRange = '每年8月7日—9日之间';
briefIntroduction = '立秋是二十四节气之一，标志秋季开始。虽然天气往往仍较炎热，但暑气开始走向收敛，早晚逐渐有凉意，万物由夏长转向秋收的节律。';
meaning = '“立秋”中的“立”是开始，“秋”在传统观念中代表收敛、成熟与收获。立秋意味着季节从夏转秋，自然界由旺盛生长逐渐转向结果与收成。\n' +
  '立秋是一个时令节点，并不等同于气温立刻下降。由于地表蓄热影响，立秋后仍可能出现持续高温，民间常有“秋后还伏”的说法。\n' +
  '\n' +
  '在农业上，立秋提示人们进入秋作物管理与准备收获阶段，同时也要关注高温余热、台风暴雨等天气对作物的影响。';
climateFeatures = '立秋前后总体仍处在夏末炎热阶段，但太阳高度逐渐降低，白昼开始缩短，暑热呈现缓慢收敛趋势。\n' +
  '南方部分地区高温与降雨并存，湿热仍明显，台风或强降雨可能增多；北方昼夜温差开始加大，早晚更易感到凉爽，但白天依然可能炎热。\n' +
  '这一时期常出现“白天热、早晚凉”的特征，需要注意及时调整衣物与作息。';
phenology = '立秋时节，自然景象出现由盛转收的变化：\n' +
  '白昼缩短，早晚凉意渐显\n' +
  '部分植物叶色开始由浓绿转深，果实逐渐成熟\n' +
  '蝉鸣仍在，但秋虫活动开始增多\n' +
  '田间作物进入灌浆成熟关键期\n' +
  '古代物候常概括为“凉风至、白露降、寒蝉鸣”，描绘了风转凉、露水增多和蝉鸣变化的时令特征。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '立秋的习俗多与迎秋、尝新和调整饮食起居有关。\n' +
  '不少地方有“贴秋膘”的说法，立秋后适当进补，寓意补回夏天消耗的体力，但也强调适量，避免过于油腻。\n' +
  '也有吃应季瓜果或尝新粮的习惯，用以感受季节更替与收获将至的喜悦。\n' +
  '部分地区会进行迎秋活动或家庭聚餐，象征从盛夏转入秋季的生活节奏变化。\n' +
  '立秋后虽然仍可能炎热，但人们会开始注意早睡早起、减少熬夜，适当运动，逐步从盛夏的防暑重点转向秋季的养护与调适。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Liqiu.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['立秋'] = solarTermsDetailInfo;

//处暑
name = '处暑';
EnglishName = 'End of Heat';
SolarDateRange = '每年8月22日—24日之间';
briefIntroduction = '处暑是二十四节气之一，表示暑气开始退去，天气由炎热向凉爽过渡。此时白昼缩短、早晚更凉，降雨形态也逐渐从夏季雷雨转向秋雨。';
meaning = '“处暑”中的“处”有停止、结束之意，“暑”指炎热。处暑表示盛夏的暑热走向尾声，季节从夏末向初秋过渡。\n' +
  '处暑后太阳高度继续降低，白昼变短，气温整体呈下降趋势，但不同地区退热速度不同，部分地方仍可能出现短时高温。\n' +
  '\n' +
  '在农业上，处暑意味着作物进入成熟与收获前的关键阶段，同时也要防范秋季台风、连阴雨等天气对作物品质和收成的影响。';
climateFeatures = '处暑前后总体气温开始回落，早晚凉意更明显，昼夜温差增大。\n' +
  '南方仍可能出现高温天气，但闷热感逐步减轻，降雨逐渐由雷阵雨转向持续性降雨，台风影响也可能增多；北方天气更趋干爽，气温下降更明显，空气舒适度提升。\n' +
  '这一时期天气变化更有秋意特征，适合逐步调整作息，但也要注意忽冷忽热带来的不适。';
phenology = '处暑时节，自然界呈现由盛夏向秋季转换的迹象：\n' +
  '早晚露水增多，空气更清爽\n' +
  '蝉鸣逐渐减少，秋虫活动增强\n' +
  '草木生长趋缓，部分植物开始显现成熟或转色\n' +
  '田间作物逐步进入成熟期，果实逐渐收获\n' +
  '古代物候常概括为“鹰乃祭鸟、天地始肃、禾乃登”，描绘了猛禽捕食、天地收敛以及作物成熟的时令变化。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '处暑的习俗多与送暑迎秋、调整生活节奏有关。\n' +
  '一些地方有“送暑”的说法，会进行简单的聚餐或活动，象征暑气退去、迎接秋凉。\n' +
  '部分地区会吃应季食物，如鸭子或清润类饮食，用以缓解夏季余热，也为转凉做身体调整。\n' +
  '农事上处暑后收获准备更紧迫，人们会加紧田间管理与抢收，关注成熟度、晾晒与储存，同时防范台风暴雨、秋雨连绵对作物造成损失。\n' +
  '生活方面，人们会开始减少冷饮，注意早晚添衣，适当运动，顺应由热转凉的节律，保持身体稳定。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Chushu.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['处暑'] = solarTermsDetailInfo;

//白露
name = '白露';
EnglishName = 'White Dew';
SolarDateRange = '每年9月7日—9日之间';
briefIntroduction = '白露是二十四节气之一，表示天气转凉，昼夜温差加大，清晨草木上常见露珠。此时暑气基本退去，秋意渐浓，空气更清爽。';
meaning = '“白露”意为白色的露水。进入白露后，夜间气温下降明显，空气中的水汽在清晨更容易凝结成露珠，附着在草叶上，呈现晶莹的白色光泽。\n' +
  '白露是秋季气候变化的重要标志，意味着由夏末的湿热逐渐转为秋季的凉爽与干燥。民间常说“白露身不露”，强调此时要注意保暖，避免着凉。\n' +
  '\n' +
  '农业上，白露前后作物进入成熟期或接近成熟期，是秋收的重要阶段，同时也需要关注早霜风险和病虫害的后期防控。';
climateFeatures = '白露前后气温总体下降，早晚凉意明显，昼夜温差加大，体感更偏向清凉。\n' +
  '南方暑热明显减弱，但部分地区仍有残余热感，降雨逐渐减少，空气湿度有所下降；北方进入明显的秋凉阶段，空气更干爽，清晨露水增多，局地可能出现早霜迹象。\n' +
  '这一时期天气多晴朗，适合户外活动，但早晚需要注意添衣保暖。';
phenology = '白露时节，自然界呈现深秋前的清爽景象：\n' +
  '清晨露水明显增多，草叶上常见晶莹露珠\n' +
  '蝉鸣渐少，秋虫声更突出\n' +
  '部分树叶开始转黄，果实逐渐成熟\n' +
  '田间作物进入收获高峰期或接近成熟\n' +
  '古代物候常概括为“鸿雁来、玄鸟归、群鸟养羞”，描绘了候鸟迁徙、燕子南归以及鸟类开始为越冬储备的特征。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '白露的习俗多与养生、防凉和应季生活有关。\n' +
  '不少地区有吃时令水果和清润食物的习惯，以适应秋季逐渐转干的气候，缓解口干咽燥等不适。\n' +
  '部分地方有品茶或酿酒的传统，认为白露时节气候清爽，适合享受秋日的清香滋味。\n' +
  '农事上白露是秋收秋管的重要阶段，人们会忙于收割、晾晒、储存，同时继续管理晚稻、秋菜等作物，确保产量与品质。\n' +
  '生活方面，白露后早晚明显转凉，人们会减少露天久坐、注意脚部保暖，逐步把作息从盛夏模式调整为更适合秋季的节律。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Bailu.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['白露'] = solarTermsDetailInfo;

//秋分
name = '秋分';
EnglishName = 'Autumn Equinox';
SolarDateRange = '每年9月22日—24日之间';
briefIntroduction = '秋分是二十四节气之一，标志着秋季的中点。这一天昼夜几乎等长，之后夜晚逐渐变长，天气由凉爽走向更明显的秋冷，收获气息更浓。';
meaning = '“秋分”中的“分”同样有两层含义：\n' +
  '一是昼夜平分，秋分这一天太阳直射赤道，全球大部分地区昼夜时间几乎相等；\n' +
  '二是季节平分，秋分处在秋季的中间位置，意味着秋意由“爽”转向“凉”，万物由生长走向成熟与收敛。\n' +
  '\n' +
  '对农业而言，秋分前后是秋收秋种的重要阶段，粮食、果实陆续成熟，田间进入收获与播种并行的忙碌时期，节气具有鲜明的生产指导意义。';
climateFeatures = '秋分前后气温继续下降，早晚更凉，昼夜温差较大，白昼开始明显缩短。\n' +
  '北方凉意显著，天气干爽，冷空气活动增多；南方暑热基本退去，舒适度提升，但降雨形态逐渐转向秋雨，部分地区会出现连阴雨。\n' +
  '这一时期空气逐渐干燥，体感由清爽转为偏凉，适合逐步添加衣物并注意润燥。';
phenology = '秋分时节，自然景象更显成熟与收敛：\n' +
  '昼夜等长后夜晚逐渐变长\n' +
  '树叶开始明显变色，落叶现象增多\n' +
  '候鸟迁徙活动更频繁\n' +
  '秋虫鸣叫明显，田野收获气息浓\n' +
  '古代物候常概括为“雷始收声、蛰虫坯户、水始涸”，描绘了雷声减少、虫类准备越冬以及水量逐渐减少的秋季特征。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '秋分的习俗多与收获、祈福和亲近自然相关。\n' +
  '在一些地方有庆祝丰收或祭祀土地的活动，表达对一年收成的感谢，也祈求来年风调雨顺。\n' +
  '部分地区有秋分竖蛋的民间玩法，与昼夜平衡的观念相联系，寓意顺遂与稳定。\n' +
  '秋分时节天气舒适，人们也常选择秋游、登高或户外活动，感受秋日清朗与成熟景色。\n' +
  '农事上秋分前后收割与播种并行，忙于收获成熟作物、晾晒储存，同时进行秋播整地、育苗等准备，节奏紧凑。\n' +
  '生活方面，秋分后更应注意保暖与润燥，减少熬夜，适当运动，顺应日照变短带来的节律变化。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Qiufen.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['秋分'] = solarTermsDetailInfo;

//寒露
name = '寒露';
EnglishName = 'Cold Dew';
SolarDateRange = '每年10月7日—9日之间';
briefIntroduction = '寒露是二十四节气之一，表示气温进一步下降，露水更凉更重，秋意明显加深。此时早晚寒凉，昼夜温差大，万物逐渐收敛进入深秋阶段。';
meaning = '“寒露”意为带寒意的露水。进入寒露后，夜间温度更低，露水凝结更明显，也更显寒凉，反映出季节由凉爽走向寒冷的变化。\n' +
  '寒露处在深秋的重要节点，提示人们天气将进一步转冷，日照继续缩短，植物生长明显放缓，逐渐进入收藏状态。\n' +
  '\n' +
  '在农业上，寒露前后秋收接近尾声，部分作物进入最后收割期，同时也要防范早霜、寒潮对晚熟作物和果实的影响。';
climateFeatures = '寒露前后气温明显下降，早晚寒凉，昼夜温差大，冷空气活动增多。\n' +
  '北方多出现明显秋冷，部分地区接近初霜或出现霜冻迹象；南方也由凉爽转向偏冷，秋雨增多时会带来湿冷感。\n' +
  '空气逐渐干燥，晴朗天气多时昼夜温差更大，适合及时添衣保暖，避免受寒。';
phenology = '寒露时节，自然界进入深秋景象：\n' +
  '露水更重更凉，清晨常见草木挂露\n' +
  '树叶颜色更明显转黄转红，落叶增多\n' +
  '候鸟迁徙加快，鸟类活动呈现南移趋势\n' +
  '昆虫活动减少，秋虫声也逐渐变弱\n' +
  '古代物候常概括为“鸿雁来宾、雀入大水为蛤、菊有黄华”，描绘了候鸟迁徙、自然变化联想以及菊花盛开的深秋特征。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '寒露的习俗多与赏秋、养生和应时生活有关。\n' +
  '不少地方在寒露时节有赏菊、登高的习惯，利用秋高气爽的时段走到户外，感受深秋景色，也有强身健体的意义。\n' +
  '饮食上更偏向温润，适当进补与润燥，减少生冷食物，以适应气温下降和空气干燥带来的影响。\n' +
  '部分地区有喝秋茶或饮用温热饮品的习惯，用以暖身舒缓。\n' +
  '农事方面寒露阶段秋收接近尾声，人们会加紧收割、晾晒与入仓，同时对果树、菜地进行后期管理，为防寒和越冬做准备。\n' +
  '生活层面寒露后早晚寒凉明显，常强调护脚保暖、避免久露在外，适当早睡早起，顺应秋季收敛的节律。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Hanlu.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['寒露'] = solarTermsDetailInfo;

//霜降
name = '霜降';
EnglishName = 'Frost\'s Descent';
SolarDateRange = '每年10月23日—24日之间';
briefIntroduction = '霜降是二十四节气之一，表示天气进一步转冷，昼夜温差大，部分地区开始出现初霜。霜降后秋意转深，万物收敛，冬季的气息逐渐显现。';
meaning = '“霜降”意为霜开始出现或逐渐增多。霜并不是从天上落下，而是近地面水汽在气温很低的条件下凝结形成。霜降到来，说明气温下降到更易结霜的阶段。\n' +
  '霜降是秋季最后一个节气，也是由秋入冬的重要过渡节点。此时自然界由成熟走向凋落与收藏，植物生长明显停止或减缓，动物开始为越冬做准备。\n' +
  '\n' +
  '农业上霜降提示人们要抓紧完成秋收秋管，做好防霜防冻工作，尤其是晚熟作物、果蔬和经济作物更要注意防护。';
climateFeatures = '霜降前后气温继续下降，冷空气活动频繁，早晚明显寒冷，昼夜温差较大。\n' +
  '北方不少地区开始出现初霜或霜冻，天气干冷；南方也逐步转凉，秋雨出现时更显湿冷，部分地区虽不常见霜，但气温下降趋势明显。\n' +
  '这一时期日照减少，风力偏大时体感更冷，需要及时增添衣物，注意保暖。';
phenology = '霜降时节，自然界呈现深秋末期的收敛景象：\n' +
  '草木枯黄加快，落叶明显增多\n' +
  '清晨地面更易出现白霜，空气更清冷\n' +
  '候鸟迁徙接近尾声，留鸟活动减少\n' +
  '昆虫活动大幅减少，田野更显寂静\n' +
  '古代物候常概括为“豺乃祭兽、草木黄落、蜇虫咸俯”，描绘了动物为越冬储备、草木凋落以及虫类潜藏的晚秋特征。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '霜降的习俗多与进补养生、赏秋收尾和防寒准备有关。\n' +
  '不少地区有霜降进补的习惯，饮食更偏温热，适当增加肉类、根茎类和汤类食物，以增强体力并适应转冷天气。\n' +
  '部分地方会在霜降前后进行登高赏秋或观红叶活动，把握秋景最后的绚烂时光。\n' +
  '也有人会开始做防寒准备，如晒被褥、添置御寒物品、整理衣物，迎接更冷的季节。\n' +
  '农事上霜降前后多为秋收尾声阶段，人们会加紧收割、晾晒、入仓，同时对果树、菜地进行越冬管理，防霜防冻，减少寒害。\n' +
  '生活方面霜降后更强调保暖，尤其注意头颈和脚部，减少受凉，同时适当锻炼增强抵抗力。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Shuangjiang.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['霜降'] = solarTermsDetailInfo;

//立冬
name = '立冬';
EnglishName = 'Beginning of Winter';
SolarDateRange = '每年11月7日—8日之间';
briefIntroduction = '立冬是二十四节气之一，标志冬季开始。气温下降明显，万物进入收藏状态，人们开始注重保暖与进补，农事也逐渐转向收尾与越冬准备。';
meaning = '“立冬”中的“立”是开始，“冬”代表寒冷与收藏。立冬意味着季节从秋转入冬，自然界的生长活动明显减弱，进入休养与蓄积阶段。\n' +
  '立冬是一个重要的时令节点，并不代表当天就会最冷，但整体气温将持续走低，冷空气活动更频繁，寒意逐步加深。\n' +
  '\n' +
  '在传统观念中，冬季重在“养藏”，立冬提醒人们调整起居饮食，顺应自然节律，同时也提示农事进入收尾和防寒越冬阶段。';
climateFeatures = '立冬前后气温明显下降，冷空气来得更频繁，风力偏大时体感更冷。\n' +
  '北方不少地区进入供暖或接近供暖期，可能出现降雪或霜冻，空气干冷；南方也逐步转冷，湿冷感更明显，阴雨天气会带来更强的寒意。\n' +
  '日照减少，昼短夜长特征更突出，早晚寒冷明显，需加强保暖防寒。';
phenology = '立冬时节，自然界呈现明显的收藏特征：\n' +
  '草木凋落，树叶大量脱落，地表颜色更偏枯黄\n' +
  '动物活动减少，部分动物开始冬眠或减少外出\n' +
  '鸟类迁徙基本完成，留鸟觅食更频繁\n' +
  '水面更易结冰，清晨霜冻增多\n' +
  '古代物候常概括为“水始冰、地始冻、雉入大水为蜃”，描绘了结冰冻土出现以及生物活动变化的入冬特征。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '立冬的习俗多与迎冬、进补和家庭团聚有关，强调在转冷时节储备体力。\n' +
  '不少地区有立冬进补的做法，常吃温热食物或炖汤，寓意补充能量、增强御寒能力。\n' +
  '北方一些地方有吃饺子的习惯，象征团圆与御寒，也带有应时饮食的意味。\n' +
  '部分地区会进行简单的迎冬活动或家庭聚餐，把立冬当作季节转换的仪式点。\n' +
  '农事方面立冬后田间工作逐渐收尾，人们会完成秋收入仓、修整农具、清理沟渠，并对果树、菜地进行防寒越冬管理。\n' +
  '生活上立冬提醒人们早睡晚起、注意保暖，尤其保护头颈和脚部，减少生冷饮食，顺应冬季养藏的节律。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Lidong.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['立冬'] = solarTermsDetailInfo;

//小雪
name = '小雪';
EnglishName = 'Minor Snow';
SolarDateRange = '每年11月22日—23日之间';
briefIntroduction = '小雪是二十四节气之一，表示气温继续下降，降水形态逐渐由雨转雪，但雪量通常不大。此时寒意加深，万物进入更明显的冬季状态。';
meaning = '“小雪”中的“雪”指降雪现象开始更常见，“小”表示雪量一般不大，尚未进入大范围强降雪的阶段。\n' +
  '小雪到来，意味着冷空气活动更频繁，气温进一步走低，降水在低温条件下更容易以雪的形式出现，地面也更容易结冰。\n' +
  '\n' +
  '在传统生活中，小雪提醒人们做好防寒保暖与冬季储备，同时也提示农事基本结束，进入冬藏与养护阶段。';
climateFeatures = '小雪前后气温明显下降，寒冷感加重，北方多出现降雪或降雪增多，空气干冷，风寒效应明显。\n' +
  '南方虽不一定下雪，但气温也持续走低，阴雨天气带来湿冷感，体感同样偏寒。\n' +
  '这一时期昼短夜长特征明显，早晚更冷，路面易出现结冰或湿滑情况，需要注意出行安全。';
phenology = '小雪时节，自然界进入更深的冬季状态：\n' +
  '北方降雪更常见，地面易结冰\n' +
  '草木枯黄凋落，植物生长停滞\n' +
  '动物活动减少，部分进入冬眠或减少觅食范围\n' +
  '鸟类多为留鸟在活动，觅食更频繁\n' +
  '古代物候常概括为“虹藏不见、天气上升地气下降、闭塞而成冬”，强调彩虹难见、天地之气收敛以及冬季闭藏特征逐渐形成。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '小雪的习俗多与冬季生活和饮食储备有关，强调御寒与保存。\n' +
  '不少地区会开始腌制或储备冬季食物，如腌菜、腊肉等，以便在寒冷季节减少外出、方便取用。\n' +
  '饮食上更偏温热，人们会喝热汤、吃炖菜等，增加热量，增强御寒能力。\n' +
  '部分地方有晒腊味、晒干货的做法，利用小雪前后的干冷或间歇晴天进行晾晒保存。\n' +
  '生活方面，小雪提醒人们加强保暖，注意防寒防燥，保持室内通风与湿度平衡，同时在降雪结冰时注意防滑出行。\n' +
  '农事上多进入冬闲阶段，主要工作转为修整农具、整理仓储和对越冬作物进行防寒管理。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Xiaoxue.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['小雪'] = solarTermsDetailInfo;

//大雪
name = '大雪';
EnglishName = 'Major Snow';
SolarDateRange = '每年12月6日—8日之间';
briefIntroduction = '大雪是二十四节气之一，表示气温进一步降低，降雪概率增大，部分地区会出现较大范围或较大雪量的降雪。此时寒意加深，冬季特征更明显。';
meaning = '“大雪”中的“大”表示降雪更频繁、雪量更大或影响范围更广。大雪到来，意味着冷空气更强，气温持续走低，降水更容易以雪的形式出现。\n' +
  '大雪并不一定代表全国都会下大雪，但从节气规律看，这一阶段更接近冬季寒冷核心区，积雪、结冰等现象更常见。\n' +
  '\n' +
  '在传统生活中，大雪提醒人们加强御寒、防滑和储备，同时也象征冬藏更深，农事进入休养阶段，人们以养生和家庭生活为主。';
climateFeatures = '大雪前后气温继续下降，寒潮更容易出现，北方降雪增多，风力偏大时体感更冷。\n' +
  '不少地区可能出现积雪、道路结冰等情况，空气干冷明显；南方虽未必下雪，但阴雨增多时湿冷感突出，体感同样寒冷。\n' +
  '这一时期昼短夜长，日照弱，早晚温度更低，需要注意保暖和出行安全。';
phenology = '大雪时节，自然界呈现深冬渐近的景象：\n' +
  '降雪更常见，部分地区积雪增厚\n' +
  '河湖水面结冰范围扩大\n' +
  '草木凋零，植物进入休眠状态\n' +
  '动物活动减少，越冬特征更明显\n' +
  '古代物候常概括为“鹖鴠不鸣、虎始交、荔挺出”，描绘了鸟类沉寂、动物繁殖行为出现以及少量耐寒植物萌动的冬季特征。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '大雪的习俗多与御寒、进补和冬季储备有关，强调在严寒前做好准备。\n' +
  '不少地方会在大雪时节进补，食用炖肉、汤类、根茎类等温热食物，以增强体力与御寒能力。\n' +
  '也有继续腌制、风干、储存食物的做法，如腌菜、腊味等，为更冷的时段做准备。\n' +
  '在北方一些地区，人们会进行扫雪清路、加固门窗、准备取暖物资等家庭防寒工作，确保冬季生活安全舒适。\n' +
  '生活方面，大雪提醒人们减少久寒久冻，注意保暖防滑，适当运动增强抵抗力，同时保持室内通风，避免过于干燥。\n' +
  '农事上进入冬闲期，更多是对农具、粮仓和越冬作物进行检查维护，为来年春耕做准备。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Daxue.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['大雪'] = solarTermsDetailInfo;

//冬至
name = '冬至';
EnglishName = 'Winter Solstice';
SolarDateRange = '每年12月21日—23日之间';
briefIntroduction = '冬至是二十四节气之一，这一天北半球白昼最短、夜晚最长。冬至后白昼逐渐变长，但寒冷往往会继续加深，是冬季的重要转折点。';
meaning = '“冬至”意为冬季到达极点。冬至这一天太阳直射南回归线附近，北半球获得的日照最少，白昼最短。\n' +
  '冬至之后，太阳直射点开始北移，白昼逐渐变长，民间有“冬至一阳生”的说法，象征阳气开始回升。\n' +
  '\n' +
  '冬至在传统文化中地位很高，不仅是重要的天文节点，也与祭祀、团聚和冬季养生密切相关。它提醒人们在严寒时节注重养藏与保暖，同时也寄托对来年转暖的期待。';
climateFeatures = '冬至前后气温普遍较低，冷空气频繁，寒意明显，北方多干冷并可能出现降雪，风寒效应强。\n' +
  '南方气温也持续走低，阴雨天气会带来湿冷感，体感偏寒。\n' +
  '冬至后虽然白昼变长，但通常进入全年最冷的时段之一，需注意防寒保暖和冬季健康管理。';
phenology = '冬至时节，自然界进入深冬状态：\n' +
  '白昼最短，日照弱，夜晚时间长\n' +
  '河湖结冰范围扩大，霜冻更常见\n' +
  '草木凋落，植物休眠，生长停滞\n' +
  '动物活动减少，越冬特征明显\n' +
  '古代物候常概括为“蚯蚓结、麋角解、水泉动”，描绘了地下生物活动减弱、动物生理变化以及寒极中仍有微弱生机的特征。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '冬至的习俗在各地十分丰富，常与团聚和进补联系在一起。\n' +
  '北方很多地方有吃饺子的习惯，寓意御寒与团圆，也象征顺顺当当过冬。\n' +
  '南方一些地区会吃汤圆或甜品，寓意团圆圆满，也让冬至更具家庭氛围。\n' +
  '部分地区保留祭祖或祭天的传统，表达对先人和自然的敬畏，并祈求来年平安顺遂。\n' +
  '饮食上冬至常被视为进补的时机，人们会喝羊肉汤、炖汤等温热食物，增强体力，抵御严寒。\n' +
  '生活方面，冬至提醒人们早睡晚起、注意保暖，适当晒太阳和运动，保持情绪稳定，顺应冬季养藏的节律。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Dongzhi.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['冬至'] = solarTermsDetailInfo;

//小寒
name = '小寒';
EnglishName = 'Minor Cold';
SolarDateRange = '每年1月5日—7日之间';
briefIntroduction = '小寒是二十四节气之一，表示进入一年中最寒冷的时段之一。冷空气活动频繁，风寒明显，部分地区会出现降雪、结冰等现象，生活与养生更强调保暖与进补。';
meaning = '“小寒”中的“寒”指寒冷，“小”表示寒冷程度已很强，但在节气序列中还有可能继续加深，通常在小寒之后还有“大寒”。\n' +
  '小寒处于隆冬阶段，往往与强冷空气和持续低温相伴。虽然不同地区最冷时段略有差异，但整体上小寒是冬季寒冷的代表性节点。\n' +
  '\n' +
  '在传统观念中，小寒提醒人们进入冬季养藏的关键期，注意防寒保暖、减少耗散，同时也象征一年进入尾声，为迎接新年做准备。';
climateFeatures = '小寒前后气温普遍较低，冷空气影响频繁，北方多干冷并伴随大风，体感风寒明显，部分地区会有降雪和道路结冰。\n' +
  '南方气温也降到较低水平，阴雨天气更容易带来湿冷感，室内外温差小，体感寒意更重。\n' +
  '这一时期昼短夜长，日照弱，早晚尤其寒冷，需要注意防寒、防冻和出行安全。';
phenology = '小寒时节，自然界处于深冬状态：\n' +
  '河湖结冰范围扩大，霜冻更常见\n' +
  '降雪或寒潮出现频率增加\n' +
  '草木枯萎，植物处于休眠状态\n' +
  '动物活动减少，更多依靠储备能量越冬\n' +
  '古代物候常概括为“雁北乡、鹊始巢、雉始雊”，描绘了部分鸟类活动变化和越冬状态中的生物节律。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '小寒的习俗多与御寒、进补和迎新准备有关。\n' +
  '不少地方在小寒开始更重视进补，食用羊肉、炖汤、根茎类等温热食物，以增强体力和抵御寒冷。\n' +
  '也有人开始做腊味、腌菜等冬季储备，把食物保存起来，方便在寒冷时段食用。\n' +
  '部分地区有贴窗花、扫尘、整理家务等迎年准备，提前营造过年的气氛。\n' +
  '生活方面小寒强调保暖，尤其注意头颈、腰腹和脚部，减少长时间受风受冻，适当运动促进循环，同时保持室内通风，避免空气过于干燥。\n' +
  '在民间观念里，小寒也提醒人们收心养神，规律作息，为即将到来的新年保持稳定的精力状态。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Xiaohan.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['小寒'] = solarTermsDetailInfo;

//大寒
name = '大寒';
EnglishName = 'Major Cold';
SolarDateRange = '每年1月20日—21日之间';
briefIntroduction = '大寒是二十四节气中的最后一个节气，通常处在一年最寒冷的时段。冷空气活动频繁，风寒强烈，降雪结冰更常见，同时也意味着新一轮节气循环即将开始。';
meaning = '“大寒”意为寒冷到极致，是隆冬阶段的代表性节气。它位于小寒之后，标志冬季寒冷达到高峰，虽然不同地区最冷时段略有差异，但大寒往往对应严寒和寒潮频繁的时期。\n' +
  '大寒也是二十四节气的收尾，紧接着便是立春。它既象征一年寒冷的终点，也暗含“寒极必转”的变化规律，提示人们在严冬中等待春回。\n' +
  '\n' +
  '在传统生活中，大寒与岁末年关相近，人们会在这一时期加强御寒、进行年货准备、完成腊味储备，并以团聚和迎新为主要主题。';
climateFeatures = '大寒前后气温普遍处在全年低位，寒潮和大风更容易出现，北方多干冷并伴随降雪，风寒效应明显，道路结冰更常见。\n' +
  '南方气温也较低，阴雨天气带来湿冷感，室内外都偏冷，体感不适更突出。\n' +
  '这一时期昼短夜长，日照弱，早晚寒冷明显，需要注意防冻、防滑和保暖。';
phenology = '大寒时节，自然界处于深冬核心期：\n' +
  '河湖冻结明显，霜雪更常见\n' +
  '草木凋零，植物休眠，生长停滞\n' +
  '动物活动减少，以节省能量为主\n' +
  '鸟类多聚集觅食，越冬状态明显\n' +
  '古代物候常概括为“鸡乳、征鸟厉疾、水泽腹坚”，描绘了严寒中家禽繁育、鸟类活动紧张以及水体冻结加厚的冬季特征。';
naturalAttributes = new NaturalAttribute(climateFeatures,phenology);
customs = '大寒的习俗多与御寒进补、岁末准备和迎新团聚有关。\n' +
  '不少地方在大寒会继续进补，吃炖肉、热汤、糯米类食物等，以增强体力并抵御严寒。\n' +
  '岁末临近，人们会忙于置办年货、制作腊味、腌制食物，把适合保存的食材准备齐全，为春节做铺垫。\n' +
  '也有人在大寒前后进行扫尘、整理居室、修缮门窗等，寓意辞旧迎新，让生活环境更整洁舒适。\n' +
  '生活方面强调保暖防寒，减少久寒久冻，注意补水润燥与室内通风，适当晒太阳和运动，保持身体状态稳定。\n' +
  '大寒作为节气收尾，也让人们在严冬中更有“盼春”的心理期待，为新的一年积蓄力量。';
solarTermsDetailInfo = new SolarTermsDetailInfo($rawfile('SolarTerms/Dahan.png'),name,EnglishName,SolarDateRange,briefIntroduction,meaning,
  naturalAttributes,customs);
SolarTermsDetailData['大寒'] = solarTermsDetailInfo;