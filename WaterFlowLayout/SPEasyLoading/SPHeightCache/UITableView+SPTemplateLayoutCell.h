//
//  UITableView+SPTemplateLayoutCell.h
//  SPTableviewHelper
//
//  Created by Tree on 2017/6/22.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+SPHeightCache.h"

@interface UITableView (SPTemplateLayoutCell)

- (CGFloat)sp_heightForCellWithIdentifier:(NSString *)identifier configuration:(void(^)(id cell))configCell;
- (CGFloat)sp_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configCell;
- (CGFloat)sp_systemCalculateCellHeightForTemplateCell:(UITableViewCell *)cell;


@end

@interface UITableViewCell (SPTemplateLayoutCell)

@property (nonatomic, assign) BOOL sp_isTemplateLayoutCell;

@end
