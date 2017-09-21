//
//  SPWaterFlowLayout.m
//  WaterFlowLayout
//
//  Created by Tree on 2017/9/6.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "SPWaterFlowLayout.h"
#import "UICollectionViewCell+FeedData.h"

struct SPColumnInfo
{
    NSInteger columnNumber;
    CGFloat columnHeight;
};


@interface SPWaterFlowLayout()
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributesArray;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *columnHeightArray;// 每列的总高度
@property (nonatomic, strong) NSMutableArray<NSValue *> *itemSizeArray;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) UIEdgeInsets viewInset;

@property (nonatomic, strong) UICollectionViewCell *templateCell;

@end

@implementation SPWaterFlowLayout

- (void)prepareLayout{
    [super prepareLayout];
    NSInteger column = self.columnNumber;
    CGFloat contentWidth = self.collectionView.bounds.size.width - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
    CGFloat itemSpace = self.interitemSpacing;
    CGFloat itemWidth = ( contentWidth -  (column - 1) * itemSpace ) / column;
    self.itemWidth = itemWidth;
    self.viewInset = self.collectionView.contentInset;
    [self calculateAttributesWithItemWidth:itemWidth];
}

#pragma mark - Calculation Part
- (void)calculateAttributesWithItemWidth:(CGFloat)itemWidth{
    BOOL isRefresh = self.datas.count <= self.pageSize;
    if (isRefresh) {
        [self refreshLayoutCache];
    }
    NSInteger cacheCount = self.itemSizeArray.count;
    for (NSInteger i = cacheCount; i < self.datas.count; i ++) {
        CGSize itemSize = [self calculateItemSizeWithIndex:i];
        UICollectionViewLayoutAttributes *layoutAttributes = [self createLayoutAttributesWithItemSize:itemSize index:i];
        [self.itemSizeArray addObject:[NSValue valueWithCGSize:itemSize]];
        [self.layoutAttributesArray addObject:layoutAttributes];
    }
}

- (UICollectionViewLayoutAttributes *)createLayoutAttributesWithItemSize:(CGSize)itemSize index:(NSInteger)index{
    UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    struct SPColumnInfo shortestInfo = [self shortestColumn:self.columnHeightArray];
    // x
    CGFloat itemX = (self.itemWidth + self.interitemSpacing) * shortestInfo.columnNumber;
    // y
    CGFloat itemY = self.columnHeightArray[shortestInfo.columnNumber].floatValue + self.lineSpacing;
    // size
    layoutAttributes.frame = (CGRect){CGPointMake(itemX, itemY),itemSize};
    self.columnHeightArray[shortestInfo.columnNumber] = @(CGRectGetMaxY(layoutAttributes.frame));
    return layoutAttributes;
}

- (CGSize)calculateItemSizeWithIndex:(NSInteger)index{
    NSAssert(index < self.datas.count, @"index is incorrect");
    UICollectionViewCell *tempCell = [self templateCellWithReuseIdentifier:self.reuseIdentifier withIndex:index];
    tempCell.feedData = self.datas[index];
    CGFloat cellHeight = [self systemCalculateHeightForTemplateCell:tempCell];
    return CGSizeMake(self.itemWidth, cellHeight);
}

- (CGFloat)systemCalculateHeightForTemplateCell:(UICollectionViewCell *)cell{
    CGFloat calculateHeight = 0;
    
    NSLayoutConstraint *widthForceConstant = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.itemWidth];

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
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
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
    return calculateHeight;
}

- (UICollectionViewCell *)templateCellWithReuseIdentifier:(NSString *)reuseIdentifier withIndex:(NSInteger)index{
    if (!self.templateCell) {
        UICollectionViewCell *templateCell = [[NSBundle mainBundle] loadNibNamed:@"TestView" owner:nil options:nil].lastObject;
        self.templateCell = templateCell;
    }
    return self.templateCell;
}

- (void)refreshLayoutCache{
    [self.layoutAttributesArray removeAllObjects];
    [self.columnHeightArray removeAllObjects];
    [self.itemSizeArray removeAllObjects];
    for (NSInteger index = 0; index < self.columnNumber; index ++) {
        [self.columnHeightArray addObject:@(self.viewInset.top)];
    }
}

- (struct SPColumnInfo)highestColumn:(NSArray<NSNumber *> *)columnHeight{
    CGFloat max = 0;
    NSInteger column = 0;
    for (int i = 0; i < self.columnNumber; i++) {
        if (columnHeight[i].floatValue > max) {
            max = columnHeight[i].floatValue;
            column = i;
        }
    }
    struct SPColumnInfo info;
    info.columnNumber = column;
    info.columnHeight = max;
    return info;
}

- (struct SPColumnInfo)shortestColumn:(NSArray<NSNumber *> *)columnHeight{
    CGFloat min = CGFLOAT_MAX;
    NSInteger column = 0;
    for (int i = 0; i < self.columnNumber; i++) {
        if (columnHeight[i].floatValue < min) {
            min = columnHeight[i].floatValue;
            column = i;
        }
    }
    NSLog(@"shortest column:%ld shortest height:%f",(long)column,min);
    struct SPColumnInfo info;
    info.columnNumber = column;
    info.columnHeight = min;
    return info;
}

#pragma mark - Override
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    return self.layoutAttributesArray;
}

- (CGSize)collectionViewContentSize{
    struct SPColumnInfo maxInfo = [self highestColumn:self.columnHeightArray];
    CGFloat height = maxInfo.columnHeight + self.viewInset.bottom + self.lineSpacing;
    CGFloat width = self.collectionView.bounds.size.width - self.viewInset.left - self.viewInset.right;
    return CGSizeMake( width, height);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.layoutAttributesArray[indexPath.item];
}

#pragma mark - Basic init
- (NSMutableArray<UICollectionViewLayoutAttributes *> *)layoutAttributesArray{
    if (!_layoutAttributesArray) {
        _layoutAttributesArray = [NSMutableArray array];
    }
    return _layoutAttributesArray;
}

- (NSMutableArray<NSNumber *> *)columnHeightArray{
    if (!_columnHeightArray) {
        _columnHeightArray = [NSMutableArray array];
    }
    return _columnHeightArray;
}

- (NSMutableArray<NSValue *> *)itemSizeArray{
    if (!_itemSizeArray) {
        _itemSizeArray = [NSMutableArray array];
    }
    return _itemSizeArray;
}

@end
