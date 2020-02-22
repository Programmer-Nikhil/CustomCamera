//
//  NDCameraController.m
//  CustomCamera
//
//  Created by Nikhil Devgire on 22/02/20.
//  Copyright © 2020 Nikhil Devgire. All rights reserved.
//

#import "NDCameraController.h"
#import <AVFoundation/AVFoundation.h>

@interface NDCameraController ()
@property (weak, nonatomic) IBOutlet UIView *frameForCapture;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (strong, nonatomic) AVCaptureSession *captureSession;

@end

@implementation NDCameraController
AVCaptureStillImageOutput *stillImageOutput;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if([self.captureSession canAddInput:deviceInput]) {
        [self.captureSession addInput:deviceInput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame  = self.frameForCapture.frame;
    [previewLayer setFrame:frame];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecTypeJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [self.captureSession addOutput:stillImageOutput];
    [self.captureSession startRunning];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.captureSession stopRunning];
}

- (IBAction)TakePhoto:(id)sender {
    
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                [videoConnection setVideoOrientation:[self interfaceToVideoOrientation]];
                break;
            }
        }
        
        if(videoConnection) {
            break;
        }
    }
    
    //Setting Video Orientation
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:[self interfaceToVideoOrientation]];
    }
    
    if ([videoConnection isVideoMirroringSupported]) {
        [videoConnection setVideoMirrored:NO];
    }
    
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (imageDataSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
//            CGRect clippedRect  = self.frameForCapture.frame;
//            CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, clippedRect);
//            UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
//            CGImageRelease(imageRef);
            [self.delegate didFinishPickingMedia:image];
            
            NSLog(@"Image Received :: %@", image);
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (UIImage*) rotateImageAppropriately:(UIImage*)imageToRotate
{
   UIImage* properlyRotatedImage;

   CGImageRef imageRef = [imageToRotate CGImage];

   if (imageToRotate.imageOrientation == 0)
   {
       properlyRotatedImage = imageToRotate;
   }
   else if (imageToRotate.imageOrientation == 3)
   {

       CGSize imgsize = imageToRotate.size;
       UIGraphicsBeginImageContext(imgsize);
       [imageToRotate drawInRect:CGRectMake(0.0, 0.0, imgsize.width, imgsize.height)];
       properlyRotatedImage = UIGraphicsGetImageFromCurrentImageContext();
       UIGraphicsEndImageContext();
   }
   else if (imageToRotate.imageOrientation == 1)
   {
       properlyRotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:1];
   }

   return properlyRotatedImage;
}


- (IBAction)flashButtonClicked:(id)sender {
    // check if flashlight available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]) {

            [device lockForConfiguration:nil];
            if (device.torchMode == AVCaptureTorchModeOff) {
                
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                [_flashButton setImage:[UIImage imageNamed:@"flashOnIcon"] forState:UIControlStateNormal];

            } else {
                
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                [_flashButton setImage:[UIImage imageNamed:@"flashOffIcon"] forState:UIControlStateNormal];
            }
            
            [device unlockForConfiguration];
        }
    }
}


- (IBAction)rotateCameraClicked:(id)sender {
    
    if (!self.captureSession) return;

    [self.captureSession beginConfiguration];

    AVCaptureDeviceInput *currentCameraInput;

    // Remove current (video) input
    for (AVCaptureDeviceInput *input in self.captureSession.inputs) {
        if ([input.device hasMediaType:AVMediaTypeVideo]) {
            [self.captureSession removeInput:input];

            currentCameraInput = input;
            break;
        }
    }

    if (!currentCameraInput) return;

    // Switch device position
    AVCaptureDevicePosition captureDevicePosition = AVCaptureDevicePositionUnspecified;
    if (currentCameraInput.device.position == AVCaptureDevicePositionBack) {
        captureDevicePosition = AVCaptureDevicePositionFront;
    } else {
        captureDevicePosition = AVCaptureDevicePositionBack;
    }
    
    // Select new camera
    AVCaptureDevice *newCamera;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

    for (AVCaptureDevice *captureDevice in devices) {
        if (captureDevice.position == captureDevicePosition) {
            newCamera = captureDevice;
        }
    }
    
    if (!newCamera) return;

    // Add new camera input
    NSError *error;
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&error];
    if (!error && [self.captureSession canAddInput:newVideoInput]) {
        [self.captureSession addInput:newVideoInput];
    }

    [self.captureSession commitConfiguration];
}

- (IBAction)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (AVCaptureVideoOrientation)interfaceToVideoOrientation {
    
  switch ([UIApplication sharedApplication].statusBarOrientation) {
    case UIInterfaceOrientationPortrait:
      return AVCaptureVideoOrientationPortrait;
    case UIInterfaceOrientationPortraitUpsideDown:
      return AVCaptureVideoOrientationPortraitUpsideDown;
    case UIInterfaceOrientationLandscapeRight:
      return AVCaptureVideoOrientationLandscapeRight;
    case UIInterfaceOrientationLandscapeLeft:
      return AVCaptureVideoOrientationLandscapeLeft;
    default:
      return AVCaptureVideoOrientationPortrait;
  }
}


@end
