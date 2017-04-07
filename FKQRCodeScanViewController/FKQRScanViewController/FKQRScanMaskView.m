//
//  FKQRScanMaskView.m
//  FKQRScanViewControllerDemo
//
//  Created by 周宏辉 on 2017/4/5.
//  Copyright © 2017年 ForKid. All rights reserved.
//

#import "FKQRScanMaskView.h"
#import <AVFoundation/AVFoundation.h>

/**
 扫描的边长
 */
CGFloat const kScanViewWidth = 250.f;

/**
 提示框高度
 */
CGFloat const kMessageLabelHeight = 30.f;

/**
 间距
 */
CGFloat const kPadding = 10.f;

/**
 默认边框粗细
 */
CGFloat const kDefaultBorderWidth = 0.5f;

/**
 默认的提示信息
 */
NSString *const kDefaultMessage = @"请将二维码放入框内即可自动扫描";


NSString *const kFKQRMaskViewAnimationKey = @"FKQRMaskViewAnimationKey";

@interface FKQRScanMaskView ()

@property (nonatomic, strong) UIView *scanView;

@property (nonatomic, strong) UIImageView *lineView;

@property (nonatomic, strong) UILabel *messageLabel;


@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;

//@property (nonatomic, assign, readwrite) CGRect visibleScanRect;
@property (nonatomic, assign) CGRect scanViewFrame;


@end

@implementation FKQRScanMaskView


#pragma mark - init

- (instancetype)init{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}



- (void)commonInit{
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    
    _scanViewBorderWidth = kDefaultBorderWidth;
    _scanViewBorderColor = [UIColor whiteColor];

    [self addSubview:self.scanView];
    [self insertSubview:self.lineView aboveSubview:self.scanView];
    [self addSubview:self.messageLabel];
    
    [self startAnimation];
}



#pragma mark - layout

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width  = self.frame.size.width;
    
    
    self.scanView.frame = self.scanViewFrame;
    
    self.lineView.frame = CGRectMake(self.scanViewFrame.origin.x,
                                     self.scanViewFrame.origin.y,
                                     self.scanViewFrame.size.width,
                                     5.f);
    
    self.messageLabel.frame = CGRectMake(0,
                                         CGRectGetMaxY(self.scanViewFrame) + kPadding,
                                         width,
                                         kMessageLabelHeight);
 
    
}


#pragma mark - animation

- (void)startAnimation{
    
    self.lineView.hidden = NO;
    
    CGPoint fromPoint = CGPointMake(self.scanViewFrame.origin.x + self.scanViewFrame.size.width / 2,
                                    self.scanViewFrame.origin.y);
    
    CGPoint endPoint  = CGPointMake(self.scanViewFrame.origin.x + self.scanViewFrame.size.width / 2,
                                    self.scanViewFrame.origin.y + self.scanViewFrame.size.height);
    
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:fromPoint];
    [movePath addLineToPoint:endPoint];
    
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = movePath.CGPath;
    moveAnim.repeatCount = MAXFLOAT;
    moveAnim.removedOnCompletion = NO;
    moveAnim.duration = 3.f;
    [self.lineView.layer addAnimation:moveAnim forKey:kFKQRMaskViewAnimationKey];
    
}


- (void)stopAnimation{
    self.lineView.hidden = YES;
    [self.lineView.layer removeAnimationForKey:kFKQRMaskViewAnimationKey];
}



#pragma mark - getter

- (CGRect)visibleScanRect{
    //由于默认的扫描是依照屏幕横着的样子  所以要对换
    CGFloat scanRectX = self.scanViewFrame.origin.y / self.frame.size.height;
    CGFloat scanRectY = self.scanViewFrame.origin.x / self.frame.size.width;
    CGFloat scanRectWidth  = self.scanViewFrame.size.height / self.frame.size.height;
    CGFloat scanRectHeight = self.scanViewFrame.size.width / self.frame.size.width;
    
    CGRect interest = CGRectMake(scanRectX, scanRectY, scanRectWidth, scanRectHeight);
    return interest;
}

- (CGRect)scanViewFrame{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    CGFloat scanViewX = screenBounds.size.width  / 2 - kScanViewWidth / 2;
    CGFloat scanViewY = screenBounds.size.height / 2 - kScanViewWidth / 2 - kPadding / 2 - kMessageLabelHeight / 2;

    return CGRectMake(scanViewX, scanViewY, kScanViewWidth, kScanViewWidth);
}


- (UIView *)scanView{
    if (!_scanView) {
        _scanView = [UIView new];
        _scanView.layer.borderColor = self.scanViewBorderColor.CGColor ? : [UIColor whiteColor].CGColor;
        _scanView.layer.borderWidth = self.scanViewBorderWidth;
    }
    return _scanView;
}

- (UIImageView *)lineView{
    if (!_lineView) {
        _lineView = [UIImageView new];
        _lineView.image = self.lineImage ? : [UIImage imageNamed:@"scan_line"];
    }
    return _lineView;
}

- (UILabel *)messageLabel{
    if (!_messageLabel) {
        _messageLabel = [UILabel new];
        _messageLabel.text = self.message ? : kDefaultMessage;
        _messageLabel.font = [UIFont systemFontOfSize:14.f];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _messageLabel;
}




#pragma mark - setter

- (void)setScanViewBorderColor:(UIColor *)scanViewBorderColor{
    UIColor *color = scanViewBorderColor ? : [UIColor whiteColor];
    _scanViewBorderColor = color.copy;
    self.scanView.layer.borderColor = color.CGColor;
}

- (void)setScanViewBorderWidth:(CGFloat)scanViewBorderWidth{
    CGFloat width = scanViewBorderWidth < 0 ? kDefaultBorderWidth : scanViewBorderWidth;
    _scanViewBorderWidth = width;
    self.scanView.layer.borderWidth = width;
}

- (void)setLineImage:(UIImage *)lineImage{
    UIImage *image = lineImage ? : [UIImage imageNamed:@"scan_line"];
    _lineImage = image.copy;
    self.lineView.image = image;
}

- (void)setMessage:(NSString *)message{
    NSString *string = message ? : kDefaultMessage;
    _message = string.copy;
    self.messageLabel.text = string;
}




@end
