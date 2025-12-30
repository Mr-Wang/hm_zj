import { easyDataRequest } from "../../api/EasyRequest";
import { ContextUtils, CoreUtils, FullLoading } from "jbase";
import { DialogHelper } from "@pura/harmony-dialog";
import { generalModel } from "../../model/ZJ_Model";
import { AppConfig } from "../../config/Index";
import { util } from '@kit.ArkTS';
import { ADD_USER_ADDRESS_HTTP, DELETE_ADDRESS_HTTP, UPDATE_USER_ADDRESS_HTTP } from "../../api/UrlConfigure";


/**
 * 地区数据接口定义 (对应 area.json 结构)
 */
interface AreaItem {
  id: string;
  text: string;
  next?: AreaItem[];
}

@Builder
export function EditAddressPageBuilder(name: string, param: Object) {
  ZJ_EditAddressPage()
}

@ComponentV2
export struct ZJ_EditAddressPage {
  @Local private navPathStack: NavPathStack = new NavPathStack();
  @Local pageLoading: boolean = false;

  // 页面参数
  @Local isEdit: boolean = false;
  @Local editModel: generalModel = new generalModel(); // 假设你的模型有默认构造函数

  // 表单状态
  @Local userName: string = "";
  @Local userPhone: string = "";
  @Local detailAddress: string = "";
  @Local isDefault: boolean = false;

  // 地区选择状态
  @Local regionText: string = "请选择地区";
  // 选中的地区数据
  @Local provinceCode: string = "";   // 对应 ProvinceCode
  @Local cityCode: string = "";       // 对应 CityCode
  @Local districtCode: string = "";   // 对应 CountryCode
  @Local provinceName: string = "";   // 对应 province
  @Local cityName: string = "";       // 对应 city
  @Local districtName: string = "";   // 对应 district


  // Picker 相关状态
  @Local isPickerVisible: boolean = false;
  @Local areaData: AreaItem[] = []; // 总数据
  @Local rangeProvince: string[] = [];
  @Local rangeCity: string[] = [];
  @Local rangeDistrict: string[] = [];
  @Local pickSelect: number[] = [0, 0, 0]; // 选中项索引 [省, 市, 区]

  aboutToAppear() {
    this.loadAreaData(); // 加载地区数据
  }

  // 接收路由参数
  onPageShow() {
    // 注意：NavDestination 的参数通常在 onReady 中获取，或者通过 @Prop 传递
    // 这里为了演示，假设参数已经正确传递并初始化
  }

  /**
   * 加载地区 JSON 数据
   * 在实际项目中，建议将 area.json 放在 rawfile 中，通过 resourceManager 读取
   * 或者直接作为一个 constant ts 文件导入
   */
  async loadAreaData() {
    try {
      // 模拟加载，实际请替换为：
      let value = await getContext(this).resourceManager.getRawFileContent("zj_area.json");
      let jsonStr = util.TextDecoder.create("utf-8").decodeWithStream(value);
      this.areaData = JSON.parse(jsonStr);

      // 这里为了代码能跑，先留空，请务必导入你的 area.json 数据
      // import areaData from './area.json'; this.areaData = areaData;
      // 或者在此处写死部分测试数据：
      /*
      this.areaData = [
        { id: "110000", text: "北京", next: [{ id: "110100", text: "北京市", next: [{id: "110101", text: "东城区"}] }] },
        { id: "130000", text: "河北", next: [{ id: "130100", text: "石家庄市", next: [{id: "130102", text: "长安区"}] }] }
      ];
      */
      // this.areaData = [
      //   { id: "110000", text: "北京", next: [{ id: "110100", text: "北京市", next: [{id: "110101", text: "东城区"}] }] },
      //   { id: "130000", text: "河北", next: [{ id: "130100", text: "石家庄市", next: [{id: "130102", text: "长安区"}] }] }
      // ];
      // 初始化 Picker 第一列
      this.updatePickerRanges(0, 0, 0);

    } catch (e) {
      console.error("加载地区数据失败", e);
    }
  }

  /**
   * 更新 Picker 的显示范围
   * @param pIndex 省索引
   * @param cIndex 市索引
   * @param dIndex 区索引
   */
  updatePickerRanges(pIndex: number, cIndex: number, dIndex: number) {
    if (this.areaData.length === 0) return;

    // 1. 更新省份列表
    this.rangeProvince = this.areaData.map(item => item.text);

    // 确保索引不越界
    pIndex = Math.min(pIndex, this.areaData.length - 1);

    // 2. 更新城市列表
    let cities = this.areaData[pIndex].next || [];
    this.rangeCity = cities.map(item => item.text);

    cIndex = Math.min(cIndex, cities.length - 1);

    // 3. 更新区县列表
    let districts = (cities.length > 0 && cities[cIndex].next) ? cities[cIndex].next! : [];
    this.rangeDistrict = districts.map(item => item.text);

    dIndex = Math.min(dIndex, districts.length - 1);

    this.pickSelect = [pIndex, cIndex, dIndex];
  }

  /**
   * Picker 滚动监听
   */
  onPickerChange(value: string | string[], index: number | number[]) {
    if (Array.isArray(index)) {
      let p = index[0];
      let c = index[1];
      let d = index[2];

      // 如果省份变了，重置市和区
      if (p !== this.pickSelect[0]) {
        this.updatePickerRanges(p, 0, 0);
      }
      // 如果城市变了，重置区
      else if (c !== this.pickSelect[1]) {
        this.updatePickerRanges(p, c, 0);
      }
      // 只有区变了
      else {
        this.pickSelect = [p, c, d];
      }
    }
  }

  /**
   * 确认选择地区
   */
  /**
   * 确认地区选择
   */
  confirmAreaSelection() {
    let pIndex = this.pickSelect[0];
    let cIndex = this.pickSelect[1];
    let dIndex = this.pickSelect[2];

    if (this.areaData.length > 0) {
      let pItem = this.areaData[pIndex];
      let cItem = (pItem.next && pItem.next.length > cIndex) ? pItem.next[cIndex] : null;
      let dItem = (cItem && cItem.next && cItem.next.length > dIndex) ? cItem.next[dIndex] : null;

      if (pItem && cItem) {
        this.provinceName = pItem.text;
        this.provinceCode = pItem.id;

        this.cityName = cItem.text;
        this.cityCode = cItem.id;

        // 部分城市可能没有区县数据
        if (dItem) {
          this.districtName = dItem.text;
          this.districtCode = dItem.id;
        } else {
          this.districtName = "";
          this.districtCode = "";
        }

        this.regionText = `${this.provinceName} ${this.cityName} ${this.districtName}`;
      }
    }
    this.isPickerVisible = false;
  }

  /**
   * 提交保存
   */
  saveAction() {
    // 1. 校验
    if (!this.userName) { CoreUtils.toast("请输入收货人"); return; }
    if (!this.userPhone) { CoreUtils.toast("请输入手机号码"); return; }
    if (!this.provinceCode) { CoreUtils.toast("请选择所在地区"); return; }
    if (!this.detailAddress) { CoreUtils.toast("请输入详细地址"); return; }

    // 2. 参数构建
    /*
    {
	"Mobile": "13522884455",
	"province": "辽宁省",
	"UserName": "all",
	"CGRUserGuid": "202108201844379633",
	"IsDefault": "0",
	"district": "皇姑区",
	"ProvinceCode": "210000",
	"city": "沈阳市",
	"CityCode": "210100",
	"Address": "租赁",
	"CountryCode": "210105"
}
     * */

    // 2. 构造参数 (严格按照你的要求)
    let params: generalModel = {
      "CGRUserGuid": ContextUtils.getUserInfo()?.userGuid || "",
      "UserName": this.userName,
      "Mobile": this.userPhone,
      "province": this.provinceName,
      "ProvinceCode": this.provinceCode,
      "city": this.cityName,
      "CityCode": this.cityCode,
      "district": this.districtName,
      "CountryCode": this.districtCode, // 你的 JSON 里 CountryCode 对应的是区县ID (如 210105)
      "Address": this.detailAddress,
      "IsDefault": this.isDefault ? "1" : "0"
    };

    let url = ADD_USER_ADDRESS_HTTP;
    // 如果是编辑，ObjC 中通常需要传 ID
    if (this.isEdit && this.editModel.RowGuid) {
      params.RowGuid = this.editModel.RowGuid;
      url = UPDATE_USER_ADDRESS_HTTP
    } else {
      url = ADD_USER_ADDRESS_HTTP;
    }



    // 3. 提交
    this.pageLoading = true;
    easyDataRequest(AppConfig.studyBaseUrl + url, params, "POST")
      .then(res => {
        if (res['code'] == 200 || res['code'] == 0) {
          CoreUtils.toast(res['msg'] || "保存成功");
          // 返回并通知上一页刷新
          this.navPathStack.pop({ refresh: true });
        } else {
          CoreUtils.toast(res['msg']);
        }
      })
      .catch((err:Error) => { CoreUtils.toast("网络异常"); })
      .finally(() => { this.pageLoading = false; });
  }

  /**
   * 删除地址
   */
  deleteAction() {
    DialogHelper.showAlertDialog({
      title: '提示',
      content: '确定要删除该地址吗？',
      primaryButton: {
        value: '取消'
      },
      secondaryButton: {
        value: '删除',
        fontColor: Color.Red,
      },
      onAction: (action) => {
        console.log("action",action)
        if (action === -2) {
          this.pageLoading = true;
          easyDataRequest(AppConfig.studyBaseUrl + DELETE_ADDRESS_HTTP, { RowGuid: this.editModel.RowGuid }, "POST")
            .then(res => {
              if (res['code'] == 200 || res['code'] == 0) {
                CoreUtils.toast("删除成功");
                this.navPathStack.pop({ refresh: true });
              } else {
                CoreUtils.toast(res['msg']);
              }
            })
            .finally(() => this.pageLoading = false);
        }
      }
    });
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          // 1. 自定义导航栏
          this.NavBarBuilder()

          // 2. 表单内容
          Column() {
            // 收货人
            this.InputRowBuilder("收货人", "请输入收货人", this.userName, (val) => this.userName = val)

            // 手机号
            this.InputRowBuilder("手机号码", "请输入手机号码", this.userPhone, (val) => this.userPhone = val, InputType.PhoneNumber)

            // 所在地区 (点击触发 Picker)
            this.SelectRowBuilder("所在地区", this.regionText || "请选择地区", () => {
              this.isPickerVisible = true;
            })

            // 详细地址 (TextArea)
            Column() {
              TextArea({ text: this.detailAddress, placeholder: "详细地址：如道路、门牌号、小区、楼栋号、单元室等" })
                .height(80)
                .fontSize(14)
                .backgroundColor(Color.Transparent)
                .padding({ left: 0 })
                .onChange((val) => this.detailAddress = val)
              Divider().color("#F0F0F0")
            }
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })

            // 设为默认
            Row() {
              Text("设置为默认地址")
                .fontSize(14)
                .fontColor(Color.Black)
              Blank()
              Toggle({ type: ToggleType.Switch, isOn: this.isDefault })
                .selectedColor($r("app.color.main_color")) // 假设有主色调
                .onChange((isOn) => this.isDefault = isOn)
            }
            .width("100%")
            .height(50)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)

          }
          .margin(16)
          .backgroundColor(Color.White)
          .borderRadius(8)


          // 3. 保存按钮
          Button(this.isEdit ? "保存地址" : "添加地址")
            .width("90%")
            .height(45)
            .backgroundColor($r("app.color.main_color"))
            .margin({ bottom: 30 })
            .onClick(() => this.saveAction())
        }
        .width("100%")
        .height("100%")
        .backgroundColor("#FAFAFA")

        FullLoading({ loading: this.pageLoading })
      }
      // 4. 地区选择器弹窗
      .bindSheet($$this.isPickerVisible, this.AreaPickerBuilder(), {
        height: 350,
        dragBar: false,
        showClose:false,
        backgroundColor: Color.White,
        onDisappear: () => { this.isPickerVisible = false }
      })
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack;
      // 获取参数
      let params :Record<string, Object> = this.navPathStack.getParamByName('EditAddressPage')[0] as Record<string, Object>;
      if (params) {
        this.isEdit = params.isEdit as boolean;
        if (this.isEdit) {
          let detail :generalModel = params['detail'] as generalModel;
          this.editModel = params['detail'] as generalModel;
          // 回显数据
          this.userName = detail.UserName || ""; // 注意检查你的 Model 字段名是大写还是小写
          this.userPhone = detail.Mobile || "";
          this.detailAddress = detail.Address || "";
          this.isDefault = detail.mrDz === "1";
          this.provinceCode = detail.ProvinceCode || "";
          this.cityCode = detail.CityCode || "";
          this.districtCode = detail.CountryCode || "";
          this.provinceName = detail.province || "";
          this.cityName = detail.city || "";
          this.districtName = detail.district || "";

          // 拼接回显的地区文本，假设 Model 里有这些名称字段，或者你需要根据 ID 去查
          // 简单起见，这里假设 Model 存了名称，或者需要你后端返回名称
          this.regionText = `${detail.province || ""} ${detail.city || ""} ${detail.district || ""}`.trim();
        }
      }
    })
  }

  // --- UI Builders ---

  @Builder
  NavBarBuilder() {
    Row() {
      Button() {
        Image($r("app.media.BFH")).objectFit(ImageFit.Contain).width(24).height(24)
      }
      .width(44).height(44).backgroundColor(Color.Transparent)
      .onClick(() => this.navPathStack.pop())

      Text(this.isEdit ? "编辑地址" : "添加地址")
        .fontSize(18).fontWeight(FontWeight.Bold).fontColor($r("app.color.white"))
        .textAlign(TextAlign.Center).layoutWeight(1)

      // 右侧按钮 (编辑模式显示删除)
      if (this.isEdit) {
        Text("删除")
          .fontSize(14).fontColor($r("app.color.white"))
          .padding({ right: 16 })
          .onClick(() => this.deleteAction())
      } else {
        Text("     ").width(44) // 占位
      }
    }
    .width("100%").height(44).backgroundColor($r("app.color.main_color"))
  }

  @Builder
  InputRowBuilder(title: string, placeholder: string, value: string, onChange: (val: string) => void, type: InputType = InputType.Normal) {
    Row() {
      Text(title).width(80).fontSize(14).fontColor(Color.Black)
      TextInput({ text: value, placeholder: placeholder })
        .layoutWeight(1)
        .fontSize(14)
        .backgroundColor(Color.Transparent)
        .type(type)
        .onChange(onChange)
    }
    .height(50)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .border({ width: { bottom: 1 }, color: "#F0F0F0" })
  }

  @Builder
  SelectRowBuilder(title: string, text: string, onClick: () => void) {
    Row() {
      Text(title).width(80).fontSize(14).fontColor(Color.Black)
      Text(this.regionText)
        .layoutWeight(1)
        .fontSize(14)
        .fontColor(this.regionText === "请选择地区" ? "#999" : Color.Black)
      Image($r("app.media.servicedetail_btn_in")) // 替换你的箭头图标
        .width(16).height(16).fillColor("#999")
    }
    .height(50)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .border({ width: { bottom: 1 }, color: "#F0F0F0" })
    .onClick(onClick)
  }

  // 地区选择器 Builder
  @Builder
  AreaPickerBuilder() {
    Column() {
      // 顶部工具栏
      Row() {
        Text("取消").fontColor("#666").onClick(() => { this.isPickerVisible = false })
        Text("请选择地区").fontWeight(FontWeight.Medium)
        Text("确定").fontColor($r("app.color.main_color")).onClick(() => this.confirmAreaSelection())
      }
      .width("100%").height(50).padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
      .border({ width: { bottom: 1 }, color: "#eee" })

      // 三级联动 Picker
      TextPicker({ range: [this.rangeProvince, this.rangeCity, this.rangeDistrict], selected: this.pickSelect })
        .layoutWeight(1)
        .width("100%")
        .onChange((value, index) => {
          this.onPickerChange(value, index)
        })
    }
  }
}