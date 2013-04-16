//
//  OpponentShape.h
//  Bounty Hunter
//
//  Created by Taras on 14.03.13.
//
//

#import <UIKit/UIKit.h>
#import "AccountDataSource.h"
#import "VisualViewDataSource.h"

@interface VisualViewCharacter : UIView<MemoryManagement>
@property (weak, nonatomic) IBOutlet UIView *mainSubView;
@property (weak, nonatomic) IBOutlet UIImageView *body;
@property (weak, nonatomic) IBOutlet UIImageView *head;
@property (weak, nonatomic) IBOutlet UIImageView *cap;
@property (weak, nonatomic) IBOutlet UIImageView *length;
@property (weak, nonatomic) IBOutlet UIImageView *shoose;
@property (strong, nonatomic) VisualViewDataSource *visualViewDataSource;

-(void)refreshWithAccountPlayer:(AccountDataSource*)accountPlayer;
-(void)cleareView;
-(UIImage*)imageFromCharacter;
@end
