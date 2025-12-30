import { image } from "@kit.ImageKit";


export interface justifyTextModel {
  content: string;
  fontSize?: number;
  fontColor?: string | Resource;
  width?:number;
  maxSize?:number;
}
@ObservedV2
export class generalModel {
  //- 辽宁专家 APP 字段
  @Trace token?: string;
  CGRUserGuid?: string;
  manufacturer?: string;
  validityPeriod?: string;
  signCertificateSerial?: string;
  expireDate?: string;
  orderStatus?: string;
  pkcs10?: string;
  pdfUrl?: string;
  yzbm?: string;
  txdz?: string;
  dwmc?: string;
  userName?: string;
  caName?: string;
  exportType?: string;
  sfzzm?: string;
  sfzfm?: string;
  signature?: string;
  invoice?: string;
  shfs?: string;
  cityCode?: string;
  isInvoice?: string;
  shrxm?: string;
  shrdh?: string;
  provinceCode?: string;
  countryCode?: string;
  shrdz?: string;
  UserName?: string;
  Mobile?: string;
  ProvinceCode?: string;
  CityCode?: string;
  CountryCode?: string;
  addressStr?: string;


  isEdit?: string | boolean;
  zddid?: string;
  ddId?: string;
  userGuid?: string;
  fhcityCode?: string;
  orderGuid?: string;
  orderguid?: string;
  orderno?: string;
  orderNo?: string;
  OrderNo?: string;
  productDescription?: string;
  companyName?: string;
  email?: string;
  phoneNumber?: string;
  phone?: string;
  identification?: string;
  @Trace UserGuid?: string;
  @Trace keyword?: string;
  @Trace sum?: string;
  @Trace type?: string;
  @Trace url?: string;
  codeText?: string;
  @Trace imgurl?: string;
  @Trace LoginID?: string;
  @Trace description?: string;
  @Trace id?: string;
  yxqName?: string;
  money?: string;
  @Trace idcardnum?: string;
  sqrxm?: string;
  @Trace isSaveSign?: string;
  @Trace userSignature?: string;
  @Trace name?: string;
  @Trace realname?: string;
  @Trace yzm?: string;
  @Trace password?: string;
  @Trace ishy?: string;
  @Trace infoid?: string;
  @Trace title?: string;
  @Trace categorynum?: string;
  @Trace infocontent?: string;
  @Trace infodate?: string;
  @Trace isOthers?: string;
  @Trace Photo?: string;
  @Trace Title?: string;
  @Trace Price?: string;
  @Trace baomingidcard?: string;
  @Trace yhdh?: string;
  @Trace PassWD?: string;
  @Trace baomingnum?: string;
  @Trace liveEndTime?: string;
  @Trace alreadybaomingnum?: string;
  @Trace num?: string;
  @Trace isVideo?: string;
  @Trace oldpassword?: string;
  @Trace newpassword?: string;
  @Trace pageTitle?: string;
  @Trace catalogName?: string;
  @Trace balance?: string;
  @Trace arrImagesUint8?:ArrayBuffer[];
  @Trace arrVideoUint8?:ArrayBuffer[];
  @Trace videoPixelMap?:ArrayBuffer;
  @Trace action?: string;

  @Trace currentPage?:string;
  @Trace pageItemNum?:string;
  @Trace xz?: string;
  @Trace key?: string;
  @Trace zjidcard?: string;
  @Trace idCard?: string;
  @Trace coursestarttime?: string;
  @Trace bidEvaluationTime?: string;
  @Trace expertName?: string;

  //---1


  @Trace createtime?: string;
  @Trace createTime?: string;
  lqbz?: string;
  lqbz1?: string;
  lqdw?: string;
  lqdw1?: string;
  lqdz?: string;
  lqdz1?: string;
  lqlxr?: string;
  lqlxr1?: string;
  lqdh?: string;
  lqdh1?: string;
  sqjg?: string;
  glpt?: string;
  dqsj?: string;
  islingqu?: string;
  amountPrice?: string;
  totalPrice?: string;
  invoiceUrl?: string;
  createDate?: string;
  @Trace daili?: string;
  @Trace major?: string;
  @Trace place?: string;
  @Trace time?: string;
  @Trace xmcode?: string;
  @Trace yjphone?: string;
  @Trace zjphone?: string;
  @Trace callOut?: string;
  @Trace callIn?: string;
  //2是评标历史
  @Trace status?: string;
  @Trace bidSectionState?: string;

  @Trace isDecrypted?: string;//是否解密 0 没 1已经解密
  @Trace signFlag?: string;//是否签到 0 没 1已经签到，2是迟到签到
  @Trace leaveFlag?: string; //是否请假 请假了 true 没请假false
  @Trace isShowLeave?: string; //是否显示请假按钮 显示 true 不显示false
  @Trace message?: string;
  ///标段名称
  @Trace bidSectionName?: string;
  @Trace projectName?: string;
  @Trace drawExpertCode?: string;
  @Trace deductionName?: string;
  @Trace evaluateTime?: string;
  projectId?: string;
  appealable?: boolean;
  appealEndTime?: string;
  @Trace deductionReason?: string;
  deductionId?: string;
  //申诉条目
  @Trace deductPoints?: string;
  ///标段编码
  @Trace bidSectionCodes?: string;
  //appealStatus  0未读  1已读  2申诉中 3申诉成功 4申诉失败
  @Trace appealStatus?: string;
  pushTime?: string;
  deductionAppendix?: string;
  deductionAppendixList?: string[];
  @Trace bidEvaluationAddress?: string;
  @Trace agencyCode?: string;
  @Trace bidSectionNames?: string;
  @Trace tenderProjectCode?: string;
  @Trace tenderProjectName?: string;
  @Trace agencyName?: string;
  @Trace expertIdCard?: string;
  @Trace expertId?: string;

  @Trace beRated?: string;// 1  为 已经评价过 不可以评价

  @Trace canRate?: string;//0 代表不可以评价

  @Trace isRated?: string;//1 是代理对我的评价

  @Trace isReconsider?: string;   //0可以申诉,1是 申诉中， 2 是已申诉

  @Trace evaluateContent?: string;
  @Trace evaluateMark?: string;

  @Trace estimatedEvaluationTime?: string;
  @Trace estimatedEvaluationPrice?: string;

  @Trace typeID?: number;
  @Trace remark?: string;

  @Trace longitude?: string;
  @Trace latitude?: string;
  @Trace wordPath?: string;
  @Trace contract?: string;
  @Trace drawExportCode?: string;
  @Trace tendereeName?: string;
  @Trace pbTime?: string;
  @Trace pbAddress?: string;

  @Trace appeal?: string;
  @Trace appealAppendix?: string;
  @Trace deductionCount?: string;

  @Trace bidEvaluatedTime?: string;
  @Trace bidEvaluatedAddress?: string;
  @Trace appealReply?: string;
  @Trace appealReplyTime?: string;

  @Trace appeal2?: string;
  @Trace appealTime?: string;
  @Trace appealTime2?: string;
  @Trace appealAppendix2?: string;

  @Trace appealAppendJgUrl?: string;
  @Trace appealAppendJgUrl2?: string;
  @Trace appealReply2?: string;
  @Trace appealReplyTime2?: string;
  @Trace unReadDeductionCount?: string;

  //隔夜
  @Trace isOvernight?: string;

  /*奖励加分*/

  @Trace applyTime?: string;
  //奖励加分类型
  @Trace rewardTerms?: string;
  //具体内容
  @Trace rewardContent?: string;
  @Trace rewardTermsCode?: string;
  @Trace code?: string;
  //附件
  @Trace sysAttachList?: generalModel[];
  //分数
  @Trace scoreStandard?: string;
  @Trace sysAttachcol?: string;

  //其他扣分事项
  @Trace otherPointsReason?: string;
  @Trace otherPointsContent?: string;
  @Trace score?: string;
  @Trace attachmentFileName?: string;

  //专家违法行为
  @Trace illegalTerms?: string;
  @Trace illegalContent?: string;
  @Trace processingDecision?: string;
  //refuse
  //总体参评得分
  /*
   unDialed 未接听
   （refuse 主动拒绝
   unanswered 拨通未回复 ） = 主动拒绝
   一级列表-未接听 unanswered
   一级列表-主动拒绝 refuse
   */
  @Trace refuse?: string; //未接听 数
  @Trace unanswered?: string; //主动拒绝 数
  //集合unDialed 未接听（refuse 主动拒绝 unanswered 拨通未回复 ） = 主动拒绝 - 拨打电话 startTime 时间-
  @Trace refuseList?: generalModel[];   //
  @Trace unansweredList?: generalModel[]; //
  @Trace unDialedList?: generalModel[]; //
  @Trace ztType?: string; // 1 是未接通cell,  2是 主动拒绝cell
  @Trace unansweredDeductPoints?: string;//年度语音电话未接听数
  @Trace refuseDeductPoints?: string;//年度主动拒绝参评数

  @Trace participation?: generalModel;
  otherScore?: string;
  projectEvaluation?: generalModel;
  studyScoreModel?: generalModel;
  rewardScoreModel?: generalModel;
  otherScoreModel?: generalModel;
  illegalMattersModel?: generalModel;

  studyScore?: string;
  examScore?: generalModel;
  rewardScore?: string;
  illegalMatters?: string;

  @Trace participationScore?: string;
  @Trace otherScoreSize?: string;
  @Trace evaluationCount?: string;
  @Trace evaluationScore?: string;
  @Trace evaluationDeductPoints?: string;
  @Trace points?: string;
  @Trace haveTrained?: boolean;
  @Trace rewardSize?: string;
  @Trace totalScore?: string;




  //当前项目是否已办理云签章 1 是已办理  0 是未办理
  @Trace isHandleCA?: string;
  //当前项目是否需要办理项目云签章 1 是需要办理  0 是不需要办理
  @Trace isNeedHandleCA?: string;
  @Trace platformContent?: string;
  ///增加签到时间字段
  @Trace signTime?: string;
  substitute?: string;
  lateTime?: string;
  collectedTime?: string;
  @Trace leaveReason?: string;
  @Trace leaveAttach?: string;
  @Trace startTime?: string;
  sjr?: string;
  sjRdh?: string;
  mrDz?: string;
  provinceName?: string;
  cityName?: string;
  districtName?: string;
  sjRdz?: string;
  xxDz?: string;
  province?: string;
  city?: string;
  district?: string;
  Address?: string;
  IsDefault?: string;
  RowGuid?: string;
  rowId?: string;

  //---2

  static categoryStringByNum(numStr: string) {
    if (numStr.length > 4) {
      numStr = numStr.substring(0, 4);
    }
    let typeStr: string = "";
    switch (numStr) {
      case "5001":
        typeStr = "法律法规";
        break;
      case "5002":
        typeStr = "政策发布";
        break;
      case "5003":
        typeStr = "理论务实";
        break;
      case "5004":
        typeStr = "案例分析";
        break;
      case "5005":
        typeStr = "电子招投标";
        break;
      default:
        typeStr = "法律法规";
        break;
    }
    return typeStr;
  }


  static categoryImageByNum(numStr: string) {
    if (numStr.length > 4) {
      numStr = numStr.substring(0, 4);
    }

    let typeStr: Resource = $r("app.media.1220_falv");
    switch (numStr) {
      case "5001":
        typeStr = $r("app.media.1220_falv");
        break;
      case "5002":
        typeStr = $r("app.media.1220_articles");
        break;
      case "5003":
        typeStr = $r("app.media.1220_caozuo");
        break;
      case "5004":
        typeStr = $r("app.media.1220_anli");
        break;
      case "5005":
        typeStr = $r("app.media.1220_fanben");
        break;
      case "002":
        typeStr = $r("app.media.lb");
        break;
      default:
        typeStr = $r("app.media.1220_falv");
        break;
    }
    return typeStr;
  }

}


