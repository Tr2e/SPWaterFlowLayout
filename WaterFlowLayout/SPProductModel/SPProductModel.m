//
//  SPProductModel.m
//  WaterFlowLayout
//
//  Created by Tree on 2017/9/19.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "SPProductModel.h"

@implementation SPProductModel
+ (instancetype)productWithDict:(NSDictionary *)dict {
    id good = [[self alloc] init];
    [good setValuesForKeysWithDictionary:dict];
    return good;
}

+ (NSArray *)productWithIndex:(NSInteger)index {
    
    NSString *fileName = [NSString stringWithFormat:@"%ld.plist", index % 3 + 1];
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSArray *goodsArray = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:goodsArray.count];
    
    [goodsArray enumerateObjectsUsingBlock: ^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        [tmpArray addObject:[self productWithDict:dict]];
    }];
    return tmpArray.copy;
}
@end
