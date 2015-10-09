//
//  CoCell.h
//  coreData
//
//  Created by Gagandeep Kaur  on 07/10/15.
//  Copyright © 2015 Gagandeep Kaur . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CoCell : UITableViewCell

@property (strong, nonatomic) MPMoviePlayerController *player;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgThumbnail;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (strong, nonatomic) NSString *strPath;

- (IBAction)actionBtnPlay:(id)sender;

@end
