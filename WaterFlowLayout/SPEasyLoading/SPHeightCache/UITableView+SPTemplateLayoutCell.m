//
//  UITableView+SPTemplateLayoutCell.m
//  SPTableviewHelper
//
//  Created by Tree on 2017/6/22.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "UITableView+SPTemplateLayoutCell.h"
#import <objc/runtime.h>

static char AssociateTemplateCellDictionaryKey;
typedef NSMutableDictionary<NSString *,UITableViewCell *> SPTemplateCellDictionary;

@implementation UITableView (SPTemplateLayoutCell)

- (CGFloat)sp_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(id))configCell{
    NSAssert(identifier.length>0, @"must use an correct identifier to calculate the height");
    if (!identifier) return 0;
    
    UITableViewCell *templateLayoutCell = [self sp_templateCellForReuseIdentifier:identifier];
    [templateLayoutCell prepareForReuse];
    
    if (configCell) {
        configCell(templateLayoutCell);
    }
    
    return [self sp_systemCalculateCellHeightForTemplateCell:templateLayoutCell];
}

- (CGFloat)sp_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configCell{

    if ([self.sp_heightCache cacheIsExistAtIndexPath:indexPath]) {
        NSLog(@"height from cache");
        return [self.sp_heightCache heightCacheForIndexPath:indexPath];
    }
    
    CGFloat height = [self sp_heightForCellWithIdentifier:identifier configuration:configCell];
    [self.sp_heightCache cacheHeight:height forIndexPath:indexPath];
    NSLog(@"height from calculating");
    
    return height;
    
}

- (CGFloat)sp_systemCalculateCellHeightForTemplateCell:(UITableViewCell *)cell{
    CGFloat contentWidth = CGRectGetWidth(cell.frame);
    
    CGRect cellbounds = cell.bounds;
    cellbounds.size.width = contentWidth;
    cell.bounds = cellbounds;
    
    CGFloat accessoryWidth = 0;
    if (cell.accessoryView) {
        accessoryWidth = 16 + CGRectGetWidth(cell.accessoryView.frame);
    }else{
        static const CGFloat systemAccessoryWidths[] = {
            [UITableViewCellAccessoryNone] = 0,
            [UITableViewCellAccessoryDisclosureIndicator] = 34,
            [UITableViewCellAccessoryDetailDisclosureButton] = 68,
            [UITableViewCellAccessoryCheckmark] = 40,
            [UITableViewCellAccessoryDetailButton] = 48
        };
        accessoryWidth = systemAccessoryWidths[cell.accessoryType];
    }
    contentWidth -= accessoryWidth;
    
    CGFloat calculateHeight = 0;
    if (contentWidth > 0) {
        NSLayoutConstraint *widthForceConstant = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentWidth];
        
        static BOOL isSystemVersionEqualOrGreaterThen10_2 = NO;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            isSystemVersionEqualOrGreaterThen10_2 = [UIDevice.currentDevice.systemVersion compare:@"10.2" options:NSNumericSearch] != NSOrderedAscending;
        });
        
        NSArray<NSLayoutConstraint *> *edgeConstraints;
        if (isSystemVersionEqualOrGreaterThen10_2) {
            // To avoid conflicts, make width constraint softer than required (1000)
            widthForceConstant.priority = UILayoutPriorityRequired - 1;
            
            // Build edge constraints
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
            NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:accessoryWidth];
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            edgeConstraints = @[leftConstraint, rightConstraint, topConstraint, bottomConstraint];
            [cell addConstraints:edgeConstraints];
        }
        
        // system calculate
        [cell.contentView addConstraint:widthForceConstant];
        calculateHeight = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        // clear constraint
        [cell.contentView removeConstraint:widthForceConstant];
        if (isSystemVersionEqualOrGreaterThen10_2) {
            [cell removeConstraints:edgeConstraints];
        }
    }
    
    if (calculateHeight == 0) {
        calculateHeight = 44;
    }
    
    if (self.separatorStyle != UITableViewCellSeparatorStyleNone) {
        calculateHeight += 1.0/[UIScreen mainScreen].scale;
    }
    
    return calculateHeight;
}

- (UITableViewCell *)sp_templateCellForReuseIdentifier:(NSString *)identifier{
    
    SPTemplateCellDictionary *templateCellDictionary = [self sp_templateCellDictionary];
    
    UITableViewCell *templateCell = templateCellDictionary[identifier];
    if (!templateCell) {
        templateCell = [self dequeueReusableCellWithIdentifier:identifier];
        templateCell.sp_isTemplateLayoutCell = YES;
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [templateCellDictionary setObject:templateCell forKey:identifier];
    }
    
    return templateCell;
}

- (SPTemplateCellDictionary *)sp_templateCellDictionary{
    SPTemplateCellDictionary *dict = objc_getAssociatedObject(self, &AssociateTemplateCellDictionaryKey);
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &AssociateTemplateCellDictionaryKey, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dict;
}

@end

static char AssociateIsTemplateLayoutCellKey;
@implementation UITableViewCell (SPTemplateLayoutCell)
@dynamic sp_isTemplateLayoutCell;

- (void)setSp_isTemplateLayoutCell:(BOOL)sp_isTemplateLayoutCell{
    objc_setAssociatedObject(self, &AssociateIsTemplateLayoutCellKey, @(sp_isTemplateLayoutCell), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)sp_isTemplateLayoutCell{
    return ((NSNumber *)objc_getAssociatedObject(self, &AssociateIsTemplateLayoutCellKey)).boolValue;
}

@end

