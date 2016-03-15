/*
 工程名:YanTu
 文件名称:SLLaunchMoviePlayerView.h
 创建者: 李善忠 SamLee 简书关注:小王子sl 爱编程  希望代码少点bug 目标:代码手工艺者
 创建时间:16/3/14
 描述:
 */
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
struct CMTime;
@class AVAsset;
@class SLLaunchMoviePlayerView;

@protocol SLLaunchMoviePlayerViewDelegate <NSObject>

- (void)moviePlayerDidFinshPlaying:(SLLaunchMoviePlayerView *)moviewPlayerView;
- (void)moviePlayerDidFinshPause:(SLLaunchMoviePlayerView *)moviewPlayerView;

@end

@interface SLLaunchMoviePlayerView : UIView

@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, assign, readonly) BOOL isPaused;
@property (nonatomic, assign) BOOL repeats;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) id<SLLaunchMoviePlayerViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame asset:(AVAsset *)asset;
- (void)playAtTime:(CMTime)startTime duration:(CMTime)duration;
- (void)play;
- (void)pause;
- (void)stop;
- (void)resume;
- (void)playOrResume;
- (void)seekToTime:(CMTime)time;
- (void)releasePlayer;

@end
