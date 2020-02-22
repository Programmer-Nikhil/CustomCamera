//
//  CameraPreviewView.m
//  CustomCamera
//
//  Created by Nikhil Devgire on 22/02/20.
//  Copyright © 2020 Nikhil Devgire. All rights reserved.
//

#import "CameraPreviewView.h"
#import "CameraFocusView.h"

@implementation CameraPreviewView {
    CameraFocusView *_focusSquare;
}

- (IBAction)tapToFocus:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationOfTouch:0 inView:self];
    if (!_focusSquare) {
        _focusSquare = [[CameraFocusView alloc] initWithTouchPoint:touchPoint];
        [self addSubview:_focusSquare];
        [_focusSquare setNeedsDisplay];
    }
    else {
        [_focusSquare updatePoint:touchPoint];
    }
    [_focusSquare animateFocusingAction];
}

@end
