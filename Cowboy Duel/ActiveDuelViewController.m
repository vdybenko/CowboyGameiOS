//
//  ActiveDuelViewController.m
//  Cowboy Duels
//
//  Created by Sergey Sobol on 10.01.13.
//
//

#import "ActiveDuelViewController.h"
#import "UIImage+Sprite.h"
#import "math.h"
#import <QuartzCore/QuartzCore.h>
#import "DuelRewardLogicController.h"
#import "FinalViewController.h"
#import "ARView.h"
#import "OponentCoordinateView.h"

#define kFilteringFactor 0.1
#define targetHeight 200
#define targetWeidth 50

@interface ActiveDuelViewController ()
{
    float startPoint;
    BOOL firstAccel;
    UIAccelerationValue rollingX, rollingY, rollingZ;
    CGPoint oldPosition;
    CGPoint centerLocation;
    AVAudioPlayer *shotAudioPlayer1;
    AVAudioPlayer *shotAudioPlayer2;
    AVAudioPlayer *shotAudioPlayer3;
    AVAudioPlayer *hitAudioPlayer;
    AVAudioPlayer *oponentShotAudioPlayer;
    AVAudioPlayer *brockenGlassAudioPlayer;
    int shotCountForSound;
    int shotCountBullet;
    int shotCountBulletForOpponent;
    int maxShotCount;
    int maxShotCountForOpponent;
    int userHitCount;
    AccountDataSource *opAccount;
    AccountDataSource *playerAccount;
    BOOL finalAnimationStarted;
    
    NSTimer *shotTimer;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIView *floatView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *fireImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *opponentImage;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *bloodImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *bloodCImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *buletLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *smokeImage;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *glassImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *oponentLiveImageView;

@end

@implementation ActiveDuelViewController

-(id)initWithTime:(int)randomTime Account:(AccountDataSource *)userAccount oponentAccount:(AccountDataSource *)pOponentAccount
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        playerAccount = userAccount;
        opAccount  = pOponentAccount;
        
                
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/shot.aif", [[NSBundle mainBundle] resourcePath]]];
        
        shotAudioPlayer1 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [shotAudioPlayer1 prepareToPlay];
        
        shotAudioPlayer2 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [shotAudioPlayer2 prepareToPlay];
        
        shotAudioPlayer3 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [shotAudioPlayer3 prepareToPlay];

        url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/cry.aif", [[NSBundle mainBundle] resourcePath]]];

        hitAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [hitAudioPlayer prepareToPlay];
        
        url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/oponent_shot.aif", [[NSBundle mainBundle] resourcePath]]];
        NSError *error;
        oponentShotAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [oponentShotAudioPlayer prepareToPlay];
        
        url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/brocken_glass.aif", [[NSBundle mainBundle] resourcePath]]];
        brockenGlassAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [brockenGlassAudioPlayer prepareToPlay];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImage *spriteSheet = [UIImage imageNamed:@"explosion_4_39_128"];
    NSArray *arrayWithSprites = [spriteSheet spritesWithSpriteSheetImage:spriteSheet
                                                              spriteSize:CGSizeMake(64, 64)];
    [self.fireImageView setAnimationImages:arrayWithSprites];
    float animationDuration = [self.fireImageView.animationImages count] * 0.0100; // 100ms per frame
    [self.fireImageView setAnimationRepeatCount:1];
    [self.fireImageView setAnimationDuration:animationDuration];
    
    UIImage *spriteSheetBlood = [UIImage imageNamed:@"blood_a"];
    NSArray *arrayWithSpritesBlood = [spriteSheetBlood spritesWithSpriteSheetImage:spriteSheetBlood
                                                              spriteSize:CGSizeMake(64, 64)];
    [self.bloodImageView setAnimationImages:arrayWithSpritesBlood];
    float animationDurationBlood = [self.bloodImageView.animationImages count] * 0.100; // 100ms per frame
    [self.bloodImageView setAnimationRepeatCount:1];
    [self.bloodImageView setAnimationDuration:animationDurationBlood];
    
    UIImage *spriteSheetBloodC = [UIImage imageNamed:@"blood_c"];
    NSArray *arrayWithSpritesBloodC = [spriteSheetBloodC spritesWithSpriteSheetImage:spriteSheetBloodC
                                                                        spriteSize:CGSizeMake(64, 64)];
    [self.bloodCImageView setAnimationImages:arrayWithSpritesBloodC];
    float animationDurationBloodC = [self.bloodCImageView.animationImages count] * 0.100; // 100ms per frame
    [self.bloodCImageView setAnimationRepeatCount:1];
    [self.bloodCImageView setAnimationDuration:animationDurationBloodC];
    
    UIImage *spriteSheetSmoke = [UIImage imageNamed:@"smoke"];
    NSArray *arrayWithSpritesSmoke = [spriteSheetSmoke spritesWithSpriteSheetImage:spriteSheetSmoke
                                                                          spriteSize:CGSizeMake(64, 64)];
    [self.smokeImage setAnimationImages:arrayWithSpritesSmoke];
    float animationDurationSmoke = [self.smokeImage.animationImages count] * 0.100; // 100ms per frame
    [self.smokeImage setAnimationRepeatCount:1];
    [self.smokeImage setAnimationDuration:animationDurationSmoke];
    
    shotCountForSound = 1;
    
    ARView *arView = (ARView *)self.view;
	
	// Create array of hard-coded places-of-interest, in this case some famous parks
    CLLocationCoordinate2D poiCoords[] = {{40.7711329, -73.9741874},
        {37.7690400, -122.4835193},
        {32.7343822, -117.1441227},
        {51.5068670, -0.1708030},
        {45.5126399, -73.6802448},
        {40.4152519, -3.6887466}};
    
    int numPois = sizeof(poiCoords) / sizeof(CLLocationCoordinate2D);
    
	NSMutableArray *placesOfInterest = [NSMutableArray arrayWithCapacity:numPois];
//	for (int i = 0; i < numPois; i++) {
		OponentCoordinateView *poi = [OponentCoordinateView oponentCoordinateWithView:self.opponentImage at:[[CLLocation alloc] initWithLatitude:poiCoords[0].latitude longitude:poiCoords[0].longitude]];
		[placesOfInterest insertObject:poi atIndex:0];
//	}
	[arView setPlacesOfInterest:placesOfInterest];


}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    userHitCount = 0;
    
    [self.glassImageView setHidden:YES];
    firstAccel = YES;
    
    [self countUpBulets];
    self.buletLabel.text=[NSString stringWithFormat:@"%d", shotCountBullet];
    [self updateOpponentViewToRamdomPosition];
    shotTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(opponentShot) userInfo:nil repeats:YES];
    ARView *arView = (ARView *)self.view;
	[arView start];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [shotTimer invalidate];
    ARView *arView = (ARView *)self.view;
	[arView stop];
}

- (void)viewDidUnload {
    [self setFloatView:nil];
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [self setFireImageView:nil];
    [self setOpponentImage:nil];
    [self setBloodImageView:nil];
    [self setBloodCImageView:nil];
    [self setBuletLabel:nil];
    [self setSmokeImage:nil];
    [self setGlassImageView:nil];
    [self setOponentLiveImageView:nil];
    [super viewDidUnload];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClick:(id)sender {
    [self dismissModalViewControllerAnimated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)countUpBulets;
{
    int countBullets = [DuelRewardLogicController countUpBuletsWithOponentLevel:opAccount.accountLevel defense:opAccount.accountDefenseValue playerAtack:playerAccount.accountWeapon.dDamage];
    
    shotCountBullet =  countBullets;
    maxShotCount = countBullets;
    
    int countBulletsForOpponent = [DuelRewardLogicController countUpBuletsWithOponentLevel:playerAccount.accountLevel defense:playerAccount.accountDefenseValue playerAtack:opAccount.accountWeapon.dDamage];
    shotCountBulletForOpponent =  countBulletsForOpponent;
    maxShotCountForOpponent = countBulletsForOpponent;
}

-(float)abs:(float)d
{
    if (d<0) return -1.0 * d;
    else return d;
}

- (IBAction)shotButtonClick:(id)sender {
    if ([self.fireImageView isAnimating]) {
        [self.fireImageView stopAnimating];
    }
    [self.fireImageView startAnimating];
    
    self.buletLabel.text=[NSString stringWithFormat:@"%d", shotCountBullet];
    
    switch (shotCountForSound) {
        case 1:
            [shotAudioPlayer1 stop];
            [shotAudioPlayer1 setCurrentTime:0.0];
            [shotAudioPlayer1 play];
            
            shotCountForSound = 2;
            break;
        case 2:
            [shotAudioPlayer2 stop];
            [shotAudioPlayer2 setCurrentTime:0.0];
            [shotAudioPlayer2 play];
            
            shotCountForSound = 3;
            break;
        case 3:
            [shotAudioPlayer3 stop];
            [shotAudioPlayer3 setCurrentTime:0.0];
            [shotAudioPlayer3 play];

            shotCountForSound = 1;
            break;
        default:
            break;
    }
    
    CGPoint targetPoint;
    targetPoint.x = self.opponentImage.center.x - (self.floatView.bounds.size.width / 2 - self.floatView.center.x);
    targetPoint.y = self.opponentImage.center.y - (self.floatView.bounds.size.height / 2 - self.floatView.center.y);
    
    CGPoint centerOfScreanPoint;
    centerOfScreanPoint.x = [UIScreen mainScreen].bounds.size.width / 2;
    centerOfScreanPoint.y = [UIScreen mainScreen].bounds.size.height / 2;
    
    [self cheackHitForShot:centerOfScreanPoint andTargetPoint:targetPoint];
    
    
}

- (void)horizontalFlip{
    
    if (finalAnimationStarted) return;
    else finalAnimationStarted = YES;
    
    self.opponentImage.layer.transform = CATransform3DMakeTranslation(0.0, 0.0, 200.0);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.opponentImage.layer.transform = CATransform3DMakeRotation(M_PI,0.0,1.0,0.0);
    } completion:^(BOOL finished) {
        self.opponentImage.layer.transform = CATransform3DMakeTranslation(0.0, 0.0, 200.0);
        [UIView animateWithDuration:0.5 animations:^{
            self.opponentImage.layer.transform = CATransform3DMakeScale(0, 0, 0);
        } completion:^(BOOL finished) {
            [self.opponentImage setHidden:YES];
            finalAnimationStarted = NO;
            self.opponentImage.layer.transform = CATransform3DMakeScale(1, 1, 1);
        }];
        
    }];
    
}

-(void)cheackHitForShot:(CGPoint)shotPoint andTargetPoint:(CGPoint)targetPoint
{
    if (([self abs:(shotPoint.x - targetPoint.x)] < targetWeidth / 2) && ([self abs:(shotPoint.y - targetPoint.y)] < targetHeight / 2)) {
        [self startRandomBloodAnimation];
        shotCountBullet--;
        
        userHitCount++;
        
        CGRect frame = self.oponentLiveImageView.frame;
        frame.size.width = ((float)(maxShotCount - userHitCount))/(float)maxShotCount * frame.size.width;
        self.oponentLiveImageView.frame = frame;
        
        [hitAudioPlayer stop];
        [hitAudioPlayer setCurrentTime:0.0];
        [hitAudioPlayer play];
        
        
        if(!shotCountBullet) [self opponentLost];
    }
}

-(void)startRandomBloodAnimation
{
    int numberOfAnimation = rand() % 5;
    switch (numberOfAnimation) {
        case 0:
            {
                [self.bloodImageView startAnimating];
            }
            break;
        case 1:
            {
                [self.bloodCImageView startAnimating];
            }
            break;
        case 2:
            {
                [self.bloodImageView startAnimating];
            }
            break;
        case 3:
            {
                [self.bloodCImageView startAnimating];
            }
            break;
        case 4:
            {
                [self.bloodImageView startAnimating];
            }
            break;
        default:
            break;
    }
}

-(void)updateOpponentViewToRamdomPosition
{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGPoint opponentCenter = self.opponentImage.center;
    int randPosition = rand() % ((int)(self.floatView.bounds.size.width - winSize.width - self.opponentImage.bounds.size.width));
    randPosition = randPosition + winSize.width / 2 + self.opponentImage.bounds.size.width / 2;
    
    opponentCenter.x = randPosition;
    self.opponentImage.center = opponentCenter;
    
    [self.opponentImage setHidden:NO];
}

-(void)opponentShot
{
    if ([self.smokeImage isAnimating]) {
        [self.smokeImage stopAnimating];
    }
    [self.smokeImage startAnimating];
    [oponentShotAudioPlayer setCurrentTime:0];
    [oponentShotAudioPlayer play];
    if (!shotCountBulletForOpponent) [self userLost];
    
    shotCountBulletForOpponent--;
}

-(void)opponentLost
{
    [self horizontalFlip];
    [self endDuel];
}

-(void)userLost
{
    [self.glassImageView setHidden:NO];
    [brockenGlassAudioPlayer play];
    [self endDuel];
}

-(void)endDuel
{
    [shotTimer invalidate];
    [self performSelector:@selector(dismissController) withObject:nil afterDelay:2.0];
}

- (void) dismissController {
    FinalViewController *finalViewController = [[FinalViewController alloc] initWithUserTime:nil andOponentTime:nil andGameCenterController:self andTeaching:YES andAccount:playerAccount andOpAccount:opAccount];
    [self.navigationController pushViewController:finalViewController animated:YES];
}

#pragma mark -
-(void)increaseMutchNumberLose
{
    
}
-(void)increaseMutchNumber
{
    
}
-(void)increaseMutchNumberWin
{
    
}

-(int)fMutchNumberLose
{
    return 0;
}
-(int)fMutchNumber
{
    return 2;
}
-(int)fMutchNumberWin
{
    return 2;
}


@end
