//
//  SPLoadMoreView.h
//  SPLoadingSystem
//
//  Created by Tree on 2017/4/17.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,SPLoadMoreState) {

    SPLoadMoreStateNormal = 1,
    SPLoadMoreStateRefreshing,
    SPLoadMoreStateHasNoMore,
    SPLoadMoreStateNonFullPage
    
};


@interface SPLoadMoreView : UIView

// default is '显示更多...'
@property (nonatomic, copy) NSString *noMoreString;

// default is '-End-'
@property (nonatomic, copy) NSString *moreString;

// if it's YES,when scroll view scroll to bottom
// change to RefreshingState automatically
// default is NO
@property (nonatomic, assign) BOOL canAutoLoadMore;

// when the state is Refreshing,call this block automatically
@property (nonatomic, copy) dispatch_block_t doLoadMoreCallBack;

// current state
@property (nonatomic, assign) SPLoadMoreState loadMoreState;

// call this block to change the view's loading property
@property (nonatomic, copy) void(^loadMoreisRefreshing)(BOOL isRefreshing);

@end
