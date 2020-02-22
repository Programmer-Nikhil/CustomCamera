//
//  NDCameraController.h
//  CustomCamera
//
//  Created by Nikhil Devgire on 22/02/20.
//  Copyright © 2020 Nikhil Devgire. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NDCameraControllerDelegate <NSObject>
- (void) didFinishPickingMedia:(UIImage*) image;
- (void) didCancelPickingMedia;
@end

@interface NDCameraController : UIViewController
@property (nonatomic, weak) id <NDCameraControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
