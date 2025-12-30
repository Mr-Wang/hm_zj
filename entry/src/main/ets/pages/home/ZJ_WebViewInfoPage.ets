import { ContextUtils, CoreUtils, FullLoading } from "jbase";
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
@Builder
export function WebViewInfoPageBuilder(name: string, param: Object) {
  // console.log("aa");
  WebViewInfoPage()
}

@ComponentV2
export struct WebViewInfoPage {
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
          Text($r("app.string.share")) // 请添加对应的资源字符串
            .fontSize(16)
            .onClick(() => {
              let shareUrl :string = this.generalModelPageData?.url ?? "";
              console.log("分享链接:"+shareUrl);
              let data: systemShare.SharedData = new systemShare.SharedData({
                utd: utd.UniformDataType.HTML,
                content: shareUrl//'Hello HarmonyOS'
              });
              let controller: systemShare.ShareController = new systemShare.ShareController(data);
              // 获取UIAbility上下文对象
              let uiContext: UIContext = this.getUIContext();
              let context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
              controller.show(context, {
                previewMode: systemShare.SharePreviewMode.DETAIL,
                selectionMode: systemShare.SelectionMode.SINGLE
              });
            })
            .width(60)
            .height(30)
            .visibility(this.generalModelPageData?.type == "2"?Visibility.Visible : Visibility.Hidden)
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
      }.width("100%")
      .padding({ bottom: 50 })
      .layoutWeight(1)
      FullLoading({ loading: this.pageLoading })
    }
    .height("100%")
    .backgroundColor($r("app.color.white"))
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack
      try {
        this.generalModelPageData = this.navPathStack.getParamByName('WebViewInfoPage')[0] as generalModel;//ObjectUtil.deepCopy();
        this.titleStr = this.generalModelPageData.title ?? "报道详情"
        this.type = this.generalModelPageData?.type ?? "1"

      } catch (ee) {
        console.error("未获取到上一页数据");
      }

    })
  }

  private initWebView() {
    if (this.generalModelPageData != null) {
      //判断 如果不是一个有效 url，url中不包含 http 则不加载页面
      if (!this.generalModelPageData?.url?.includes("http")) {
        ToastUtil.showToast("不是有效地址"+this.generalModelPageData?.url);
        return;
      }
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