//
//  CoCell.m
//  coreData
//
//  Created by Gagandeep Kaur  on 07/10/15.
//  Copyright © 2015 Gagandeep Kaur . All rights reserved.
//

#import "CoCell.h"

@implementation CoCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (IBAction)actionBtnPlay:(id)sender {
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", _strPath]];
    
    _player =  [[MPMoviePlayerController alloc]
                     initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                             name : MPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    _player.controlStyle = MPMovieControlStyleDefault;
    _player.view.frame = self.videoView.frame;
    _player.movieSourceType = MPMovieSourceTypeFile;
    [_player prepareToPlay];
    [_player play];
    [self.contentView addSubview:_player.view];
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

#pragma mark - delegate methods

- (void) playVideo:(NSURL *)url{

    _player =  [[MPMoviePlayerController alloc]
                initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                name : MPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    _player.controlStyle = MPMovieControlStyleDefault;
    _player.view.frame = self.videoView.frame;
    _player.movieSourceType = MPMovieSourceTypeFile;
    [_player prepareToPlay];
    [_player play];
    [self.contentView addSubview:_player.view];
}


@end
