
#import <UIKit/UIKit.h>
#import "CDPlayerOnLine.h"
#import "SSServer.h"

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

@property (strong, nonatomic) IBOutlet UIView *userAtackView;
@property (strong, nonatomic) IBOutlet UIView *userDefenseView;
@property (strong, nonatomic) IBOutlet UILabel *userAtack;
@property (strong, nonatomic) IBOutlet UILabel *userDefense;

+(PlayerOnLineCell*)cell;
+(NSString*) cellID;

-(void) populateWithPlayer:(SSServer *)player;
-(void) initMainControls;
-(void) setPlayerIcon:(UIImage*)iconImage;
-(void) setRibbonHide:(BOOL)hide;
-(void)showIndicatorConnectin;
-(void)hideIndicatorConnectin;
@end
