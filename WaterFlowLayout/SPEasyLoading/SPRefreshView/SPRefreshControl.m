//
//  SPRefreshControl.m
//  SPLoadingSystem
//
//  Created by Tree on 2017/4/18.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "SPRefreshControl.h"
#import "SPEasyLoadingHeader.h"


@interface SPRefreshControl(){
    
    BOOL _refreshingFlag;
    BOOL _isCollectionViewFlag;
    BOOL _autoAdjustContentInset;
    
    CGPoint _originalOffsets;
    CGFloat _conditionValue;
    UIEdgeInsets _originalInsets;
    CGRect  _originalRefreshFrame;
    
}

@property (nonatomic, weak) UIScrollView *baseView;
@property (nonatomic, strong) UILabel *refreshTipLabel;
@property (nonatomic, strong) UIImageView *refreshArrowImg;
@property (nonatomic, strong) UIActivityIndicatorView *refreshIndicator;

@end

@implementation SPRefreshControl

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    
    [self.superview removeObserver:self forKeyPath:k_contentOffset];
    
    if (newSuperview) {
        self.baseView = (UIScrollView *)newSuperview;
        self.baseView.alwaysBounceVertical = YES;
        _originalRefreshFrame = self.frame;
    }
    
    if ([newSuperview isKindOfClass:[UICollectionView class]]) {
        _isCollectionViewFlag = YES;
    }
    
}

- (void)layoutSubviews{
    if (_isCollectionViewFlag) {
        self.frame = CGRectOffset(_originalRefreshFrame,
                                  -_baseView.contentInset.left,
                                  -_baseView.contentInset.top);
    }
    
    if (_refreshState == SPRefreshStateNormal ||
        _refreshState == SPRefreshStateNonAnimateRefreshing) {
        _originalInsets = _baseView.contentInset;
        _originalOffsets = _baseView.contentOffset;
        
    }
    
    [super layoutSubviews];
}

#pragma mark - kvo
- (void)setBaseView:(UITableView *)baseView{
    _baseView = baseView;
    [baseView addObserver:self forKeyPath:k_contentOffset options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
}

- (UIViewController *)getCurrentViewController:(UIView *) currentView{
    
    if ([currentView superview]) {
        for (UIView* next = [currentView superview]; next; next = next.superview){
            UIResponder *nextResponder = [next nextResponder];
            if ([nextResponder isKindOfClass:[UIViewController class]])
            {
                return (UIViewController *)nextResponder;
            }
        }
    }else{
        return (UIViewController *)[currentView nextResponder];
    }
    return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:k_contentOffset]) {
        
        //        id newChange = [change objectForKey:NSKeyValueChangeNewKey];// object for key / value for key
        //        NSString *newChangeStr = [NSString stringWithFormat:@"%@",newChange];
        //        CGPoint newPoint = CGPointFromString(newChangeStr);
        //        NSLog(@" contentoffset_Y ---> %f",newPoint.y);
        [self changeAppearanceWithBaseView:_baseView];
        
    }
    
}

- (void)changeAppearanceWithBaseView:(UIScrollView *)baseView{
    
    CGFloat contentInsetTop = baseView.contentInset.top;
    CGFloat contentOffsety = baseView.contentOffset.y;
    
    BOOL isBaseIniPhoneX = NO;
    if (baseView.frame.size.height == 812) {// iPhone X
        isBaseIniPhoneX = YES;
    }
    
    CGFloat conditionValue = - contentInsetTop - refreshControlHeight + _originalOffsets.y;
    _conditionValue = conditionValue;
    
    if (baseView.dragging)
    {
        _refreshArrowImg.hidden = NO;
        _refreshIndicator.hidden = YES;
        _refreshTipLabel.hidden = NO;
        
        if (contentOffsety <= conditionValue && _refreshState == SPRefreshStateNormal)
        {
            self.refreshState = SPRefreshStatePulling;
            NSLog(@"Pulling");
            NSLog(@"\ncontentOffsetY:%f\nconditionValue:%f",contentOffsety,conditionValue);
        }
        else if (contentOffsety > conditionValue && _refreshState == SPRefreshStatePulling)
        {
            self.refreshState = SPRefreshStateNormal;
            NSLog(@"Normal");
            NSLog(@"\ncontentOffsetY:%f\nconditionValue:%f",contentOffsety,conditionValue);
        }
        
    }
    else
    {
        if (_refreshState == SPRefreshStatePulling) {// 不拖拽则进入刷新状态
            self.refreshState = SPRefreshStateRefreshing;
            NSLog(@"Refreshing");
            NSLog(@"\ncontentOffsetY:%f\nconditionValue:%f",contentOffsety,conditionValue);
        }else{
            if (contentOffsety >= _originalOffsets.y) {
                _refreshArrowImg.hidden = YES;
                _refreshIndicator.hidden = YES;
                _refreshTipLabel.hidden = YES;
            }
            NSLog(@"Recover");
            NSLog(@"\ncontentOffsetY:%f\nconditionValue:%f",contentOffsety,conditionValue);
        }
        //        NSLog(@"contentOffset %f",contentOffsety);
    }
    //    NSLog(@"----> Intime Change <----");
    //    NSLog(@"\ncontentOffsetY:%f\nconditionValue:%f",contentOffsety,conditionValue);
}



#pragma mark - initialize ui
- (void)initialize{
    
    self.refreshIndicator.center = CGPointMake(self.bounds.size.width/2.0 - 30, self.bounds.size.height/2.0);
    self.refreshTipLabel.center = CGPointMake(self.bounds.size.width/2.0 + 10, self.bounds.size.height/2.0);
    self.refreshArrowImg.center = self.refreshIndicator.center;
    
    
    [self addSubview:_refreshArrowImg];
    [self addSubview:_refreshIndicator];
    [self addSubview:_refreshTipLabel];
    
    self.refreshState = SPRefreshStateNormal;
    
}


#pragma mark - set
- (void)setRefreshState:(SPRefreshState)refreshState{
    
    BOOL isRefreshing = refreshState == SPRefreshStateRefreshing;
    self.refreshControlisRefreshing?self.refreshControlisRefreshing(isRefreshing):nil;
    
    switch (refreshState) {
        case SPRefreshStatePulling:
        {
            _refreshingFlag = NO;
            _refreshTipLabel.text = @"松开刷新";
            _refreshArrowImg.hidden = NO;
            _refreshIndicator.hidden = YES;
            _refreshTipLabel.hidden = NO;
            [UIView animateWithDuration:0.25f animations:^{
                _refreshArrowImg.transform = CGAffineTransformMakeRotation(M_PI);
            }];
        }
            break;
        case SPRefreshStateNormal:
        {
            _refreshingFlag = NO;
            
            if (_refreshState == SPRefreshStateRefreshing ||
                _refreshState == SPRefreshStateNonAnimateRefreshing)
            {
                [UIView animateWithDuration:0.25f animations:^{
                    
                    self.baseView.contentInset = _originalInsets;
                    
                } completion:^(BOOL finished) {
                    
                    _refreshArrowImg.hidden = YES;
                    _refreshIndicator.hidden = YES;
                    _refreshTipLabel.hidden = YES;
                    _refreshTipLabel.text = @"下拉刷新";
                    _refreshArrowImg.transform = CGAffineTransformIdentity;
                    [_refreshIndicator stopAnimating];
                    
                }];
            }
            else// 初始化时 全部隐藏
            {
                _refreshArrowImg.hidden = YES;
                _refreshIndicator.hidden = YES;
                _refreshTipLabel.hidden = YES;
                _refreshTipLabel.text = @"下拉刷新";
                [_refreshIndicator stopAnimating];
                
                [UIView animateWithDuration:0.25f animations:^{
                    _refreshArrowImg.transform = CGAffineTransformIdentity;
                }];
            }
            
        }
            break;
        case SPRefreshStateRefreshing:
        {
            _refreshArrowImg.hidden = YES;
            _refreshIndicator.hidden = NO;
            _refreshTipLabel.hidden = NO;
            _refreshTipLabel.text = @"正在刷新";
            [_refreshIndicator startAnimating];
            
            
            [UIView animateWithDuration:0.25f animations:^{
                self.baseView.contentInset = UIEdgeInsetsMake(_isCollectionViewFlag?refreshControlHeight + _originalInsets.top:refreshControlHeight, _originalInsets.left, _originalInsets.bottom, _originalInsets.right);
                [self.baseView setContentOffset:CGPointMake(_originalOffsets.x, _originalOffsets.y - refreshControlHeight) animated:NO];
            }];
            if (!_refreshingFlag) {
                _refreshingFlag = YES;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            
        }
            break;
        case SPRefreshStateNonAnimateRefreshing:// 不做任何处理
        {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
            break;
    }
    
    _refreshState = refreshState;
    
}


#pragma mark - get
- (UILabel *)refreshTipLabel{
    
    if (!_refreshTipLabel) {
        _refreshTipLabel = [[UILabel alloc] init];
        _refreshTipLabel.textColor = [UIColor lightGrayColor];
        _refreshTipLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
        _refreshTipLabel.text = @"下拉刷新";
        [_refreshTipLabel sizeToFit];
    }
    return _refreshTipLabel;
}

- (UIImageView *)refreshArrowImg{
    
    if (!_refreshArrowImg) {
        _refreshArrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sp_arrow"]];
        [_refreshArrowImg sizeToFit];
    }
    return _refreshArrowImg;
}

- (UIActivityIndicatorView *)refreshIndicator{
    
    if (!_refreshIndicator) {
        _refreshIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _refreshIndicator;
}

- (void)removeFromSuperview{
    [super removeFromSuperview];
    [self.baseView removeObserver:self forKeyPath:k_contentOffset];
}


@end

