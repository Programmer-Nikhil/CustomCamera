//
//  ViewController.m
//  CustomCamera
//
//  Created by Nikhil Devgire on 22/02/20.
//  Copyright © 2020 Nikhil Devgire. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *frameForCapture;
@end

@implementation ViewController

AVCaptureSession *captureSession;
AVCaptureStillImageOutput *stillImageOutput;
AVCaptureDevice *inputDevice;
AVCaptureDeviceInput *deviceInput;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    captureSession = [[AVCaptureSession alloc] init];
    [captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if([captureSession canAddInput:deviceInput]) {
        [captureSession addInput:deviceInput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame  = self.frameForCapture.frame;
    [previewLayer setFrame:frame];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecTypeJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [captureSession addOutput:stillImageOutput];
    [captureSession startRunning];
    
}

- (IBAction)TakePhoto:(id)sender {
    
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        
        if(videoConnection) {
            break;
        }
    }
    
    //Setting Video Orientation
    if ([videoConnection isVideoOrientationSupported]) {
        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
        [videoConnection setVideoOrientation:orientation];
    }
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (imageDataSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            NSLog(@"Image Received :: %@", image);
        }
    }];
}


- (IBAction)flashButtonClicked:(id)sender {
}


- (IBAction)rotateCameraClicked:(id)sender {
    
    if (!captureSession) return;

    [captureSession beginConfiguration];
    
    if (!deviceInput) return;
    AVCaptureDeviceInput *currentCameraInput;
    [captureSession removeInput:deviceInput];
    currentCameraInput = deviceInput;

    if (!currentCameraInput) return;

    // Switch device position
    AVCaptureDevicePosition captureDevicePosition = AVCaptureDevicePositionUnspecified;
    if (currentCameraInput.device.position == AVCaptureDevicePositionBack) {
        captureDevicePosition = AVCaptureDevicePositionFront;
    } else {
        captureDevicePosition = AVCaptureDevicePositionBack;
    }
    
    if (!inputDevice) return;

    // Add new camera input
    NSError *error;
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputDevice error:&error];
    if (!error && [captureSession canAddInput:newVideoInput]) {
        [captureSession addInput:newVideoInput];
    }

    [captureSession commitConfiguration];
}



@end
