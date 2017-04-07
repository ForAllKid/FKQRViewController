//
//  FKQRScanViewController.h
//  FKQRScanViewControllerDemo
//
//  Created by 周宏辉 on 2017/4/5.
//  Copyright © 2017年 ForKid. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FKQRScanViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol FKQRScanViewControllerDelegate <NSObject>

- (void)QRViewController:(FKQRScanViewController *)viewController completionScanWithResult:(NSString *)result;

@end


//call back

typedef void(^authorizationDeniedCallback)(void);

typedef void(^completionScanCallback)(NSString *result);




@interface FKQRScanViewController : UIViewController



/**
 delegate
 */
@property (nullable, nonatomic, weak) id <FKQRScanViewControllerDelegate> delegate;


/**
 如果授权未开启 则会走该回调
 */
@property (nullable, nonatomic, copy) authorizationDeniedCallback deniedCallback;



/**
 扫描结果
 */
@property (nullable, nonatomic, copy) completionScanCallback completionCallback;


@end

NS_ASSUME_NONNULL_END
