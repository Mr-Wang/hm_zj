import { UserConstants } from "../constants/UserConstants"
import { CoreUtils } from "./CoreUtils"
import preferences from "@ohos.data.preferences"

// 用户信息
export interface UserInfo {
  id?: string;
  loginTime?: string;
  loginNum?: string;
  sbrUnitguid?: string;
  sbrName?: string;
  sbrCode?: string;
  sbrUnitname?: string;
  sbrDate?: string;
  sbrTel?: string;
  sbrMoblie?: string;
  shrCode?: string;
  shrName?: string;
  shrDate?: string;
  dogsenderCode?: string;
  dogsenderName?: string;
  dogsenderDate?: string;
  createrName?: string;
  createrCode?: string;
  yxq?: string;
  orgDanWeiGuid?: string;
  createrDate?: string;
  rowId?: string;
  orgnum?: string;
  faren?: string;
  zhuceziben?: string;
  lianxiren?: string;
  lianxiphone?: string;
  fax?: string;
  address?: string;
  baomingidcard?: string;
  authorizationLetterUrl?: string;
  commitmentLetterUrl?: string;
  idcardAUrl?: string;
  idcardBUrl?: string;
  danweizhengUrl?: string;
  postalcode?: string;
  processcode?: string;
  processguid?: string;
  isaudit?: string;
  idcardnum?: string;
  unitbankname?: string;
  unitbankcode?: string;
  token?: string;
  oldPassword?: string;
  newPassword?: string;
  yzm?: string;
  yhdh?: string;
  weixin?: string;
  catype?: string;
  cadueDate?: string;
  caapplyDate?: string;
  epapplyDate?: string;
  epdueDate?: string;
  adduration?: string;
  adapplyDate?: string;
  addueDate?: string;
  vipapplyDate?: string;
  vipdueDate?: string;
  viptype?: string;
  viplevel?: string;
  avatarPath?: string;
  user_type?: string;
  type_name?: string;
  lsh?: string;
  adposition?: string;
  loginType?: string;
  enterpriseKeyID?: string;
  spAddress?: string;
  title?: string;
  content?: string;
  bxContent?: string;
  createtime?: string;
  zanType?: string;
  bxZanType?: string;
  scType?: string;
  nicheng?: string;
  zanNum?: number;
  dzUserGuid?: string;
  pllsh?: string;
  chatid?: string;
  uuid?: string;
  type?: string;
  pic?: string;
  orgtype?: string;
  isuserjob?: string;
  ischeck?: string;
  key?: string;
  userid?: string;
  shouji?: string;
  yhname?: string;
  userSignature?: string;
  sfzzm?: string;
  sfzfm?: string;
  partyMember?: number;
  mobilePhone?: string;
  auditStatus?: string;
  sex?: string;
  danWeiName?: string;
  EMail?: string;
  passWD?: string;
  realname?: string;
  loginID?: string;
  userType?: string;
  userGuid?: string;
  UserGuid?: string;
}


export class ContextUtils {



  // 记住密码
  static setRememberPassword = (token: string) => {
    CoreUtils.setJhmData(UserConstants.REMEMBER_PASSWORD, token);
  }
  static getRememberPassword = (): preferences.ValueType => {
    return CoreUtils.getJhmData(UserConstants.REMEMBER_PASSWORD, '');
  }

  // 记住密码
  static setRememberUserName = (token: string) => {
    CoreUtils.setJhmData(UserConstants.REMEMBER_USERNAME, token);
  }
  static getRememberUserName = (): preferences.ValueType => {
    return CoreUtils.getJhmData(UserConstants.REMEMBER_USERNAME, '');
  }


  // token信息
  static setToken = (token: string) => {
    CoreUtils.setJhmData(UserConstants.TOKEN_KEY, token);
  }
  static getToken = (): preferences.ValueType => {
    return CoreUtils.getJhmData(UserConstants.TOKEN_KEY, '');
  }
  // 上下文信息
  static setUserInfo = (userInfo: UserInfo) => {
    CoreUtils.setJhmData(UserConstants.CTT_KEY, userInfo);
  }
  static getUserInfo = (): UserInfo | null => {
    const userInfoStr: string = JSON.stringify(CoreUtils.getJhmData(UserConstants.CTT_KEY, ''));
    const userInfo: UserInfo = JSON.parse(userInfoStr);
    return userInfo;
  }
}