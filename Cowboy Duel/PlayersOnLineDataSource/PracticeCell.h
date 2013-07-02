
#import <UIKit/UIKit.h>

@interface PracticeCell : UITableViewCell {
	
}
@property (weak,nonatomic) IBOutlet UIButton * btnDuel;
@property (weak, nonatomic) IBOutlet UILabel *lbInvite;
@property (weak, nonatomic) IBOutlet UIImageView *ivTargets;

+(PracticeCell*)cell;
+(NSString*) cellID;

-(void) initMainControls;
-(void) cellForPractice:(BOOL)practice;
@end
