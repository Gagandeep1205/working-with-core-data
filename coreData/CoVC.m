//
//  CoVC.m
//  coreData
//
//  Created by Gagandeep Kaur  on 07/10/15.
//  Copyright © 2015 Gagandeep Kaur . All rights reserved.
//

#import "CoVC.h"

@interface CoVC ()

@end

@implementation CoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:143/255.f green:191/255.f blue:103/255.f alpha:1.f]];

     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:143/255.f green:191/255.f blue:103/255.f alpha:1.f];
    
    _i = 10;
    [_activityIndicator setHidden:YES];
    
    [self loadCameraView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated{

    _recording = NO;
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:143/255.f green:191/255.f blue:103/255.f alpha:1.f]];

}

#pragma mark - loading the camera view

- (void) loadCameraView{
    
    _session = [[AVCaptureSession alloc] init];
    
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    AVCaptureDevice *VideoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (VideoDevice)
    {
        NSError *error;
        _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:VideoDevice error:&error];
        if (!error)
        {
            if ([_session canAddInput:_deviceInput])
                [_session addInput:_deviceInput];
            else
                NSLog(@"Couldn't add video input");
        }
        else
        {
            NSLog(@"Couldn't create video input");
        }
    }
    else
    {
        NSLog(@"Couldn't create video capture device");
    }
    
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    if (audioInput)
    {
        [_session addInput:audioInput];
    }
        
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    
    [_previewLayer setFrame:CGRectMake(0, 0, rootLayer.bounds.size.height, rootLayer.bounds.size.height)];
    [rootLayer insertSublayer:_previewLayer atIndex:0];
    
    _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    Float64 TotalSeconds = 60;
    int32_t preferredTimeScale = 30;
    CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);
    _movieFileOutput.maxRecordedDuration = maxDuration;
    _movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;
    
    if ([_session canAddOutput:_movieFileOutput])
        [_session addOutput:_movieFileOutput];;
    [self CameraSetOutputProperties];
    
    [_session setSessionPreset:AVCaptureSessionPresetMedium];
    
    UIView *CameraView = [[UIView alloc] init];
    [[self view] addSubview:CameraView];
    [self.view sendSubviewToBack:CameraView];
    [[CameraView layer] addSublayer:_previewLayer];
    
    [_session startRunning];
    
}

- (void) CameraSetOutputProperties
{
    AVCaptureConnection *CaptureConnection = [_movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if ([CaptureConnection isVideoOrientationSupported])
    {
        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationLandscapeRight;		        [CaptureConnection setVideoOrientation:orientation];
    }
    
}

#pragma mark - button actions

- (IBAction)actionBtnCapture:(id)sender {
    
    if (!_recording)
    {
        NSLog(@"START RECORDING");
        _recording = YES;
        
        _i ++;
        NSArray *paths = [[NSArray alloc] init];
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * myDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"videos"];
        NSError *error;
        if (![[NSFileManager defaultManager] fileExistsAtPath:myDirectory])
            [[NSFileManager defaultManager] createDirectoryAtPath:myDirectory withIntermediateDirectories:NO attributes:nil error:&error];
        NSString *destFilename = [NSString stringWithFormat:@"%ld.mov",(long)_i];
        NSString *destPath = [myDirectory stringByAppendingPathComponent:destFilename];
        
        NSURL* saveLocationURL = [[NSURL alloc] initFileURLWithPath:destPath];
        [_movieFileOutput startRecordingToOutputFileURL:saveLocationURL recordingDelegate:self];
        
    }
    else
    {
        NSLog(@"STOP RECORDING");
        _recording = NO;
        [_activityIndicator setHidden:NO];
        [_activityIndicator startAnimating];
    }
}


- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error
{
    BOOL RecordedSuccessfully = YES;
    if ([error code] != noErr)
    {
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
        {
            RecordedSuccessfully = [value boolValue];
        }
    }
    if (RecordedSuccessfully)
    {
        
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Saving"
                                    message:@"Your video has been saved to documents directory"
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * cancel = [UIAlertAction
                                  actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                      [_activityIndicator setHidden:YES];
                                  }];
        
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];

    }
}


- (IBAction)actionBtnFlash:(id)sender {
    if(!_device.torchMode){
        
        if ([_device hasTorch]) {
            [_device lockForConfiguration:nil];
            [_device setTorchMode:AVCaptureTorchModeOn];
            [_device unlockForConfiguration];
        }
    }
    else{
        
        if ([_device hasTorch]) {
            [_device lockForConfiguration:nil];
            [_device setTorchMode:AVCaptureTorchModeOff];
            [_device unlockForConfiguration];
        }
    }
}

- (IBAction)actionBtnSwipe:(id)sender {
    
    if (_device.position == AVCaptureDevicePositionBack) {
        for ( _device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] ) {
            if ( _device.position == AVCaptureDevicePositionFront) {
                
                NSError * error;
                AVCaptureDeviceInput * newDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:_device error:&error];
                [_session beginConfiguration];
                for (_deviceInput in [_session inputs]) {
                    [_session removeInput:_deviceInput];
                }
                
                if ([_session canAddInput:newDeviceInput]) {
                    [_session addInput:newDeviceInput];
                }
                [_session commitConfiguration];
                break;
            }
        }
        
    }else  {
        for ( _device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] ) {
            if ( _device.position == AVCaptureDevicePositionBack) {
                
                NSError * error;
                AVCaptureDeviceInput * newDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:_device error:&error];
                [_session beginConfiguration];
                for (_deviceInput in [_session inputs]) {
                    [_session removeInput:_deviceInput];
                }
                
                if ([_session canAddInput:newDeviceInput]) {
                    [_session addInput:newDeviceInput];
                }
                [_session commitConfiguration];
                break;
            }
        }
    }

}
@end
