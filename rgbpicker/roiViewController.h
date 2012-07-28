//
//  roiViewController.h
//  rgbpicker
//
//  Created by Vijay Selvaraj on 7/27/12.
//  Copyright (c) 2012 Vijay Selvaraj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ImageUtil.h"


@interface roiViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
    ImageUtil *imgUtil;
}

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) IBOutlet UIView *uiView;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UIView *colorPallet;


@property (nonatomic, retain) IBOutlet UILabel *rValue;
@property (nonatomic, retain) IBOutlet UILabel *gValue;
@property (nonatomic, retain) IBOutlet UILabel *bValue;
@property (nonatomic, retain) IBOutlet UILabel *hexValue;

@property (nonatomic, retain) IBOutlet UIImageView *bottomBar;
@property (nonatomic, retain) IBOutlet UIImageView *imgSample;





-(IBAction)buttonPressed:(id)sender;

@end
