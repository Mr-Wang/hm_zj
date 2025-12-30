import { RcpRequestUtils } from "jbase"
import { AppConfig } from "../config/Index"
import { http } from "@kit.NetworkKit"
import { LOGIN_HTTP } from "./UrlConfigure";

export interface LoginParams {
  // authStr: string;
  password: string;
  username: string;
}

// 登录方法
export const login = (params: LoginParams): Promise<object> => {
  return RcpRequestUtils.request({
    url: AppConfig.baseUrl + LOGIN_HTTP,
    method: "POSTFORM",
    data: params,
    headers: {
      isToken: false,

    }
  })
}



// 获取用户详细信息
export const getUserInfo = (): Promise<object> => {
  return RcpRequestUtils.request({
    url: AppConfig.baseUrl + '/getInfo',
    method: http.RequestMethod.GET
  })
}

// 退出方法
export const logout = (): Promise<object> => {
  return RcpRequestUtils.request({
    url: AppConfig.baseUrl + '/logout',
    method: http.RequestMethod.POST
  })
}

// 获取验证码
export const getCodeImg = (): Promise<object> => {
  return RcpRequestUtils.request({
    url: AppConfig.baseUrl + '/captchaImage',
    method: http.RequestMethod.GET,
    headers: {
      isToken: false
    },
    timeout: 20000
  })
}
