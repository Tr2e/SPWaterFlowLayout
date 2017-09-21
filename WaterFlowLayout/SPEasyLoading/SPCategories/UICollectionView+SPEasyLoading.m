//
//  UICollectionView+SPEasyLoading.m
//  SPScrollViewTest
//
//  Created by Tree on 2017/7/6.
//  Copyright © 2017年 TR2E. All rights reserved.
//

#import "UICollectionView+SPEasyLoading.h"
#import "SPLoadMoreView.h"
#import "SPBlankView.h"
#import <objc/runtime.h>
#import "SPEasyLoadingHeader.h"

@implementation UICollectionView (SPEasyLoading)

void sp_collectionView_instanceMethod_Swizzle(Class c,SEL orig,SEL news){
    
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, news);
    
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, news, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
    
}


+ (void)load{
    sp_collectionView_instanceMethod_Swizzle(self, @selector(reloadData), @selector(sp_collectionView_reloadData));
    sp_collectionView_instanceMethod_Swizzle(self, @selector(reloadSections:), @selector(sp_collectionView_reloadSections:));
}

- (void)sp_dealloc{
    [self sp_dealloc];
    if (self.canRefresh) {
        [self removeObserver:self forKeyPath:k_contentOffset];
    }
    if (self.canLoadMore) {
        [self removeObserver:self forKeyPath:k_contentSize];
    }
}

- (void)sp_collectionView_reloadData{
    [self sp_collectionView_reloadData];
    
    // more view
    if (self.pageSize != 0)
    {
        if (self.sp_datas.count < self.pageSize)
        {
            [self showMoreView:NO];
        }
        else
        {
            [self showMoreView:YES];
        }
    }
    
}

- (void)sp_collectionView_reloadSections:(NSIndexSet *)sections{
    [self sp_collectionView_reloadSections:sections];
    
    // more view
    if (self.pageSize != 0)
    {
        if (self.sp_datas.count < self.pageSize)
        {
            [self showMoreView:NO];
        }
        else
        {
            [self showMoreView:YES];
        }
    }
    
}

- (void)showMoreView:(BOOL) show{
    
    if (!self.canLoadMore) return;
    self.sp_loadMoreView.hidden = !show;
    
}

@end
