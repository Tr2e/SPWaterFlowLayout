//
//  UICollectionViewCell+FeedData.m
//  WaterFlowLayout
//
//  Created by Tree on 2017/9/18.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "UICollectionViewCell+FeedData.h"
#import <objc/runtime.h>

static NSString *AssociateKeyFeedData = @"AssociateKeyFeedData";
static NSString *AssociateKeySubFeedData = @"AssociateKeySubFeedData";
@implementation UICollectionViewCell (FeedData)
@dynamic feedData;
@dynamic subfeedData;

- (void)setFeedData:(id)feedData{
    objc_setAssociatedObject(self, &AssociateKeyFeedData, feedData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)feedData{
    return objc_getAssociatedObject(self, &AssociateKeyFeedData);
}

- (void)setSubfeedData:(id)subfeedData{
    objc_setAssociatedObject(self, &AssociateKeySubFeedData, subfeedData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)subfeedData{
    return objc_getAssociatedObject(self, &AssociateKeySubFeedData);
}

@end
