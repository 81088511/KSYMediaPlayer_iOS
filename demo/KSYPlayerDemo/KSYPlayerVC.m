//
//  KSYPlayerVC.m
//
//  Created by zengfanping on 11/3/15.
//  Copyright (c) 2015 zengfanping. All rights reserved.
//

#import "KSYPlayerVC.h"
#import <KSYMediaPlayer/KSYMediaPlayer.h>
#import <CommonCrypto/CommonDigest.h>

@interface KSYPlayerVC ()
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSURL *reloadUrl;
@property (strong, nonatomic) KSYMoviePlayerController *player;
@end

@implementation KSYPlayerVC{
    UILabel *stat;
    NSTimer* timer;
    double lastSize;
    NSTimeInterval lastCheckTime;
    NSString* serverIp;
    UIView *videoView;
    UIButton *btnPlay;
    UIButton *btnPause;
    UIButton *btnReload;
    UIButton *btnStop;
    UIButton *btnQuit;
    UILabel  *lableVPP;
    UISwitch *switchVPP;
    UISwitch *switchLog;
    UIButton *getQosBtn;
    UISwitch  *switchHwCodec;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    //_url = [NSURL URLWithString:@"http://ksy.vcloud.sdk.ks3-cn-beijing.ksyun.com/TestVideo/gif_test_0319_1730.flv"];
    _reloadUrl = [NSURL URLWithString:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"];
//     _url = [NSURL URLWithString:@"http://120.132.75.127/vod/mp4/mtv_x264_1920x1080_30_1000K.mp4"];
    //_url = [NSURL URLWithString:@"http://121.42.58.232:8980/hls_test/1.m3u8"];

    //_url = [NSURL URLWithString:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"];
//    _url = [NSURL URLWithString:@"rtmp://test.rtmplive.ks-cdn.com/live/fpzeng"];
    //_url = [NSURL URLWithString:@"http://121.40.205.48:8091/demo/h265.flv"];
        _url = [NSURL URLWithString:@"http://120.132.75.127/vod/flv/bbb_720p_qy265.flv"];
       // _url = [NSURL URLWithString:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"];
    //_url = [NSURL URLWithString:@"http://ksy.vcloud.sdk.ks3-cn-beijing.ksyun.com/TestVideo/gif_test_0319_1730.flv"];
    //_url = [NSURL URLWithString:@"http://gifshow.rtmplive.ks-cdn.com/live/AWLW7_ePxNM.flv"];
    
    [self setupObservers];
    [self initKSYAuth];
}
- (void) initUI {
    //add UIView for player
    videoView = [[UIView alloc] init];
    videoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:videoView];
    
    //add play button
    btnPlay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnPlay setTitle:@"play" forState: UIControlStateNormal];
    btnPlay.backgroundColor = [UIColor lightGrayColor];
    [btnPlay addTarget:self action:@selector(onPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPlay];
    //add pause button
    btnPause = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnPause setTitle:@"pause" forState: UIControlStateNormal];
    btnPause.backgroundColor = [UIColor lightGrayColor];
    [btnPause addTarget:self action:@selector(onPauseVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPause];
    //add pause button
    btnReload = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnReload setTitle:@"reload" forState: UIControlStateNormal];
    btnReload.backgroundColor = [UIColor lightGrayColor];
    [btnReload addTarget:self action:@selector(onReloadVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReload];

    
    //add stop button
    btnStop = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnStop setTitle:@"stop" forState: UIControlStateNormal];
    btnStop.backgroundColor = [UIColor lightGrayColor];
    [btnStop addTarget:self action:@selector(onStopVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnStop];
    //add quit button
    btnQuit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnQuit setTitle:@"quit" forState: UIControlStateNormal];
    btnQuit.backgroundColor = [UIColor lightGrayColor];
    [btnQuit addTarget:self action:@selector(onQuit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnQuit];
    
    getQosBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [getQosBtn setTitle:@"QosInfo" forState: UIControlStateNormal];
    getQosBtn.backgroundColor = [UIColor lightGrayColor];
    [getQosBtn addTarget:self action:@selector(getQosBtnEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getQosBtn];

    stat = [[UILabel alloc] init];
    stat.backgroundColor = [UIColor clearColor];
    stat.textColor = [UIColor redColor];
    stat.numberOfLines = -1;
    stat.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:stat];
    
    lableVPP = [[UILabel alloc] init];
    lableVPP.text = @"开启硬件解码";
    lableVPP.textColor = [UIColor lightGrayColor];
    [self.view addSubview:lableVPP];

//    switchVPP = [[UISwitch alloc] init];
//    [self.view addSubview:switchVPP];
//    switchVPP.on = YES;
    
//    switchLog = [[UISwitch alloc] init];
//    [switchLog addTarget:self action:@selector(switchControlEvent:) forControlEvents:UIControlEventValueChanged];
//    [self.view addSubview:switchLog];
//    switchLog.on = YES;
    
    switchHwCodec = [[UISwitch alloc] init];
    [self.view  addSubview:switchHwCodec];
    switchHwCodec.on = YES;
    
    [self layoutUI];
}
- (void) layoutUI {
    CGFloat wdt = self.view.bounds.size.width;
    CGFloat hgt = self.view.bounds.size.height;
    CGFloat gap = 20;
    CGFloat btnWdt = ( (wdt-gap) / 5) - gap;
    CGFloat btnHgt = 30;
    CGFloat xPos = 0;
    CGFloat yPos = 0;

    yPos = gap;
    xPos = gap;
    lableVPP.frame =CGRectMake(xPos, yPos, btnWdt * 2, btnHgt);
    xPos += gap + lableVPP.frame.size.width;
    switchVPP.frame = CGRectMake(xPos, gap, btnWdt, btnHgt);
    switchLog.frame = CGRectMake(xPos + btnWdt + 50, gap, btnWdt, btnHgt);
    switchHwCodec.frame = CGRectMake(xPos, gap, btnWdt, btnHgt);

    videoView.frame = CGRectMake(0, 0, wdt, hgt);
    xPos = gap;
    yPos = hgt - btnHgt - gap;
    btnPlay.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnPause.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnReload.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnStop.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnQuit.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    stat.frame = CGRectMake(gap, 0, wdt, hgt/2);
    // top row 3 left
    yPos += (gap + btnHgt);
    xPos = gap;
    getQosBtn.frame = CGRectMake(xPos, btnStop.frame.origin.y - 40, btnWdt, btnHgt);

    
}

- (BOOL)shouldAutorotate {
    [self layoutUI];
    return YES;
}

- (void)switchControlEvent:(UISwitch *)switchControl
{
    if (_player) {
        _player.shouldEnableKSYStatModule = switchControl.isOn;

    }
}
- (NSString *)MD5:(NSString*)raw {
    
    const char * pointer = [raw UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(pointer, (CC_LONG)strlen(pointer), md5Buffer);
    
    NSMutableString *string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [string appendFormat:@"%02x",md5Buffer[i]];
    
    return string;
}
/**
 @abstrace 初始化金山云认证信息
 @discussion 开发者帐号fpzeng，其他信息如下：
 
 * appid: QYA0EEF0FDDD38C79913
 * ak: abc73bb5ab2328517415f8f52cd5ad37
 * sk: sff25dc4a428479ff1e20ebf225d113
 * sksign: md5(sk+tmsec)
 
 以上信息随时可能失效，请找金山云提供。
 
 @warning 请将appid/ak/sk信息更新至开发者自己信息，再进行编译测试
 */

- (void)initKSYAuth
{
    NSString* time = [NSString stringWithFormat:@"%d",(int)[[NSDate date]timeIntervalSince1970]];
    NSString* sk = [NSString stringWithFormat:@"sff25dc4a428479ff1e20ebf225d113%@", time];
    NSString* sksign = [self MD5:sk];
    [[KSYPlayerAuth sharedInstance]setAuthInfo:@"QYA0EEF0FDDD38C79913" accessKey:@"abc73bb5ab2328517415f8f52cd5ad37" secretKeySign:sksign timeSeconds:time];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handlePlayerNotify:(NSNotification*)notify
{
    if (!_player) {
        return;
    }
    if (MPMediaPlaybackIsPreparedToPlayDidChangeNotification ==  notify.name) {
        stat.text = [NSString stringWithFormat:@"player prepared"];
        // using autoPlay to start live stream
        //        [_player play];
        serverIp = [_player serverAddress];
        NSLog(@"%@ -- ip:%@", _url, serverIp);
        [self StartTimer];
    }
    if (MPMoviePlayerPlaybackStateDidChangeNotification ==  notify.name) {
        NSLog(@"------------------------");
        NSLog(@"player playback state: %ld", (long)_player.playbackState);
        NSLog(@"------------------------");
    }
    if (MPMoviePlayerLoadStateDidChangeNotification ==  notify.name) {
        NSLog(@"player load state: %ld", (long)_player.loadState);
        if (MPMovieLoadStateStalled & _player.loadState) {
            stat.text = [NSString stringWithFormat:@"player start caching"];
            NSLog(@"player start caching");
        }
        
        if (_player.bufferEmptyCount &&
            (MPMovieLoadStatePlayable & _player.loadState ||
             MPMovieLoadStatePlaythroughOK & _player.loadState)){
                NSLog(@"player finish caching");
                NSString *message = [[NSString alloc]initWithFormat:@"loading occurs, %d - %0.3fs",
                                     (int)_player.bufferEmptyCount,
                                     _player.bufferEmptyDuration];
                [self toast:message];
            }
    }
    if (MPMoviePlayerPlaybackDidFinishNotification ==  notify.name) {
        NSLog(@"player finish state: %ld", (long)_player.playbackState);
        NSLog(@"player download flow size: %f MB", _player.readSize);
        NSLog(@"buffer monitor  result: \n   empty count: %d, lasting: %f seconds",
              (int)_player.bufferEmptyCount,
              _player.bufferEmptyDuration);
        int reason = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
        if (reason == 0) {
            stat.text = [NSString stringWithFormat:@"player finish"];

        }else if (reason == 1){
            stat.text = [NSString stringWithFormat:@"player Error"];

        }else if (reason == 2){
            stat.text = [NSString stringWithFormat:@"player userExited"];

        }
        [self StopTimer];
    }
    if (MPMovieNaturalSizeAvailableNotification ==  notify.name) {
        NSLog(@"video size %.0f-%.0f", _player.naturalSize.width, _player.naturalSize.height);
    }
}
- (void) toast:(NSString*)message{
    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil, nil];
    [toast show];
    
    double duration = 0.5; // duration in seconds
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
}

- (void)setupObservers
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMediaPlaybackIsPreparedToPlayDidChangeNotification)
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerPlaybackStateDidChangeNotification)
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerPlaybackDidFinishNotification)
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerLoadStateDidChangeNotification)
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMovieNaturalSizeAvailableNotification)
                                              object:nil];
}

- (void)releaseObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackDidFinishNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerLoadStateDidChangeNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMovieNaturalSizeAvailableNotification
                                                 object:nil];
}
- (IBAction)onPlayVideo:(id)sender {
    if (_player) {
        if (switchLog.isOn == NO) {
            _player.shouldEnableKSYStatModule = NO;
        }
        [_player play];
        [self StartTimer];
        return;
    }
    _player = [[KSYMoviePlayerController alloc] initWithContentURL: _url];
    if (switchLog.isOn == NO) {
        _player.shouldEnableKSYStatModule = NO;
    }
    _player.logBlock = ^(NSString *logJson){
        
        NSLog(@"logJson is %@",logJson);
    };

    stat.text = [NSString stringWithFormat:@"url %@", _url];
    _player.controlStyle = MPMovieControlStyleNone;
    [_player.view setFrame: videoView.bounds];  // player's frame must match parent's
    [videoView addSubview: _player.view];
    [videoView bringSubviewToFront:stat];
    videoView.autoresizesSubviews = TRUE;
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _player.shouldAutoplay = TRUE;
//    _player.bufferTimeMax = 5;
    _player.shouldEnableVideoPostProcessing = switchVPP.on;
    _player.scalingMode = MPMovieScalingModeAspectFit;
    //_player.shouldUseHWCodec = switchHwCodec.isOn;
    //[_player setTimeout:10];
    [_player prepareToPlay];
}

- (IBAction)onReloadVideo:(id)sender {
    if (_player) {
        [_player reload:_reloadUrl];
    }
}

- (IBAction)onPauseVideo:(id)sender {
    if (_player) {
        [_player pause];
    }
}
- (IBAction)onStopVideo:(id)sender {
    if (_player) {
        NSLog(@"player download flow size: %f MB", _player.readSize);
        NSLog(@"buffer monitor  result: \n   empty count: %d, lasting: %f seconds",
              (int)_player.bufferEmptyCount,
              _player.bufferEmptyDuration);
        
        [_player stop];
        [_player.view removeFromSuperview];
        _player = nil;
        stat.text = [NSString stringWithFormat:@"url: %@\nstopped", _url];
        [self StopTimer];
    }
}

- (NSTimeInterval) getCurrentTime{
    return [[NSDate date] timeIntervalSince1970];
}

- (void)StartTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateStat:) userInfo:nil repeats:YES];
    switchVPP.enabled = NO;
}
- (void)StopTimer
{
    if (nil == timer) {
        return;
    }
    [timer invalidate];
    timer = nil;
    switchVPP.enabled = YES;
}
- (void)updateStat:(NSTimer *)t
{
    if ( 0 == lastCheckTime) {
        lastCheckTime = [self getCurrentTime];
        return;
    }
    if (nil == _player) {
        return;
    }
    double flowSize = [_player readSize];
    
    stat.text = [NSString stringWithFormat:@"%@\nip:%@ (w-h: %.0f-%.0f)\nplay time:%.1fs - %.1fs - %.1fs\ncached time:%.1fs/%ld - %.1fs\nspeed: %0.1f kbps",
                 _url,
                 serverIp, _player.naturalSize.width, _player.naturalSize.height,
                 _player.currentPlaybackTime, _player.playableDuration, _player.duration,
                 _player.bufferEmptyDuration, _player.bufferEmptyCount, _player.bufferTimeMax,
                 8*1024.0*(flowSize - lastSize)/([self getCurrentTime] - lastCheckTime)];
    lastCheckTime = [self getCurrentTime];
    lastSize = flowSize;
}

- (IBAction)onQuit:(id)sender {
    [self onStopVideo:nil];
    //[self.navigationController popToRootViewControllerAnimated:FALSE];
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPlay:
                [_player play];
                NSLog(@"play");
                break;
                
            case UIEventSubtypeRemoteControlPause:
                [_player pause];
                NSLog(@"pause");
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                
                break;
                
            default:
                break;
        }
    }
}

- (void)getQosBtnEvent
{
    KSYQosInfo *info = _player.qosInfo;
    NSLog(@"\n audioBufferByteLength is %d \n audioBufferTimeLength is %d \n audioTotalDataSize is %lld \n videoBufferByteLength is %d \n videoBufferTimeLength is %d \n  videoTotalDataSize is %lld \n totalDataSize is %lld \n",info.audioBufferByteLength,info.audioBufferTimeLength,info.audioTotalDataSize,info.videoBufferByteLength,info.videoBufferTimeLength,info.videoTotalDataSize,info.totalDataSize);
}

@end
