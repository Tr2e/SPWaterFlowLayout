//
//  UIScrollView+SPEasyLoading.m
//  SPScrollViewTest
//
//  Created by Tree on 2017/7/6.
//  Copyright © 2017年 TR2E. All rights reserved.
//

#import "UIScrollView+SPEasyLoading.h"
#import "SPEasyLoadingHeader.h"
#import "SPLoadMoreView.h"
#import "SPRefreshControl.h"
#import "SPBlankView.h"
#import <objc/runtime.h>

//------------ iPhone X ------------
#define DEVICE_IS_IPHONEX [UIScreen mainScreen].bounds.size.height == 812

// the strange thing is that when we use self.frame before layoutsubviews
// the value always based on 375(the width of 4.7' screen)
// so we must calculate the ratio manually to make sure the width is correct
#define SCREENRATIO [UIScreen mainScreen].bounds.size.width/375.0

static char AssociateDatasKey;
static char AssociateCanRefreshKey;
static char AssociateCanLoadMoreKey;
static char AssociateCanAutoLoadMoreKey;
static char AssociateRefreshControlKey;
static char AssociateMoreViewKey;
static char AssociatePageSizeKey;
static char AssociateRefreshDataBlockKey;
static char AssociateLoadMoreDataBlockKey;
static char AssociateLoadingStateKey;
static char AssociateBlankViewKey;
static char AssociateNeedBlankViewKey;
static char AssociateNeedBlankImgKey;
static char AssociateNeedBlankTipsKey;

@implementation UIView (SPEasyLoading)
@dynamic sp_datas;

- (NSMutableArray *)sp_datas{
    id datas = objc_getAssociatedObject(self, &AssociateDatasKey);
    if (!datas) {
        datas = [NSMutableArray array];
        objc_setAssociatedObject (self, &AssociateDatasKey,datas,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return datas;
}

- (void)setSp_datas:(NSMutableArray *)sp_datas{
    objc_setAssociatedObject (self, &AssociateDatasKey,sp_datas,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIScrollView (SPEasyLoading)

@dynamic pageSize;
@dynamic loading;
@dynamic blankView;
@dynamic canRefresh;
@dynamic canLoadMore;
@dynamic needBlankView;
@dynamic canAutoLoadMore;
@dynamic sp_loadMoreView;
@dynamic sp_refreshControl;
@dynamic refreshDataCallBack;
@dynamic loadMoreDataCallBack;
@dynamic blankImgName;
@dynamic blankTips;


#pragma mark - initialize ui
// 初始化refreshControl
- (void)initializeRefreshControl{
    
    if (!self.sp_refreshControl)
    {
        self.sp_refreshControl = [[SPRefreshControl alloc] initWithFrame:
                                  CGRectMake(0, -refreshControlHeight, self.frame.size.width, refreshControlHeight)];
        
        __weak typeof(self) ws = self;
        self.sp_refreshControl.refreshControlisRefreshing = ^(BOOL isRefreshing) {
            ws.loading = isRefreshing;
        };
        
        [self.sp_refreshControl addTarget:self action:@selector(refreshControlAction:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:self.sp_refreshControl];
    }
    
}

// 初始化loadmoreView
- (void)initializeLoadMoreView{
    
    if (!self.sp_loadMoreView) {
        
        self.sp_loadMoreView = [[SPLoadMoreView alloc] initWithFrame:
                                CGRectMake(0, self.contentSize.height, self.frame.size.width, moreViewHeight)];
        
        __weak typeof(self) ws = self;
        self.sp_loadMoreView.loadMoreisRefreshing = ^(BOOL isRefreshing) {
            ws.loading = isRefreshing;
        };
        
        self.loadMoreDataCallBack = self.sp_loadMoreView.doLoadMoreCallBack;
    
        self.sp_loadMoreView.canAutoLoadMore = self.canAutoLoadMore;
        
        [self addSubview:self.sp_loadMoreView];
        
    }
    
}

#pragma mark - action part
// action part
- (void)beginNonAnimateRefreshing{
    self.sp_refreshControl.refreshState = SPRefreshStateNonAnimateRefreshing;
}

- (void)beginAnimateRefreshing{
    self.sp_refreshControl.refreshState = SPRefreshStateRefreshing;
}

- (void)doneLoadDatas{
    self.sp_refreshControl.refreshState = SPRefreshStateNormal;
    
    // blank view
    [self handleBlankView];
    
    if (!self.sp_loadMoreView) return;
    if (self.sp_datas.count < self.pageSize)
    {
        self.sp_loadMoreView.loadMoreState = SPLoadMoreStateNonFullPage;
    }
    else
    {
        NSInteger flag = self.sp_datas.count % self.pageSize;
        if (flag)
        {
            self.sp_loadMoreView.loadMoreState = SPLoadMoreStateHasNoMore;
        }
        else
        {
            self.sp_loadMoreView.loadMoreState = SPLoadMoreStateNormal;
        }
    }
}

#pragma mark - Refresh part
// refresh call back
- (void)refreshControlAction:(SPRefreshControl *)sender{
    
    self.refreshDataCallBack?self.refreshDataCallBack():nil;
    
    // 如果存在loadmoreview 将之前的状态清空
    if (self.sp_loadMoreView)
    {
        self.sp_loadMoreView.loadMoreState = SPLoadMoreStateNormal;
    }
    
}

- (void)handleBlankView{
    
    if (!self.needBlankView) {
        return;
    }
    
    // blank view
    if (!self.sp_datas.count) {
        
        if (self.blankView) {// 防止重复添加
            return;
        }
        
        self.blankView = [[SPBlankView alloc] initWithFrame:
                          CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width)];
        if (self.blankImgName) {
            ((SPBlankView *)self.blankView).blankImgName = self.blankImgName;
        }
        if (self.blankTips) {
            ((SPBlankView *)self.blankView).blankTipString = self.blankTips;
        }
        self.blankView.center = CGPointMake(self.bounds.size.width/2.0 - self.contentInset.left, self.bounds.size.height/2.0 - self.contentInset.top - (DEVICE_IS_IPHONEX?88:64));
        [self addSubview:self.blankView];
        
    }else{
        self.blankView.hidden = YES;
        [self.blankView removeFromSuperview];
        self.blankView = nil;
    }
}

- (void)showBlankViewWithLoading:(BOOL)loading{
    if (loading && self.blankView && self.needBlankView) {
        self.blankView.hidden = YES;
        [self.blankView removeFromSuperview];
        self.blankView = nil;
    }
}

#pragma mark - get/set
- (void)setCanLoadMore:(BOOL)loadMore{
    objc_setAssociatedObject (self, &AssociateCanLoadMoreKey,@(loadMore),OBJC_ASSOCIATION_ASSIGN);
    if (loadMore) {
        [self initializeLoadMoreView];
    }else{
        self.sp_loadMoreView = nil;
    }
}



- (BOOL)canLoadMore{
    return [objc_getAssociatedObject(self, &AssociateCanLoadMoreKey) boolValue];
}

- (void)setCanAutoLoadMore:(BOOL)canAutoLoadMore{
    objc_setAssociatedObject (self, &AssociateCanAutoLoadMoreKey,@(canAutoLoadMore),OBJC_ASSOCIATION_ASSIGN);
    if (!self.canLoadMore) {
        self.canLoadMore = YES;
    }
}

- (BOOL)canAutoLoadMore{
    return objc_getAssociatedObject(self, &AssociateCanAutoLoadMoreKey);
}

- (void)setCanRefresh:(BOOL)canRefresh{
    objc_setAssociatedObject (self, &AssociateCanRefreshKey,@(canRefresh),OBJC_ASSOCIATION_ASSIGN);
    if (canRefresh) {
        [self initializeRefreshControl];
    }else {
        self.refreshControl = nil;
    }
}

- (BOOL)canRefresh{
    return [objc_getAssociatedObject(self, &AssociateCanRefreshKey) boolValue];
}

- (void)setLoading:(BOOL)loading{
    [self showBlankViewWithLoading:loading];
    objc_setAssociatedObject(self, &AssociateLoadingStateKey, @(loading), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)loading{
    return [objc_getAssociatedObject(self, &AssociateLoadingStateKey) boolValue];
}


- (void)setRefreshDataCallBack:(dispatch_block_t)refreshDataCallBack{
    objc_setAssociatedObject (self, &AssociateRefreshDataBlockKey,refreshDataCallBack,OBJC_ASSOCIATION_COPY);
}

- (dispatch_block_t)refreshDataCallBack{
    return objc_getAssociatedObject(self,&AssociateRefreshDataBlockKey);
}

- (void)setLoadMoreDataCallBack:(dispatch_block_t)loadMoreDataCallBack{
    objc_setAssociatedObject (self, &AssociateLoadMoreDataBlockKey,loadMoreDataCallBack,OBJC_ASSOCIATION_COPY);
    SPLoadMoreView *moreView = objc_getAssociatedObject(self, &AssociateMoreViewKey);
    if (moreView) {
        moreView.doLoadMoreCallBack = loadMoreDataCallBack;
    }
}

- (dispatch_block_t)loadMoreDataCallBack{
    return objc_getAssociatedObject(self,&AssociateLoadMoreDataBlockKey);
}


- (void)setSp_refreshControl:(SPRefreshControl *)sp_refreshControl{
    objc_setAssociatedObject (self, &AssociateRefreshControlKey,sp_refreshControl,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SPRefreshControl *)sp_refreshControl{
    return objc_getAssociatedObject(self, &AssociateRefreshControlKey) ;
}

- (SPLoadMoreView *)sp_loadMoreView{
    id moreView = objc_getAssociatedObject(self, &AssociateMoreViewKey);
    return moreView;
}

- (void)setSp_loadMoreView:(SPLoadMoreView *)sp_loadMoreView{
    objc_setAssociatedObject (self, &AssociateMoreViewKey,sp_loadMoreView,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPageSize:(NSInteger)pageSize{
    objc_setAssociatedObject (self, &AssociatePageSizeKey,@(pageSize),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)pageSize{
    NSInteger size = [objc_getAssociatedObject(self, &AssociatePageSizeKey) integerValue];
    return size;
}

- (void)setBlankView:(UIView *)blankView{
    objc_setAssociatedObject(self, &AssociateBlankViewKey, blankView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)blankView{
    UIView *blankView = objc_getAssociatedObject(self, &AssociateBlankViewKey);
    return blankView;
}

- (void)setNeedBlankView:(BOOL)needBlankView{
    objc_setAssociatedObject (self, &AssociateNeedBlankViewKey,@(needBlankView),OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)needBlankView{
    return [objc_getAssociatedObject(self, &AssociateNeedBlankViewKey) boolValue];
}

- (void)setBlankTips:(NSString *)blankTips{
    objc_setAssociatedObject(self, &AssociateNeedBlankTipsKey, blankTips, OBJC_ASSOCIATION_COPY);
}

- (NSString *)blankTips{
    return objc_getAssociatedObject(self, &AssociateNeedBlankTipsKey);
}

- (void)setBlankImgName:(NSString *)blankImgName{
    objc_setAssociatedObject(self, &AssociateNeedBlankImgKey, blankImgName, OBJC_ASSOCIATION_COPY);
}

- (NSString *)blankImgName{
    return objc_getAssociatedObject(self, &AssociateNeedBlankImgKey);
}

@end
