//
//  SPProductModel.h
//  WaterFlowLayout
//
//  Created by Tree on 2017/9/19.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPProductModel : NSObject
@property (nonatomic, assign) NSInteger h; // 商品图片高
@property (nonatomic, assign) NSInteger w; // 商品图片宽
@property (nonatomic, copy) NSString *img; // 商品图片地址
@property (nonatomic, copy) NSString *price; // 商品价格

+ (instancetype)productWithDict:(NSDictionary *)dict; // 字典转模型
+ (NSArray *)productWithIndex:(NSInteger)index; // 根据索引返回商品数组

@end
