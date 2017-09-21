//
//  UITableView+SPHeightCache.h
//  SPTableviewHelper
//
//  Created by Tree on 2017/6/21.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+SPEasyLoading.h"

@class SPHeightCache;
@interface SPHeightCache : NSObject

// Allow Cache Clear Automatically
@property (nonatomic, assign) BOOL allowAutomaticOperation;

// Cache Output
- (CGFloat)heightCacheForIndexPath:(NSIndexPath *)indexPath;

// Cache Input
- (void)cacheHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath;

// Cache Exist
- (BOOL)cacheIsExistAtIndexPath:(NSIndexPath *)indexPath;

// Cache Clear
- (void)clearHeightCacheForIndexPath:(NSIndexPath *)indexPath;
- (void)clearAllHeigthCaches;

@end

@interface UITableView (SPHeightCache)

@property (nonatomic, strong) SPHeightCache *sp_heightCache;

@end

@interface UITableView (SPHeightCacheOperation)

- (void)sp_reloadDataWithNoCacheClearOperation;

@end
