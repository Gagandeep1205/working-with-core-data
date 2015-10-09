//
//  CoVC.h
//  coreData
//
//  Created by Gagandeep Kaur  on 07/10/15.
//  Copyright © 2015 Gagandeep Kaur . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>
#define CAPTURE_FRAMES_PER_SECOND 20

@interface CoVC : UIViewController<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic) AVCaptureDevice * device;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *deviceInput;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) AVCaptureConnection *videoConnection;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;

@property (weak, nonatomic) IBOutlet UIButton *btnCapture;
@property (weak, nonatomic) IBOutlet UIButton *btnFlash;
@property (weak, nonatomic) IBOutlet UIButton *btnSwipe;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property BOOL recording;
@property NSInteger i;

- (IBAction)actionBtnCapture:(id)sender;
- (IBAction)actionBtnFlash:(id)sender;
- (IBAction)actionBtnSwipe:(id)sender;


@end
