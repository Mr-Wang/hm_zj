import { Base64Util, RegexUtil, SHA, StrUtil, WindowUtil } from '@pura/harmony-utils';
import { BaseConstants, MainButton, CoreUtils, ContextUtils, FullLoading, UserInfo } from 'jbase'
import { easyDataRequest } from '../api/EasyRequest';
import { getCodeImg, login, getUserInfo, LoginParams } from '../api/Login'
import { ZC_HTTP, ZC_SEND_SHORT_HTTP } from '../api/UrlConfigure';
import { AppConfig } from '../config/Index'
import { generalModel } from '../model/ZJ_Model';

const getAuthorizationStr = (username:string,password:string) => {
  let authStr = '';

  let  aa:string = username +':'+ password;
  authStr = Base64Util.encodeToStrSync(StrUtil.strToUint8Array(aa));
  return authStr
}


/**
 * 登录页面
 */
@Entry
@ComponentV2
struct Main {
  @Local timer: number = 1;
  @Local isCodeSending: boolean = false;
  @Local codeCount: number = 60;
  @Local isLoginSelect: boolean = true;

  @Local username: string = ''
  @Local zcusername: string = ''
  @Local password: string = ''
  @Local passwordState: boolean = false
  @Local userinfo: UserInfo = {}
  // 验证码图片
  @Local codeImg: string = ''
  @Local codeValue: string = ''

  @Local isRememberPass: boolean = false
  @Local loginAgree: boolean = false
  @Local pageLoading: boolean = false
  // 是否开启验证码
  @Local captchaEnabled: boolean = true
  @Local uuid: string = ''
  @Consumer('pageInfos') pageStack: NavPathStack = new NavPathStack();

  onPageShow(): void {
    console.log("onPageShow")

  }


  aboutToAppear(): void {
    // this.loadCodeImg()

    this.pageStack.setInterception({
      willShow: (from: NavDestinationContext | 'navBar', to: NavDestinationContext | 'navBar',
        operation: NavigationOperation, animated: boolean) => {
        if (typeof from === 'string') {
          let target = to as NavDestinationContext
          console.info(`from page is navigation home 1111111111 -> ${target.pathInfo.name}`);
        } else if (typeof to === 'string') {
          let target = from as NavDestinationContext
          console.info(`${target.pathInfo.name} -> to page is navigation home 22222222222`);

          WindowUtil.setWindowSystemBarProperties({
            statusBarColor: "#00000000",       // 你的颜色
            statusBarContentColor: '#FFFFFF' // 图标/文字颜色
          })
          WindowUtil.setImmersiveModeEnabledState(true);

        }
      }
    })

    this.username = ContextUtils.getRememberUserName().toString();
    this.password = ContextUtils.getRememberPassword().toString();
    if(this.password){
      this.isRememberPass = true;
    }else{
      this.isRememberPass = false;
    }
  }


  // 加载图片验证码
  loadCodeImg(): void {
    this.pageLoading = true
    getCodeImg().then((res) => {
      this.codeImg = 'data:image/gif;base64,' + res['img']
      this.captchaEnabled = res['captchaEnabled']
      this.uuid = res['uuid']
    }).finally(() => this.pageLoading = false)
  }


  // 注册并登录按钮点击事件
  async registerAndLoginBtnClick(): Promise<void> {

    if(!this.loginAgree){
      CoreUtils.toast($r('app.string.pls_read_tips'))
      return;
    }
    // 校验用户名和密码是否为空
    if (!this.zcusername) {
      return CoreUtils.toast($r('app.string.pls_user'))
    }
    if (!this.codeValue) {
      return CoreUtils.toast($r('app.string.pls_ver_code'))
    }
    console.log(this.zcusername.substring(5)+"@wl");
    // 注册
    let params:generalModel = {
      LoginID:this.zcusername,
      password:StrUtil.toUpper(SHA.digestSync(this.zcusername.substring(5)+"@wl","SHA1")),
      yzm: this.codeValue
    }

    easyDataRequest(ZC_HTTP,params,"POST").then((res) => {
      this.username = this.zcusername;
      this.password = params.password!;
      this.isRememberPass = true;
      // 登录
      this.loginBtnClick()
    })
    .catch((err:object) => {
      CoreUtils.toast(err['msg'])
    })
    .finally(() => this.pageLoading = false)

  }

  // 登录按钮点击事件
  async loginBtnClick(): Promise<void> {

    if(!this.loginAgree){
      CoreUtils.toast($r('app.string.pls_read_tips'))
      return;
    }
    // 校验用户名和密码是否为空
    if (!this.username) {
      return CoreUtils.toast($r('app.string.pls_user'))
    }
    if (!this.password) {
      return CoreUtils.toast($r('app.string.pls_pass'))
    }


    this.pageLoading = true
    let digest1 =StrUtil.toUpper(SHA.digestSync(this.password,"SHA1"));


    login({
      username:this.username,
      password:digest1,
    } as LoginParams).
    then((res) => {
      this.userinfo = res["data"];
      // 存储 token
      ContextUtils.setToken(this.userinfo.token ?? "")
      //存储用户名
      ContextUtils.setRememberUserName(this.username);
      //存储密码
      ContextUtils.setRememberPassword(this.isRememberPass?this.password:"");

      CoreUtils.toast($r('app.string.login_success'))
      // // 获取用户信息
      // getUserInfo().then((res) => {
      ContextUtils.setUserInfo(this.userinfo)
      //   // 跳转首页
        CoreUtils.toIndex()
      // })
    })
      .catch((err:object) => {
        CoreUtils.toast(err['msg'])
      })
      .finally(() => this.pageLoading = false)
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        // Image($r('app.media.background')).width('100%').height(180).position({ top: -40 })
        Image($r("app.media.logintop")).width(260).height(50).margin({ top: 80, bottom: 80 })
          .objectFit(ImageFit.Fill)

        Column() {
          Row() {
            Text($r('app.string.login'))
              .fontSize(this.isLoginSelect ? 24 : 16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isLoginSelect ? $r('app.color.black') : $r('app.color.gl_999'))
              .padding(10)
              .onClick(() => {
                this.isLoginSelect = true
              })
            Text($r('app.string.register'))
              .fontSize(this.isLoginSelect ? 16 : 24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isLoginSelect ? $r('app.color.gl_999') : $r('app.color.black'))
              .padding(10)
              .onClick(() => {
                this.isLoginSelect = false
              })
          }
          .width(280)
          .justifyContent(FlexAlign.SpaceAround)
          .margin({ bottom: 20, top: 10 })

          if (this.isLoginSelect) {
            // 账号输入框
            TextInput({ placeholder: $r('app.string.pls_user'), text: this.username })
              .cancelButton({ style: CancelButtonStyle.INPUT })
              .onChange((value: string) => {
                this.username = value
              })
              .type(InputType.USER_NAME)
              .inputStyle()
              .fontSize(16)

            // 密码输入框
            TextInput({ placeholder: $r('app.string.pls_pass'), text: this.password })
              .type(InputType.Password)
              .showPasswordIcon(true)
              .cancelButton({ style: CancelButtonStyle.INPUT })
              .onChange((value: string) => {
                this.password = value
              })
              .showPassword(this.passwordState)
              .onSecurityStateChange(((isShowPassword: boolean) => {
                // 更新密码显示状态
                this.passwordState = isShowPassword
              }))
              .inputStyle()
              .fontSize(16)
            // 记住密码、忘记密码
            Row() {
              Checkbox({ group: 'checkboxGroup' })
                .select(this.isRememberPass)
                .shape(CheckBoxShape.ROUNDED_SQUARE)
                .height(16)
                .width(16)
                .onClick(() => {
                  this.isRememberPass = !this.isRememberPass
                  return false
                })

              Text($r('app.string.remember_pass'))
                .fontSize(14)
                .fontColor($r('app.color.black'))
                .onClick((event) => {
                  this.isRememberPass = !this.isRememberPass
                  return false
                })
                .margin({ left: 5 })
                .layoutWeight(1)

              Text($r('app.string.forget_pass')).fontSize(14).fontColor($r('app.color.black'))
                .onClick((event) => {
                  this.pageStack?.pushPathByName('LostPassword',null,false);
                  return false
                })
            }
            .padding({ top: 5, bottom: 5 })
            .width(280)
            .justifyContent(FlexAlign.SpaceBetween)

          } else {
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

          }

          Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
            Radio({
              value: 'Radio1', group: 'radioGroup', indicatorType: RadioIndicatorType.TICK
            }).checked(this.loginAgree).height(16).width(16)
              .onClick((event) => {
                this.loginAgree = !this.loginAgree
                return false
              })
            Text($r('app.string.pls_read_agree')).fontSize(12).fontColor($r('app.color.gl_888'))
            Text($r('app.string.privacy_policy')).fontSize(12).fontColor($r('app.color.main_color'))
              .onClick((event) => {
                this.pageStack?.pushPathByName('WebViewInfoPage',
                  { url: `https://www.capass.cn/Avatar/ysxy.pdf`, title: "隐私政策", type: "2" } as generalModel,false);
                return false
              })
            Text($r('app.string.and')).fontSize(12).fontColor($r('app.color.gl_888'))
            Text($r('app.string.user_agreement')).fontSize(12).fontColor($r('app.color.main_color'))
              .onClick((event) => {
                this.pageStack?.pushPathByName('WebViewInfoPage',
                  { url: `https://www.capass.cn/Avatar/zjapp.pdf`, title: "用户协议", type: "2" } as generalModel,false);
                return false
              })
          }
          .padding({ top: 10, bottom: 10 })
          .width(280)
          .onClick(() => {
            this.loginAgree = !this.loginAgree
          })

          if (this.isLoginSelect) {
            // 登录按钮
            MainButton({
              btnText: $r('app.string.login_text'), btnWidth: 280,
              onButtonClick: () => this.loginBtnClick()
            }).margin({ top: 10, bottom: 10 })
          } else {
            // 注册按钮
            MainButton({
              btnText: $r('app.string.registerAndLogin'), btnWidth: 280,
              onButtonClick: () => this.registerAndLoginBtnClick()
            }).margin({ top: 10, bottom: 10 })
          }


        }
        .backgroundImage($r('app.media.logincentent'))
        .padding({
          top: 20,
          bottom: 30,
          left: 20,
          right: 20
        })
        .backgroundImageSize(ImageSize.FILL)

        // // 全屏加载组件
        // FullLoading({ loading: this.pageLoading })


        // 底部版权
        Text($r('app.string.copy_right'))
          .fontSize(14)
          .fontColor($r('app.color.white'))
          .width(BaseConstants.FULL_WIDTH)
          .textAlign(TextAlign.Center)
          .position({ bottom: 54 })

        // 备案编号
        Text($r('app.string.filing_no'))
          .fontSize(14)
          .fontColor($r('app.color.white'))
          //下划线
          .decoration({ type: TextDecorationType.Underline, color: $r('app.color.white') })
          .width(BaseConstants.FULL_WIDTH)
          .textAlign(TextAlign.Center)
          .position({ bottom: 24 })
          .onClick((event) => {
            this.pageStack?.pushPathByName('WebViewInfoPage',
              { url: `https://beian.miit.gov.cn/`, title: "备案查询", type: "2" } as generalModel,false);
            return false
          })

      }
      .backgroundImage($r('app.media.loginbg'))
      .backgroundImageSize(ImageSize.FILL)
      .width(BaseConstants.FULL_WIDTH)
      .height(BaseConstants.FULL_HEIGHT)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Start)
    }
    .mode( NavigationMode.Stack)
    .height(BaseConstants.FULL_HEIGHT)
    .hideTitleBar(true)
    .titleMode(NavigationTitleMode.Mini)
    .onAppear(() => {
      console.log("登录页面加载完成")
      WindowUtil.setWindowSystemBarProperties({
        statusBarColor: "#00000000",       // 你的颜色
        statusBarContentColor: '#FFFFFF' // 图标/文字颜色
      })
      WindowUtil.setImmersiveModeEnabledState(true);
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
    easyDataRequest(ZC_SEND_SHORT_HTTP
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