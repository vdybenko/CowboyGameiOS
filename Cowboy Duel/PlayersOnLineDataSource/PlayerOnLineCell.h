
#import <UIKit/UIKit.h>
#import "CDPlayerOnLine.h"
#import "SSServer.h"

@interface PlayerOnLineCell : UITableViewCell {
	
}
@property (weak,nonatomic) IBOutlet UIView * backGround;
@property (weak,nonatomic) IBOutlet UIImageView * icon;
@property (weak,nonatomic) IBOutlet UILabel * playerName;
@property (weak,nonatomic) IBOutlet UILabel * gold;
@property (weak,nonatomic) IBOutlet UILabel * rank;
@property (weak,nonatomic) IBOutlet UIButton * btnDuel;
@property (weak,nonatomic) IBOutlet UILabel * status;
@property (weak,nonatomic) IBOutlet UIActivityIndicatorView *indicatorConnectin;
@property (weak,nonatomic) IBOutlet UIImageView * ribbon;

@property (weak, nonatomic) IBOutlet UILabel *userAtack;
@property (weak, nonatomic) IBOutlet UILabel *userDefense;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *facebookAvatar;

+(PlayerOnLineCell*)cell;
+(NSString*) cellID;

-(void) populateWithPlayer:(SSServer *)player;
-(void) initMainControls;
-(void) setPlayerIcon:(UIImage*)iconImage;
-(void) setRibbonHide:(BOOL)hide;
-(void)showIndicatorConnectin;
-(void)hideIndicatorConnectin;
@end
