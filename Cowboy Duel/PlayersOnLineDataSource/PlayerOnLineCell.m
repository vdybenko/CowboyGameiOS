
#import "PlayerOnLineCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+Image+Title.h"
#import "Utils.h"


@implementation PlayerOnLineCell

@synthesize Icon;
@synthesize playerName;
@synthesize gold;
@synthesize rank;
@synthesize btnDuel;
@synthesize status;
@synthesize indicatorConnectin;
@synthesize ribbon;
@synthesize rankLevel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		[self setControlls];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //[self setControlls];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}





-(void) setControlls {
    
//    background
    [self setBackgroundColor:[UIColor redColor]];
    UIImage *imageBackGround=[UIImage imageNamed:@"view_dinamic_height.png"];
    CGRect mainFrame=CGRectMake(0, 0, 320, 78);
    CGRect frameToCrop;
    
    if ([Utils isiPhoneRetina]) {
        frameToCrop=CGRectMake(0, 0, 2*imageBackGround.size.width, 2*mainFrame.size.height);
    }else {
        frameToCrop=CGRectMake(0, 0, imageBackGround.size.width, mainFrame.size.height);
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageBackGround CGImage], frameToCrop);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    UIImageView *ivBody=[[UIImageView alloc] initWithImage:cropped];
    CGRect frame=CGRectMake(12, 2, imageBackGround.size.width, mainFrame.size.height);
    [ivBody setFrame:frame];
    
    [self addSubview:ivBody];
    CGImageRelease(imageRef);
    
    ivBody.layer.cornerRadius = 20.0;
    ivBody.layer.masksToBounds = YES;
    
    UIImageView *ivBottom=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"view_dinamic_height_bottom.png"]];
    CGRect frameBottom=ivBottom.frame;
    frameBottom.origin.x=frame.origin.x;
    frameBottom.origin.y=frame.origin.y+(frame.size.height-frameBottom.size.height);
    [ivBottom setFrame:frameBottom];
    [self addSubview:ivBottom];

    Icon=[[UIImageView alloc] initWithFrame:CGRectMake(33, 21, 42, 42)];
    Icon.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:Icon];
    
    UIImageView *iconFrame=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ls_OnLine_frame.png"]];
    frame=iconFrame.frame;
    frame.origin=CGPointMake(32, 19);
    [iconFrame setFrame:frame];
    [self addSubview:iconFrame];

    //  Ribbon
        ribbon=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topPlayerRibbon.png"]];
        frame=ribbon.frame;
        frame.origin=CGPointMake(11 , 0);
        [ribbon setFrame:frame];
        [self addSubview:ribbon];
        
        rankLevel=[[UILabel alloc] initWithFrame:CGRectMake(2, 21, 40 , 11)];
        rankLevel.font = [UIFont systemFontOfSize:10.0f];
        rankLevel.backgroundColor = [UIColor clearColor];
        rankLevel.textColor=[UIColor whiteColor];
        [rankLevel setTextAlignment:UITextAlignmentCenter];
        CGFloat angle = M_PI * -0.25;
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        rankLevel.transform = transform;
        
        [ribbon addSubview:rankLevel]; 
        
        rankLevel.text=@"TOP 10";
    
    
    UIColor *bronzeColor=[UIColor colorWithRed:0.596 green:0.525 blue:0.416 alpha:1];
    UIColor *brownColor=[UIColor colorWithRed:0.38 green:0.267 blue:0.133 alpha:1];
    
    playerName=[[UILabel alloc] initWithFrame:CGRectMake(84 , 18, 135, 16)];
    playerName.textColor = [UIColor blackColor];
    playerName.font = [UIFont systemFontOfSize:14.0f];
    playerName.backgroundColor = [UIColor clearColor];
    [playerName setTextAlignment:UITextAlignmentLeft];
    playerName.textColor=brownColor;
    [self addSubview:playerName];   

    UILabel *coldTitle=[[UILabel alloc] initWithFrame:CGRectMake(84, 39, 28, 11)];
    coldTitle.textColor = [UIColor blackColor];
    coldTitle.font = [UIFont systemFontOfSize:10.0f];
    coldTitle.backgroundColor = [UIColor clearColor];
    coldTitle.text=NSLocalizedString(@"Gold:", @"");
    coldTitle.textColor=bronzeColor;
    [coldTitle setTextAlignment:UITextAlignmentRight];
    [self addSubview:coldTitle];   
    
    gold=[[UILabel alloc] initWithFrame:CGRectMake(112, 39, 105 , 11)];
    gold.textColor = [UIColor blackColor];
    gold.font = [UIFont systemFontOfSize:10.0f];
    gold.backgroundColor = [UIColor clearColor];
    gold.textColor=brownColor;
    [gold setTextAlignment:UITextAlignmentLeft];
    [self addSubview:gold];   
    
    UILabel *runkTitle=[[UILabel alloc] initWithFrame:CGRectMake(84, 54, 28, 11)];
    runkTitle.textColor = [UIColor blackColor];
    runkTitle.font = [UIFont systemFontOfSize:10.0f];
    runkTitle.backgroundColor = [UIColor clearColor];
    runkTitle.text=NSLocalizedString(@"Rank:", @"");
    runkTitle.textColor=bronzeColor;
    [runkTitle setTextAlignment:UITextAlignmentRight];
    [self addSubview:runkTitle];  
    
    rank=[[UILabel alloc] initWithFrame:CGRectMake(112, 54, 105 , 11)];
    rank.font = [UIFont systemFontOfSize:10.0f];
    rank.textColor=brownColor;
    rank.backgroundColor = [UIColor clearColor];
    [rank setTextAlignment:UITextAlignmentLeft];
    [self addSubview:rank];
    
    status=[[UILabel alloc] initWithFrame:CGRectMake(217, 50, 71 , 11)];
    status.font = [UIFont systemFontOfSize:10.0f];
    status.textColor=bronzeColor;
    status.backgroundColor = [UIColor clearColor];
    [status setTextAlignment:UITextAlignmentCenter];
    [self addSubview:status];
    
    btnDuel= [UIButton buttonWithType:UIButtonTypeCustom];
    frame = CGRectMake(217, 18, 71, 30);
    [btnDuel setBackgroundImage:[UIImage imageNamed:@"salon_duel.png"] forState:UIControlStateNormal];
    [btnDuel setFrame:frame];
    [self addSubview:btnDuel];
    
    [btnDuel setTitleByLabel:@"DUEL"];
    [btnDuel changeColorOfTitleByLabel:[UIColor colorWithRed:0.95 green:0.86 blue:0.68 alpha:1.0]];
    
    indicatorConnectin=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(26, 6, 18, 18)];
    [indicatorConnectin setHidesWhenStopped:YES];
    [indicatorConnectin setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [btnDuel addSubview:indicatorConnectin]; 
}

-(void) setPlayerIcon:(UIImage*)iconImage;
{
    [Icon setImage:iconImage];
}

-(void)showIndicatorConnectin;
{
    [indicatorConnectin startAnimating];
    NSArray *arr=[btnDuel subviews];
    UILabel *label1=(UILabel*)[arr objectAtIndex:([arr count]-2)];
    NSLog(@"label1 %@",label1.text);
    [label1 setHidden:YES];
}

-(void)hideIndicatorConnectin;
{
    [indicatorConnectin stopAnimating];
    NSArray *arr=[btnDuel subviews];
    UILabel *label1=(UILabel*)[arr objectAtIndex:([arr count]-2)];
    [label1 setHidden:NO];
}

-(void)setRibbonHide:(BOOL)hide;
{
    if (hide) {
        [ribbon setHidden:YES];
    }else {
        [ribbon setHidden:NO];
    }
}
@end
