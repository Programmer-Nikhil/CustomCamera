//
//  ViewController.m
//  CustomCamera
//
//  Created by Nikhil Devgire on 22/02/20.
//  Copyright © 2020 Nikhil Devgire. All rights reserved.
//

#import "ViewController.h"
#import "NDCameraController.h"

@interface ViewController ()<NDCameraControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *capturedImageView;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)takePhoto:(id)sender {
    NDCameraController *controller = [[NDCameraController alloc] initWithNibName:@"NDCameraController" bundle:[NSBundle mainBundle]];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void) didFinishPickingMedia:(UIImage*) image {
    [_capturedImageView setImage:image];
}

- (void) didCancelPickingMedia {
    
}

@end
