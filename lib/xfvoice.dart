import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

//  "${PODS_ROOT}/Frameworks/xfvoice/Frameworks"
/// Platform 需要实现的方法：
/// 初始化方法：- init(String appid)
/// 设置讯飞识别参数：- setParameter(Map param)
/// 打开麦克风并开始识别：- start
/// 关闭麦克风并停止识别：- stop
class XFVoice {
  static const MethodChannel _channel = const MethodChannel('xfvoice');

  static final XFVoice shared = XFVoice._();

  XFVoice._();

  Future<void> init(
      {@required String appIdIos, @required String appIdAndroid}) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('init', appIdIos);
    }
    if (Platform.isAndroid) {
      await _channel.invokeMethod('init', appIdAndroid);
    }

    _channel.setMethodCallHandler((MethodCall call) async {
      print(call.method);
      print(call.arguments.toString());
    });
  }

  Future<void> setParameter(Map<String, dynamic> param) async {
    await _channel.invokeMethod('setParameter', param);
  }


  Future<void> startWithView({XFVoiceListener listener}) async {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onCancel' && listener?.onCancel != null) {
        listener.onCancel();
      }
      if (call.method == 'onBeginOfSpeech' &&
          listener?.onBeginOfSpeech != null) {
        listener.onBeginOfSpeech();
      }
      if (call.method == 'onEndOfSpeech' && listener?.onEndOfSpeech != null) {
        listener.onEndOfSpeech();
      }
      if (call.method == 'onCompleted' && listener?.onCompleted != null) {
        listener.onCompleted(call.arguments[0], call.arguments[1]);
      }
      if (call.method == 'onResults' && listener?.onResults != null) {
        listener.onResults(call.arguments[0], call.arguments[1]);
      }
      if (call.method == 'onVolumeChanged' &&
          listener?.onVolumeChanged != null) {
        listener.onVolumeChanged(call.arguments);
      }
    });
    await _channel.invokeMethod('startWithView');
  }


  Future<void> start({XFVoiceListener listener}) async {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onCancel' && listener?.onCancel != null) {
        listener.onCancel();
      }
      if (call.method == 'onBeginOfSpeech' &&
          listener?.onBeginOfSpeech != null) {
        listener.onBeginOfSpeech();
      }
      if (call.method == 'onEndOfSpeech' && listener?.onEndOfSpeech != null) {
        listener.onEndOfSpeech();
      }
      if (call.method == 'onCompleted' && listener?.onCompleted != null) {
        listener.onCompleted(call.arguments[0], call.arguments[1]);
      }
      if (call.method == 'onResults' && listener?.onResults != null) {
        listener.onResults(call.arguments[0], call.arguments[1]);
      }
      if (call.method == 'onVolumeChanged' &&
          listener?.onVolumeChanged != null) {
        listener.onVolumeChanged(call.arguments);
      }
    });
    await _channel.invokeMethod('start');
  }

  Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }

  Future<void> dispose() async {
    await _channel.invokeMethod('dispose');
  }

  Future<void> cancel() async {
    await _channel.invokeMethod('cancel');
  }

  /// 用完记得释放listener
  void clearListener() {
    _channel.setMethodCallHandler(null);
  }
}

/// 讯飞语音识别的回调映射，有flutter来决定处理所有的回调结果，
/// 会更具有灵活性
class XFVoiceListener {
  VoidCallback onCancel;
  VoidCallback onEndOfSpeech;
  VoidCallback onBeginOfSpeech;

  /// error信息构成的key-value map，[filePath]是音频文件路径
  void Function(Map<dynamic, dynamic> error, String filePath) onCompleted;
  void Function(String result, bool isLast) onResults;
  void Function(int volume) onVolumeChanged;

  XFVoiceListener(
      {this.onBeginOfSpeech,
      this.onResults,
      this.onVolumeChanged,
      this.onEndOfSpeech,
      this.onCompleted,
      this.onCancel});
}

/* Example
 * {
  "sn": 1,
  "ls": true,
  "bg": 0,
  "ed": 0,
  "ws": [
    {
      "bg": 0,
      "cw": [
        {
          "w": " 今天 ",
          "sc": 0
        }
      ]
    },
    {
      "bg": 0,
      "cw": [
        {
          "w": " 的",
          "sc": 0
        }
      ]
    },
    {
      "bg": 0,
      "cw": [
        {
          "w": " 天气 ",
          "sc": 0
        }
      ]
    },
    {
      "bg": 0,
      "cw": [
        {
          "w": " 怎么样 ",
          "sc": 0
        }
      ]
    },
    {
      "bg": 0,
      "cw": [
        {
          "w": " 。",
          "sc": 0
        }
      ]
    }
  ]
}
 */
class XFJsonResult {
  int sn;
  bool ls;
  int bg;
  int ed;
  String pgs;
  List rg;
  List ws;

  XFJsonResult(String jsonResult) {
    final json = jsonDecode(jsonResult);
    this.sn = json['sn'] as int;
    this.ls = json['ls'] as bool;
    this.bg = json['bg'] as int;
    this.ed = json['ed'] as int;
    this.pgs = json['pgs'] as String;
    this.rg = json['rg'] as List;
    this.ws = json['ws'] as List;
  }

  /// 适配动态修正
  void mix(XFJsonResult another) {
    this.sn = another.sn;
    this.ls = another.ls;
    this.bg = another.bg;
    this.ed = another.ed;
    this.rg = another.rg;
    if (another.pgs == 'apd') {
      this.ws.addAll(another.ws);
    } else {
      this.ws = another.ws;
    }
  }

  String resultText() {
    final resultStr = this
        .ws
        .map((element) {
          List cw = element['cw'];
          if (cw == null || cw.length == 0) {
            return '';
          } else {
            return cw[0]['w'] as String;
          }
        })
        .toList()
        .join();
    return resultStr;
  }
}

class XFVoiceParam {
  String accent;
  String speech_timeout;
  String domain;
  String result_type;
  String timeout;
  String power_cycle;
  String sample_rate;
  String engine_type;
  String local;
  String cloud;
  String mix;
  String auto;
  String text_encoding;
  String result_encoding;
  String player_init;
  String player_deactive;
  String recorder_init;
  String recorder_deactive;
  String speed;
  String pitch;
  String tts_audio_path;
  String vad_enable;
  String vad_bos;
  String vad_eos;
  String voice_name;
  String voice_id;
  String voice_lang;
  String volume;
  String tts_buffer_time;
  String tts_data_notify;
  String next_text;
  String mpplayinginfocenter;
  String audio_source;
  String asr_audio_path;
  String asr_sch;
  String asr_ptt;
  String local_grammar;
  String cloud_grammar;
  String grammar_type;
  String grammar_content;
  String lexicon_content;
  String lexicon_name;
  String grammar_list;
  String nlp_version;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> param = {
      'accent': accent,
      'speech_timeout': speech_timeout,
      'domain': domain,
      'result_type': result_type,
      'timeout': timeout,
      'power_cycle': power_cycle,
      'sample_rate': sample_rate,
      'engine_type': engine_type,
      'local': local,
      'cloud': cloud,
      'mix': mix,
      'auto': auto,
      'text_encoding': text_encoding,
      'result_encoding': result_encoding,
      'player_init': player_init,
      'player_deactive': player_deactive,
      'recorder_init': recorder_init,
      'recorder_deactive': recorder_deactive,
      'speed': speed,
      'pitch': pitch,
      'tts_audio_path': tts_audio_path,
      'vad_enable': vad_enable,
      'vad_bos': vad_bos,
      'vad_eos': vad_eos,
      'voice_name': voice_name,
      'voice_id': voice_id,
      'voice_lang': voice_lang,
      'volume': volume,
      'tts_buffer_time': tts_buffer_time,
      'tts_data_notify': tts_data_notify,
      'next_text': next_text,
      'mpplayinginfocenter': mpplayinginfocenter,
      'audio_source': audio_source,
      'asr_audio_path': asr_audio_path,
      'asr_sch': asr_sch,
      'asr_ptt': asr_ptt,
      'local_grammar': local_grammar,
      'cloud_grammar': cloud_grammar,
      'grammar_type': grammar_type,
      'grammar_content': grammar_content,
      'lexicon_content': lexicon_content,
      'lexicon_name': lexicon_name,
      'grammar_list': grammar_list,
      'nlp_version': nlp_version,
    };
    final isNull = (key, value) {
      return value == null;
    };
    param.removeWhere(isNull);
    return param;
  }
}
