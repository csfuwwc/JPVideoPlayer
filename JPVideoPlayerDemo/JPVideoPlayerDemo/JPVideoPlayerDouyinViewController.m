/*
 * This file is part of the JPVideoPlayer package.
 * (c) NewPan <13246884282@163.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * Click https://github.com/newyjp
 * or http://www.jianshu.com/users/e2f2d779c022/latest_articles to contact me.
 */

#import "JPVideoPlayerDouyinViewController.h"
#import "JPVideoPlayerKit.h"

@interface JPDouyinProgressView: JPVideoPlayerProgressView

@end

@implementation JPDouyinProgressView

- (void)layoutThatFits:(CGRect)constrainedRect
nearestViewControllerInViewTree:(UIViewController *_Nullable)nearestViewController
  interfaceOrientation:(JPVideoPlayViewInterfaceOrientation)interfaceOrientation {
    [super layoutThatFits:constrainedRect
nearestViewControllerInViewTree:nearestViewController
            interfaceOrientation:interfaceOrientation];

    self.trackProgressView.frame = CGRectMake(0,
            constrainedRect.size.height - JPVideoPlayerProgressViewElementHeight - nearestViewController.tabBarController.tabBar.bounds.size.height,
            constrainedRect.size.width,
            JPVideoPlayerProgressViewElementHeight);
    self.cachedProgressView.frame = self.trackProgressView.bounds;
    self.elapsedProgressView.frame = self.trackProgressView.frame;
}

@end

@interface JPVideoPlayerDouyinViewController()<UIScrollViewDelegate, JPVideoPlayerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *firstImageView;

@property (nonatomic, strong) UIImageView *secondImageView;

@property (nonatomic, strong) UIImageView *thridImageView;

@property (nonatomic, strong) NSArray<NSString *> *douyinVideoStrings;

@property(nonatomic, assign) NSUInteger currentVideoIndex;

@property(nonatomic, assign) CGFloat scrollViewOffsetYOnStartDrag;

@end

@implementation JPVideoPlayerDouyinViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.contentInset = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.scrollViewOffsetYOnStartDrag = -100;
    [self scrollViewDidEndScrolling];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.secondImageView jp_stopPlay];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self scrollViewDidEndScrolling];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDidEndScrolling];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.scrollViewOffsetYOnStartDrag = scrollView.contentOffset.y;
}


#pragma mark - JPVideoPlayerDelegate

- (BOOL)shouldShowBlackBackgroundBeforePlaybackStart {
    return YES;
}

#pragma mark - Private

- (void)scrollViewDidEndScrolling {
    if(self.scrollViewOffsetYOnStartDrag == self.scrollView.contentOffset.y){
        return;
    }

    CGSize referenceSize = UIScreen.mainScreen.bounds.size;
    [self.scrollView setContentOffset:CGPointMake(0, referenceSize.height) animated:NO];
    [self.secondImageView jp_stopPlay];
    [self.secondImageView jp_playVideoMuteWithURL:[self fetchDouyinURL]
                               bufferingIndicator:nil
                                     progressView:[JPDouyinProgressView new]
                          configurationCompletion:^(UIView *view, JPVideoPlayerModel *playerModel) {
                              view.jp_muted = NO;
                          }];
}

- (NSURL *)fetchDouyinURL {
    if(self.currentVideoIndex == (self.douyinVideoStrings.count - 1)){
        self.currentVideoIndex = 0;
    }
    NSURL *url = [NSURL URLWithString:self.douyinVideoStrings[self.currentVideoIndex]];
    self.currentVideoIndex++;
    return url;
}

- (NSArray<NSString *> *)douyinVideoStrings {
    if(!_douyinVideoStrings){
        _douyinVideoStrings = @[
                @"https://www.apple.com/105/media/cn/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-cn-20170912_1280x720h.mp4",
                @"https://static.smartisanos.cn/common/video/smartisan-tnt.mp4",
                @"https://static.smartisanos.cn/common/video/video-jgpro.mp4",
                @"https://static.smartisanos.cn/common/video/m1-coffee.mp4",
                @"https://static.smartisanos.cn/common/video/m1-white.mp4",
                @"https://static.smartisanos.cn/common/video/smartisanT2.mp4",
                @"https://static.smartisanos.cn/common/video/smartisant1.mp4 https://static.smartisanos.cn/common/video/ammounition-video.mp4",
                @"https://static.smartisanos.cn/common/video/t1-ui.mp4"
        ];
    }
    return _douyinVideoStrings;
}


#pragma mark - Setup

- (void)setup {
    self.view.backgroundColor = [UIColor whiteColor];
    CGSize referenceSize = UIScreen.mainScreen.bounds.size;
    self.currentVideoIndex = 0;

    self.scrollView = ({
        UIScrollView *scrollView = [UIScrollView new];
        scrollView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:scrollView];
        scrollView.frame = self.view.bounds;
        scrollView.contentSize = CGSizeMake(referenceSize.width, referenceSize.height * 3);
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;

        scrollView;
    });

    self.firstImageView = ({
        UIImageView *imageView = [UIImageView new];
        [self.scrollView addSubview:imageView];
        imageView.frame = CGRectMake(0, 0, referenceSize.width, referenceSize.height);
        imageView.image = [UIImage imageNamed:@"placeholder1"];

        imageView;
    });

    self.secondImageView = ({
        UIImageView *imageView = [UIImageView new];
        [self.scrollView addSubview:imageView];
        imageView.frame = CGRectMake(0, referenceSize.height, referenceSize.width, referenceSize.height);
        imageView.image = [UIImage imageNamed:@"placeholder2"];
        imageView.jp_videoPlayerDelegate = self;

        imageView;
    });

    self.thridImageView = ({
        UIImageView *imageView = [UIImageView new];
        [self.scrollView addSubview:imageView];
        imageView.frame = CGRectMake(0, referenceSize.height * 2, referenceSize.width, referenceSize.height);
        imageView.image = [UIImage imageNamed:@"placeholder1"];

        imageView;
    });
}

@end
