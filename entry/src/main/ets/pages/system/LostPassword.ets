import { Base64Util, RegexUtil, SHA, StrUtil, ToastUtil, WindowUtil } from "@pura/harmony-utils"
import { BaseConstants, ContextUtils, CoreUtils, MainButton, PageTitleBuilder } from "jbase"
import { easyDataRequest } from "../../api/EasyRequest"
import { LOST_PWD_SEND_SHORT_HTTP, RESET_PWD_HTTP } from "../../api/UrlConfigure"
import { generalModel } from "../../model/ZJ_Model"


const getAuthorizationStr = (username:string,password:string) => {
  let authStr = '';

  let  aa:string = username +':'+ password;
  authStr = Base64Util.encodeToStrSync(StrUtil.strToUint8Array(aa));
  return authStr
}

@Builder
export function LostPasswordBuilder(name: string, param: Object) {
  LostPassword()
}

// 密码修改页面
@ComponentV2
export struct LostPassword {
  @Local private navPathStack: NavPathStack = new NavPathStack()

  @Local newPassword: string = ''
  @Local confirmPassword: string = ''

  @Local newPasswordShow: boolean = false
  @Local confirmPasswordShow: boolean = false


  @Local zcusername: string = ''
  @Local codeValue: string = ''
  @Local timer: number = 1;
  @Local isCodeSending: boolean = false;
  @Local codeCount: number = 60;

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

  aboutToAppear(): void {
    WindowUtil.setWindowSystemBarProperties({
      statusBarColor: '#2A7AFD',       // 你的颜色
      statusBarContentColor: '#FFFFFF' // 图标/文字颜色
    })
    WindowUtil.setImmersiveModeEnabledState(false);
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
          Text($r('app.string.lost_pass')) // 请添加对应的资源字符串
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

            // 账号输入框
            TextInput({ placeholder: $r('app.string.pls_user'), text: this.zcusername })
              .cancelButton({ style: CancelButtonStyle.INPUT })
              .onChange((value: string) => {
                this.zcusername = value
              })
              .type(InputType.PhoneNumber)
              .inputStyle()
              .fontSize(16)

            Row() {
              // 验证码输入框
              TextInput({ placeholder: $r('app.string.pls_ver_code'), text: this.codeValue })
                .type(InputType.Number)
                .cancelButton({ style: CancelButtonStyle.INPUT })
                .onChange((value: string) => {
                  this.codeValue = value
                })
                .inputStyle()
                .fontSize(16)
                .layoutWeight(1)
              // 获取验证码按钮
              Button(!this.isCodeSending ? "发送验证码" : `${this.codeCount}后重新获取`,
                { type: ButtonType.Normal, stateEffect: true })
                .enabled(!this.isCodeSending)
                .onClick((event) => {
                  //60秒后重新获取验证码
                  this.sendCodeAction();
                  return false
                })
                .margin({ left: 10 })
                .fontColor($r('app.color.white'))
                .borderRadius(5)
                .backgroundColor($r('app.color.main_color'))
                .height(30)
                .fontSize(12)
            }
            .width(280)

            // 密码输入框
            TextInput({ placeholder: $r('app.string.pls_pass'), text: this.newPassword })
              .type(InputType.Password)
              .showPasswordIcon(true)
              .enableAutoFill(false)
              .cancelButton({ style: CancelButtonStyle.INPUT })
              .onChange((value: string) => {
                this.newPassword = value
              })
              .showPassword(this.newPasswordShow)
              .onSecurityStateChange(((isShowPassword: boolean) => {
                // 更新密码显示状态
                this.newPasswordShow = isShowPassword
              }))
              .inputStyle()
              .fontSize(16)

            // 二次密码输入框
            TextInput({ placeholder: $r('app.string.pls_pass'), text: this.confirmPassword })
              .type(InputType.Password)
              .enableAutoFill(false)
              .showPasswordIcon(true)
              .cancelButton({ style: CancelButtonStyle.INPUT })
              .onChange((value: string) => {
                this.confirmPassword = value
              })
              .showPassword(this.confirmPasswordShow)
              .onSecurityStateChange(((isShowPassword: boolean) => {
                // 更新密码显示状态
                this.confirmPasswordShow = isShowPassword
              }))
              .inputStyle()
              .fontSize(16)

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
              // 校验用户名和密码是否为空
              if (!this.zcusername) {
                CoreUtils.toast($r('app.string.pls_user'))
                return;
              }
              if (!this.codeValue) {
                CoreUtils.toast($r('app.string.pls_ver_code'))
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
              // @"^(?=.*)(?=.*[a-zA-Z])(?=.*[~!@#$%^&*\\-:;,.=?$\x22]).{6,15}$"
              // 密码规则校验，至少包含大小写字母和特殊字符，长度在6到15之间
              if (!RegexUtil.isMatch(this.newPassword,"^(?=.*)(?=.*[a-zA-Z])(?=.*[~!@#$%^&*\\-:;,.=?$\x22]).{6,15}$")) {
                ToastUtil.showToast("密码不符合规则，请重新输入");
                return;
              }
              let dicPost : generalModel = {
                yhdh: this.zcusername,
                PassWD: StrUtil.toUpper(SHA.digestSync(this.newPassword,"SHA1")),
                yzm: this.codeValue
              };
              // 调用接口修改密码
              easyDataRequest(RESET_PWD_HTTP, dicPost, "POST").then((res) => {
                // 页面跳转或关闭当前页等操作...
                ToastUtil.showToast("密码修改成功");
                this.navPathStack.pop(true);
              }).catch((err: object) => {
                CoreUtils.toast(err['msg'])
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


  private sendCodeAction() {

    //判断手机号是否填写
    if (!this.zcusername) {
      CoreUtils.toast("请先填写手机号！");
      return;
    }
    //验证手机号格式
    if (!RegexUtil.isPhone(this.zcusername)) {
      CoreUtils.toast("手机号格式不正确！");
      return;
    }
    easyDataRequest(LOST_PWD_SEND_SHORT_HTTP
      , {yhdh:this.zcusername}, "POST").then((res) => {
      // 这里可以调用后端接口发送验证码
      this.codeCount = 60;
      this.isCodeSending = true;
      // 倒计时逻辑 - 每秒递减，直到0为止，同时更新isCodeSending状态为false，表示验证码获取按钮可以再次点击。
      // 不可重复生成setInterval，否则会导致多个定时器同时运行，造成混乱。
      if (this.timer) {
        clearInterval(this.timer);
      }
      this.timer = setInterval(() => {
        if (this.codeCount === 0) {
          clearInterval(this.timer);
          this.codeCount = 60;
          this.isCodeSending = false;
        } else {
          this.codeCount--;
          this.isCodeSending = true;
        }
      }, 1000);
      CoreUtils.toast("验证码已发送到您的手机，请注意查收！");
    }).catch((error: object) => {
      CoreUtils.alert(error["msg"]);
    }).finally(() => {
    });

  }


  @Styles inputStyle() {
    .margin({ bottom: 10 })
    .width(280)
    .backgroundColor(Color.Transparent)
    .border({color:$r("app.color.color_line"),width:{bottom:1},radius:0})
    .padding({ left: 20, right: 20, top: 14, bottom: 14 })
  }
}