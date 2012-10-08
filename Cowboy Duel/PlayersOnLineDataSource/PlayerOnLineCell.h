
#import <UIKit/UIKit.h>

@interface PlayerOnLineCell : UITableViewCell {
	
}

@property (strong,nonatomic) UIImageView * Icon;
@property (strong,nonatomic) UILabel * playerName;
@property (strong,nonatomic) UILabel * gold;
@property (strong,nonatomic) UILabel * rank;
@property (strong,nonatomic) UIButton * btnDuel;
@property (strong,nonatomic) UILabel * status;
@property (strong,nonatomic) UIActivityIndicatorView *indicatorConnectin;
@property (strong,nonatomic) UILabel * rankLevel;
@property (strong,nonatomic) UIImageView * ribbon;

-(void) setPlayerIcon:(UIImage*)iconImage;
-(void)showIndicatorConnectin;
-(void)hideIndicatorConnectin;
-(void)setRibbonHide:(BOOL)hide;
@end
