//
//  UITableView+SPHeightCache.m
//  SPTableviewHelper
//
//  Created by Tree on 2017/6/21.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "UITableView+SPHeightCache.h"
#import "SPLoadMoreView.h"
#import "SPBlankView.h"
#import <objc/runtime.h>

typedef NSMutableArray<NSMutableArray<NSNumber *> *> SPCachesArray ;

@interface SPHeightCache()
@property (nonatomic, strong) SPCachesArray *heightCachesForPotrait;
@property (nonatomic, strong) SPCachesArray *heightCachesForLandscape;

// Current Caches Array
- (SPCachesArray *)currentCachesArray;

@end

@implementation SPHeightCache

- (instancetype)init{
    if (self = [super init]) {
        self.heightCachesForLandscape = [NSMutableArray array];
        self.heightCachesForPotrait = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Cache Input
- (void)cacheHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath{
    [self createCachesWithIndexPathIfNeeded:indexPath];
    self.currentCachesArray[indexPath.section][indexPath.row] = @(height);
}

#pragma mark - Cache Output
- (CGFloat)heightCacheForIndexPath:(NSIndexPath *)indexPath{
    [self createCachesWithIndexPathIfNeeded:indexPath];
    NSNumber *targetNum = self.currentCachesArray[indexPath.section][indexPath.row];
    return targetNum.floatValue;
}

#pragma mark - Cache Clear
- (void)clearHeightCacheForIndexPath:(NSIndexPath *)indexPath{
    [self createCachesWithIndexPathIfNeeded:indexPath];
    [self operateAllCachesArray:^(NSMutableArray *targetArray) {
        targetArray[indexPath.section][indexPath.row] = @-1;
    }];
}

- (void)clearAllHeigthCaches{
    [self operateAllCachesArray:^(NSMutableArray *targetArray) {
        [targetArray removeAllObjects];
    }];
}

- (void)checkIndexPathSafety:(NSIndexPath *)indexPath{
    NSAssert(indexPath.section <= self.currentCachesArray.count, @"arr operation error");
    NSAssert(indexPath.row <= self.currentCachesArray[indexPath.section].count,@"arr operation error");
}

#pragma mark - Current Caches
- (SPCachesArray *)currentCachesArray{
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)?self.heightCachesForPotrait:self.heightCachesForLandscape;
}

- (BOOL)cacheIsExistAtIndexPath:(NSIndexPath *)indexPath{
    return [self heightCacheForIndexPath:indexPath] != -1;
}

#pragma mark - Array Check Part

/**
 检查数组有效性

 @param indexPath 传入当前indexPath
 */
- (void)createCachesWithIndexPathIfNeeded:(NSIndexPath *)indexPath{
    [self createCachesForSectionsAtSectionIfNeeded:indexPath.section];
    [self createCachesForRow:indexPath.row IfNeededInSection:indexPath.section];
}

- (void)operateAllCachesArray:(void(^)(NSMutableArray *targetArray))arrBlock{
    arrBlock(self.heightCachesForPotrait);
    arrBlock(self.heightCachesForLandscape);
}

- (void)createCachesForRow:(NSInteger)row IfNeededInSection:(NSInteger)section{
    [self operateAllCachesArray:^(NSMutableArray *targetArray) {
        NSMutableArray *rowCachesArr = targetArray[section];
        for (NSInteger i=0; i <=row; i++) {
            if (row >= rowCachesArr.count) {
                [rowCachesArr addObject:@(-1)];
            }
        }
    }];
}

- (void)createCachesForSectionsAtSectionIfNeeded:(NSInteger)section{
    [self operateAllCachesArray:^(SPCachesArray *targetArray) {
        for (NSInteger i = 0; i <= section; i++) {
            if (i>=targetArray.count){
                targetArray[i] = [NSMutableArray array];
            }
        }
    }];
}

@end

static const char AssociateSPHeightCacheKey;

@implementation UITableView (SPHeightCache)
@dynamic sp_heightCache;

- (SPHeightCache *)sp_heightCache{
    SPHeightCache *_cache = objc_getAssociatedObject(self, &AssociateSPHeightCacheKey);
    if (!_cache) {
        _cache = [[SPHeightCache alloc] init];
        _cache.allowAutomaticOperation = YES;// default is YES
        objc_setAssociatedObject(self, &AssociateSPHeightCacheKey, _cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _cache;
}

@end


static void __SP_PRIMARY_CALL(void (^callout)(void)) {
    callout();
}
#define SPPrimaryCall(...) do {__SP_PRIMARY_CALL(^{__VA_ARGS__});} while(0)
@implementation UITableView (SPHeightCacheOperation)

void sp_tableView_instanceMethod_Swizzle(Class c,SEL orig,SEL news){
    
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, news);
    
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, news, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
    
}

+ (void)load{

    SEL selectors[] = {
        @selector(reloadData),
        @selector(insertSections:withRowAnimation:),
        @selector(deleteSections:withRowAnimation:),
        @selector(reloadSections:withRowAnimation:),
        @selector(moveSection:toSection:),
        @selector(insertRowsAtIndexPaths:withRowAnimation:),
        @selector(deleteRowsAtIndexPaths:withRowAnimation:),
        @selector(reloadRowsAtIndexPaths:withRowAnimation:),
        @selector(moveRowAtIndexPath:toIndexPath:)
    };
    
    for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([@"sp_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        sp_tableView_instanceMethod_Swizzle(self, originalSelector, swizzledSelector);
    }
    
}

- (void)sp_reloadData{
    if (self.sp_heightCache.allowAutomaticOperation) {
        [self.sp_heightCache operateAllCachesArray:^(NSMutableArray *targetArray) {
            [targetArray removeAllObjects];
        }];
    }
    
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
    
    SPPrimaryCall([self sp_reloadData];);
}

- (void)showMoreView:(BOOL) show{
    
    if (!self.canLoadMore) return;
    self.sp_loadMoreView.hidden = !show;
    
}

- (void)sp_reloadDataWithNoCacheClearOperation{
    SPPrimaryCall([self sp_reloadData];);
}

#pragma mark - Sections' Actions
- (void)sp_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation{
    if (self.sp_heightCache.allowAutomaticOperation) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
            [self.sp_heightCache createCachesForSectionsAtSectionIfNeeded:section];
            [self.sp_heightCache operateAllCachesArray:^(NSMutableArray *targetArray) {
                NSAssert(section<=targetArray.count, @"arr operation error");
                [targetArray insertObject:[NSMutableArray array] atIndex:section];
            }];
        }];
    }
    SPPrimaryCall([self sp_insertSections:sections withRowAnimation:animation];);
}

- (void)sp_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation{
    if (self.sp_heightCache.allowAutomaticOperation) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
            [self.sp_heightCache createCachesForSectionsAtSectionIfNeeded:section];
            [self.sp_heightCache operateAllCachesArray:^(NSMutableArray *targetArray) {
                NSAssert(section<targetArray.count, @"arr operation error");
                [targetArray removeObjectAtIndex:section];
            }];
        }];
    }
    SPPrimaryCall([self sp_deleteSections:sections withRowAnimation:animation];);
}

- (void)sp_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation{
    if (self.sp_heightCache.allowAutomaticOperation) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
            [self.sp_heightCache createCachesForSectionsAtSectionIfNeeded:section];
            [self.sp_heightCache operateAllCachesArray:^(NSMutableArray *targetArray) {
                [targetArray[section] removeAllObjects];
            }];
        }];
    }
    SPPrimaryCall([self sp_reloadSections:sections withRowAnimation:animation];);
}

- (void)sp_moveSection:(NSInteger)section toSection:(NSInteger)newSection{
    if (self.sp_heightCache.allowAutomaticOperation) {
        [self.sp_heightCache createCachesForSectionsAtSectionIfNeeded:section];
        [self.sp_heightCache operateAllCachesArray:^(NSMutableArray *targetArray) {
            NSAssert(section<targetArray.count, @"arr operation error");
            NSAssert(newSection<targetArray.count, @"arr operation error");
            [targetArray exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    SPPrimaryCall([self sp_moveSection:section toSection:newSection];);
}

#pragma mark - Rows' Actions
- (void)sp_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation{
    if (self.sp_heightCache.allowAutomaticOperation) {
        for (NSIndexPath *indexPath in indexPaths) {
            [self.sp_heightCache createCachesWithIndexPathIfNeeded:indexPath];
        }
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.sp_heightCache operateAllCachesArray:^(SPCachesArray *targetArray) {
                NSAssert(obj.section<targetArray.count, @"arr operation error");
                NSAssert(obj.row<targetArray[obj.section].count, @"arr operation error");
                [targetArray[obj.section] insertObject:@-1 atIndex:obj.row];
            }];
        }];
    }
    SPPrimaryCall([self sp_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)sp_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation{
    if (self.sp_heightCache.allowAutomaticOperation) {
        for (NSIndexPath *indexPath in indexPaths) {
            [self.sp_heightCache createCachesWithIndexPathIfNeeded:indexPath];
        }
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.sp_heightCache operateAllCachesArray:^(SPCachesArray *targetArray) {
                NSAssert(obj.section<targetArray.count, @"arr operation error");
                NSAssert(obj.row<targetArray[obj.section].count, @"arr operation error");
                [targetArray[obj.section] removeObjectAtIndex:obj.row];
            }];
        }];
    }
    SPPrimaryCall([self sp_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)sp_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation{
    if (self.sp_heightCache.allowAutomaticOperation) {
        for (NSIndexPath *indexPath in indexPaths) {
            [self.sp_heightCache createCachesWithIndexPathIfNeeded:indexPath];
        }
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           [self.sp_heightCache operateAllCachesArray:^(NSMutableArray *targetArray) {
               NSAssert(obj.section<targetArray.count, @"arr operation error");
               targetArray[obj.section][obj.row] = @-1;
           }];
        }];
    }
    SPPrimaryCall([self sp_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)sp_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    if (self.sp_heightCache.allowAutomaticOperation) {
        [self.sp_heightCache createCachesWithIndexPathIfNeeded:indexPath];
        [self.sp_heightCache createCachesWithIndexPathIfNeeded:newIndexPath];
        [self.sp_heightCache operateAllCachesArray:^(SPCachesArray *targetArray) {
            NSAssert(indexPath.row<targetArray[indexPath.section].count, @"arr operation error");
            NSAssert(indexPath.row<targetArray[newIndexPath.section].count, @"arr operation error");
            NSMutableArray <NSNumber *> *cacheArrForSection = targetArray[indexPath.section];
            NSMutableArray <NSNumber *> *newCacheArrForSection = targetArray[newIndexPath.section];
            NSNumber *cache = cacheArrForSection[indexPath.row];
            NSNumber *newCache = newCacheArrForSection[newIndexPath.row];
            
            cacheArrForSection[indexPath.row] = newCache;
            newCacheArrForSection[newIndexPath.row] = cache;
            
        }];
    }
    SPPrimaryCall([self sp_moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];);
}

@end
