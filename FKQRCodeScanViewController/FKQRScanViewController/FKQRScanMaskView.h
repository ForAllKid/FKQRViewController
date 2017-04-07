//
//  FKQRScanMaskView.h
//  FKQRScanViewControllerDemo
//
//  Created by 周宏辉 on 2017/4/5.
//  Copyright © 2017年 ForKid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKQRScanMaskView : UIView


/**
 扫描的范围区间
 */
@property (nonatomic, assign, readonly) CGRect visibleScanRect;


/**
 边框颜色
 */
@property (nullable, nonatomic, copy) UIColor *scanViewBorderColor;


/**
 边框线条粗细
 */
@property (nonatomic, assign) CGFloat scanViewBorderWidth;



/**
 扫描线条
 */
@property (nullable, nonatomic, copy) UIImage *lineImage;


/**
 提示消息文本
 */
@property (nullable, nonatomic, copy) NSString *message;


/**
 开始扫描动画
 */
- (void)startAnimation;


/**
 停止扫描动画
 */
- (void)stopAnimation;



@end
