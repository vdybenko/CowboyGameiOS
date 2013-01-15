
#import <UIKit/UIKit.h>

@interface PracticeCell : UITableViewCell {
	
}
@property (weak,nonatomic) IBOutlet UIButton * btnDuel;

+(PracticeCell*)cell;
+(NSString*) cellID;

-(void) initMainControls;

@end
