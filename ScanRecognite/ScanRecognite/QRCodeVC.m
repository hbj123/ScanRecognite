//
//  QRCodeVC.m
//  ScanRecognite
//
//  Created by hbj on 2017/8/23.
//  Copyright © 2017年 宝剑. All rights reserved.
//

#import "QRCodeVC.h"
#import <AVFoundation/AVFoundation.h>//原生二维码扫描必须导入这个框架
#define SCREENWidth  [UIScreen mainScreen].bounds.size.width   //设备屏幕的宽度
#define SCREENHeight [UIScreen mainScreen].bounds.size.height //设备屏幕的高度
#define kScanW      260


#define TOP (SCREENHeight-kScanW)/2
#define LEFT (SCREENWidth-kScanW)/2
#define kScanRect CGRectMake(LEFT, TOP, kScanW, kScanW)

@interface QRCodeVC ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
     CAShapeLayer *cropLayer;
}
@property (nonatomic,strong)AVCaptureSession *session;
@property (nonatomic, strong)AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation QRCodeVC
- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupScanningQRCode];

    [self creatCenterView];
    [self setCropRect:kScanRect];
   
   
}
- (void)creatCenterView {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWidth - kScanW) / 2, (SCREENHeight - kScanW) / 2, 260, 260)];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = [UIImage imageNamed:@"pick_bg"];
    [self.view addSubview:imageView];
    

    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWidth - kScanW) / 2, (SCREENHeight - kScanW) / 2, 260, 3)];
    imageV.backgroundColor = [UIColor clearColor];
    imageV.image = [UIImage imageNamed:@"line"];
    [self.view addSubview:imageV];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //使用CABasicAnimation创建基础动画
        CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"position"];
        anima.fromValue = [NSValue valueWithCGPoint:CGPointMake(SCREENWidth / 2, (SCREENHeight - kScanW) /2)];
        anima.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREENWidth / 2 , (SCREENHeight - kScanW) /2 + kScanW)];
        anima.duration = 2.0f;
        anima.fillMode = kCAFillModeForwards;
        anima.repeatCount = MAXFLOAT;
        [imageV.layer addAnimation:anima forKey:@"positionAnimation"];
    });
}

//添加扫描页面透明框
- (void)setCropRect:(CGRect)cropRect{
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, self.view.bounds);
    
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.6];
    [cropLayer setNeedsDisplay];
    [self.view.layer addSublayer:cropLayer];
}

- (void)animation {
    
}


- (void)setupScanningQRCode {
    
    
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                });
                    // 用户第一次同意了访问相机权限
                    NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                    
                } else {
                    // 用户第一次拒绝了访问相机权限
                    NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                }
            }];
        } else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机
            NSLog(@"用户访问相机权限 - - %@", [NSThread currentThread]);
        } else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
            
        } else if (status == AVAuthorizationStatusRestricted) {
            NSLog(@"因为系统原因, 无法访问相册");
        }
    } else {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
    }
   // 2、创建设备输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
   // 3、创建数据输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // 3(1)创建设备输出流
    AVCaptureVideoDataOutput *VideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [VideoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 设置有效的扫描范围（每一个取值0～1，以屏幕右上角为坐标原点）
    // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）
   //    output.rectOfInterest = CGRectMake(((SCREENWidth - kScanW) / 2) / SCREENWidth, ((SCREENHeight - kScanW) / 2) / SCREENHeight, kScanW / SCREENWidth, kScanW/ SCREENHeight);
    output.rectOfInterest = CGRectMake(((SCREENHeight - kScanW) / 2) / SCREENHeight, ((SCREENWidth - kScanW) / 2) / SCREENWidth, kScanW/ SCREENHeight, kScanW / SCREENWidth);
    
    self.session = [[AVCaptureSession alloc] init];
     // 会话采集率: AVCaptureSessionPresetHigh
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    [_session addInput:input];
    [_session addOutput:output];
    // 7(1)添加设备输出流到会话对象；与 3(1) 构成识别光线强弱
    [_session addOutput:VideoDataOutput];

    // 8、设置数据输出类型，需要将数据输出添加到会话后，才能指定元数据类型，否则会报错
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    // 9、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    // 保持纵横比；填充层边界
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.layer.bounds;
    
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    // 10、启动会话
    [_session startRunning];
    
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    NSLog(@"metadataObjects===%@", metadataObjects);
    
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    NSLog(@"sampleBuffer===%@", sampleBuffer);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
