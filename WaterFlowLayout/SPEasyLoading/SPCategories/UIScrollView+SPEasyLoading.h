//
//  UIScrollView+SPEasyLoading.h
//  SPScrollViewTest
//
//  Created by Tree on 2017/7/6.
//  Copyright © 2017年 TR2E. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPLoadMoreView;
@class SPRefreshControl;

@interface UIView (SPEasyLoading)
@property (nonatomic, strong) NSMutableArray *sp_datas;
@end

@interface UIScrollView (SPEasyLoading)

// load part
@property (nonatomic, strong) SPLoadMoreView *sp_loadMoreView;
@property (nonatomic, strong) SPRefreshControl *sp_refreshControl;

// blank part
@property (nonatomic, assign) BOOL needBlankView;// default is NO
@property (nonatomic, strong) UIView *blankView;
@property (nonatomic, copy) NSString *blankImgName;
@property (nonatomic, copy) NSString *blankTips;

// data part
@property (nonatomic, assign) NSInteger pageSize;

// call back
@property (nonatomic, copy) dispatch_block_t loadMoreDataCallBack;
@property (nonatomic, copy) dispatch_block_t refreshDataCallBack;

// current loading state
@property (nonatomic, assign) BOOL loading;

// pull to refresh, default is NO
@property (nonatomic, assign) BOOL canRefresh;

// push to refresh, default is NO
@property (nonatomic, assign) BOOL canLoadMore;
// push to refresh, when scroll to bottom,load more automatically,default is NO
@property (nonatomic, assign) BOOL canAutoLoadMore;

// action part
- (void)beginNonAnimateRefreshing;
- (void)beginAnimateRefreshing;
- (void)doneLoadDatas;

@end

