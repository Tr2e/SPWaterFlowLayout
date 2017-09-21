//
//  ViewController.m
//  WaterFlowLayout
//
//  Created by Tree on 2017/9/6.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "ViewController.h"
#import "UICollectionViewCell+FeedData.h"
#import "SPProductModel.h"
#import "YYFPSLabel.h"
#import "SPEasyLoadingForCollectionView.h"
#import "SPWaterFlowLayout.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) NSArray *datas;

@property (nonatomic, strong) YYFPSLabel *fpsLabel;
@property (nonatomic, assign) NSInteger pageTag;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.pageTag = 0;
    
    SPWaterFlowLayout *flowlayout = [[SPWaterFlowLayout alloc] init];
    flowlayout.columnNumber = 2;
    flowlayout.interitemSpacing = 10;
    flowlayout.lineSpacing = 10;
    flowlayout.pageSize = 54;
    flowlayout.reuseIdentifier = @"Cell";
    UICollectionView *test = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowlayout];
    test.contentInset = UIEdgeInsetsMake(10, 10, 5, 10);
    [self.view addSubview:test];
    test.delegate = self;
    test.dataSource = self;
    [test registerNib:[UINib nibWithNibName:@"TestView" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    test.backgroundColor = [UIColor whiteColor];
    
    test.canRefresh = YES;
    test.canAutoLoadMore = YES;
    test.pageSize = 54;
    
    __weak typeof(test) wtest = test;
    test.refreshDataCallBack = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.pageTag = 0;
            NSArray *datas = [SPProductModel productWithIndex:0];
            flowlayout.datas = datas;
            wtest.sp_datas = [datas mutableCopy];
            [wtest doneLoadDatas];
            [wtest reloadData];
        });
    };
    test.loadMoreDataCallBack = ^{
        self.pageTag ++;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSArray *datas = [SPProductModel productWithIndex:self.pageTag];
            NSArray *total = [flowlayout.datas arrayByAddingObjectsFromArray:datas];
            flowlayout.datas = total;
            wtest.sp_datas = [total mutableCopy];
            [wtest doneLoadDatas];
            [wtest reloadData];
        });
    };
    
    
    _fpsLabel = [YYFPSLabel new];
    _fpsLabel.frame = CGRectMake(20, 35, 50, 30);
    [_fpsLabel sizeToFit];
    [self.view addSubview:_fpsLabel];
    
    [test beginNonAnimateRefreshing];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return collectionView.sp_datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.feedData = collectionView.sp_datas[indexPath.item];
    cell.subfeedData = @(indexPath.item);
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
