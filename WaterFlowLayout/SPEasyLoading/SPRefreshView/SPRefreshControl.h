//
//  SPRefreshControl.h
//  SPLoadingSystem
//
//  Created by Tree on 2017/4/18.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,SPRefreshState) {
    
    SPRefreshStatePulling = 1,
    SPRefreshStateNormal,
    SPRefreshStateRefreshing,
    SPRefreshStateNonAnimateRefreshing
    
};



@interface SPRefreshControl : UIControl

// current state
@property (nonatomic, assign) SPRefreshState refreshState;

// call this block to change the view's loading property
@property (nonatomic, copy) void(^refreshControlisRefreshing)(BOOL isRefreshing);

@end
