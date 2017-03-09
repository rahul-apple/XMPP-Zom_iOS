//
//  VROButton.m
//  Zom
//
//  Created by Bose on 09/03/17.
//
//

#import "VROButton.h"

@implementation VROButton


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.layer.masksToBounds = YES;
}

-(void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

-(void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    CGFloat radius = cornerRadius * [UIScreen mainScreen].bounds.size.width/320.0;
    self.layer.cornerRadius = radius;
}

-(void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = [borderColor CGColor];
}

@end
