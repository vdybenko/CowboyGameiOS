
#import <UIKit/UIKit.h>
#import "CDPlayerOnLine.h"

@interface PlayerOnLineCell : UITableViewCell {
	
}
@property (strong,nonatomic) IBOutlet UIView * backGround;
@property (strong,nonatomic) IBOutlet UIImageView * icon;
@property (strong,nonatomic) IBOutlet UILabel * playerName;
@property (strong,nonatomic) IBOutlet UILabel * gold;
@property (strong,nonatomic) IBOutlet UILabel * rank;
@property (strong,nonatomic) IBOutlet UIButton * btnDuel;
@property (strong,nonatomic) IBOutlet UILabel * status;
@property (strong,nonatomic) IBOutlet UIActivityIndicatorView *indicatorConnectin;
@property (strong,nonatomic) IBOutlet UIImageView * ribbon;

+(PlayerOnLineCell*)cell;
+(NSString*) cellID;

-(void) populateWithPlayer:(CDPlayerOnLine *)player;
-(void) initMainControls;
-(void) setPlayerIcon:(UIImage*)iconImage;
-(void) setRibbonHide:(BOOL)hide;
-(void)showIndicatorConnectin;
-(void)hideIndicatorConnectin;
@end
