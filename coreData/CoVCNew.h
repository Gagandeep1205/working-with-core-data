//
//  CoVCNew.h
//  coreData
//
//  Created by Gagandeep Kaur  on 07/10/15.
//  Copyright © 2015 Gagandeep Kaur . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBJVideoPlayerController.h"
#import "CoCell.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

@interface CoVCNew : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) MPMoviePlayerViewController *moviePlayerVC;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *arrUrl;
@property NSMutableArray *arrTitles;
@property NSMutableArray *arrThumbnail;
@property NSArray *paths;
@property NSString *myDirectoryUrl;
@property NSString *myDirectoryTitles;
@property NSInteger index;
@property CGPoint viewCenter;
@property NSIndexPath *playingIndex;

@end
