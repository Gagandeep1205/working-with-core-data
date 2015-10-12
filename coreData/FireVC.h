//
//  FireVC.h
//  coreData
//
//  Created by Gagandeep Kaur  on 09/10/15.
//  Copyright © 2015 Gagandeep Kaur . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface FireVC : UIViewController <UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSURL *audioFileUrl;
@property (strong, nonatomic) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *playerSuperView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *labeltimer;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property NSArray *paths;
@property NSString *myDirectoryUrl;
@property NSArray *arrUrl;
@property NSInteger seconds;
@property NSInteger minutes;

@property BOOL recording;
@property BOOL playing;

- (IBAction)actionBtnStop:(id)sender;
- (IBAction)actionBtnPlay:(id)sender;
- (IBAction)actionBtnClose:(id)sender;

@end
