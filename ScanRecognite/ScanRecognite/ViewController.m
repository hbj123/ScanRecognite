//
//  ViewController.m
//  ScanRecognite
//
//  Created by hbj on 2017/8/22.
//  Copyright © 2017年 宝剑. All rights reserved.
//

#import "ViewController.h"
#import "ScanRecogniteVC.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
//硬件设备
@property (nonatomic, strong) AVCaptureDevice *device;
//输入流
@property (nonatomic, strong) AVCaptureDeviceInput *input;
//协调输入输出流的数据
@property (nonatomic, strong) AVCaptureSession *session;
//预览层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

//输出流
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;  //用于捕捉静态图片
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;    //原始视频帧，用于获取实时图像以及视频录制
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;      //用于二维码识别以及人脸识别

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view.layer addSublayer:_previewLayer]; //1.5把previewLayer添加到self.view.layer上
    [self.session startRunning];
    
}
//1.6找个合适的位置, 让session运行起来
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}


//1.1获取硬件设备
- (AVCaptureDevice *)decive {
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([_device lockForConfiguration:nil]) {
            //自动闪光灯
            if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [_device setFlashMode:AVCaptureFlashModeAuto];
            }
            //自动白平衡
            if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
                [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            }
            //自动对焦
            if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            //自动曝光
            if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            [_device unlockForConfiguration];
        }
    }
    return _device;
}

//1.2获取硬件的输入流  ---waring 此时会弹出alert向用户获取相机权限
- (AVCaptureDeviceInput *)input {
    if (_input == nil) {
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    }
    return _input;
}

//1.3需要一个用来协调输入和输出数据的回话,然后把input添加到回话中
- (AVCaptureSession *)session {
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canAddInput:self.input]) {
            [_session addInput:self.input];
        }
    }
    return _session;
}

//1.4然后需要一个预览图层展示图像
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.frame = self.view.layer.bounds;
    }
    return _previewLayer;
}



- (IBAction)clickAction:(UIButton *)sender {
    ScanRecogniteVC *scanVC = [[ScanRecogniteVC alloc] init];
    [self presentViewController:scanVC animated:YES completion:^{
        NSLog(@"跳转到扫图界面");
    }];
}









- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
