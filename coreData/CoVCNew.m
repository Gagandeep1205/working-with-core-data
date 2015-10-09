//
//  CoVCNew.m
//  coreData
//
//  Created by Gagandeep Kaur  on 07/10/15.
//  Copyright © 2015 Gagandeep Kaur . All rights reserved.
//

#import "CoVCNew.h"

@interface CoVCNew ()

@end

@implementation CoVCNew

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:143/255.f green:191/255.f blue:103/255.f alpha:1.f]];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:143/255.f green:191/255.f blue:103/255.f alpha:1.f];
    
    UIBarButtonItem *addDetails = [[UIBarButtonItem alloc] initWithTitle:@"Add Video" style:UIBarButtonItemStylePlain target:self action:@selector(actionBtnAddVideo:)];
    [addDetails setTintColor:[UIColor blackColor]];
    self.navigationItem.rightBarButtonItem = addDetails;
    
    _index = 20;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _viewCenter = self.view.center;

}

- (void) viewWillAppear:(BOOL)animated{
    
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:143/255.f green:191/255.f blue:103/255.f alpha:1.f]];
    
    _paths = [[NSArray alloc] init];
    _paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _myDirectoryUrl = [[_paths objectAtIndex:0] stringByAppendingPathComponent:@"videos"];
    _myDirectoryTitles = [[_paths objectAtIndex:0] stringByAppendingPathComponent:@"Titles"];
    NSError *error;

    if (![[NSFileManager defaultManager] fileExistsAtPath:_myDirectoryUrl]){
        [[NSFileManager defaultManager] createDirectoryAtPath:_myDirectoryUrl withIntermediateDirectories:NO attributes:nil error:&error];
        [[NSFileManager defaultManager] createDirectoryAtPath:_myDirectoryTitles withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Video"];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    self.arrUrl = [[NSMutableArray alloc] initWithArray:[[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy]];
    NSLog(@"%@",_arrUrl);
    _arrThumbnail = [[NSMutableArray alloc] init];

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - button actions

- (void) actionBtnAddVideo : (UIBarButtonItem *)btn{

    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * cancel = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  
                              }];

    UIAlertAction * choose = [UIAlertAction
                              actionWithTitle:@"Select Video"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  
                                  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                  picker.delegate = self;
                                  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                  [self presentViewController:picker animated:YES completion:NULL];
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  
                              }];

    UIAlertAction * record = [UIAlertAction
                              actionWithTitle:@"Record Video"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  
                                  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                                  {
                                      UIImagePickerController *videoRecorder = [[UIImagePickerController alloc] init];
                                      videoRecorder.sourceType = UIImagePickerControllerSourceTypeCamera;
                                      videoRecorder.delegate = self;
                                      
                                      NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
                                      NSArray *videoMediaTypesOnly = [mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", @"movie"]];
                                      
                                      if ([videoMediaTypesOnly count] == 0)		                                      {
                                                                                }
                                      else
                                      {
                                          if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
                                              videoRecorder.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                                          
                                          videoRecorder.mediaTypes = videoMediaTypesOnly;
                                          videoRecorder.videoQuality = UIImagePickerControllerQualityTypeMedium;
                                          videoRecorder.videoMaximumDuration = 180;
                                          
                                          [self presentViewController:videoRecorder animated:YES completion:NULL];
                                      }
                                  }
    
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  
                              }];

    [alert addAction:cancel];
    [alert addAction:choose];
    [alert addAction:record];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - image picker controller delegates


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{

    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    NSData *videoData = [NSData dataWithContentsOfURL:url];

    int random = arc4random();
    NSString *tempPath = [_myDirectoryUrl stringByAppendingPathComponent:[NSString stringWithFormat:@"vid%d.mp4",random]];
    
    [videoData writeToFile:tempPath atomically:NO];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newVideo = [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:context];
    [newVideo setValue:tempPath forKey:@"path"];
    [newVideo setValue:@"This is a random title" forKey:@"title"];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    else{
        
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Video"];
        self.arrUrl = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        NSLog(@"%@",_arrUrl);
        
        [self.tableView reloadData];
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - table view delegates and data sources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _arrUrl.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CoCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CoCell"];
    NSManagedObject *video = [self.arrUrl objectAtIndex:indexPath.row];
    
    cell.imgThumbnail.image = [self getThumbnailForVideoNamed : [video valueForKey:@"path"]];
    cell.strPath = [video valueForKey:@"path"];
    cell.labelTitle.text = [video valueForKey:@"title"];
    cell.btnPlay.tag = indexPath.row;

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSManagedObject *video = [self.arrUrl objectAtIndex:indexPath.row];

    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", [video valueForKey:@"path"]]];
    
    _moviePlayerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentMoviePlayerViewControllerAnimated:_moviePlayerVC];
    
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

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    if ([player
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    }
}


#pragma mark - getting thumb nails for videos

-(UIImage *)getThumbnailForVideoNamed:(NSString *)str{
    
    NSURL *videoURL = [NSURL fileURLWithPath:str];
    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
    generate1.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 2);
    CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *thumbNailImage = [[UIImage alloc] initWithCGImage:oneRef];
    return thumbNailImage;
}

#pragma mark - scroll view delegates and data sources

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (!decelerate) {
    
        NSArray *paths = [_tableView indexPathsForVisibleRows];

        if (paths.count == 3) {
            
            _playingIndex = [paths objectAtIndex:1];
        }
        
        else if (paths.count == 1) {
            _playingIndex = [paths objectAtIndex:0];
        }
        
        else if (paths.count == 2){
            
            NSMutableArray *visibleCells = [[NSMutableArray alloc] init];
            for (NSIndexPath *path in paths) {
                [visibleCells addObject:[_tableView cellForRowAtIndexPath:path]];
                
                CGRect cell = [scrollView convertRect:[_tableView cellForRowAtIndexPath:path].frame toView:scrollView.superview];
                CGPoint center = self.view.center;
                if (CGRectContainsPoint(cell,center)){
                
                    _playingIndex = path;
                }
            }
        }

        NSLog(@"%@",_playingIndex);
        
        NSManagedObject *video = [self.arrUrl objectAtIndex:_playingIndex.row];
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", [video valueForKey:@"path"]]];
        _moviePlayerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        [self presentMoviePlayerViewControllerAnimated:_moviePlayerVC];
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    NSArray *paths = [_tableView indexPathsForVisibleRows];
    
    if (paths.count == 3) {
        
        _playingIndex = [paths objectAtIndex:1];
    }
    
    else if (paths.count == 1) {
        _playingIndex = [paths objectAtIndex:0];
    }
    
    else if (paths.count == 2){
        
        NSMutableArray *visibleCells = [[NSMutableArray alloc] init];
        for (NSIndexPath *path in paths) {
            [visibleCells addObject:[_tableView cellForRowAtIndexPath:path]];
            
            CGRect cell = [scrollView convertRect:[_tableView cellForRowAtIndexPath:path].frame toView:scrollView.superview];
            CGPoint center = self.view.center;
            if (CGRectContainsPoint(cell,center)){
                
                _playingIndex = path;
            }
        }
    }
    
    NSLog(@"%@",_playingIndex);
    
    NSManagedObject *video = [self.arrUrl objectAtIndex:_playingIndex.row];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", [video valueForKey:@"path"]]];
    _moviePlayerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentMoviePlayerViewControllerAnimated:_moviePlayerVC];

}


@end
