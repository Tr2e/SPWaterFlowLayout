//
//  SPWaterFlowLayout.h
//  WaterFlowLayout
//
//  Created by Tree on 2017/9/6.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPWaterFlowLayout : UICollectionViewLayout

/** 列数 */
@property (nonatomic, assign) NSInteger columnNumber;
/** 列间距 */
@property (nonatomic, assign) NSInteger interitemSpacing;
/** 行间距 */
@property (nonatomic, assign) NSInteger lineSpacing;
/** 页面大小 */
@property (nonatomic, assign) NSInteger pageSize;
/** cell的reuseIdentifier */
@property (nonatomic, copy) NSString *reuseIdentifier;
/** 数据源 */
@property (nonatomic, strong) NSArray *datas;

@end
