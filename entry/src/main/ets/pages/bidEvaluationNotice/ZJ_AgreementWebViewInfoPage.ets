import { ContextUtils, CoreUtils, FullLoading, UserInfo } from "jbase";
import { PhotoHelper } from '@pura/picker_utils';
import { BusinessError } from "@kit.BasicServicesKit";
import { DeviceUtil, DialogUtil, ImageUtil, KeyboardUtil, LogUtil, ToastUtil, WindowUtil } from "@pura/harmony-utils";

import { fileUri } from "@kit.CoreFileKit";
import fs from '@ohos.file.fs'
import { photoAccessHelper } from "@kit.MediaLibraryKit";
import { image } from "@kit.ImageKit";
import {generalModel} from "../../model/ZJ_Model"
import { webview } from "@kit.ArkWeb";
import { popupImagePreviewer} from '@ethan/image-previewer'
import { PreviewImageInfo, Previewer } from "@humor/lg-image-previewer"
import { common } from "@kit.AbilityKit";
import { AppConfig } from "../../config/Index";
import { systemShare } from "@kit.ShareKit";
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { DialogHelper } from '@pura/harmony-dialog';
import { easyDataRequest } from "../../api/EasyRequest";
import { ZJ_REQUEST_REVIEW_SIGNATURE_HTTP } from "../../api/UrlConfigure";

@Builder
export function AgreementWebViewInfoPageBuilder(name: string, param: Object) {
  // console.log("aa");
  AgreementWebViewInfoPage()
}

@ComponentV2
export struct AgreementWebViewInfoPage {
  @Local signSuccessDic?: generalModel = undefined;
  @Local signPdfUrl: undefined;
  @Local isSignText: string = "0";
  @Local userInfo?:UserInfo = undefined;
  @Local pageLoading: boolean = false;
  @Local private navPathStack: NavPathStack = new NavPathStack()

  @Local generalModelPageData?: generalModel = undefined;
  @Local pixelMap?: image.PixelMap = undefined;
  private  controller: webview.WebviewController = new webview.WebviewController()
  @Local isImageModalVisible: boolean = false;
  @Local selectedImageUrl: string = "";
  @Local titleStr: string = "";
  @Local type: string = "1"; //1:内部链接-默认， 2 外部链接

  aboutToAppear(): void {
    WindowUtil.setWindowSystemBarProperties({
      statusBarColor: '#2A7AFD',       // 你的颜色
      statusBarContentColor: '#FFFFFF' // 图标/文字颜色
    })
    WindowUtil.setImmersiveModeEnabledState(false);
    this.userInfo = ContextUtils.getUserInfo()??{};
  }



  // 处理返回按钮点击
  handleBack() {
    // 这里实现返回逻辑，可能是路由返回或关闭页面
    console.log("返回按钮被点击");
    this.navPathStack.pop({},false);
  }

  //注入JS
  // 注册JavaScript接口
  registerJavaScriptInterface() {
    try {
      // 注册一个名为"imageClickHandler"的接口
      this.controller.registerJavaScriptProxy({
        // 当JavaScript调用imageClicked方法时触发
        imageClicked: (url: string) => {
          this.selectedImageUrl = url;
          this.isImageModalVisible = true;
          console.log(url);

          let urls = [
            url,
          ]
          const imageList: Array<PreviewImageInfo> = [
            {
              url: url,
              id: 'img1'
            },
          ]
          //基础图片预览- 简单
          // popupImagePreviewer(urls, 0)

          const index = 0

          Previewer.show(
            {
              imgList: imageList,
              initIndex: index,
            }
          )

        }
      }, "imageClickHandler", ["imageClicked"]);

      console.info("JavaScript接口注册成功");
    } catch (error) {
      console.error("注册JavaScript接口失败: " + JSON.stringify(error));
    }
  }

  // 注入JavaScript代码来监听图片点击
  injectImageClickListener() {
    const jsCode = `
    (function() {
      // 添加viewport meta标签
      var meta = document.createElement('meta');
      meta.setAttribute('name', 'viewport');
      meta.setAttribute('content', 'width=device-width,initial-scale=1,user-scalable=no');
      document.getElementsByTagName('head')[0].appendChild(meta);

      // 处理表格缩放 - 关键修改
      function scaleTablesToFit() {
        var tables = document.getElementsByTagName('table');
        var screenWidth = window.innerWidth || document.documentElement.clientWidth;

        for (var i = 0; i < tables.length; i++) {
          var table = tables[i];
          if (!table || !table.style) continue;

          // 移除之前的样式
          table.style.width = '';
          table.style.maxWidth = '';
          table.style.overflowX = '';
          table.style.display = '';

          // 获取表格的实际宽度
          var tableWidth = table.offsetWidth;

          // 如果表格宽度超过屏幕宽度，则进行缩放
          if (tableWidth > screenWidth) {
            var scaleRatio = screenWidth / tableWidth;
            table.style.transform = 'scale(' + scaleRatio + ')';
            table.style.transformOrigin = 'top left';
            table.style.width = tableWidth + 'px'; // 保持原始尺寸
          } else {
            table.style.width = '100%';
          }
        }
      }

      // 初始执行一次
      scaleTablesToFit();

      // 监听窗口大小变化
      window.addEventListener('resize', scaleTablesToFit);

      // 添加CSS样式来处理表格和内容
      var style = document.createElement('style');
      style.innerHTML = \`
        /* 表格基础样式 */
        table {
          border-collapse: collapse;
          width: auto !important;
          max-width: 100vw !important;
          margin: 0 auto;
          table-layout: fixed;
        }

        /* 表格单元格样式 */
        td, th {
          word-break: break-word;
          overflow-wrap: break-word;
          padding: 8px;
          border: 1px solid #ddd;
          font-size: 14px;
          line-height: 1.4;
        }

        /* 确保内容不溢出 */
        * {
          box-sizing: border-box;
          max-width: 100vw;
        }

        /* 图片样式 */
        img {
          max-width: 100% !important;
          height: auto !important;
          display: block;
        }

        /* 正文样式 */
        body {
          -webkit-text-size-adjust: 100%;
          overflow-wrap: break-word;
          word-wrap: break-word;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          line-height: 1.6;
          color: #333;
          padding: 12px;
          margin: 0;
          width: 100%;
          overflow-x: hidden;
        }

        /* 容器样式 */
        div, p, span, section, article {
          max-width: 100% !important;
          overflow-wrap: break-word !important;
        }

        /* 防止任何水平滚动 */
        html, body {
          overflow-x: hidden !important;
          width: 100% !important;
          position: relative;
        }
      \`;
      document.head.appendChild(style);

      // 获取所有图片元素
      var images = document.querySelectorAll('img');

      // 为每个图片添加点击事件监听
      images.forEach(function(img) {
        img.addEventListener('click', function() {
          if (window.imageClickHandler && typeof window.imageClickHandler.imageClicked === 'function') {
            window.imageClickHandler.imageClicked(this.src);
          }
        });
        img.style.cursor = 'pointer';
      });

      // 监听动态加载的内容
      var observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
          mutation.addedNodes.forEach(function(node) {
            if (node.nodeType === 1) {
              // 处理新增图片
              var newImages = node.querySelectorAll ? node.querySelectorAll('img') : [];
              if (node.tagName === 'IMG') {
                newImages = [node];
              }

              newImages.forEach(function(img) {
                img.addEventListener('click', function() {
                  if (window.imageClickHandler && typeof window.imageClickHandler.imageClicked === 'function') {
                    window.imageClickHandler.imageClicked(this.src);
                  }
                });
                img.style.cursor = 'pointer';
              });

              // 处理新增表格 - 重新缩放
              var newTables = node.querySelectorAll ? node.querySelectorAll('table') : [];
              if (node.tagName === 'TABLE') {
                newTables = [node];
              }

              if (newTables.length > 0) {
                setTimeout(scaleTablesToFit, 100); // 延迟执行确保DOM完全加载
              }
            }
          });
        });
      });

      // 开始观察DOM变化
      observer.observe(document.body, {
        childList: true,
        subtree: true
      });

      // 监听图片加载完成重新计算表格
      var loadImages = document.querySelectorAll('img');
      loadImages.forEach(function(img) {
        if (!img.complete) {
          img.onload = scaleTablesToFit;
        }
      });

    })();
  `;

    try {
      this.controller.runJavaScript(jsCode)
        .then(() => {
          console.info('表格缩放和图片点击监听脚本注入成功');
        })
        .catch((err:Error) => {
          console.error('注入脚本失败: ' + JSON.stringify(err));
        });
    } catch (error) {
      console.error('执行runJavaScript失败: ' + JSON.stringify(error));
    }
  }


  build() {
    NavDestination() {
      Column() {
        // 顶部导航条 - 修改版
        Row() {
          // 返回按钮
          Button() {
            Image($r("app.media.BFH")) // 请替换为实际的返回图标资源
              .objectFit(ImageFit.Contain)
              .width(24)
              .height(24)
          }
          .width(44)
          .height(44)
          .onClick(() => {
            this.handleBack();
          })

          // 标题
          Text(this.titleStr) // 请添加对应的资源字符串
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .fontColor($r("app.color.white"))

          // 提交按钮
          Text($r("app.string.submit")) // 请添加对应的资源字符串
            .fontSize(16)
            .onClick(() => {

            })
            .width(60)
            .height(30)
            .visibility(Visibility.Hidden)
            .fontColor($r("app.color.white"))
            .textAlign(TextAlign.End)
            .padding({ right: 10, top: 5 })
        }
        .width("100%")
        .padding(10)
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r("app.color.main_color"))

        // 页面内容
        Column() {
          Web({ src: "", controller: this.controller })
            .javaScriptAccess(true)
            .onPageEnd(()=>{
              console.log("页面加载完成，注入图片点击监听");
              //内部链接 注入 JS
              if (this.type == "1") {
                this.injectImageClickListener();
              }
            })
            .onControllerAttached(() => {
              //内部链接 注入 JS
              if (this.type == "1") {
                this.registerJavaScriptInterface();
              }
              this.initWebView();
            }).layoutWeight(1)
            .zoomAccess(true) // 允许缩放
            .initialScale(1) // 设置初始缩放比例
            .databaseAccess(true) // 允许数据库存储
            .domStorageAccess(true) // 允许DOM存储
        }
        .layoutWeight(1)

        // 底部导航条
        Row({space: 10}) {
          // 底部导航条内容
          //取消按钮、重新签名按钮、签名按钮
          Button() {
            Text($r("app.string.cancel")) // 请添加对应的资源字符串
              .fontSize(16)
              .fontColor($r("app.color.gl_999"))
          }
          .backgroundColor($r("app.color.white"))
          .borderRadius(1)
          .borderColor($r("app.color.gl_999"))
          .borderWidth(1)
          .onClick(() => {
            this.handleBack();
          })
          .height('100%')
          .layoutWeight(1)

          // 重新签名按钮
          Button() {
            Text($r("app.string.reSign")) // 请添加对应的资源字符串
              .fontSize(16)
              .fontColor($r("app.color.gl_999"))
          }
          .backgroundColor($r("app.color.white"))
          .borderRadius(1)
          .borderColor($r("app.color.gl_999"))
          .borderWidth(1)
          .visibility(this.isSignText == "1"?Visibility.Visible:Visibility.None)
          .onClick(() => {
            this.navPathStack?.pushPathByName('SignPage', {}, (params) => {
              if (params && params.result['picUrl'] ) {
                console.log("子页面让-执行刷新操作"+params.result['picUrl']);
                //调用接口签字；
                this.signPDFByUserSignature(params.result['picUrl']);
              }
            });
          })
          .height('100%')
          .layoutWeight(1)

          // 签名按钮
          Button() {
            Text(this.isSignText != "1"?$r("app.string.sign"):$r("app.string.confirm")) // 请添加对应的资源字符串
              .fontSize(16)
              .fontColor($r("app.color.white"))
          }
          .onClick(() => {
            //如果没有签过字 -  判断 用户信息中 是否有签字-
            if(this.isSignText != "1"){
              //如果有-直接调用接口签字；
              if(this.userInfo?.userSignature != null){
                //调用接口签字；
                this.signPDFByUserSignature(this.userInfo?.userSignature);
              }else{
                //如果没有- 去签字页保存后-再调用接口签字；
                this.navPathStack?.pushPathByName('SignPage', {isSaveSign:"1"} as generalModel, (params) => {
                  if (params && params.result['picUrl'] ) {
                    console.log("子页面让-执行刷新操作"+params.result['picUrl']);
                    //调用接口签字；
                    this.signPDFByUserSignature(params.result['picUrl']);
                  }
                });
              }
            }else{
              //如果已经签字 点击确认返回
              this.navPathStack.pop(this.signSuccessDic,true);
            }


          })
          .borderRadius(1)
          .backgroundColor($r("app.color.main_color"))
          .height('100%')
          .layoutWeight(1)
        }
        .height(60)
        .padding(10)
        .backgroundColor($r("app.color.white"))
      }.width("100%")
      .layoutWeight(1)
      FullLoading({ loading: this.pageLoading })
    }
    .height("100%")
    .backgroundColor($r("app.color.white"))
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack
      try {
        this.generalModelPageData = this.navPathStack.getParamByName('AgreementWebViewInfoPage')[0] as generalModel;//ObjectUtil.deepCopy();
        this.titleStr = this.generalModelPageData.pageTitle ?? "报道详情"
        this.type = this.generalModelPageData?.type ?? "1"

      } catch (ee) {
        console.error("未获取到上一页数据");
      }

    })
  }

  signPDFByUserSignature(userSignature: string) {

    let postDic:generalModel = {
      id: this.generalModelPageData?.id,
      idcardnum: this.userInfo?.idcardnum,
      userSignature: userSignature,
      drawExportCode: this.generalModelPageData?.drawExportCode
    }
    easyDataRequest(ZJ_REQUEST_REVIEW_SIGNATURE_HTTP, postDic, "POSTFORM")
      .then((res) => {
        if (res['code'] == 0) {
          this.signPdfUrl = res['data']["agreement"];
          this.signSuccessDic = res['data'] as generalModel;
          this.controller.loadUrl(this.signPdfUrl,
            [
              { headerKey: "systemtype", headerValue: "ios" },
              { headerKey: "token", headerValue: ContextUtils.getToken().toString() },
              { headerKey: "appKey", headerValue: DeviceUtil.getODID() }]);
          this.isSignText = "1"
        }
      })
      .catch((err:object) => {
        CoreUtils.toast(err['msg'])
      })
      .finally(() => this.pageLoading = false)
  }

  private initWebView() {
    if (this.generalModelPageData != null) {
      this.controller.loadUrl(this.generalModelPageData?.url??"",
        [
          { headerKey: "systemtype", headerValue: "ios" },
          { headerKey: "token", headerValue: ContextUtils.getToken().toString() },
          { headerKey: "appKey", headerValue: DeviceUtil.getODID() }]);
    }else {
      ToastUtil.showToast("参数错误");
    }

  }

}