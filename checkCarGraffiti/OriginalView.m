//
//  OriginalView.m
//  KF_banPen
//
//  Created by 白印潇 on 2019/3/25.
//  Copyright © 2019年 白印潇. All rights reserved.
//

#import "OriginalView.h"

@implementation OriginalView

- (void)setBaseImage:(UIImage *)baseImage{
    _baseImage = baseImage;
    [self setNeedsDisplay];
}

- (void)setImageArray:(NSArray *)imageArray{
    _imageArray = imageArray;
//    NSLog(@"~~~~%zd",_imageArray.count);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // 在给定的区域内按照 scaleFill 的模式画图
    [_baseImage drawInRect:rect];
    for (NSInteger i = 0; i < _imageArray.count; i ++) {
        NSDictionary *dic = _imageArray[i];
        rect = CGRectFromString(dic[@"rect"]);
        UIImage *image = [UIImage imageNamed:dic[@"imageName"]];
        [image drawInRect:rect];
    }
}

@end
