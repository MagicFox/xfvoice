import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import 'package:xfvoice/xfvoice.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

// class MyApp extends StatefulWidget {
//   _MyApp createState() => _MyApp();
// }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter EasyLoading',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: First(),
      builder: EasyLoading.init(),
    );
  }
}

class First extends StatefulWidget {
  _First createState() => _First();
}


class _First extends State<First> {
  String voiceMsg = '暂无数据';
  String iflyResultString = '按下方块说话';
  String iflyResultString2 = '按下方块说话';

  XFJsonResult xfResult;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

   Future<void> initPlatformState() async {
    final voice = XFVoice.shared;
    // 请替换成你的appid
    voice.init(appIdIos: '5d133a41', appIdAndroid: '02ab9aa1');
    final param = new XFVoiceParam();
    param.domain = 'iat';
    // param.asr_ptt = '0';   //取消注释可去掉标点符号
    param.asr_audio_path = 'audio.pcm';
    param.result_type = 'json'; //可以设置plain
    final map = param.toMap();
    map['dwa'] = 'wpgs';        //设置动态修正，开启动态修正要使用json类型的返回格式
    voice.setParameter(map);

    // bool status = await Permission.microphone.isGranted;

   }

  List<Permission> permissionList =  [
  Permission.storage,
  Permission.speech,
  ];
  // 获取权限
  requestPermission(Function fun ) async {
    // 为空则不需要申请权限

    await permissionList.request();
    bool isPermission = true;
    for (Permission permission in permissionList) {
      // 有一项为false则表示权限未授权
      if (!await permission.request().isGranted) {
        isPermission = false;
      }
    }
    if (isPermission) {
      fun();
    } else {
      // 二次获取权限
      requestPermission(fun);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '测试的demo',
      home: Scaffold(
        appBar: AppBar(
          title: new Text('测试demo'),
        ),
        body: Center(
          child: Column(
            children: [
              Container(height: 20,child: Text("带弹框"),),
              GestureDetector(
                child: Container(
                  child: Text(iflyResultString),
                  width: 300.0,
                  height: 150.0,
                  color: Colors.redAccent,
                ),
                onTapDown: (d) {
                  setState(() {
                    voiceMsg = '按下';
                  });
                  _recongize();
                },
                onTapUp: (d) {
                  // _recongizeOver();
                },
              ),
              Container(height: 20, margin: EdgeInsets.only(top: 15), child: Text("${voiceMsg}")),
              GestureDetector(
                child: Container(
                  child: Text(iflyResultString2),
                  width: 300.0,
                  height: 150.0,
                  color: Colors.blueAccent,
                ),
                onTapDown: (d) {
                  setState(() {
                    voiceMsg = '按下';
                  });
                  _recongize2();
                },
                onTapUp: (d) {
                  // _recongizeOver();
                },
              )
            ],
          ),
        )
      ),
    );
  }

  String str = "";

  void _recongize2() {

    final listen = XFVoiceListener(
        onVolumeChanged: (volume) {
        },
        onBeginOfSpeech: () {
          EasyLoading.show(status: '语音采集转换中...');
          xfResult = null;
          str = "";
        },
        onResults: (String result,bool isLast) {
          if (xfResult == null) {
            xfResult = XFJsonResult(result);
          } else {
            final another = XFJsonResult(result);
            xfResult.mix(another);
          }
          if (result.length > 0) {
            str += xfResult.resultText();
            // setState(() {
            //   iflyResultString = xfResult.resultText();
            // });
          }

          if(isLast == true) {
            EasyLoading.dismiss();
            setState(() {
              iflyResultString2 = str;
            });
          }
        },
        onCompleted: (Map<dynamic, dynamic> errInfo, String filePath) {

          print('${errInfo}');
          setState(() {

          });
        }
    );
    requestPermission((){
      XFVoice.shared.start(listener: listen);
    });
  }
  void _recongize() {

    final listen = XFVoiceListener(
      onVolumeChanged: (volume) {
      },
      onBeginOfSpeech: () {
        xfResult = null;
        str = "";
      },
      onResults: (String result,bool isLast) {
        // if (xfResult == null) {
        //   xfResult = XFJsonResult(result);
        // } else {
        //   final another = XFJsonResult(result);
        //   xfResult.mix(another);
        // }
        // if (result.length > 0) {
        //   str += xfResult.resultText();
        //   // setState(() {
        //   //   iflyResultString = xfResult.resultText();
        //   // });
        // }

        if(isLast == true) {
          setState(() {
            iflyResultString = result;
          });
        }
      },
      onCompleted: (Map<dynamic, dynamic> errInfo, String filePath) {
        print('${errInfo}');
          setState(() {
          
        });
      }
    );
    requestPermission((){
      XFVoice.shared.startWithView(listener: listen);
    });
  }

  void _recongizeOver() {
    XFVoice.shared.stop();
  }
}
