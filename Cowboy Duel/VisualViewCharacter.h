//
//  OpponentShape.h
//  Bounty Hunter
//
//  Created by Taras on 14.03.13.
//
//

#import <UIKit/UIKit.h>

@interface VisualViewCharacter : UIView<MemoryManagement>
@property (weak, nonatomic) IBOutlet UIView *mainSubView;
@property (weak, nonatomic) IBOutlet UIImageView *body;
@property (weak, nonatomic) IBOutlet UIImageView *head;
@property (weak, nonatomic) IBOutlet UIImageView *cap;

@end
