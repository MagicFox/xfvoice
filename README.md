# xfvoice

fork by https://github.com/ligun123/xfvoice.git

科大讯飞语音识别插件
A plugin for xunfei dictation for iOS and Android.

## Install

First, add xfvoice as a dependency in your pubspec.yaml file.

## Setting

Set privacy on iOS in Info.plist

```
<key>NSMicrophoneUsageDescription</key>
<string></string>
<key>NSLocationUsageDescription</key>
<string></string>
<key>NSLocationAlwaysUsageDescription</key>
<string></string>
<key>NSContactsUsageDescription</key>
<string></string>
```

Set privacy on Android in AndroidManifest.xml
```
<!--连接网络权限，用于执行云端语音能力 -->
<uses-permission android:name="android.permission.INTERNET"/>
<!--获取手机录音机使用权限，听写、识别、语义理解需要用到此权限 -->
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<!--读取网络信息状态 -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<!--获取当前wifi状态 -->
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
<!--允许程序改变网络连接状态 -->
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE"/>
<!--读取手机信息权限 -->
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<!--读取联系人权限，上传联系人需要用到此权限 -->
<uses-permission android:name="android.permission.READ_CONTACTS"/>
<!--外存储写权限，构建语法需要用到此权限 -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<!--外存储读权限，构建语法需要用到此权限 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<!--配置权限，用来记录应用配置信息 -->
<uses-permission android:name="android.permission.WRITE_SETTINGS"/>
<!--手机定位信息，用来为语义等功能提供定位，提供更精准的服务-->
<!--定位信息是敏感信息，可通过Setting.setLocationEnable(false)关闭定位请求 -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<!--如需使用人脸识别，还要添加：摄相头权限，拍照需要用到 -->
<uses-permission android:name="android.permission.CAMERA" />
```

## Usage

- Init the plugin. Use the appId you register on https://www.xfyun.cn/
```
final voice = XFVoice.shared;
voice.init(appIdIos: 'the app id for ios', appIdAndroid: 'the app id for android');
```
- Set the parameter. Class `XFVoiceParam` is usefull.
```
    // 请替换成你的appid
    voice.init(appIdIos: '5d133a41', appIdAndroid: '5d133aae');
    final param = new XFVoiceParam();
    param.domain = 'iat';
    // param.asr_ptt = '0';   //取消注释可去掉标点符号
    param.asr_audio_path = 'audio.pcm';
    param.result_type = 'json'; //可以设置plain
    final map = param.toMap();
    map['dwa'] = 'wpgs';        //设置动态修正，开启动态修正要使用json类型的返回格式
    voice.setParameter(map);
```

- Start dictation. Use `XFVoiceListener` for listen on the callback.
```
final listener = XFVoiceListener(
      onVolumeChanged: (volume) {
        print('$volume');
      },
      onResults: (String result, isLast) {
        print(result.toString());
      },
      onCompleted: (Map<dynamic, dynamic> errInfo, String filePath) {
        print('onCompleted');
      }
    );
voice.start(listener: listener);
```
The `result` type is based on the parameter `result_type` you setted before. It may be `json/xml/plain`.

- Stop dictate.

```
voice.stop();
```

## Important
The binary downloaded from xunfei is bind with you appid.  
So, when you use this plugin, you should replace the binary in both Android and iOS project.

iOS
```
xfvoice/ios/Frameworks/iflyMSC.framework
```

Android
```
xfvoice/android/libs/Msc.jar
```