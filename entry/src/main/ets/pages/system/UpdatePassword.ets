import { Base64Util, StrUtil, ToastUtil } from "@pura/harmony-utils"
import { BaseConstants, ContextUtils, MainButton, PageTitleBuilder } from "jbase"
import { easyDataRequest } from "../../api/EasyRequest"
import { generalModel } from "../../model/ZJ_Model"


const getAuthorizationStr = (username:string,password:string) => {
  let authStr = '';

  let  aa:string = username +':'+ password;
  authStr = Base64Util.encodeToStrSync(StrUtil.strToUint8Array(aa));
  return authStr
}

@Builder
export function UpdatePasswordBuilder(name: string, param: Object) {
  UpdatePassword()
}

// 密码修改页面
@ComponentV2
export struct UpdatePassword {
  @Local private navPathStack: NavPathStack = new NavPathStack()
  @Local oldPassword: string = ''
  @Local newPassword: string = ''
  @Local confirmPassword: string = ''
  @Local oldPasswordShow: boolean = false
  @Local newPasswordShow: boolean = false
  @Local confirmPasswordShow: boolean = false

  @Builder LabelText(name: string | Resource) {
    Text(name)
      .fontSize(16)
      .fontColor($r('app.color.black'))
      .width(110)
      .padding({ right: 10 })
  }
  // 处理返回按钮点击
  handleBack() {
    // 这里实现返回逻辑，可能是路由返回或关闭页面
    console.log("返回按钮被点击");
    this.navPathStack.pop(true);
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
          .onClick(()=>{
            this.handleBack()
          })

          // 标题
          Text($r('app.string.change_pass')) // 请添加对应的资源字符串
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .fontColor($r("app.color.white"))

          // 提交按钮
          Text($r("app.string.submit")) // 请添加对应的资源字符串
            .fontSize(16)
            .visibility(Visibility.Hidden)
            .width(60)
            .height(30)
            .fontColor($r("app.color.white"))
            .textAlign(TextAlign.End)
            .padding({ right: 10, top: 5 })
        }
        .width("100%")
        .padding(10)
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r("app.color.main_color"))

        Column() {
          Column() {
            Flex({ alignItems: ItemAlign.Center }) {
              // 旧密码
              this.LabelText($r('app.string.old_pass'))
              TextInput({
                placeholder: $r('app.string.pls_old_pass'),
                text: this.oldPassword
              })
                .type(this.oldPasswordShow ? InputType.Normal : InputType.Password)
                .showPasswordIcon(true)
                .onChange((value: string) => {
                  this.oldPassword = value
                })
                .showPassword(this.oldPasswordShow)
                .onSecurityStateChange((isShowPassword: boolean) => {
                  this.oldPasswordShow = isShowPassword
                })
                .inputStyle().fontSize(16)
                .height(48).flexGrow(1)
            }.margin({ bottom: 20 })

            // 新密码
            Flex({ alignItems: ItemAlign.Center }) {
              this.LabelText($r('app.string.new_pass'))
              TextInput({
                placeholder: $r('app.string.pls_new_pass'),
                text: this.newPassword
              })
                .type(this.newPasswordShow ? InputType.Normal : InputType.Password)
                .showPasswordIcon(true)
                .onChange((value: string) => {
                  this.newPassword = value
                })
                .showPassword(this.newPasswordShow)
                .onSecurityStateChange((isShowPassword: boolean) => {
                  this.newPasswordShow = isShowPassword
                })
                .inputStyle().fontSize(16)
                .height(48).flexGrow(1)
            }.margin({ bottom: 20 })

            // 确认密码
            Flex({ alignItems: ItemAlign.Center }) {
              this.LabelText($r('app.string.confirm_pass'))
              TextInput({
                placeholder: $r('app.string.pls_confirm_pass'),
                text: this.confirmPassword
              })
                .type(this.confirmPasswordShow ? InputType.Normal : InputType.Password)
                .showPasswordIcon(true)
                .onChange((value: string) => {
                  this.confirmPassword = value
                })
                .showPassword(this.confirmPasswordShow)
                .onSecurityStateChange((isShowPassword: boolean) => {
                  this.confirmPasswordShow = isShowPassword
                })
                .inputStyle().fontSize(16)
                .height(48).flexGrow(1)
            }.margin({ bottom: 20 })

            // 密码规则提示
            Column() {
              Text($r('app.string.pass_tips'))
                .fontSize(14)
                .fontColor($r('app.color.gl_999'))
                .margin({ bottom: 4 })
              Text($r('app.string.pass_rule1'))
                .fontSize(14)
                .fontColor($r('app.color.gl_999'))
                .margin({ bottom: 4 })
              Text($r('app.string.pass_rule2'))
                .fontSize(14)
                .fontColor($r('app.color.gl_999'))
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .margin({ top: 10 })
          }
          .padding(BaseConstants.MODULE_PADDING + 10)
          .borderRadius(BaseConstants.BORDER_RADIUS)
          .backgroundColor($r('app.color.white'))
          .width(BaseConstants.FULL_WIDTH)

          // 确认修改按钮
          MainButton({
            btnText: $r('app.string.confirm_change'),
            btnWidth: BaseConstants.FULL_WIDTH,
            onButtonClick: () => {
              // TODO: 实现密码修改逻辑
              if (this.oldPassword == '') {
                ToastUtil.showToast("请输入旧密码");
                return;
              }
              if (this.newPassword == '') {
                ToastUtil.showToast("请输入新密码");
                return;
              }
              if (this.newPassword != this.confirmPassword) {
                ToastUtil.showToast("两次密码输入不一致，请重新输入");
                return;
              }
              if (this.oldPassword != ContextUtils.getRememberPassword()) {
                ToastUtil.showToast("旧密码输入错误，请重新输入");
                return;
              }
              if (this.newPassword == this.oldPassword) {
                ToastUtil.showToast("旧密码与新密码不能一致，请重新输入");
                return;
              }
              if (this.newPassword.length < 6) {
                ToastUtil.showToast("密码长度不能小于 6 位，请重新输入");
                return;
              }

              let dicPost : generalModel = {
                action: "updatepassword",
                oldpassword: this.oldPassword,
                newpassword: this.confirmPassword
              };
              // 调用接口修改密码
              easyDataRequest("servlet/EditClient", dicPost, "POST").then((res) => {
                // 密码修改逻辑
                ContextUtils.setRememberPassword(this.newPassword);
                let userName : string = ContextUtils.getRememberUserName()!.toString();
                // 存储 token
                ContextUtils.setToken(getAuthorizationStr(userName,this.confirmPassword))
                // 页面跳转或关闭当前页等操作...
                ToastUtil.showToast("密码修改成功");
                this.navPathStack.pop(true);
              }).catch((error: Error) => {
                console.error("获取数据失败:" + error.message);
              }).finally(() => {
              });
            }
          }).margin({ top: 20 })
        }
        .padding({ top: 16, left: 20, right: 20 })


      }
      .width(BaseConstants.FULL_WIDTH)
    }
    .title(PageTitleBuilder($r('app.string.change_pass')))
    .hideTitleBar(true)
    .backgroundColor($r('app.color.back_color'))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack
    })
  }


  @Styles inputStyle() {
    .backgroundColor($r('app.color.back_color'))
    .borderRadius(BaseConstants.BORDER_RADIUS)
    .padding({ left: 16, right: 16 })
  }
}