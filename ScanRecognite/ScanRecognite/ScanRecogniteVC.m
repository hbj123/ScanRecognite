//
//  ScanRecogniteVC.m
//  ScanRecognite
//
//  Created by hbj on 2017/8/22.
//  Copyright © 2017年 宝剑. All rights reserved.
//

/*ios录像和拍照的使用*/
#import "ScanRecogniteVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>


#define kLog(str) NSLog(@"hbj<<<%d<<<%@", __LINE__, str)
#define kScreenHeight  [UIScreen mainScreen].bounds.size.height
#define kScreenWidth   [UIScreen mainScreen].bounds.size.width

@interface ScanRecogniteVC ()<AVCapturePhotoCaptureDelegate>

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic, strong) AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property (nonatomic, strong) AVCaptureDeviceInput *input;

//输出图片 /* AVCaptureStillImageOutput ios10之后用AVCapturePhotoOutput代替*/
@property (nonatomic ,strong) AVCapturePhotoOutput *imageOutput;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic, strong) AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;

//展示捕获的场景
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ScanRecogniteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor blackColor]];
    //初始化
    [self initCameraDistrict];
   
}
//返回上一级按钮
- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//拍照按钮
- (IBAction)clickAction:(UIButton *)sender {
    [self photoBtnDidClick];
}

//初始化拍照成像
- (void)initCameraDistrict
{
    [self.view.layer addSublayer:self.previewLayer];
}
//1.1获取硬件设备
- (AVCaptureDevice *)device {
    if (_device == nil) {
        //    AVCaptureDevicePositionBack  后置摄像头
        //    AVCaptureDevicePositionFront 前置摄像头
        _device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        [self configurationDevice:_device];
    }
    return _device;
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    AVCaptureDeviceDiscoverySession *devicesIOS10 = [AVCaptureDeviceDiscoverySession  discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
    
    NSArray *devicesIOS  = devicesIOS10.devices;
    for (AVCaptureDevice *device in devicesIOS) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}
- (void)configurationDevice:(AVCaptureDevice *)device {
    if ([device lockForConfiguration:nil]) {
        //自动闪光灯
        if ([device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        //自动对焦
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动曝光
        if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [device unlockForConfiguration];
    }

}

//1.2获取硬件的输入流  ---waring 此时会弹出alert向用户获取相机权限
- (AVCaptureDeviceInput *)input {
    if (_input == nil) {
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    }
    return _input;
}
//1.3获取硬件的输出流
- (AVCapturePhotoOutput *)imageOutput {
    if (_imageOutput == nil) {
        _imageOutput = [[AVCapturePhotoOutput alloc] init];
    }
    return _imageOutput;
}
//1.4需要一个用来协调输入和输出数据的会话,然后把input添加到回话中
- (AVCaptureSession *)session {
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
        //     拿到的图像的大小可以自行设定
        //    AVCaptureSessionPreset320x240
        //    AVCaptureSessionPreset352x288
        //    AVCaptureSessionPreset640x480
        //    AVCaptureSessionPreset960x540
        //    AVCaptureSessionPreset1280x720
        //    AVCaptureSessionPreset1920x1080
        //    AVCaptureSessionPreset3840x2160
        _session.sessionPreset = AVCaptureSessionPreset640x480;
        //输入输出设备结合
        if ([_session canAddInput:self.input]) {
            [_session addInput:self.input];
        }
        if ([_session canAddOutput:self.imageOutput]) {
            [_session addOutput:self.imageOutput];
        }
        //设备取景开始
        [_session startRunning];
  }
    return _session;
}
//1.5然后需要一个预览图层展示图像
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        //预览层的生成
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.frame = CGRectMake(0, (kScreenHeight - 450)/2, kScreenWidth, 450);
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

//执行拍照
- (void)photoBtnDidClick
{
    //传入的参数集合
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection) {
        kLog(@"Connection is not active");
    }
    [self.imageOutput capturePhotoWithSettings:settings delegate:self];
}

#pragma mark ------  AVCapturePhotoCaptureDelegate代理方法
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput willBeginCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings {
    kLog(resolvedSettings);
}

/*!
 @method captureOutput:willCapturePhotoForResolvedSettings:
 @abstract
 A callback fired just as the photo is being taken.
 
 @param captureOutput
 The calling instance of AVCapturePhotoOutput.
 @param resolvedSettings
 An instance of AVCaptureResolvedPhotoSettings indicating which capture features have been selected.
 
 @discussion
 The timing of this callback is analogous to AVCaptureStillImageOutput's capturingStillImage property changing from NO to YES. The callback is delivered right after the shutter sound is heard (note that shutter sounds are suppressed when Live Photos are being captured).
 */
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput willCapturePhotoForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings {
     kLog(resolvedSettings);
}

/*!
 @method captureOutput:didCapturePhotoForResolvedSettings:
 @abstract
 A callback fired just after the photo is taken.
 
 @param captureOutput
 The calling instance of AVCapturePhotoOutput.
 @param resolvedSettings
 An instance of AVCaptureResolvedPhotoSettings indicating which capture features have been selected.
 
 @discussion
 The timing of this callback is analogous to AVCaptureStillImageOutput's capturingStillImage property changing from YES to NO.
 */
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didCapturePhotoForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings {
     kLog(resolvedSettings);
}

/*!
 @method captureOutput:didFinishProcessingPhotoSampleBuffer:previewPhotoSampleBuffer:resolvedSettings:bracketSettings:error:
 @abstract
 A callback fired when the primary processed photo or photos are done.
 
 @param captureOutput
 The calling instance of AVCapturePhotoOutput.
 @param photoSampleBuffer
 A CMSampleBuffer containing an uncompressed pixel buffer or compressed data, along with timing information and metadata. May be nil if there was an error.
 @param previewPhotoSampleBuffer
 An optional CMSampleBuffer containing an uncompressed, down-scaled preview pixel buffer. Note that the preview sample buffer contains no metadata. Refer to the photoSampleBuffer for metadata (e.g., the orientation). May be nil.
 @param resolvedSettings
 An instance of AVCaptureResolvedPhotoSettings indicating which capture features have been selected.
 @param bracketSettings
 If this image is being delivered as part of a bracketed capture, the bracketSettings corresponding to this image. Otherwise nil.
 @param error
 An error indicating what went wrong if photoSampleBuffer is nil.
 
 @discussion
 If you've requested a single processed image (uncompressed or compressed) capture, the photo is delivered here. If you've requested a bracketed capture, this callback is fired bracketedSettings.count times (once for each photo in the bracket).
 */
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error {
    kLog(photoSampleBuffer);
    kLog(previewPhotoSampleBuffer);
    kLog(resolvedSettings);
    self.imageView.image = [UIImage imageWithData:[AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer] scale:0.8];
    /*
     1.将捕获的视频或者照片保存到相册
     2.将数据上传到服务器
     */
}

/*!
 @method captureOutput:didFinishProcessingRawPhotoSampleBuffer:previewPhotoSampleBuffer:resolvedSettings:bracketSettings:error:
 @abstract
 A callback fired when the RAW photo or photos are done.
 
 @param captureOutput
 The calling instance of AVCapturePhotoOutput.
 @param rawSampleBuffer
 A CMSampleBuffer containing Bayer RAW pixel data, along with timing information and metadata. May be nil if there was an error.
 @param previewPhotoSampleBuffer
 An optional CMSampleBuffer containing an uncompressed, down-scaled preview pixel buffer. Note that the preview sample buffer contains no metadata. Refer to the rawSampleBuffer for metadata (e.g., the orientation). May be nil.
 @param resolvedSettings
 An instance of AVCaptureResolvedPhotoSettings indicating which capture features have been selected.
 @param bracketSettings
 If this image is being delivered as part of a bracketed capture, the bracketSettings corresponding to this image. Otherwise nil.
 @param error
 An error indicating what went wrong if rawSampleBuffer is nil.
 
 @discussion
 Single RAW image and bracketed RAW photos are delivered here. If you've requested a RAW bracketed capture, this callback is fired bracketedSettings.count times (once for each photo in the bracket).
 */
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingRawPhotoSampleBuffer:(nullable CMSampleBufferRef)rawSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error {
    kLog(rawSampleBuffer);
    kLog(previewPhotoSampleBuffer);
    kLog(resolvedSettings);
    self.imageView.image = [UIImage imageWithData:[AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:rawSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer] scale:0.8];
    
    /*
     1.将捕获的视频或者照片保存到相册
     2.将数据上传到服务器
     */
}

/*!
 @method captureOutput:didFinishRecordingLivePhotoMovieForEventualFileAtURL:resolvedSettings:
 @abstract
 A callback fired when the Live Photo movie has captured all its media data, though all media has not yet been written to file.
 
 @param captureOutput
 The calling instance of AVCapturePhotoOutput.
 @param outputFileURL
 The URL to which the movie file will be written. This URL is equal to your AVCapturePhotoSettings.livePhotoMovieURL.
 @param resolvedSettings
 An instance of AVCaptureResolvedPhotoSettings indicating which capture features have been selected.
 
 @discussion
 When this callback fires, no new media is being written to the file. If you are displaying a "Live" badge, this is an appropriate time to dismiss it. The movie file itself is not done being written until the -captureOutput:didFinishProcessingLivePhotoToMovieFileAtURL:duration:photoDisplayTime:resolvedSettings:error: callback fires.
 */
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishRecordingLivePhotoMovieForEventualFileAtURL:(NSURL *)outputFileURL resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings {
    kLog(resolvedSettings);
}

/*!
 @method captureOutput:didFinishProcessingLivePhotoToMovieFileAtURL:duration:photoDisplayTime:resolvedSettings:error:
 @abstract
 A callback fired when the Live Photo movie is finished being written to disk.
 
 @param captureOutput
 The calling instance of AVCapturePhotoOutput.
 @param outputFileURL
 The URL where the movie file resides. This URL is equal to your AVCapturePhotoSettings.livePhotoMovieURL.
 @param duration
 A CMTime indicating the duration of the movie file.
 @param photoDisplayTime
 A CMTime indicating the time in the movie at which the still photo should be displayed.
 @param resolvedSettings
 An instance of AVCaptureResolvedPhotoSettings indicating which capture features have been selected.
 @param error
 An error indicating what went wrong if the outputFileURL is damaged.
 
 @discussion
 When this callback fires, the movie on disk is fully finished and ready for consumption.
 */
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingLivePhotoToMovieFileAtURL:(NSURL *)outputFileURL duration:(CMTime)duration photoDisplayTime:(CMTime)photoDisplayTime resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings error:(nullable NSError *)error {
    kLog(resolvedSettings);
}

/*!
 @method captureOutput:didFinishCaptureForResolvedSettings:error:
 @abstract
 A callback fired when the photo capture is completed and no more callbacks will be fired.
 
 @param captureOutput
 The calling instance of AVCapturePhotoOutput.
 @param resolvedSettings
 An instance of AVCaptureResolvedPhotoSettings indicating which capture features were selected.
 @param error
 An error indicating whether the capture was unsuccessful. Nil if there were no problems.
 
 @discussion
 This callback always fires last and when it does, you may clean up any state relating to this photo capture.
 */
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings error:(nullable NSError *)error {
    kLog(resolvedSettings);
}





/*用来呈现拍到的场景*/
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 100, 75, 90)];
        [self.view addSubview:_imageView];
    }
    return _imageView;
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
