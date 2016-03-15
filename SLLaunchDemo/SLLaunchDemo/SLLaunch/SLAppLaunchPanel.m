/*
 工程名:YanTu
 文件名称:SLAppLaunchPanel.m
 创建者: 李善忠 SamLee 简书关注:小王子sl 爱编程  希望代码少点bug 目标:代码手工艺者
 创建时间:16/3/14
 描述:
 */

#import "SLAppLaunchPanel.h"
#import "SLLaunchMoviePlayerView.h"

static SLAppLaunchPanel *appLaunchPanel = nil;

@interface SLAppLaunchPanel()<SLLaunchMoviePlayerViewDelegate>
@property (nonatomic, strong) SLLaunchMoviePlayerView *playView;
@property (nonatomic, strong) AVURLAsset *urlAsset;

@end
@implementation SLAppLaunchPanel
+ (void)displayAppLaunchPanel{
    if (appLaunchPanel == nil) {
        appLaunchPanel = [[SLAppLaunchPanel alloc] init];
        appLaunchPanel.backgroundColor = [UIColor whiteColor];
        appLaunchPanel.rootViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    }
    [appLaunchPanel show];
}

#pragma mark - life cycle
- (id)init
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"begin_movie" withExtension:@"mp4"];
        NSDictionary *opts = [[NSDictionary alloc] initWithObjectsAndKeys:@YES, AVURLAssetPreferPreciseDurationAndTimingKey, nil];
        AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:url options:opts];
        _urlAsset = urlAsset;
            _playView = [[SLLaunchMoviePlayerView alloc] initWithFrame:self.frame asset:urlAsset];
            _playView.repeats = NO;
        _playView.delegate = self;
        [self addSubview:_playView];
    }
    return self;
}

- (void)moviePlayerDidFinshPlaying:(SLLaunchMoviePlayerView *)moviewPlayerView{
    
}

- (void)moviePlayerDidFinshPause:(SLLaunchMoviePlayerView *)moviewPlayerView{
    __weak typeof (self)weakSelf = self;

    [UIView animateWithDuration:0.8 animations:^{
        
        moviewPlayerView.alpha = 0.9;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
            __strong typeof (weakSelf)strongSelf = weakSelf;

            [strongSelf setX:-CGRectGetWidth([UIScreen mainScreen].bounds)];

        } completion:^(BOOL finished) {
            __strong typeof (weakSelf)strongSelf = weakSelf;

            [moviewPlayerView releasePlayer];
            [moviewPlayerView removeFromSuperview];
            [strongSelf removeFromSuperview];
        }];
    }];

}
- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)show
{
    [_playView playOrResume];
    [self setHidden:NO];
}

@end
