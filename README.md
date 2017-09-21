# SPWaterFlowLayout
![SPWaterFlowLayout](https://github.com/Tr2e/SPEasyCollectionView/raw/master/waterflow.gif)
**how to use**
```
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
```
