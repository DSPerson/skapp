import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import 'package:provider/provider.dart';
import 'package:skapp/http/API.dart';
import 'package:skapp/http/http_request.dart';
import 'package:skapp/store/root.dart';
import 'package:flutter_dlna/flutter_dlna.dart';

//http://jx.idc126.net/jx/?url=https://v.youku.com/v_show/id_XMjI2OTc2OTE2.html?spm=a2h03.12024492.drawer3.dzj1_1&scm=20140719.rcmd.1694.show_cbfccde2962411de83b1&s=cbfccde2962411de83b1

class Dlna extends StatefulWidget {
  @override
  _DlnaState createState() => _DlnaState();
}

class _DlnaState extends State<Dlna> {
  bool globalLoading = false;
  FlutterDlna manager = new FlutterDlna();
  List deviceList = List();
  //当前选择的设备
  String currentDeviceUUID = "";

  @override
  void initState() {
    super.initState();
    manager.init();
    manager.setSearchCallback((devices) {
      if (devices != null && devices.length > 0) {
        this.setState(() {
          this.deviceList = devices;
        });
      }
    });
    // getVideoInfo();
  }

  @override
  Widget build(BuildContext context) {
    final Global _global = Provider.of<Global>(context);
    return Observer(
      builder: (_) => Scaffold(
        // appBar: AppBar(
        //   title: Text('视频解析'),
        // ),
        resizeToAvoidBottomInset: false,
        body: globalLoading
            ? _global.isDark
                ? PKDarkCardListSkeleton(
                    isCircularImage: false,
                    isBottomLinesActive: true,
                  )
                : PKCardListSkeleton(
                    isCircularImage: false,
                    isBottomLinesActive: true,
                  )
            : SafeArea(
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          TextButton(
                            child: Text("搜索"),
                            onPressed: () {
                              manager.search();
                            },
                          ),
                          TextButton(
                            child: Text("退出投屏"),
                            onPressed: () {
                              manager.stop();
                            },
                          ),
                        ],
                      ),
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Column(children: [
                          Column(
                              children: deviceList.map((e) {
                            return InkWell(
                              child: Column(
                                children: [
                                  Container(
                                      padding:
                                          EdgeInsets.only(left: 8, right: 8),
                                      height: 55,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            e["name"],
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Color(0xFF111111),
                                                fontSize: 12),
                                          )),
                                        ],
                                      )),
                                  Divider(
                                    color: Color(0xFFEEEEEE),
                                    height: 0.5,
                                    endIndent: 2,
                                    indent: 2,
                                  )
                                ],
                              ),
                              onTap: () async {
                                if (this.currentDeviceUUID == e["id"]) {
                                  return;
                                }
                                await this.manager.setDevice(e["id"]);
                                await this.manager.setVideoUrlAndName(
                                    "https://vod3.buycar5.cn/20201030/Fk3mpLH6/index.m3u8",
                                    "不期而遇");
                                await this.manager.startAndPlay();
                              },
                            );
                          }).toList()),
                        ]),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
