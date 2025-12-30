import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ContextUtils, UserInfo } from './ContextUtils';
import { CoreUtils } from './CoreUtils';
import { StringUtils } from './StringUtils';
import { BaseConstants } from '../constants/BaseConstants';
import { UserConstants } from '../constants/UserConstants';
import convert from '@ohos/xml_js'
import { buffer, JSON } from '@kit.ArkTS';
import { DeviceUtil, StrUtil } from '@pura/harmony-utils';
import {efRcpClientApi,EfRcpResponse} from '@yunkss/ef_rcp'
import { rcp } from '@kit.RemoteCommunicationKit';

// 更精确的函数类型定义
type XmlAttributeHandler = (val: string, elementName: string) => string;

interface XmlConversionOptions {
  compact: boolean;
  textFn: XmlAttributeHandler;
  instructionNameFn: XmlAttributeHandler;
  elementNameFn: XmlAttributeHandler;
  attributeNameFn: XmlAttributeHandler;
  attributeValueFn: XmlAttributeHandler;
  textKey:string,
  cdataKey:string,
  alwaysChildren:boolean

}

/**
 * 请求工具类
 */
export interface RequestConfig {
  url: string;
  headers?: RequestHeaders;
  method: http.RequestMethod | string;
  data?: object;
  updateData?:rcp.MultipartFormFields;
  timeout?: number;
  loadingTxt?:string;
}

export interface RequestHeaders {
  isToken?: boolean;
  token?: string;
  'Content-Type'?: string;
  Protocol?: string;
  system?:string;
  version?:string;
  appKey?:string;
  Accept?:string;

}


export class RcpRequestUtils {


  static request = async (config: RequestConfig) => {
    // 是否需要设置 token
    let isToken = true;
    let headerObj: RequestHeaders | undefined = config.headers?config.headers:{} ;
    headerObj.appKey= DeviceUtil.getODID();
    if (!!config.headers && config.headers?.isToken === false) {
      isToken = false;
    } else {
      headerObj.token =  ContextUtils.getToken().toString();
      console.log('token:' + headerObj.token)
      //因为写接口的人菜，这个 B 接口设计 所有接口都需要传递 UserGuid 参数，反人类，只能破坏结构从这里传了；
      if(config.data) {
        config.data["UserGuid"] = ContextUtils.getUserInfo()?.userGuid;
        //config.url 后面需要拼接UserGuid参数，不然会报错
        if (config.method != "GET") {
          if (config.url.indexOf("?") > 0) {
            config.url = config.url + "&UserGuid=" + ContextUtils.getUserInfo()?.userGuid;
          } else {
            config.url = config.url + "?UserGuid=" + ContextUtils.getUserInfo()?.userGuid;
          }
        }
      } else {
        config.data = {
          UserGuid: ContextUtils.getUserInfo()?.userGuid,
        } as UserInfo;
      }

    }
    let dataResponse: EfRcpResponse<object> | null = null; // 明确类型并初始化为 null

    if (config.method == "GET") {
      dataResponse =  await efRcpClientApi.get({
        url: config.url,
        headers: {
          "appKey": DeviceUtil.getODID(),
          "token": ContextUtils.getToken().toString(),
        },
        query: config.data,
        isParams:config.data != null,
        loadingTxt: config.loadingTxt
      },)
    }else if (config.method == "POST") {
      dataResponse =  await efRcpClientApi.post({
          url: config.url,
          headers: {
            "appKey": DeviceUtil.getODID(),
            "token": ContextUtils.getToken().toString(),
          },
          query: config.data,
          loadingTxt: config.loadingTxt
        },)
    }
    else if (config.method == "POSTFORM") {
      dataResponse =  await efRcpClientApi.postForm({
        url: config.url,
        headers: {
          "appKey": DeviceUtil.getODID(),
          "token": ContextUtils.getToken().toString(),
        },
        query: config.data,
        loadingTxt: config.loadingTxt
      },)
    }
    else if (config.method == "postMultipartForm") {
      dataResponse =  await efRcpClientApi.uploadFile({
        fileInfo:config.updateData,
        url: config.url,
        headers: {
          "appKey": DeviceUtil.getODID(),
          "token": ContextUtils.getToken().toString()
        },
        loadingTxt: config.loadingTxt
      },)
    }
    const promise: Promise<object> = new Promise((resolve: Function, reject: Function) => {

      if (dataResponse?.data != null) {
         if (dataResponse?.data["code"] == 0) {
          // 返回解析后的对象
          resolve(dataResponse?.data);
        } else if (dataResponse?.data["code"] == 401) {
           AlertDialog.show(
             {
               title: $r('app.string.tips'),
               message: $r('app.string.to_login_tips'),
               cornerRadius: BaseConstants.BORDER_RADIUS,
               height: 200,

               secondaryButton: {
                 value: $r('app.string.re_login'),
                 action: () => {
                   CoreUtils.delJhmData(UserConstants.TOKEN_KEY)
                   CoreUtils.toLogin()
                 }
               }
             }
           )
           reject(dataResponse?.data);
         } else {
          reject(dataResponse?.data);
        }

      }
      else {
        if (dataResponse?.error?.code == 401) {
          if (isToken) {
            AlertDialog.show(
              {
                title: $r('app.string.tips'),
                message: $r('app.string.to_login_tips'),
                cornerRadius: BaseConstants.BORDER_RADIUS,
                height: 200,
                secondaryButton: {
                  value: $r('app.string.re_login'),
                  action: () => {
                    CoreUtils.delJhmData(UserConstants.TOKEN_KEY)
                    CoreUtils.toLogin()
                  }
                }
              }
            )
            reject($r('app.string.login_timeout'))


          }
          else {
            AlertDialog.show(
              {
                title: $r('app.string.tips'),
                message: $r('app.string.login_error'),
                cornerRadius: BaseConstants.BORDER_RADIUS,
                height: 200,
                secondaryButton: {
                  value: $r('app.string.yesbtn'),
                  action: () => {
                  }
                }
              }
            )
            reject($r('app.string.login_error'))
          }
          return;
        }
        console.error( config.url + ', error:' + dataResponse?.error?.message);
        const message = StringUtils.getResStr($r('app.string.request_error')) + '[' + dataResponse?.error?.message + ']';
        CoreUtils.toast(message);
        reject(dataResponse?.error);
      }

    });
    return promise;
  }


}
