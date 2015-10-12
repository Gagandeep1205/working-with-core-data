//
//  FireVC.m
//  coreData
//
//  Created by Gagandeep Kaur  on 09/10/15.
//  Copyright © 2015 Gagandeep Kaur . All rights reserved.
//

#import "FireVC.h"

@interface FireVC ()

@end

@implementation FireVC

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self UISetup];
    [self audioSetup];
}

#pragma mark - initialisation and setup

- (void) viewWillAppear:(BOOL)animated{
    
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:253/255.f green:163/255.f blue:75/255.f alpha:1.f]];
    
    _paths = [[NSArray alloc] init];
    _paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _myDirectoryUrl = [[_paths objectAtIndex:0] stringByAppendingPathComponent:@"Audio"];
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_myDirectoryUrl]){
        [[NSFileManager defaultManager] createDirectoryAtPath:_myDirectoryUrl withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Audio"];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    self.arrUrl = [[NSMutableArray alloc] initWithArray:[[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy]];
    NSLog(@"%@",_arrUrl);
    
    [self.tableView reloadData];

}

- (void) audioSetup{

    int random = arc4random();
    _paths = [[NSArray alloc] init];
    _paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _myDirectoryUrl = [[_paths objectAtIndex:0] stringByAppendingPathComponent:@"Audio"];
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_myDirectoryUrl]){
        [[NSFileManager defaultManager] createDirectoryAtPath:_myDirectoryUrl withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    _audioFileUrl = [NSURL fileURLWithPath:[_myDirectoryUrl stringByAppendingString:[NSString stringWithFormat:@"audio%d.m4a",random]]];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    NSMutableDictionary *audioSettings = [[NSMutableDictionary alloc] init];
    
    [audioSettings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [audioSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [audioSettings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    self.audioRecorder = [[AVAudioRecorder alloc]
                          initWithURL:_audioFileUrl
                          settings:audioSettings
                          error:nil];
    _audioRecorder.delegate = self;
    _audioRecorder.meteringEnabled = YES;
    
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [_audioRecorder prepareToRecord];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) UISetup{

    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:253/255.f green:163/255.f blue:75/255.f alpha:1.f]];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:253/255.f green:163/255.f blue:75/255.f alpha:1.f];
    
    UIBarButtonItem *addAudio = [[UIBarButtonItem alloc] initWithTitle:@"Add Audio" style:UIBarButtonItemStylePlain target:self action:@selector(actionBtnAddAudio:)];
    [addAudio setTintColor:[UIColor blackColor]];
    self.navigationItem.rightBarButtonItem = addAudio;
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_progressView setHidden:YES];
    [_playerSuperView setHidden:YES];

}

#pragma mark - button actions

- (void) actionBtnAddAudio : (UIBarButtonItem *)btn{
    
    [self.playerSuperView setHidden:NO];
    [self.timer invalidate];
    [self.progressView setHidden:YES];
    [self.labeltimer setHidden:NO];
    [self.audioRecorder record];
    _recording = YES;
    
    _minutes = 0;
    _seconds = 0;
    _labeltimer.text = @"0.0";
    self.progressView.progress = 0.0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                  target: self
                                                selector: @selector(callAfterOneSecond:)
                                                userInfo: nil
                                                 repeats: YES];
}

- (IBAction)actionBtnStop:(id)sender {
    
    [self.audioPlayer stop];
    [self.audioRecorder stop];
    [self.timer invalidate];
    
    _recording = NO;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (IBAction)actionBtnPlay:(id)sender {
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_audioFileUrl error:nil];
    [_audioPlayer setDelegate:self];
    [self.audioPlayer play];
    [_labeltimer setHidden:YES];
    self.progressView.progress = 0.0;
    [self.progressView setHidden:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.25
                                        target:self
                                        selector:@selector(updateProgress)
                                        userInfo:nil
                                        repeats:YES];
}

- (IBAction)actionBtnClose:(id)sender {
    
    [_playerSuperView setHidden:YES];
    [_progressView setHidden:YES];
    [self.audioPlayer stop];
    [self audioSetup];
}

#pragma mark - update methods

- (void)updateProgress
{
    float timeLeft = self.audioPlayer.currentTime/self.audioPlayer.duration;
    
    self.progressView.progress= timeLeft;
}

- (void) callAfterOneSecond: (NSTimer *)timer{
    
    if (_recording) {
        
        if (_seconds%60 != 0) {
            _seconds ++;
        }
        else if (_seconds !=0 && _seconds %60 == 0) {
            _minutes ++;
            _seconds = 0;
        }
        else if (_seconds == 0){
            _seconds++;
        }
        NSString *str = [NSString stringWithFormat:@"%ld : %ld",(long)_minutes,(long)_seconds];
        [_labeltimer setText:str];
    }
}


#pragma mark - table view delegates and data sources

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _arrUrl.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FireCell"];
    
    NSManagedObject *audio = [self.arrUrl objectAtIndex:indexPath.row];
    cell.textLabel.text = [audio valueForKey:@"title"];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSManagedObject *audio = [self.arrUrl objectAtIndex:indexPath.row];
    
    NSURL *url = [NSURL URLWithString:[audio valueForKey:@"path"]];
    
    [self.playerSuperView setHidden:NO];
    [self.progressView setHidden:NO];
    [self.labeltimer setHidden:YES];
    self.progressView.progress = 0.0;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_audioPlayer setDelegate:self];
    [NSTimer scheduledTimerWithTimeInterval:0.25
                                        target:self
                                        selector:@selector(updateProgress)
                                        userInfo:nil
                                        repeats:YES];
    [self.audioPlayer play];
}

#pragma mark - audio recorder and player delegates

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Save"
                                  message:@"Save your audio as"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancel = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  
                              }];
    
    UIAlertAction * done = [UIAlertAction
                            actionWithTitle:@"Done"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                NSManagedObjectContext *context = [self managedObjectContext];
                                NSManagedObject *newAudio = [NSEntityDescription insertNewObjectForEntityForName:@"Audio" inManagedObjectContext:context];
                                [newAudio setValue:[NSString stringWithFormat:@"%@",_audioFileUrl] forKey:@"path"];
                                [newAudio setValue:[alert.textFields objectAtIndex:0].text forKey:@"title"];
                                NSError *error = nil;
                                if (![context save:&error]) {
                                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                                }
                                else{
                                    
                                    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
                                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Audio"];
                                    self.arrUrl = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                                    NSLog(@"%@",_arrUrl);
                                    
                                    [self.tableView reloadData];
                                    [self.playerSuperView setHidden:YES];
                                    [self.progressView setHidden:YES];
                                }


                            [self dismissViewControllerAnimated:YES completion:nil];
                            }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
    }];
    [alert addAction:cancel];
    [alert addAction:done];
    
    [self presentViewController:alert animated:YES completion:nil];

}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{

}

#pragma mark - core data functions

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


@end
