import { RcpRequestUtils } from "jbase"
import { generalModel } from "../model/ZJ_Model"
import { rcp } from "@kit.RemoteCommunicationKit"


// 获取论坛TAB
export const easyRequest = (url:string,method:string): Promise<object> => {
  return RcpRequestUtils.request({
    url: url,
    method: method
  })
}

export const easyDataRequest = (url:string, params: generalModel, method:string): Promise<object> => {
  return RcpRequestUtils.request({
    url: url,
    method: method,
    data:params
  })
}

function isMultipartFormFieldValue(value: string): rcp.MultipartFormFieldValue | rcp.MultipartFormFieldValue[] {
  return typeof value === 'string' ||
    typeof value === 'number' ||
    typeof value === 'boolean'
}

function convertToMultipartFormFields(model: generalModel): rcp.MultipartFormFields {
  const result: rcp.MultipartFormFields = {};

  Object.keys(model).forEach((key: string) => {
    // 通过键来获取值
    const value :string= (model as Record<string, string>)[key] || "";
    console.log(`Key: ${key}, Value: ${value}`);
    // 这里添加你的处理逻辑
    if (value !== undefined && value !== null && isMultipartFormFieldValue(value)) {
      result[key] = value;
    }
  });

  return result;
}

export const easyUploadRequest = (url:string, params: generalModel, method:string = "POST"): Promise<object> => {
  //如果有图片或者视频 - 走上传方法
  if ((params.arrImagesUint8 != null && params.arrImagesUint8.length > 0) || (params.arrVideoUint8 != null && params.arrVideoUint8.length > 0)) {
    // let multipartFormFields: rcp.MultipartFormFields = {
    //   "content":params.content??"",
    //   "isVideo":params.isVideo??"",
    //   "columnId":params.columnId??"",
    //   "action":params.action??"",
    //   "title":params.title??"",
    //   "num":params.num??"",
    //   "type":params.type??"",
    // }
    let multipartFormFields: rcp.MultipartFormFields = convertToMultipartFormFields(params)

    if(params.isVideo == "1") {
      //添加视频
      // 使用动态键名添加图片字段
      multipartFormFields[`videofile`] = {
        contentType: 'video/mp4',
        remoteFileName: `video.mp4`,
        contentOrPath: {
          content: params.arrVideoUint8![0]
        }
      };
      // videoImg	image/jpeg	xxx.jpg	112.66 KB (115,361 bytes)
      multipartFormFields[`videoImg`] = {
        contentType: 'image/jpeg',
        remoteFileName: `videoPixelMap.jpg`,
        contentOrPath: {
          content: params.videoPixelMap!
        }
      };

    }  else {
      //添加图片
      // 动态添加图片字段
      if (params.arrImagesUint8 && params.arrImagesUint8.length > 0) {
        for (let i = 0; i < params.arrImagesUint8.length; i++) {
          // 使用动态键名添加图片字段 action = updatePhoto 这个逼接口 只传 1 张图片，不加索引值
          multipartFormFields[params.arrImagesUint8.length == 1 ?'file':`file${i + 1}`] = {
            contentType: 'image/png',
            remoteFileName: `image_${i + 1}.png`,
            contentOrPath: {
              content: params.arrImagesUint8[i]
            }
          };
        }
      }
    }


    return RcpRequestUtils.request({
      url:url,
      method: "postMultipartForm",
      updateData:multipartFormFields,
    })
  }
  else {
    return RcpRequestUtils.request({
      url:url,
      method: method,
      data:params,
    })
  }
}