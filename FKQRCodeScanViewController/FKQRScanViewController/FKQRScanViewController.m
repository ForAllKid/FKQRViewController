//
//  FKQRScanViewController.m
//  FKQRScanViewControllerDemo
//
//  Created by 周宏辉 on 2017/4/5.
//  Copyright © 2017年 ForKid. All rights reserved.
//

#import "FKQRScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "FKQRScanMaskView.h"


NSString *const kFKQRAuthorizeNotificationKey = @"FKQRAuthorizeNotificationKey";


@interface FKQRScanViewController ()

<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) FKQRScanMaskView *maskView;

/** 
 输入数据源
 */
@property (nonatomic, strong) AVCaptureDeviceInput *input;

/**
 输出数据源
 */
@property (nonatomic, strong) AVCaptureMetadataOutput *output;

/** 
 输入输出的中间桥梁 负责把捕获的音视频数据输出到输出设备中
 */
@property (nonatomic, strong) AVCaptureSession *session;

/**
 预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layerView;



/**
 是否授权
 */
//@property (nonatomic, assign, getter=isAuthorization) BOOL authorization;

@end

@implementation FKQRScanViewController

#pragma mark - life cycle



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
#if TARGET_IPHONE_SIMULATOR
    
    NSLog(@"模拟器不支持相机测试");


#else
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authStatus) {
        case AVAuthorizationStatusDenied:
            [self showAlert];
            break;
        case AVAuthorizationStatusAuthorized:// 已授权，可使用
            [self initConfig];
            break;
        case AVAuthorizationStatusRestricted:// 未授权，且用户无法更新，如家长控制情况下
            break;
        case AVAuthorizationStatusNotDetermined:// 未进行授权选择
            [self initConfig];
            break;
    }
    
    
#endif


}



- (void)showAlert{

    NSString *message = @"您没有开启相机权限，请在\n“设置”-“隐私”-“相机”功能中，找到“悦享易栈”\n打开相机访问权";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.deniedCallback) {
            self.deniedCallback();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}



- (void)initConfig{

    
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:device error: nil];
    self.output = [AVCaptureMetadataOutput new];    
    [self.view addSubview:self.maskView];

    //设置扫描范围
    [self.output setRectOfInterest:self.maskView.visibleScanRect];
    
    
    
    self.session = [AVCaptureSession new];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.session addInput:self.input];
    [self.session addOutput:self.output];
    [self.output setMetadataObjectsDelegate: self queue: dispatch_get_main_queue()];

    self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes;

    
    self.layerView = [AVCaptureVideoPreviewLayer layerWithSession: self.session];
    self.layerView.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.layerView.frame = self.view.bounds;
    
    
    [self.view.layer addSublayer:self.layerView];
    [self.view addSubview:self.maskView];

    
    [self.session startRunning];
}

#pragma mark - 实现代理方法, 完成二维码扫描
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
//    [self playSound];

    
    //停止扫描
    [self.session stopRunning];
    [self.maskView stopAnimation];
    
    
    if (metadataObjects.count > 0) {
    
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;

        if (self.completionCallback) {
            self.completionCallback(metadataObject.stringValue);
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(QRViewController:completionScanWithResult:)]) {
            [self.delegate QRViewController:self completionScanWithResult:metadataObject.stringValue];
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:metadataObject.stringValue
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self.session startRunning];
            [self.maskView startAnimation];
        }];
        
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
        
        
        
//        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        
        NSString *message = @"未扫描到结果";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            [self.session startRunning];
            [self.maskView startAnimation];
        }];
        
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    
}

- (void)playSound{
    
    static SystemSoundID soundIDTest = 0;
    NSString * path = [[NSBundle mainBundle] pathForResource:@"scanSound" ofType:@"wav"];
    if (path) {
        AudioServicesCreateSystemSoundID( (__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundIDTest );
    }
    AudioServicesPlaySystemSound( soundIDTest );

}


#pragma mark - layout

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.maskView.frame = self.view.bounds;
}



#pragma mark - setter


#pragma mark - getter

- (FKQRScanMaskView *)maskView{
    if (!_maskView) {
        _maskView = [[FKQRScanMaskView alloc] initWithFrame:self.view.bounds];
    }
    return _maskView;
}




@end
