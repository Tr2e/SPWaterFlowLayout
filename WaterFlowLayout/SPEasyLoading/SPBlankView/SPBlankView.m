//
//  SPBlankView.m
//  SPScrollViewTest
//
//  Created by Tree on 2017/7/6.
//  Copyright © 2017年 TR2E. All rights reserved.
//

#import "SPBlankView.h"

@interface SPBlankView()
@property (nonatomic, strong) UILabel *blankTipLabel;
@property (nonatomic, strong) UIImageView *blankImgView;
@end

@implementation SPBlankView

- (instancetype)init{
    if (self = [super init]) {
        [self initializeUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeUI];
    }
    return self;
}

- (void)initializeUI{
    
    UIImage *image = [UIImage imageNamed:@"sp_blank"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView sizeToFit];
    [self addSubview:imageView];
    self.blankImgView  = imageView;
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"暂无内容";
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightThin];
    label.textColor = [UIColor colorWithRed:172/255.0 green:172/255.0 blue:172/255.0 alpha:1];
    [label sizeToFit];
    [self addSubview:label];
    self.blankTipLabel = label;
    
}

- (void)setBlankImgName:(NSString *)blankImgName{
    _blankImgName = blankImgName;
    self.blankImgView.image = [UIImage imageNamed:blankImgName];
    [self.blankImgView sizeToFit];
}

- (void)setBlankTipString:(NSString *)blankTipString{
    _blankTipString = blankTipString;
    self.blankTipLabel.text = blankTipString;
    [self.blankTipLabel sizeToFit];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.blankImgView.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0 - 40);
    self.blankTipLabel.center = CGPointMake(CGRectGetMidX(_blankImgView.frame), CGRectGetMaxY(_blankImgView.frame) + _blankTipLabel.frame.size.height/2 + 20);
    
}

@end
