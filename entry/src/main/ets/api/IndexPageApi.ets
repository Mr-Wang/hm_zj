import { RcpRequestUtils } from "jbase"
import rcp from "@hms.collaboration.rcp";

export interface FormFieldFileValue {
  contentType?: ContentType;
  remoteFileName?: string;
  contentOrPath: string;
}

// 获取首页数据接口
export const indexPageRequest = (): Promise<object> => {
  return RcpRequestUtils.request({
    url:'jsp/club/client/index.jsp',
    method: "POST"
  })
}



// // 简单请求
// export const easyRequest = (url:string,method:string): Promise<object> => {
//   return RcpRequestUtils.request({
//     url: url,
//     method: method
//   })
// }
