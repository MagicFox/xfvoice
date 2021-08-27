#import "XfvoicePlugin.h"
#import <iflyMSC/iflyMSC.h>
#import <objc/runtime.h>

static FlutterMethodChannel *_channel = nil;

@interface XfvoicePlugin () <IFlySpeechRecognizerDelegate>

@property (nonatomic, strong) NSString *resultString;

@end

@implementation XfvoicePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"xfvoice"
                                     binaryMessenger:[registrar messenger]];
    XfvoicePlugin* instance = [[XfvoicePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    _channel = channel;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"init" isEqualToString:call.method]) {
        [self iflyInit:call.arguments];
        result(NULL);
    } else if ([@"setParameter" isEqualToString:call.method]) {
        [self setParameter:call.arguments];
        result(NULL);
    } else if ([@"start" isEqualToString:call.method]) {
        [self start];
        result(NULL);
    } else if([@"startWithView" isEqualToString:call.method]) {
        [self startWithView];
        result(NULL);
    } else if ([@"stop" isEqualToString:call.method]) {
        [self stop];
        result(NULL);
    } else if ([@"dispose" isEqualToString:call.method]) {
        [self cancel];
        result(NULL);
    } else if ([@"cancel" isEqualToString:call.method]) {
        [self cancel];
        result(NULL);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - Bridge Actions

- (void)iflyInit:(NSString *)appId {
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", appId];
    [IFlySpeechUtility createUtility:initString];
    [[IFlySpeechRecognizer sharedInstance] setDelegate:self];
    [IFlySetting setLogFile:LVL_NONE];
}

- (void)setParameter:(NSDictionary *)param {
    [param enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [[IFlySpeechRecognizer sharedInstance] setParameter:obj forKey:key];
    }];
}

- (void)start {
    if ([[IFlySpeechRecognizer sharedInstance] isListening]) {
        return;
    }
    self.resultString = nil;
    [[IFlySpeechRecognizer sharedInstance] startListening];
}

- (void)startWithView {
    if ([[IFlySpeechRecognizer sharedInstance] isListening]) {
        return;
    }
    self.resultString = nil;
    [[IFlySpeechRecognizer sharedInstance] startListening];
}

- (void)stop {
    [[IFlySpeechRecognizer sharedInstance] stopListening];
}

- (void)cancel {
    [[IFlySpeechRecognizer sharedInstance] cancel];
}

#pragma mark - iFly delegate

- (void)onCompleted:(IFlySpeechError *)errorCode {
    NSDictionary *dic = NSNull.null;
    if (errorCode.errorCode != 0) {
        dic = @{@"code": @(errorCode.errorCode),
                @"type": @(errorCode.errorType),
                @"desc": errorCode.errorDesc
                };
    }
    
    NSString *path = [[IFlySpeechRecognizer sharedInstance] parameterForKey:@"asr_audio_path"];
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory
                                                              , NSUserDomainMask
                                                              , YES);
    NSString *folder = cachePaths.firstObject;
    NSString *filePath = [folder stringByAppendingPathComponent:path];
    [_channel invokeMethod:@"onCompleted" arguments:@[dic, filePath]];
}

- (void)onResults:(NSArray *)results isLast:(BOOL)isLast {
    NSString *res = NSNull.null;
    if (results != nil) {
        NSDictionary *dic = [results firstObject];
        res = dic.allKeys.firstObject;
        self.resultString = res;
    } else {
        if (self.resultString != nil) {
            res = self.resultString;
        }
    }
    [_channel invokeMethod:@"onResults" arguments:@[res, @(isLast)]];
}

- (void)onVolumeChanged:(int)volume {
    [_channel invokeMethod:@"onVolumeChanged" arguments:@(volume)];
}

- (void)onBeginOfSpeech {
    [_channel invokeMethod:@"onBeginOfSpeech" arguments:NULL];
}

- (void)onEndOfSpeech {
    [_channel invokeMethod:@"onEndOfSpeech" arguments:NULL];
}

- (void)onCancel {
    [_channel invokeMethod:@"onCancel" arguments:NULL];
}

+ (void)testParam {
    NSMutableArray *paramArr = [NSMutableArray arrayWithCapacity:100];
    [paramArr addObject:[IFlySpeechConstant SPEECH_TIMEOUT]];
    [paramArr addObject:[IFlySpeechConstant IFLY_DOMAIN]];
    [paramArr addObject:[IFlySpeechConstant NET_TIMEOUT]];
    [paramArr addObject:[IFlySpeechConstant POWER_CYCLE]];
    [paramArr addObject:[IFlySpeechConstant SAMPLE_RATE]];
    [paramArr addObject:[IFlySpeechConstant ENGINE_TYPE]];
    [paramArr addObject:[IFlySpeechConstant TYPE_LOCAL]];
    [paramArr addObject:[IFlySpeechConstant TYPE_CLOUD]];
    [paramArr addObject:[IFlySpeechConstant TYPE_MIX]];
    [paramArr addObject:[IFlySpeechConstant TYPE_AUTO]];
    [paramArr addObject:[IFlySpeechConstant TEXT_ENCODING]];
    [paramArr addObject:[IFlySpeechConstant RESULT_ENCODING]];
    [paramArr addObject:[IFlySpeechConstant PLAYER_INIT]];
    [paramArr addObject:[IFlySpeechConstant PLAYER_DEACTIVE]];
    [paramArr addObject:[IFlySpeechConstant RECORDER_INIT]];
    [paramArr addObject:[IFlySpeechConstant RECORDER_DEACTIVE]];
    [paramArr addObject:[IFlySpeechConstant SPEED]];
    [paramArr addObject:[IFlySpeechConstant PITCH]];
    [paramArr addObject:[IFlySpeechConstant TTS_AUDIO_PATH]];
    [paramArr addObject:[IFlySpeechConstant VAD_ENABLE]];
    [paramArr addObject:[IFlySpeechConstant VAD_BOS]];
    [paramArr addObject:[IFlySpeechConstant VAD_EOS]];
    [paramArr addObject:[IFlySpeechConstant VOICE_NAME]];
    [paramArr addObject:[IFlySpeechConstant VOICE_ID]];
    [paramArr addObject:[IFlySpeechConstant VOICE_LANG]];
    [paramArr addObject:[IFlySpeechConstant VOLUME]];
    [paramArr addObject:[IFlySpeechConstant TTS_BUFFER_TIME]];
    [paramArr addObject:[IFlySpeechConstant TTS_DATA_NOTIFY]];
    [paramArr addObject:[IFlySpeechConstant NEXT_TEXT]];
    [paramArr addObject:[IFlySpeechConstant MPPLAYINGINFOCENTER]];
    [paramArr addObject:[IFlySpeechConstant AUDIO_SOURCE]];
    [paramArr addObject:[IFlySpeechConstant ASR_AUDIO_PATH]];
    [paramArr addObject:[IFlySpeechConstant ASR_SCH]];
    [paramArr addObject:[IFlySpeechConstant ASR_PTT]];
    [paramArr addObject:[IFlySpeechConstant LOCAL_GRAMMAR]];
    [paramArr addObject:[IFlySpeechConstant CLOUD_GRAMMAR]];
    [paramArr addObject:[IFlySpeechConstant GRAMMAR_TYPE]];
    [paramArr addObject:[IFlySpeechConstant GRAMMAR_CONTENT]];
    [paramArr addObject:[IFlySpeechConstant LEXICON_CONTENT]];
    [paramArr addObject:[IFlySpeechConstant LEXICON_NAME]];
    [paramArr addObject:[IFlySpeechConstant GRAMMAR_LIST]];
    [paramArr addObject:[IFlySpeechConstant NLP_VERSION]];
    
    NSMutableString *defineString = [NSMutableString stringWithString:@"\n"];
    NSMutableString *toJson = [NSMutableString stringWithString:@""];
    [paramArr enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [defineString appendFormat:@"String %@;\n", obj];
        [toJson appendFormat:@"'%@': %@,\n", obj, obj];
    }];
    NSLog(@"********");
    NSLog(defineString);
    NSLog(toJson);
    
}

@end

