/*
 工程名:YanTu
 文件名称:SLLaunchMoviePlayerView.m
 创建者: 李善忠 SamLee 简书关注:小王子sl 爱编程  希望代码少点bug 目标:代码手工艺者
 创建时间:16/3/14
 描述:
 */

#import "SLLaunchMoviePlayerView.h"


typedef enum __SLLaunchMoviePlayerState : char{
    SLLaunchMoviewPlayerStateStoped,
    SLLaunchMoviewPlayerStatePlaying,
    SLLaunchMoviewPlayerStatePaused
}SLLaunchMoviePlayerState;

@interface SLLaunchMoviePlayerView(){
    
    AVPlayerItem *mPlayerItem;
    id mPlayerObserver;
    CMTime mBeginTime;
    CMTime mEndTime;
    SLLaunchMoviePlayerState mState;
}

@property (nonatomic,strong)AVPlayer *mPlayer;
@property (nonatomic, strong) NSTimer *progressTimer;


@end

@implementation SLLaunchMoviePlayerView

+ (Class)layerClass{
    
    return [AVPlayerLayer class];
}

- (id)initWithFrame:(CGRect)frame asset:(AVAsset *)asset{
    
    if (self = [super initWithFrame:frame]) {
//        [self setBackgroundColor:[UIColor blackColor]];
        [self setUserInteractionEnabled:YES];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
        AVPlayerLayer *palyerLayer = (AVPlayerLayer *)[self layer];
        
        mPlayerItem = [[AVPlayerItem alloc]initWithAsset:asset];
        [mPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

        _mPlayer = [[AVPlayer alloc]initWithPlayerItem:mPlayerItem];
        [palyerLayer setContentsScale:[[UIScreen mainScreen] scale]];
        [palyerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [palyerLayer setPlayer:_mPlayer];
        
        mBeginTime = kCMTimeZero;
        mEndTime = kCMTimePositiveInfinity;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(
         DidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    return self;
}
#pragma mark - 观察者对应的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        if (AVPlayerItemStatusReadyToPlay == status) {
            [self removeProgressTimer];
            [self addProgressTimer];
        } else {
            [self removeProgressTimer];
        }
    }
}
#pragma mark - 定时器操作
- (void)addProgressTimer
{
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}

- (void)removeProgressTimer
{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}
- (void)updateProgressInfo
{
    // 1.更新时间
    NSTimeInterval duration = CMTimeGetSeconds(self.mPlayer.currentItem.duration);
    NSTimeInterval currentTime = CMTimeGetSeconds(self.mPlayer.currentTime);
    NSLog(@"%f-%f",currentTime,duration);
    if (duration<currentTime+2) {
        if ([self.delegate respondsToSelector:@selector(moviePlayerDidFinshPause:)]){

        [self.delegate moviePlayerDidFinshPause:self];
        }
        [self pause];
        [self removeProgressTimer];
    }
}
- (void)play{
    if (nil == mPlayerObserver) {
        static const CMTime kCMTimeUpdateDuration = { 250000, 1000000, kCMTimeFlags_Valid, 0 };
        __weak typeof (self)weakSelf = self;
        mPlayerObserver = [_mPlayer addPeriodicTimeObserverForInterval:kCMTimeUpdateDuration queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            __strong typeof (weakSelf)strongSelf = weakSelf;
            //DLog(@"time: %f", CMTimeGetSeconds(time));
            if (CMTIME_COMPARE_INLINE(time, >=, [mPlayerItem duration]) || CMTIME_COMPARE_INLINE(time, >=, mEndTime)) {
                
                if (SLLaunchMoviewPlayerStateStoped == mState) {
                    [strongSelf stop];
                    if ([strongSelf.delegate respondsToSelector:@selector(moviePlayerDidFinshPlaying:)]){

                    [strongSelf.delegate moviePlayerDidFinshPlaying:strongSelf];
                    }
                } else {
                    [strongSelf.mPlayer pause];
                    if (strongSelf.repeats) {
                        [strongSelf performSelector:@selector(play) withObject:nil afterDelay:0.1];
                    } else {
                        mState = SLLaunchMoviewPlayerStatePaused;
                        if ([strongSelf.delegate respondsToSelector:@selector(moviePlayerDidFinshPlaying:)]){
                            
                            [strongSelf.delegate moviePlayerDidFinshPlaying:strongSelf];
                        }                    }
                }
            }
        }];
    }
    
    [_mPlayer seekToTime:mBeginTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self _play];

}

- (void)_play{
    [_mPlayer play];
    if (AVPlayerStatusFailed== [_mPlayer status]) {
        [self stop];
    }else{
        mState = SLLaunchMoviewPlayerStatePlaying;
    }
}

- (void)pause{
    
    if (mState == SLLaunchMoviewPlayerStatePlaying) {
        [_mPlayer pause];
        mState = SLLaunchMoviewPlayerStatePaused;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}


- (void)resume{
    if (mState == SLLaunchMoviewPlayerStatePaused) {
        mState = SLLaunchMoviewPlayerStatePlaying;
        [self _play];
    }
}

- (void)stop{
    if (mPlayerObserver) {
        [_mPlayer removeTimeObserver:mPlayerObserver];
        mPlayerObserver = nil;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_mPlayer pause];
    mState = SLLaunchMoviewPlayerStateStoped;
}

- (void)playOrResume{
    if (SLLaunchMoviewPlayerStatePaused == mState) {
        [self resume];
    } else if (SLLaunchMoviewPlayerStateStoped == mState) {
        [self play];
    }
}

- (void)playAtTime:(CMTime)startTime duration:(CMTime)duration{
    if (SLLaunchMoviewPlayerStatePlaying == mState) {
        [self stop];
    }
    mBeginTime = startTime;
    mEndTime = CMTimeAdd(startTime, duration);
    [self play];
}

- (void)seekToTime:(CMTime)time {
    [_mPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}
- (void)setMuted:(BOOL)muted{
    if (_muted != muted) {
        _muted = muted;
        if (mPlayerItem) {
            [self updatedVolume];
        }
    }
}

- (void)updatedVolume {
    NSArray *audioTracks = [[mPlayerItem asset] tracksWithMediaType:AVMediaTypeAudio];
    
    NSMutableArray *audioParams = [[NSMutableArray alloc] init];
    
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        
        [audioInputParams setVolume:(_muted ? 0 : 1) atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [audioParams addObject:audioInputParams];
    }
    
    AVMutableAudioMix *audioMix = [[AVMutableAudioMix alloc] init];
    
    [audioMix setInputParameters:audioParams];
    
    [mPlayerItem setAudioMix:audioMix];
}




- (void)DidEnterBackground{
    if (SLLaunchMoviewPlayerStatePlaying == mState) {
        [_mPlayer pause];
    }
}

- (void)WillEnterForeground{
    if (SLLaunchMoviewPlayerStatePlaying == mState) {
        [_mPlayer play];
    }
}

- (BOOL)isPlaying {
    return (SLLaunchMoviewPlayerStatePlaying == mState);
}

- (BOOL)isPaused {
    return (SLLaunchMoviewPlayerStatePaused == mState);
}

- (void)releasePlayer{
    if (_mPlayer) {
        [_mPlayer.currentItem cancelPendingSeeks];
        [_mPlayer.currentItem.asset cancelLoading];

    }
}


@end
