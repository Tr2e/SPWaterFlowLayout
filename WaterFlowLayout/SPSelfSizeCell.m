//
//  SPSelfSizeCell.m
//  WaterFlowLayout
//
//  Created by Tree on 2017/9/18.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "SPSelfSizeCell.h"
#import "UIImageView+WebCache.h"
#import "SPProductModel.h"

@interface SPSelfSizeCell()
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *productImg;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end

@implementation SPSelfSizeCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6].CGColor;
    self.layer.borderWidth = 1;
}

- (void)setFeedData:(SPProductModel *)feedData{
    self.detailLabel.text = feedData.img;
    [self.productImg sd_setImageWithURL:[NSURL URLWithString:feedData.img]];
}

- (void)setSubfeedData:(NSNumber *)subfeedData{
    self.numberLabel.text = [NSString stringWithFormat:@"%@",subfeedData];
}

@end
