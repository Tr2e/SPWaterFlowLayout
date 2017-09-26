//
//  SPLoadMoreView.m
//  SPLoadingSystem
//
//  Created by Tree on 2017/4/17.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "SPLoadMoreView.h"
#import "SPEasyLoadingHeader.h"

@interface SPLoadMoreView(){
    
    BOOL _refreshingFlag;
    BOOL _isCollectionViewFlag;
    
    CGPoint _originalOffsets;
    CGFloat _conditionValue;
    UIEdgeInsets _originalInsets;
    CGRect  _originalRefreshFrame;
    
}

@property (nonatomic, weak) UIScrollView *baseView;
@property (nonatomic, strong) UIButton *loadBtn;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation SPLoadMoreView

- (instancetype) initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame])
    {
        [self initializeMainViewWithFrame:frame];
    }
    
    return self;

}


- (void)initializeMainViewWithFrame:(CGRect)frame{
    
    // load more btn
    self.loadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loadBtn.frame = CGRectMake(0, 0, frame.size.width-20, moreViewHeight);
    _loadBtn.center = self.center;
    _loadBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_loadBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_loadBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [_loadBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_loadBtn addTarget:self action:@selector(loadMoreAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    // activity
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.center = CGPointMake(frame.size.width - 25, _loadBtn.center.y);
    
    // tip
    self.moreString = _moreString.length?_moreString:@"显示更多...";
    
    // init state
    self.loadMoreState = SPLoadMoreStateNormal;
    
    //
    [self addSubview:_loadBtn];
    [self addSubview:_activityView];
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    
    [self.superview removeObserver:self forKeyPath:k_contentSize];
    if (_canAutoLoadMore) {
        [self.superview removeObserver:self forKeyPath:k_contentOffset];
    }
    
    if (newSuperview) {
        self.baseView = (UIScrollView *)newSuperview;
    }
    
    if ([newSuperview isKindOfClass:[UICollectionView class]]) {
        _isCollectionViewFlag = YES;
    }

}

- (void)layoutSubviews{
    
    if (_isCollectionViewFlag){
        
        self.frame = CGRectOffset(_originalRefreshFrame,
                                  -_baseView.contentInset.left,
                                  0);
    }
    
    if(_loadMoreState == SPLoadMoreStateNormal)
    {
        _originalInsets = _baseView.contentInset;
        _originalOffsets = _baseView.contentOffset;
        
        UIEdgeInsets targetInset = UIEdgeInsetsMake(_originalInsets.top, _originalInsets.left, moreViewHeight, _originalInsets.right);
        _originalInsets = targetInset;
        
        _baseView.contentInset = targetInset;
        
        NSLog(@"loadmore content inset top:%f bottom:%f",_originalInsets.top,_originalInsets.bottom);
    }
    
    [super layoutSubviews];
}

#pragma mark - kvo
- (void)setBaseView:(UIScrollView *)baseView{
    _baseView = baseView;
    [baseView addObserver:self forKeyPath:k_contentSize options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    if (_canAutoLoadMore) {
        [baseView addObserver:self forKeyPath:k_contentOffset options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:k_contentSize]) {
//        
//        id newChange = [change objectForKey:NSKeyValueChangeNewKey];// object for key / value for key
//        NSString *newChangeStr = [NSString stringWithFormat:@"%@",newChange];
//        CGSize contentSize = CGSizeFromString(newChangeStr);
//        NSLog(@"contentSize height---> %f",contentSize.height);
        [self changeLocationWithBaseView:_baseView];
        
    }
    
    if ([keyPath isEqualToString:k_contentOffset]) {
        
        [self changeAppearanceWithBaseView:_baseView];

    }
    
}

- (void)changeLocationWithBaseView:(UIScrollView *)baseView{

    CGFloat contentSizeHeight = baseView.contentSize.height;
    _originalRefreshFrame = self.frame = CGRectMake(self.frame.origin.x, contentSizeHeight, self.frame.size.width, self.frame.size.height);
    
}

- (void)changeAppearanceWithBaseView:(UIScrollView *)baseView{
    
    CGPoint contentOffset = baseView.contentOffset;
    CGFloat contentSizeHeight = baseView.contentSize.height + moreViewHeight;// canLoadmore时设置了inset
    
    if (contentOffset.y + _baseView.frame.size.height > contentSizeHeight) {
        if (baseView.isDragging && baseView.isDecelerating && !_refreshingFlag) {
            self.loadMoreState = SPLoadMoreStateRefreshing;
        }
    }
    
}

#pragma mark - Actions
- (void)loadMoreAction{
    self.loadMoreState = SPLoadMoreStateRefreshing;
}

#pragma mark - Properties

- (void)setCanAutoLoadMore:(BOOL)canAutoLoadMore{
    _canAutoLoadMore = canAutoLoadMore;
}

- (void)setLoadMoreState:(SPLoadMoreState)loadMoreState{
    
    BOOL isRefreshing = loadMoreState == SPLoadMoreStateRefreshing;
    self.loadMoreisRefreshing?self.loadMoreisRefreshing(isRefreshing):nil;
    if(loadMoreState == _loadMoreState) return;
    _loadMoreState = loadMoreState;
    [self updateAppearanceWithState:loadMoreState];
}

- (void)updateAppearanceWithState:(SPLoadMoreState)state{
    
    if (state == SPLoadMoreStateNonFullPage)
    {
        _refreshingFlag = NO;
        
        _loadBtn.hidden = YES;
        [_activityView stopAnimating];
        return;
    }
    
    _loadBtn.hidden = NO;
    
    if (state == SPLoadMoreStateRefreshing)
    {
        _refreshingFlag = YES;
        
        _loadBtn.enabled = NO;
        [UIView setAnimationsEnabled:NO];
        [_loadBtn setTitle:@"正在加载..." forState:UIControlStateNormal];
        [_loadBtn layoutIfNeeded];
        [UIView setAnimationsEnabled:YES];
        [_activityView startAnimating];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25f];
        _baseView.contentInset = _originalInsets;
        [UIView commitAnimations];
        
        // 获取更多数据时回调
        self.doLoadMoreCallBack?self.doLoadMoreCallBack():nil;
        
    }
    else if (state == SPLoadMoreStateNormal)
    {
        _refreshingFlag = NO;
        
        _loadBtn.enabled = YES;
        [UIView setAnimationsEnabled:NO];
        [_loadBtn setTitle:_moreString forState:UIControlStateNormal];
        [_loadBtn layoutIfNeeded];
        [UIView setAnimationsEnabled:YES];
        [_activityView stopAnimating];
        
    }
    else if (state == SPLoadMoreStateHasNoMore)
    {
        _refreshingFlag = YES;
        
        _loadBtn.enabled = NO;
        [UIView setAnimationsEnabled:NO];
        [_loadBtn setTitle:_noMoreString?_noMoreString:@"-End-"  forState:UIControlStateNormal];
        [_loadBtn layoutIfNeeded];
        [UIView setAnimationsEnabled:YES];
        [_activityView stopAnimating];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25f];
        _baseView.contentInset = _originalInsets;
        [UIView commitAnimations];
        
    }
    
}

- (void)dealloc{
    [self.baseView removeObserver:self forKeyPath:k_contentSize];
}

@end
