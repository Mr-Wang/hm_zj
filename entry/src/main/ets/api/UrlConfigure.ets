
///首页
export const GET_STUDY_SY = "webdbInformation/getStudySy";
/// 培训首页
export const GET_TRA_ENROL_HOME_HTTP = "traCourse/getTraEnrolHome";
///视频专区和阅读专区列表 --002 是通知公告；
export const GET_INFORMATION_LIST_HTTP = "webdbInformation/getInformationList";

///文章详情
export const GET_XQBY_INFOID_HTTP = "webdbInformation/getXqbyInfoid";

///更新用户信息
export const UPDATE_USER_INFO_HTTP = "huiyuanUser/updateUserInfo";

///查询用户所属企业
export const GET_COMPANY_LIST_BY_ID_HTTP = "search/getCompanyListByID";

///用户更新企业信息
export const UPDATE_DAN_WEI_INFO_HTTP = "huiyuanUser/updateDanWeiInfo";

///培训课程分类列表
export const GET_TRA_COURSE_LIST_FROM_HOME_HTTP = "traCourse/getTraCourseListFromHome";

///课程详情页
export const GET_TRA_COURSE_DETAIL_HTTP = "traCourse/getTraCourseDetail";

///获取企业人员列表
export const GET_COMPANY_PERSON_LISTS_HTTP = "search/getCompanyPersonLists";

///获取地址列表
export const GET_USER_ADDRESS_LIST = "spaddress/getUserAddressList";
///报名提交接口
export const TRA_ENROL_GENERATE_HTTP = "traCourse/traEnrolGenerate";
/// 订单支付
export const ONLINE_PAY_HTTP = "pay/onlinepay";
/// 订单支付-通联
export const ALLIN_PAY_HTTP = "pay/allinPay";

/// 支付成功回调
export const BACK_ONLINE_PAY_HTTP = "product/onlinepay";

///我的课程-列表
export const TRA_ENROL_LIST_HTTP = "traCourse/traEnrolList";

///课程订单详情页
export const TRA_ENROL_DETAIL_HTTP = "traCourse/traEnrolDetail";

///电子发票列表
export const GET_INVOICE_LIST_HTTP = "sporderinvoice/getInvoiceList";

///电子发票详情
export const GET_INVOICE_DETAIL_HTTP = "sporderinvoice/getInvoiceDetail";

///查询用户积分
export const GET_XX_JF_HTTP = "webdbInformation/getXxJf";

/// 通过邀请码观看直播
export const CHECK_AUTH_CODE_HTTP = "webdbInformation/checkauthCode";

///考核首页
export const GET_EXAM_HOME_HTTP = "tExamScore/getExamHome";

///自测开始考试 -获取考试题
export const GET_QUESTION_LIST_HTTP = "tExamScore/getQuestionList";

///正式考试- 获取考试题
export const GET_REAL_QUESTION_LIST_HTTP = "tExamScore/getRealQuestionList";
/// 自测-个人历史
export const GET_PERSON_ORDER_HTTP = "tExamScore/getPersonOrder";

/// 自测-企业历史
export const GET_PERSON_OF_UNIT_ORDER_HTTP = "tExamScore/getPersonOfUnitOrder";

/// 试题回顾
export const GET_EAXM_MX_HTTP = "tExamScore/getEaxmMX";

///重置试题
export const RESET_EXAM_HTTP = "tExamScore/resetExam";

///提交考试内容 - 自测
export const COMMIT_EAXM_HTTP = "tExamScore/commitEaxm";

///提交考试内容 - 真实
export const COMMIT_REAL_EAXM_HTTP = "tExamScore/commitRealEaxm";

///获取正式考试列表
export const GET_EXAM_LIST_HTTP = "huiyuanUser/getExam";

///判断考试能否进行
export const GET_IS_EXAM_HTTP = "huiyuanUser/getIsexam";

///获取报名用户信息
export const GET_RZXX_HTTP = "huiyuanUser/getrzxx";

///报名认证 -提交
export const SM_RZXX_HTTP = "huiyuanUser/smrzxx";

///提交考试人脸信息内容(真实考试)
export const CHECK_FACE_HTTP = "tExamScore/checkface";

///收藏功能
export const INSERT_COLLECT_HTTP = "webdbInformation/insertCollect";

///阅读文章得积分
export const INSET_INTEGRAL_HTTP = "webdbInformation/insetIntegral";

///收藏列表
export const GET_COLLECT_HTTP = "webdbInformation/getCollect";

///获取上课限制人数
export const SELECT_DANWEI_GUID_HTTP = "traCourse/selectDanweiguid";

/// 留言板列表
export const GET_TRAIN_MESSAGE_HTTP = "tTrainmessage/getTrainmessage";

///添加留言
export const INSET_T_TRAIN_MESSAGE_HTTP = "tTrainmessage/insetTTrainmessage";

///消息列表
export const GET_TSLB_HTTP = "webdbInformation/getTslb";
///消息详情
export const UPDATE_TSLB_HTTP = "webdbInformation/updateTslb";

///添加地址
export const ADD_USER_ADDRESS_HTTP = "spaddress/addUserAddress";
///修改地址
export const UPDATE_USER_ADDRESS_HTTP = "spaddress/updateUserAddress";
///删除地址
export const DELETE_ADDRESS_HTTP = "spaddress/deleteAddress";
/// 上传文件
export const UPLOAD_TP_HTTP = "huiyuanUser/uploadavatar";

///type图片类型（1 学习  2培训 3考试  4 进入页）
export const GET_TP_URL_HTTP = "webdbInformation/getTpUrl";

///首页热搜词
export const GET_USER_KEY_HTTP = "webdbInformation/getUserkey";
///pdfShow
export const GET_PDF_HTTP = "tExamScore/getpdf";
///删除pdf
export const DELETE_PDF_HTTP = "traCourse/deletePDF";
///视频列表
export const GET_INFORMATION_VIDEO_LIST_HTTP = "webdbInformation/getInformationVideoList";
///企业人员所有积分（只有企业主能看）
export const GET_QYRY_JFLB_HTTP = "webdbInformation/getQyryJflb";

//出题
export const ADD_QUESTION_HTTP = "tQuestion/addQuestion";
//修改题目
export const UPDATE_QUESTION_HTTP = "tQuestion/updateQuestion";
// 题目列表
export const GET_T_QUESTION_LIST_HTTP = "tQuestion/getQuestionList";
///审核题目
export const CHECK_QUESTION_HTTP = "tQuestion/checkQuestion";
///获取是否为代理用户
export const DL_PERSON_HTTP = "sys/login/dlPerson";
/// 余额充值列表
export const APP_PRICE_HTTP = "tAppCoin/getPriceList";
///获取余额接口
export const GET_APP_COIN_HTTP = "tAppCoin/getAppCoin";

///默认余额列表
export const GET_DEFAULT_PRICE_LIST_HTTP = "tAppCoin/getdefaultPriceList";
/// 充值余额
export const MODIFY_APP_COIN_HTTP = "tAppCoin/modifyAppCoin";

/// 余额详情
export const GET_APP_COIN_DETAIL_HTTP = "tAppCoin/getAppCoinDetail";

///余额支付
export const APP_COIN_PAY_HTTP = "product/appCoinpay";

///专票附件上传
export const UPLOAD_INVOICE_HTTP = "product/uploadInvoice";

///会员详情页
export const GET_OPEN_VIP_HOME_HTTP = "huiyuanVipXx/getOpenVIPHome";

/**专家 -BaseURL */

///实名认证接口
export const ZJ_SM_RZXX_HTTP = "bidevaluation/smrzxx";
///检查该人员是否在监管库
export const CHECK_IN_JIANGUAN_HTTP = "bidevaluation/checkinjianguan";
///评标通知接口
export const GET_BID_NOTICE_LIST_HTTP = "bidevaluation/getBidNoticeList";
///评标专家首页接口
export const ZJ_GET_DEFAULT_HTTP = "zjDefault/getDefault";
///绑定pushID
export const ADD_PUSH_CLIENT_EQUIPMENT = "pushClientEquipment/addPushClientEquipment";
///专家上传图片
export const E_UPLOAD_FILE_HTTP = "expert/uploadFile";
///选择专业
export const GET_PROFESSION_HTTP = "expert/getProfession";

///选择老专业  参数 pcode   第一级下拉传空字符串
export const EXPERT_GET_SYS_INDUSTRIES_TYPE_SECOND_LIST_HTTP = "expert/getSysIndustriesTypeSecondList";

///获取专家信息
export const GET_EXPERT_MESSAGE_HTTP = "expert/getExpertMessage";
///获取无专业类别专家信息
export const GET_EXPERT_MESSAGE_OF_ALL_HTTP = "expert/getExpertMessageOfAll";

///提交专家信息
export const UPDATE_ZJ_DATA_HTTP = "expert/updateZjData";
///完善信息审核状态
export const EXPERT_GET_EXPERT_LIST_HTTP = "expert/getExpertList";
///获取专家完善信息状态
export const EXPERT_GET_USER_HAS_COMPLETE_STATUS_HTTP = "expert/getUserHasCompleteStatus";
///获取专家锁定状态
export const EXPERT_IS_LOCKED_HTTP = "expert/isLocked";
///获取专家信用
export const EXPERT_GET_EXPERT_PENALTY_HTTP = "expert/getExpertPenalty";
///专家请假获取电话
export const EXPERT_GET_LEAVE_PHONE_HTTP = "expert/getLeavePhone";
///一天扫一次脸 -data 0 不需要扫脸，1需要扫脸
export const BID_EVALUATION_SM_RZXX_IS_BELOW_HTTP = "bidevaluation/smrzxxIsBelow";
///签到接口
export const EXPERT_DECRYPT_HTTP = "expert/signIn";
///签到判断时间、距离接口
export const EXPERT_DISTANCE_HTTP = "expert/distance";
///扫脸登录
export const FACE_LOGIN_HTTP = "sys/face/login";

/// 登陆
export const LOGIN_HTTP = "sys/login/restful";
/// 退出登陆
export const LOGOUT_HTTP = "sys/logout";
/// 注册获取验证码
export const ZC_SEND_SHORT_HTTP = "pushClientEquipment/sendShortMessageZc";
/// 找回密码获取验证码
export const LOST_PWD_SEND_SHORT_HTTP = "pushClientEquipment/sendShortMessage";
///修改密码
export const UPDATE_PASSWORD_HTTP = "huiyuanUser/updatePassword";
///重置密码
export const RESET_PWD_HTTP = "huiyuanUser/resetPassword";
/// 注册
export const ZC_HTTP = "sys/login/register";
///获取专家是否通过考试
export const EXPERT_GET_EXPERT_PASS_HTTP = "expert/getExpertPass";

///获取专家完善信息身份列表
export const EXPERT_GET_EXPERT_IDENTITY_HTTP = "expert/getExpertIdentity";

///获取专家-专业列表
export const GET_WAIT_EXTRACT_PROFESSION_HTTP = "expert/getWaitExtractProfession";

///专家专业更多- 列表
export const GET_PROFESSION_HISTORY_HTTP = "expert/getProfessionHistory";

///获取专家完善的信息(新-2020-11-03)
export const EXPERT_GET_EXPERT_INFO_HTTP = "expert/getExpertInfo";

///网联-获取专家证书前置条件 0 成功、1失败、2未生成证书
export const WL_ADD_QUESTION_GET_ZJ_STATUS_HTTP = "tExamScore/getZJStatus";

///网联-上传头像生成证书
export const WL_T_EXAM_SCORE_CREATE_ZJ_CERT_HTTP = "tExamScore/getZJcertNew";

///专家-获取职称等级
export const ZJ_EXPERT_GET_JOB_TITLE_HTTP = "expert/getJobTitle";

///专家-添加评论
export const ZJ_INSERT_RATE_HTTP = "expert/insertRate";
///专家 - 我的评价列表
export const ZJ_GET_EXPERT_RATE_LIST_HTTP = "expert/getExpertRateList";

///专家 - 查看代理对我的评价
export const ZJ_GET_EXPERT_EVALUATE_HTTP = "expert/getExpertEvaluate";

///专家 - 获取我的评价详情
export const ZJ_GET_EXPERT_RATE_DETAIL_HTTP = "expert/getExpertRateDetail";
///-专家 - 获取评价详情 新的
export const ZJ_BID_EVALUATION_GET_EXPERT_EVALUATE_HTTP = "bidevaluation/getExpertEvaluate";

///专家 - 提交申诉
export const ZJ_EXPERT_RECONSIDER_HTTP = "expert/expertReconsider";

///专家 - 申诉详情
export const ZJ_GET_RECONSIDER_DETAIL_HTTP = "expert/getReconsiderDetail";

/// 专家- 推送列表
export const ZJ_GET_TS_LIST_HTTP = "expert/getTsList";
/// 专家- CA生成申请书
export const ZJ_CA_CREATE_CA_HTTP = "ca/createCa";
/// 专家-CA - 获取用户基本信息
export const ZJ_SYS_GET_INFO_HTTP = "sys/getInfo";
/// 专家- CA签名申请书
export const ZJ_CA_REQUEST_CA_HTTP = "ca/requestCa";
/// 专家-CA提交订单接口
export const ZJ_CREATE_DD_HTTP = "ca/createDD";
/// 专家-CA订单列表接口
export const ZJ_GET_MY_DEAL_HTTP = "ca/getMyDeal";
/// 专家-CA订单详情接口
export const ZJ_GET_MY_DEAL_INFO_HTTP = "ca/getMyDealInfo";
/// 专家 - CA确认收货
export const ZJ_CA_RECEIPT_HTTP = "ca/receipt";
/// 专家 -获取的CA申请状态
export const ZJ_CA_GET_CA_STATUS_HTTP = "ca/getCaStatus";
/// 专家 -删除CA订单
export const ZJ_CA_DELETE_DD_HTTP = "ca/deleteDD";
/// 专家-CA补办接口
export const ZJ_CREATE_BB_HTTP = "ca/createBB";
/// 专家- CA补办签名申请书
export const ZJ_CA_REQUEST_BB_HTTP = "ca/requestBB";
/// 专家-CA补办-下单接口
export const ZJ_CREATE_BB_DD_HTTP = "ca/createBBDD";
///专家-CA查询-是否有补办未完结状态；
export const ZJ_GET_BB_STATUS_HTTP = "ca/getBBStatus";
/// 专家-是否能获取专家行动轨迹
export const ZJ_GET_ZJ_ADDRESSES_STATUS_HTTP = "expert/getZjAddressesStatus";
/// 专家-收集专家行动轨迹坐标
export const ZJ_GET_ZJ_ADDRESSES_HTTP = "expert/getZjAddresses";
/// 专家-文档列表
export const ZJ_GET_BOOK_LIST_HTTP = "expert/getBookList";
/// 学习 - 转换HTML
export const DEL_HTML_TAG_HTTP = "tExamScore/delHTMLTag";
/// 专家获取管理员身份； -code 0是管理员
export const ZJ_SYS_GET_ADMIN = "sys/getAdmin";

/// -监管- 创建咨询投诉
export const JG_EXPERT_QUESTION_CREATE_QUESTION_HTTP = "expertQuestion/createQuestion";
/// -监管- 创建咨询投诉 - 提交
export const JG_EXPERT_QUESTION_ANSWER_QUESTION_HTTP = "expertQuestion/answerQuestion";
/// -监管- 创建咨询投诉 - 上传图片
export const JG_EXPERT_QUESTION_UPLOAD_HTTP = "expertQuestion/upload";
/// -监管- 创建咨询投诉 - 获取我的提问列表
export const JG_EXPERT_QUESTION_GET_MY_QUESTION_HTTP = "expertQuestion/getMyQuestionNew";
/// -监管- 创建咨询投诉 - 管理员获取提问列表
export const JG_EXPERT_QUESTION_GET_QUESTION_FOR_ADMIN_HTTP = "expertQuestion/getQuestionForAdminNew";
/// -监管- 获取城市列表
export const JG_REGION_CITY_BY_LN_HTTP = "region/cityByLN";
///-监管- 咨询投诉评分 - body参数 回复的id 评分 anRate
export const JG_EXPERT_QUESTION_ANSWER_RATE_HTTP = "expertQuestion/answerRate";
/// -专家- 回避单位列表
export const ZJ_EXPERT_GET_ACTIVE_AVOIDANCE_COMPANY_HTTP = "expert/getActiveAvoidanceCompany";
/// -专家 - 添加回避单位
export const ZJ_EXPERT_UPDATE_ACTIVE_AVOIDANCE_COMPANY_HTTP = "expert/updateActiveAvoidanceCompany";

/// -专家 - 删除回避单位
export const ZJ_EXPERT_DELETE_ACTIVE_AVOIDANCE_COMPANY_HTTP = "expert/deleteActiveAvoidanceCompany";

/// - 专家 - 专业buff
export const ZJ_EXPERT_GET_EXPERT_TAGS_HTTP = "expert/getExpertTag";
///虚拟中间号- AB绑定
export const ZJ_HOST_RECORD_PHONE_HTTP = "host/recordPhone";
///专家证书 - 生成确认接口
export const XX_INSERT_ZJ_CERT = "tExamScore/insertZJcert";
///专家银行卡- 获取
export const ZJ_GET_EXPERT_BANK_HTTP = "expert/getExpertBank";
///专家银行卡输入银行卡号后 自动验证
export const ZJ_EXPERT_BANK_GET_BANK_HTTP = "expert/bank/getBank";
///专家-添加银行卡接口
export const ZJ_PERFECT_BANK_HTTP = "expert/perfectBank";
///专家- 查询是是不是社会专家，社会紫（超龄）1、社会蓝（甲方）2
export const ZJ_EXPERT_GET_EXPERT_IS_MIND_HTTP = "expert/getExpertIsMind";
///专家- 新专家征集报名
export const ZJ_EXPERT_TOURIST_CHANGE_EXPERT_HTTP = "expert/touristChangeExpert";
///-专家- 申请注销账号
export const ZJ_USER_LOGOUT_HTTP = "sys/user/logout";

///-专家- 获取 是否新入库专家  0 是  1 不是
export const ZJ_EXPERT_GET_EXPERT_IS_NEW_HTTP = "expert/getExpertIsNew";
///-专家- 修改专家库手机号
export const ZJ_EXPERT_UPDATE_PHONE_HTTP = "expert/updatePhone";
/// - 专家- 习惯手机号 -发送验证码
export const ZJ_EXPERT_SEND_UPDATE_MESSAGE_HTTP = "expert/sendUpdateMessage";

/// - 专家- 获取专家资格证书照片
export const ZJ_GET_CERTIFICATES_HTTP = "expert/getCertificates";
/// - 专家- 上传专家资格证书照片
export const ZJ_PERFECT_CERTIFICATES_HTTP = "expert/perfectCertificates";
/// -专家-上传
export const ZJ_CA_SIGN_GOT_HTTP = "ca/signGot";

/// -专家保存-中共党员身份 和 签字的接口    2022-04-08 18:19:26
export const ZJ_GET_USER_SIGNATURE_HTTP = "huiyuanUser/getUserSignature";
/// -专家劳务报酬结算列表
export const ZJ_GET_BID_EVALUATION_FEE_LIST_HTTP = "bidevaluation/getBidEvaluationFeeList"

/// -专家评标协议签字-协议没有签字  bidSectionCodes标段名称  idcardnum 身份号   UserGuid 用户id
export const ZJ_REQUEST_REVIEW_HTTP = "bidevaluation/signinSignature";

/// -专家评标协议签字-协议带签字   bidSectionCodes标段名称  idcardnum 身份号   UserGuid 用户id   userSignature  签字url
export const ZJ_REQUEST_REVIEW_SIGNATURE_HTTP = "bidevaluation/signinSignatureNew";

/// -专家费详情
export const ZJ_GET_BID_EVALUATION_FEE_DETAILED_HTTP = "bidevaluation/getBidEvaluationFeeDetailed";
/// - 专家费结算记录
export const ZJ_GET_BID_EVALUATION_FEE_RECORD_HTTP = "bidevaluation/getbidEvaluationFeeRecord";
/// -专家增加费用异议
export const ZJ_GET_EXPERT_DETAILED_HTTP = "bidevaluation/getExpertDetailed";
/// 结算签字协议
export const ZJ_TRADING_SIGNATURE_HTTP = "bidevaluation/tradingSignature";
/// 结算未签字协议
export const ZJ_TRADING_NOT_SIGNATURE_HTTP = "bidevaluation/tradingNotSignature";
/// 提交结算
export const ZJ_TRADING_SIGNATURE_CONFIRM_HTTP = "bidevaluation/tradingSignatureConfirm";

/// - 专家办理云签章 - 获取云签章类型
export const ZJ_GET_CLOUD_SIGNATURE_TYPE_HTTP = "ca/getCloudSignatureType";
/// - 专家办理云签章 - 获取云签章介绍
export const ZJ_HANDLE_CLOUD_SIGNATURE_INTRODUCE_HTTP = "ca/handleCloudSignatureIntroduce";

/// - 专家办理云签章 -生成订单
export const ZJ_HANDLE_CLOUD_SIGNATURE_HTTP = "ca/handleCloudSignature";

//getCloudSignaturePrice(String manufacturer,String validityPeriod)
/// - 专家办理云签章 - 查钱
export const ZJ_GET_CLOUD_SIGNATURE_PRICE_HTTP = "ca/getCloudSignaturePrice";
/// -专家办理云签章列表
export const ZJ_GET_CLOUD_SIGNATURE_LIST_HTTP = "ca/getCloudSignatureList";
/// -专家云签章订单详情
export const ZJ_GET_CLOUD_SIGNATURE_HTTP = "ca/getCloudSignature";
/// -专家云签章取消订单
export const ZJ_CANCEL_CLOUD_SIGNATURE_HTTP = "ca/cancelCloudSignature";
/// -专家证书、云签章获取订单状态
export const ZJ_CANABLE_TO_HANDLE_HTTP = "ca/canableToHandle";
/// -专家- 云签章 修改签名
export const ZJ_UPDATE_SIGNATURE_HTTP = "ca/updateSignature";
///取消结算
export const ZJ_TRADING_CANCEL_SIGNATURE_HTTP = "bidevaluation/tradingCancelSignature";
///专家字典表
export const ZJ_DICTIONARY_HTTP = "dictionary";
///添加申诉
export const ZJ_APPEAL_EXPERT_EVALUATE_HTTP = "bidevaluation/appealExpertEvaluate";
///申诉列表
export const ZJ_GET_APPEAL_LIST_HTTP = "bidevaluation/getAppealList";
///考评记录表
export const ZJ_GET_EXPERT_EVALUATE_TABLE_HTTP = "bidevaluation/getExpertEvaluateTable";
///申诉详情
export const ZJ_GET_EXPERT_EVALUATE_BY_ID_HTTP = "bidevaluation/getExpertEvaluateById";
///首页消息未读数
export const ZJ_GET_EXPERT_EVALUATE_UN_READ_COUNT_HTTP = "bidevaluation/getExpertEvaluateUnReadCount";
///年度评价首页
export const ZJ_EVALUATE_HTTP = "bidevaluation/year/evaluate";
///奖励加分事项类型代码表
export const ZJ_REWARD_CODE_HTTP = "bidevaluation/rewardCode";
///奖励加分列表
export const ZJ_REWARD_APPLY_LIST_HTTP = "bidevaluation/rewardApplyList";
///申请奖励加分
export const ZJ_REWARD_APPLY_HTTP = "bidevaluation/rewardApply";
///其他扣分
export const ZJ_GET_OTHER_POINTS_HTTP = "bidevaluation/getOtherPoints";
///违法行为
export const ZJ_GET_ILLEGAL_IDCARD_HTTP = "bidevaluation/getIllegalIdcard";
///总体参评得分
export const ZJ_GET_CALL_RESULT_HTTP = "bidevaluation/getCallResult";
///一键请假
export const ZJ_LEAVE_HTTP = "bidevaluation/leave";
///苹果支付-云签章
export const ZJ_PAY_IOS_PAY_HTTP = "pay/iosPay";
///开关接口
export const ZJ_DICTIONARY_GET_CODE_HTTP = "dictionary/getCode";
///同步专家库
export const ZJ_SYNC_EXPERT_DATA_HTTP = "expert/syncExpertData";
///专家修改专业地区
export const ZJ_UPDATE_CITY_HTTP = "expert/updateCity";
///专家修改地区 审核记录
export const ZJ_GET_APPROVAL_HTTP = "expert/approvalRecord";
///专家修改地区详情页
export const ZJ_UPDATE_DETAIL_HTTP = "expert/selectDetailById";
///云签章-临时项目
export const ZJ_HANDLE_PROJECT_CLOUD_SIGNATURE_HTTP = "ca/handleProjectCloudSignature";
///设置主评专业
export const ZJ_SET_MAIN_EVALUATION_MAJOR_HTTP = "expert/setMainEvaluationMajor";
///申请国家节点
export const ZJ_INSERT_NATIONAL_NODES_OR_NEW_MECHANISM_HTTP = "expert/insertNationalNodesOrNewMechanism";
///申请国家节点详情页；
export const ZJ_GET_EXPERT_MAIN_EVALUATION_INFORMATION_HTTP = "expert/getExpertMainEvaluationInformation";
///国家节点库及新机制审核列表
export const ZJ_GET_EXPERT_MAIN_EVALUATION_LIST_HTTP = "expert/getExpertMainEvaluationList";

/// 查询getCommitmentEleNew
export const ZJ_GET_COMMITMENT_ELE_NEW_HTTP = "expert/getCommitmentEleNew";
/// 修改commitmentEleNew
export const ZJ_UPD_COMMITMENT_ELE_NEW_HTTP = "expert/updCommitmentEleNew";

/// 首页提示
export const ZJ_GET_CITY_EXPORT_UPD_HTTP = "expert/getCityExportUpd";
///看视频轮询
export const ADD_VIDEO_DETAIL_HTTP = "webdbInformation/addVideoDetail";
///评价详情接口
export const GET_TRAIN_MESSAGE_NEW_HTTP = "tTrainmessage/getTrainmessagenew";

export const ZJ_EXPERT_LEAVE_RESPONSE_HTTP = "expert/expertLeaveResponse";