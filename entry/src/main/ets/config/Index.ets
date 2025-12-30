import { AppConfigModel } from "jbase";

/**
 * 配置信息
 */
export const AppConfig: AppConfigModel = {
  baseUrl: 'https://lnwlzj.capass.cn/',
  studyBaseUrl:'https://fgwstudy.lnwlzb.com/',
  appLogo: $r('app.media.logo'),
  appName: '辽宁专家服务',
  loginTitle: ``,
  loginLogo: $r('app.media.logo'),
  copyRight: ``,
  // Ai相关配置
  aiRootUrl: ''
}
//微信 APPID
export  const APP_ID_WX = 'wxd2381bec1a8984de'
// 图片压缩尺寸，单位kb
export  const IMAGE_COMPRESSION_SIZE = 1000