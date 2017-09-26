# SPWaterFlowLayout

[简书地址](http://www.jianshu.com/p/bd856b5e140a)

![SPWaterFlowLayout](https://github.com/Tr2e/SPWaterFlowLayout/raw/master/waterflow.gif)

## how to use

**initialize**
```
    SPWaterFlowLayout *flowlayout = [[SPWaterFlowLayout alloc] init];
    flowlayout.columnNumber = 2;
    flowlayout.interitemSpacing = 10;
    flowlayout.lineSpacing = 10;
    flowlayout.pageSize = 54;
    flowlayout.xibName = @"TestView";
    UICollectionView *test = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowlayout];
    test.contentInset = UIEdgeInsetsMake(10, 10, 5, 10);
    [self.view addSubview:test];
    test.delegate = self;
    test.dataSource = self;
    [test registerNib:[UINib nibWithNibName:@"TestView" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    test.backgroundColor = [UIColor whiteColor];
```
update**SPWaterFlowLayout**'s property `datas` when Refresh or LoadMore

**Refresh**
```
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
```
**LoadMore**
```
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
```
