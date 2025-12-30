export class BaseConstants {
  /**
   * 组件尺寸
   */
  static readonly FULL_PERCENT: string = '100%'; // 完全百分比宽度
  static readonly FULL_SIZE: string = '100%'; // 完全尺寸
  static readonly FULL_HEIGHT: string = '100%'; // 完全高度
  static readonly FULL_WIDTH: string = '100%'; // 完全宽度
  static readonly NINETY_WIDTH_PERCENT: string = '90%'; // 90%宽度
  static readonly IMAGE_ONE_WIDTH_SM: string = '66.6%'; // 小屏幕单图宽度
  static readonly IMAGE_ONE_WIDTH_MD: string = '63.8%'; // 中屏幕单图宽度
  static readonly IMAGE_ONE_WIDTH_LG: string = '32.1%'; // 大屏幕单图宽度
  static readonly TAB_PADDING_TOP: string = '28.6%'; // 标签顶部内边距
  static readonly TAB_PADDING_BOTTOM: string = '28.6%'; // 标签底部内边距
  static readonly HOME_LIST_WIDTH: string = '37%'; // 首页列表宽度
  static readonly APPLET_LIST_WIDTH: string = '37%'; // 小程序列表宽度
  static readonly IMAGE_ONE_ASPECT_RATIO: number = 1.33; // 单图宽高比
  static readonly BORDER_RADIUS: number = 14; // 边框圆角半径
  static readonly MODULE_PADDING: number = 14; // 模块内边距
  /**
   * 文本属性
   */
  static readonly FONT_WEIGHT_SEVEN: number = 700; // 字体粗细700
  static readonly FONT_WEIGHT_SIX: number = 600; // 字体粗细600
  static readonly FONT_WEIGHT_FIVE: number = 500; // 字体粗细500
  static readonly FONT_WEIGHT_FOUR: number = 400; // 字体粗细400
  /**
   * 应用相关
   */
  static readonly SPLIT_DOCUMENT_SCREEN = false; // 是否拆分文档屏幕
  static readonly SPLIT_APPLET_SCREEN = false; // 是否拆分小程序屏幕
  /**
   * Flex 相关
   */
  static readonly FLEX_GROW_ONE = 1; // flex-grow 为 1
  static readonly LAYOUT_WEIGHT_ONE = 1; // 布局权重为 1
  static readonly FLEX_SHRINK_ZERO = 0; // flex-shrink 为 0
  static readonly FLEX_SHRINK_ONE = 1; // flex-shrink 为 1
  /**
   * HomeTab
   */
  static readonly HOME_TAB_HEIGHT_SM: string = '56vp'; // 小屏幕首页标签高度
  static readonly HOME_TAB_HEIGHT_MD: string = '56vp'; // 中屏幕首页标签高度
  static readonly HOME_TAB_HEIGHT_LG: string = '100%'; // 大屏幕首页标签高度
  static readonly HOME_TAB_WIDTH_SM: string = '100%'; // 小屏幕首页标签宽度
  static readonly HOME_TAB_WIDTH_MD: string = '100%'; // 中屏幕首页标签宽度
  static readonly HOME_TAB_WIDTH_LG: string = '96vp'; // 大屏幕首页标签宽度
  static readonly CONTACTS_PHONE_WIDTH_SM: string = '27%'; // 小屏幕联系人电话宽度
  static readonly CONTACTS_PHONE_WIDTH_MD: string = '28%'; // 中屏幕联系人电话宽度
  static readonly CONTACTS_PHONE_WIDTH_LG: string = '25%'; // 大屏幕联系人电话宽度
  static readonly CONTACTS_DETAIL_HEIGHT_SM: string = '100%'; // 小屏幕联系人详情高度
  static readonly CONTACTS_DETAIL_HEIGHT_MD: string = '100%'; // 中屏幕联系人详情高度
  static readonly CONTACTS_DETAIL_HEIGHT_LG: string = '90%'; // 大屏幕联系人详情高度
  static readonly CONTACTS_ITEM_HEIGHT_SM: string = '11%'; // 小屏幕联系人项高度
  static readonly CONTACTS_ITEM_HEIGHT_MD: string = '11%'; // 中屏幕联系人项高度
  static readonly CONTACTS_ITEM_HEIGHT_LG: string = '10%'; // 大屏幕联系人项高度
  /**
   * 文档标签
   */
  static readonly DOCUMENT_TITLE_HEIGHT_SM: string = '33%'; // 小屏幕文档标题高度
  static readonly DOCUMENT_TITLE_HEIGHT_MD: string = '58%'; // 中屏幕文档标题高度
  static readonly DOCUMENT_TITLE_HEIGHT_LG: string = '100%'; // 大屏幕文档标题高度
  static readonly DOCUMENT_TITLE_SPACE_SM: number = 32; // 小屏幕文档标题间距
  static readonly DOCUMENT_TITLE_SPACE_MD: number = 56; // 中屏幕文档标题间距
  static readonly DOCUMENT_TITLE_SPACE_LG: number = 103; // 大屏幕文档标题间距
  /**
   * 组件透明度值：1.
   */
  static readonly FULL_OPACITY: number = 1; // 完全不透明
  /**
   * 组件透明度值：0.6.
   */
  static readonly SIXTY_OPACITY: number = 0.6; // 60%透明度
  /**
   * 设备网格列列表。
   */
  static readonly DEVICE_GRID_COLUMNS: string[] = ['1fr 1fr', '1fr 1fr 1fr', '1fr 1fr 1fr 1fr', '1fr 1fr 1fr 1fr 1fr',
    '1fr 1fr 1fr 1fr 1fr 1fr 1fr']; // 设备网格列配置
  /**
   * 设备 2in1。
   */
  static readonly DEVICE_2IN1: string = '2in1'; // 2in1设备
}

export enum DeviceTypes {
  PHONE = 'phone', // 手机
  TABLET = 'tablet', // 平板
  "2IN1" = '2in1', // 2in1设备
}
