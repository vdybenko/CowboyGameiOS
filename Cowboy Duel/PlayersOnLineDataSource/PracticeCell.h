
#import <UIKit/UIKit.h>

@interface PracticeCell : UITableViewCell {
	
}
@property (strong,nonatomic) IBOutlet UIButton * btnDuel;

+(PracticeCell*)cell;
+(NSString*) cellID;

-(void) initMainControls;

@end
