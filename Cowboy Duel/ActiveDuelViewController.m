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
//#import "ARView.h"
#import "OponentCoordinateView.h"
#import "StartViewController.h"
#import "GunDrumViewController.h"
#import "WomanShape.h"
#import "OpponentShape.h"

#define targetHeight 260
#define targetWeidth 100
#define MOVE_DISTANCE 100
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
    NSTimer *moveTimer;
    NSTimer *ignoreTimer;
    
    int time;
    
    BOOL arrowAnimationContinue;
    
    BOOL foll;
    BOOL duelTimerEnd;
    BOOL duelEnd;
    
    GunDrumViewController  *gunDrumViewController;
    ProfileViewController *profileViewController;
    ActivityIndicatorView *activityIndicatorView;
    NSMutableArray *oponentsViewCoordinates;
    float steadyScale;
    float scaleDelta;
    
    BOOL isGunCanShotOfFrequently;
    BOOL oponnentFoll;
    BOOL oponnentFollSend;
    
    int opponentTime;
    
    __weak IBOutlet WomanShape *womanShape;
    __weak IBOutlet OpponentShape *opponentShape;
    IconDownloader *iconDownloader;
    __weak IBOutlet UIImageView *blinkBottom;
    __weak IBOutlet UIImageView *blinkTop;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIView *floatView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *fireImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *bloodImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *bloodCImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *smokeImage;
@property (weak, nonatomic) IBOutlet UIView *glassImageViewAllBackground;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *glassImageViewHeader;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *glassImageViewBottom;
@property (weak, nonatomic) IBOutlet UIButton *gunButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *opStatsLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *userStatsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleSteadyFire;
@property (weak, nonatomic) IBOutlet FXLabel *lblBehold;
@property (weak, nonatomic) IBOutlet UIImageView *crossImageView;
@property (weak, nonatomic) IBOutlet UIView *userLiveImageView;

@end

@implementation ActiveDuelViewController
@synthesize delegate;
@synthesize glassImageViewAllBackground;

static CGFloat userLiveImageViewStartWidth;
static CGFloat blinkTopOriginY;
static CGFloat blinkBottomOriginY;

-(id)initWithTime:(int)randomTime Account:(AccountDataSource *)userAccount oponentAccount:(AccountDataSource *)pOponentAccount
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        // Custom initialization
        playerAccount = userAccount;
        opAccount  = pOponentAccount;
        time = randomTime + 5;
        
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/shot.aif", [[NSBundle mainBundle] resourcePath]]];
        
        shotAudioPlayer1 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [shotAudioPlayer1 prepareToPlay];
        
        shotAudioPlayer2 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [shotAudioPlayer2 prepareToPlay];
        
        shotAudioPlayer3 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [shotAudioPlayer3 prepareToPlay];

        url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/cry.mp3", [[NSBundle mainBundle] resourcePath]]];

        hitAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [hitAudioPlayer prepareToPlay];
        
        NSError *error;
        url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/brocken_glass.aif", [[NSBundle mainBundle] resourcePath]]];
        brockenGlassAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [brockenGlassAudioPlayer prepareToPlay];
        
        [StartViewController sharedInstance].playerStop;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
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
    
//    UIImage *spriteSheetSmoke = [UIImage imageNamed:@"smokeSpriteSheet"];
//    NSArray *arrayWithSpritesSmoke = [spriteSheetSmoke spritesWithSpriteSheetImage:spriteSheetSmoke
//                                                                          spriteSize:CGSizeMake(64, 64)];
//    [self.smokeImage setAnimationImages:arrayWithSpritesSmoke];
//    
//    float animationDurationSmoke = [self.smokeImage.animationImages count] * 0.100; // 100ms per frame
//    [self.smokeImage setAnimationRepeatCount:1];
//    [self.smokeImage setAnimationDuration:animationDurationSmoke];
    
    shotCountForSound = 1;

    plView = (PLView *)self.view;
    
    plView.camera.pitchRange = PLRangeMake (-180, 180);
    plView.camera.rollRange = PLRangeMake (-180, 180);
    plView.camera.yawRange = PLRangeMake (-180, 180);
    
    NSString *syfics = @"";
    if ([Utils isiPhoneRetina]) {
//        syfics = @"@2x";
    }
    PLCubicPanorama *cubicPanorama = [PLCubicPanorama panorama];
    [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pano_f%@",syfics] ofType:@"jpg"]]] face:PLCubeFaceOrientationFront];
    [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pano_b%@",syfics] ofType:@"jpg"]]] face:PLCubeFaceOrientationBack];
    [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pano_l%@",syfics] ofType:@"jpg"]]] face:PLCubeFaceOrientationLeft];
    [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pano_r%@",syfics] ofType:@"jpg"]]] face:PLCubeFaceOrientationRight];
    [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pano_u%@",syfics] ofType:@"jpg"]]] face:PLCubeFaceOrientationUp];
    [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pano_d%@",syfics] ofType:@"jpg"]]] face:PLCubeFaceOrientationDown];
    [plView setPanorama:cubicPanorama];
    
    [self hideHelpViewOnStartDuel];
    
    int iPhone5Delta = [UIScreen mainScreen].bounds.size.height - 480;
    CGRect deltaFrame = plView.frame;
    deltaFrame.size.height += iPhone5Delta;
    [plView setFrame:deltaFrame];
    
    CLLocationCoordinate2D oponentCoords;
    if(!delegate && !opAccount.bot)
    {
        oponentCoords.latitude = 1;//(((float) rand()) / RAND_MAX) * 360 - 180;
        oponentCoords.longitude = 1;// (((float) rand()) / RAND_MAX) * 360 - 180;
    }else{
        oponentCoords.latitude = (((float) rand()) / RAND_MAX) * 360 - 180;
        oponentCoords.longitude = (((float) rand()) / RAND_MAX) * 360 - 180;
        
    }
    
	oponentsViewCoordinates = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < 5; i++) {
        
        UIImageView *obstracleImage;
        CGRect obstracleImageFrame;
        int randomNumber = arc4random() % 2;
        switch (randomNumber) {
            case 0:
                obstracleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bochka.png"]];
                obstracleImageFrame = obstracleImage.frame;
                obstracleImageFrame.origin.y = 240;
                break;
            case 1:
                obstracleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cactus.png"]];
                obstracleImageFrame = obstracleImage.frame;
                obstracleImageFrame.origin.y = 175;
                break;
            default:
                break;
        }
        obstracleImageFrame.origin.x = (((float) rand()) / RAND_MAX) * 800;
        obstracleImage.frame = obstracleImageFrame;
        obstracleImage.tag = 1;
        [self.floatView addSubview:obstracleImage];
    }
    
    OponentCoordinateView *poi = [OponentCoordinateView oponentCoordinateWithView:self.floatView at:[[CLLocation alloc] initWithLatitude:oponentCoords.latitude longitude:oponentCoords.longitude]];
    [oponentsViewCoordinates addObject:poi];
    [plView setOponentCoordinates:oponentsViewCoordinates];
    
    //    int index = [self.view.subviews indexOfObject:self.glassImageView];
    //    [self.view exchangeSubviewAtIndex:([self.view.subviews count] - 1) withSubviewAtIndex:index];
    int index = [self.view.subviews indexOfObject:self.crossImageView];
    [self.view exchangeSubviewAtIndex:([self.view.subviews count] - 2) withSubviewAtIndex:index];
    
    gunDrumViewController = [[GunDrumViewController alloc] initWithNibName:Nil bundle:Nil];

    [self.view addSubview:gunDrumViewController.view];
    [self.view exchangeSubviewAtIndex:([self.view.subviews count] - 1) withSubviewAtIndex:([self.view.subviews count] - 3)];
    
    index = [self.view.subviews indexOfObject:self.gunButton];
    [self.view exchangeSubviewAtIndex:([self.view.subviews count] - 1) withSubviewAtIndex:index];
    
    [self.view bringSubviewToFront:self.glassImageViewBottom];
    [self.view bringSubviewToFront:self.glassImageViewHeader];
    [self.view bringSubviewToFront:glassImageViewAllBackground];

    CGRect frame;
    activityIndicatorView = [[ActivityIndicatorView alloc] init];
    frame = activityIndicatorView.frame;
    frame.origin = CGPointMake(0,0);
    activityIndicatorView.frame = frame;
    [self.view addSubview:activityIndicatorView];
    
    blinkTopOriginY = blinkTop.frame.origin.y;
    blinkBottomOriginY = blinkBottom.frame.origin.y;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ignoreTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(userIgnorePunish) userInfo:nil repeats:NO];
    foll = NO;
    duelTimerEnd = NO;
    duelEnd = NO;
    follAccelCheck = NO;
    accelerometerState = NO;
    soundStart = NO;
    isGunCanShotOfFrequently = YES;
    
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(3.0 / 60.0)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    [gunDrumViewController showGun];
    self.gunButton.hidden = YES;
    self.crossImageView.hidden = YES;
    
    [self showHelpViewOnStartDuel];
    
    userHitCount = 0;
    
    [glassImageViewAllBackground setHidden:YES];
    [self.glassImageViewHeader setHidden:YES];
    [self.glassImageViewBottom setHidden:YES];
    
    [self.userLiveImageView setHidden:YES];
    
    firstAccel = YES;
    
    [self countUpBulets];
    [self updateOpponentViewToRamdomPosition];
    [womanShape randomPositionWithView:opponentShape];
    
	[plView startAnimation];
    
    [activityIndicatorView hideView];
    [self.gunButton setEnabled:NO];
    
    userLiveImageViewStartWidth = self.userLiveImageView.frame.size.width;
    
    self.opStatsLabel.text = [NSString stringWithFormat: @"A: +%d\rD: +%d",opAccount.accountWeapon.dDamage,opAccount.accountDefenseValue];
    self.userStatsLabel.text = [NSString stringWithFormat: @"A: +%d\nD: +%d",playerAccount.accountWeapon.dDamage,playerAccount.accountDefenseValue];
    [self.titleSteadyFire setHidden:YES];
    [self.lblBehold setHidden:YES];
    

    [self.lblBehold setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:25]];
    self.lblBehold.text = NSLocalizedString(@"Behold!", @"");
    self.lblBehold.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
    self.lblBehold.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
  
    steadyScale = 1.0;
    
    opponentShape.hidden = YES;
    womanShape.hidden = YES;
    
    if(!delegate)
    {
        if (!opAccount.bot) opponentTime=7000;
        else{
            int countBullets = [DuelRewardLogicController countUpBuletsWithOponentLevel:[AccountDataSource sharedInstance].accountLevel defense:[AccountDataSource sharedInstance].accountDefenseValue playerAtack:opAccount.accountWeapon.dDamage];
            
            
            //opponentTime = 3000 + countBullets * (220 + rand() % 160);
            DLog(@"bot opponentTime %d", opponentTime);
        }
    }
   [plView startSensorialRotation];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [gunDrumViewController hideGun];
    [shotTimer invalidate];
    [moveTimer invalidate];
    [ignoreTimer invalidate];
    plView = (PLView *)self.view;
    [plView stopSensorialRotation];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [opponentShape setStatusBody:OpponentShapeStatusLive];
    [opponentShape cleareDamage];
    [opponentShape refreshLiveBar];
    CGRect frame = self.userLiveImageView.frame;
    frame.size.width = userLiveImageViewStartWidth;
    self.userLiveImageView.frame = frame;
}

- (void)viewDidUnload {
    [self releaseComponents];
    blinkBottom = nil;
    blinkBottom = nil;
    opponentShape = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //[self releaseComponents];
    // Dispose of any resources that can be recreated.
}

#pragma mark
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
    if (isGunCanShotOfFrequently) {
        [self startGunFrequentlyBlockTime];
        
        if(delegate)
        {
            [delegate sendShot];
        }
    
        [gunDrumViewController shotAnimation];
        [self hideSteadyImage];
        
        switch (shotCountForSound) {
            case 1:
                [self.titleSteadyFire setHidden:YES];
                [self.lblBehold setHidden:YES];
                //self.gunButton.hidden = NO;
                
                [shotAudioPlayer1 stop];
                [shotAudioPlayer1 setCurrentTime:0.0];
                [shotAudioPlayer1 performSelectorInBackground:@selector(play) withObject:nil];
                
                shotCountForSound = 2;
                
                break;
            case 2:
                [shotAudioPlayer2 stop];
                [shotAudioPlayer2 setCurrentTime:0.0];
                [shotAudioPlayer2 performSelectorInBackground:@selector(play) withObject:nil];
                
                shotCountForSound = 3;
                break;
            case 3:
                [shotAudioPlayer3 stop];
                [shotAudioPlayer3 setCurrentTime:0.0];
                [shotAudioPlayer3 performSelectorInBackground:@selector(play) withObject:nil];

                shotCountForSound = 1;
                break;
            default:
                break;
        }
        
        CGPoint targetPoint;
        targetPoint.x = opponentShape.center.x - (self.floatView.bounds.size.width / 2 - self.floatView.center.x);
        targetPoint.y = opponentShape.center.y - (self.floatView.bounds.size.height / 2 - self.floatView.center.y);
        
        CGPoint centerOfScreanPoint;
        centerOfScreanPoint.x = self.crossImageView.bounds.origin.x + self.crossImageView.center.x;
        centerOfScreanPoint.y = self.crossImageView.bounds.origin.y + self.crossImageView.center.y;
        
        [self cheackHitForShot:centerOfScreanPoint andTargetPoint:targetPoint];
    }
}

- (void)horizontalFlip{
    
    if (duelEnd) return;
    duelEnd = YES;
    
    if (finalAnimationStarted) return;
    else finalAnimationStarted = YES;
    
    opponentShape.layer.transform = CATransform3DMakeTranslation(0.0, 0.0, 200.0);
    
    [UIView animateWithDuration:0.5 animations:^{
        opponentShape.layer.transform = CATransform3DMakeRotation(M_PI,0.0,1.0,0.0);
    } completion:^(BOOL finished) {
        opponentShape.layer.transform = CATransform3DMakeTranslation(0.0, 0.0, 200.0);
        [UIView animateWithDuration:0.5 animations:^{
            opponentShape.layer.transform = CATransform3DMakeScale(0, 0, 0);
        } completion:^(BOOL finished) {
            [opponentShape setHidden:YES];
            finalAnimationStarted = NO;
            opponentShape.layer.transform = CATransform3DMakeScale(1, 1, 1);
        }];
    }];
    
}

-(void)cheackHitForShot:(CGPoint)shotPoint andTargetPoint:(CGPoint)targetPoint
{
    BOOL result = [womanShape shotInWomanWithPoint:shotPoint superViewOfPoint:self.view];
    if (result) {
        [self opponentShot];
        return;
    }
    
    for (UIImageView *obstracle in self.floatView.subviews) {
        if(obstracle.tag != 1) continue;
        CGRect obstracleFrame = obstracle.frame;
        obstracleFrame.origin.x = obstracle.frame.origin.x - (self.floatView.bounds.size.width / 2 - self.floatView.center.x);
        obstracleFrame.origin.y = obstracle.frame.origin.y - (self.floatView.bounds.size.height / 2 - self.floatView.center.y);
        if (CGRectContainsPoint(obstracleFrame, shotPoint)) {
            return;
        }
        
    }
    
    if (([self abs:(shotPoint.x - targetPoint.x)] < targetWeidth / 2) && ([self abs:(shotPoint.y - targetPoint.y)] < targetHeight / 2)) {
        
        shotCountBullet--;
        
        userHitCount++;
        
        [opponentShape changeLiveBarWithUserHitCount:userHitCount maxShotCount:maxShotCount];
        
        CGPoint targetPoint;
        targetPoint.x = opponentShape.center.x - (self.floatView.bounds.size.width / 2 - self.floatView.center.x);
        targetPoint.y = opponentShape.center.y - (self.floatView.bounds.size.height / 2 - self.floatView.center.y);
        
        CGPoint centerOfScreanPoint;
        centerOfScreanPoint.x = self.crossImageView.bounds.origin.x + self.crossImageView.center.x;
        centerOfScreanPoint.y = self.crossImageView.bounds.origin.y + self.crossImageView.center.y;
        
        CGRect opponentBodyFrame = [[opponentShape.imgBody superview] convertRect:opponentShape.imgBody.frame toView:self.view];
            
        if (CGRectContainsPoint(opponentBodyFrame, shotPoint)) {
            [self startRandomBloodAnimation];
            [opponentShape hitTheOponentWithPoint:shotPoint mainView:self.view];
        }
        
        if(!shotCountBullet) {
            if (duelEnd) return;
            duelEnd = YES;
            [activityIndicatorView setText:@""];
            [activityIndicatorView showView];
            [self horizontalFlip];
            if(!delegate)
            {
                DLog(@"Kill!!!");
                DLog(@"Shot Time = %d.%d", (shotTime - time * 1000) / 1000, (shotTime - time * 1000));
                
                FinalViewController *finalViewController = [[FinalViewController alloc] initWithUserTime:(shotTime - time * 1000) andOponentTime:opponentTime andGameCenterController:self andTeaching:YES andAccount: playerAccount andOpAccount:opAccount];
                
                [self performSelector:@selector(dismissWithController:) withObject:finalViewController afterDelay:2.0];
                [timer invalidate];
                [moveTimer invalidate];
            } 
            else
            {
                DLog(@"try send shot time");
                if ([delegate respondsToSelector:@selector(sendShotTime:)])
                    [delegate sendShotTime:(shotTime - time * 1000)];
            }
            [self opponentLost];
        }
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
    CGPoint opponentCenter = opponentShape.center;
    int randPosition = rand() % ((int)(self.floatView.bounds.size.width - winSize.width - opponentShape.bounds.size.width));
    randPosition = randPosition + winSize.width / 2 + opponentShape.bounds.size.width / 2;
    
    opponentCenter.x = randPosition;
    opponentShape.center = opponentCenter;
}

-(void)opponentShot
{
    if (duelEnd) return;

    [opponentShape shot];
    
    CGRect frame = self.userLiveImageView.frame;
    frame.size.width = (float)((shotCountBulletForOpponent)*userLiveImageViewStartWidth)/maxShotCountForOpponent;
    self.userLiveImageView.frame = frame;
    
    if(!shotCountBulletForOpponent){
        [self userLost];
        FinalViewController *finalViewController = [[FinalViewController alloc] initWithUserTime:(shotTime - time * 1000) andOponentTime:999999 andGameCenterController:self andTeaching:YES andAccount: playerAccount andOpAccount:opAccount];

        [self performSelector:@selector(dismissWithController:) withObject:finalViewController afterDelay:1.0];
        [timer invalidate];
        [moveTimer invalidate];
    }
    shotCountBulletForOpponent--;
    
    
}

-(void)opponentLost
{
    [opponentShape setStatusBody:OpponentShapeStatusDead];
}

-(void)userIgnorePunish
{
    if (duelIsStarted){
        [ignoreTimer invalidate];
        return;
    }
    
    [self userLost];

    if ([delegate respondsToSelector:@selector(lostConnection)]) {
        [delegate performSelector:@selector( lostConnection )];
    }else
    {
        FinalViewController *finalViewController = [[FinalViewController alloc] initWithUserTime:0 andOponentTime:10 andGameCenterController:self andTeaching:YES andAccount: playerAccount andOpAccount:opAccount];
        
        [self performSelector:@selector(dismissWithController:) withObject:finalViewController afterDelay:2.0];
    }
}

-(void)userLost
{
    if (duelEnd) return;
    duelEnd = YES;
    
    CGRect frame = blinkTop.frame;
    frame.origin.y = blinkTopOriginY;
    blinkTop.frame = frame;
    
    frame = blinkBottom.frame;
    frame.origin.y = blinkBottomOriginY;
    blinkBottom.frame = frame;
    
    [self.glassImageViewHeader setHidden:NO];
    [self.glassImageViewBottom setHidden:NO];
    [glassImageViewAllBackground setHidden:NO];
    
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = blinkBottom.frame;
        frame.origin.y = 151;
        blinkBottom.frame = frame;
        
        frame = blinkTop.frame;
        frame.origin.y = 0;
        blinkTop.frame = frame;
        
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = blinkBottom.frame;
            frame.origin.y = 201;
            blinkBottom.frame = frame;
            
            frame = blinkTop.frame;
            frame.origin.y = -30;
            blinkTop.frame = frame;
        }completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = blinkBottom.frame;
            frame.origin.y = 151;
            blinkBottom.frame = frame;
            
            frame = blinkTop.frame;
            frame.origin.y = 0;
            blinkTop.frame = frame;
        }completion:^(BOOL finished) {
        }];

        }];
    }];

    
    [brockenGlassAudioPlayer play];
    [timer invalidate];
    [moveTimer invalidate];
    
    self.gunButton.hidden = YES;
    [ignoreTimer invalidate];
}

- (void) dismissWithController:(UIViewController *)controller {
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark UIAccelerometer delegate

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    rollingX = (acceleration.x * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
    rollingY = (acceleration.y * kFilteringFactor) + (rollingY * (1.0 - kFilteringFactor));
    rollingZ = (acceleration.z * kFilteringFactor) + (rollingZ * (1.0 - kFilteringFactor));

    //        Position for Shot
    if ((acceleration.y < -0.5) || (rollingX < -0.3) || (rollingX > 0.3)) accelerometerState = NO;
    
    //       Position for STEADY
    if (((acceleration.y > -0.4) && (rollingX > -0.3) && (rollingX < 0.3)) && rollingZ < 0) accelerometerState = YES;
            
    if((accelerometerState)&& (!soundStart)){
        
        if(oponnentFollSend){
            oponnentFollSend = NO;
            accelerometerStateSend = NO;
        }
        
        if (!accelerometerStateSend) {
            if ([delegate respondsToSelector:@selector(setAccelStateTrue)])
                [delegate setAccelStateTrue];
            [self readyToStart];
            [ignoreTimer invalidate];
            accelerometerStateSend = YES;
        
        }else {
            if(!delegate)[self startDuel];
        }
    }
    else {
        if ([delegate respondsToSelector:@selector(setAccelStateFalse)])
            [delegate setAccelStateFalse];
        accelerometerStateSend = NO;
        }
    
    if ((!accelerometerState) && (soundStart) && (!duelIsStarted)) {
        if(!follAccelCheck){
            [self restartCountdown];
            if(!oponnentFollSend){
                oponnentFollSend = YES;
                [delegate follStart];
            }

        }
    }

}

#pragma mark

-(void)restartCountdown;
{
    NSLog(@"restartCountdown");
    
    follAccelCheck = NO;
    accelerometerState = NO;
    soundStart = NO;
    
    [timer invalidate];
    [player stop];
    [player setCurrentTime:0.0];
    [self showHelpViewOnStartDuel];
}

-(void)shotTimer
{
    nowInterval = [NSDate timeIntervalSinceReferenceDate];
    activityInterval = (nowInterval-startInterval)*1000;
    shotTime = (int)activityInterval;
    
    UIViewController *curentVC=[self.navigationController visibleViewController];
    if ((shotTime * 0.001 >= time) && (!duelIsStarted) && (!foll)&&([curentVC isEqual:self])) {
        DLog(@"FIRE !!!!!");
        duelIsStarted = YES;
        [ignoreTimer invalidate];
        [gunDrumViewController hideGun];
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fire.mp3", [[NSBundle mainBundle] resourcePath]]];
        NSError *error;
        [player stop];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [player play];
        [self vibrationStart];
        [self.gunButton setEnabled:YES];
        [self.userLiveImageView setHidden:NO];
        opponentShape.hidden = NO;
        womanShape.hidden = NO;
        
        if(!delegate) shotTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(opponentShot) userInfo:nil repeats:YES];
        moveTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(moveOponent) userInfo:nil repeats:YES];
    }
    if ((shotTime * 0.001 >= 30.0) && (!duelTimerEnd) && (soundStart)) {
        if ([delegate respondsToSelector:@selector(duelTimerEnd)])
            [delegate duelTimerEnd];
        duelTimerEnd = YES;
        [timer invalidate];
    }
    
//    if (!delegate) {
//        if (shotTime - time * 1000 > opponentTime) {
//            [self userLost];
//            FinalViewController *finalViewController = [[FinalViewController alloc] initWithUserTime:(shotTime - time * 1000) andOponentTime:opponentTime andGameCenterController:self andTeaching:YES andAccount: playerAccount andOpAccount:opAccount];
//            
//            [self performSelector:@selector(dismissWithController:) withObject:finalViewController afterDelay:2.0];
//            [timer invalidate];
//            [moveTimer invalidate];
//        }
//    }
}

#pragma mark

-(void)hideHelpViewOnStartDuel;
{
    arrowAnimationContinue = NO;    
}

-(void)showHelpViewOnStartDuel;
{
    [gunDrumViewController showGun];
    [gunDrumViewController closeDump];
    self.gunButton.hidden = YES;
}

#pragma mark

-(void)scaleView:(UIView *)viewForAnimation
{
    [UIView animateWithDuration:0.4 animations:^{
        viewForAnimation.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL complete) {
        if(!arrowAnimationContinue) return;
        [UIView animateWithDuration:0.4 animations:^{
            viewForAnimation.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }completion:^(BOOL complete){
            if(arrowAnimationContinue){
                [self scaleView:viewForAnimation];
            }
        }];
    }];
}

-(void)vibrationStart;
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    [self.titleSteadyFire setHidden:NO];

    [self.lblBehold setHidden:NO];
    self.gunButton.hidden = NO;
        
    [self setScale];
}

-(void)duelTimerEndFeedBack
{
    duelTimerEnd = YES;
}

-(void)moveOponent
{
    [opponentShape performSelectorInBackground:@selector(moveOponentInBackground) withObject:nil];
}

-(void)setScale
{
    if (steadyScale >= 1.3) scaleDelta = -0.01;
    if (steadyScale <= 1.0) scaleDelta = 0.02;
    steadyScale += scaleDelta;
    if(duelIsStarted){
        [self performSelector:@selector(hideSteadyImage) withObject:nil afterDelay:2.5];
    }
    CGAffineTransform steadyTransform = CGAffineTransformMakeScale( steadyScale+scaleDelta*2, steadyScale+scaleDelta*2);
    self.titleSteadyFire.transform = steadyTransform;
    CGAffineTransform beholdTransform = CGAffineTransformMakeScale( steadyScale, steadyScale);
    self.lblBehold.transform = beholdTransform;
}


-(void)hideSteadyImage
{
    steadyScale = 1.0;
    [self.titleSteadyFire setHidden:YES];
    [self.lblBehold setHidden:YES];
    self.crossImageView.hidden = NO;
}

#pragma mark - Frequently of gun

-(void)finishGunFrequentlyBlockTime
{
    isGunCanShotOfFrequently = YES;
}

-(void)startGunFrequentlyBlockTime
{
    isGunCanShotOfFrequently = NO;
    [self performSelector:@selector(finishGunFrequentlyBlockTime) withObject:Nil afterDelay:playerAccount.accountWeapon.dFrequently];
}

#pragma mark - IBAction
- (void)cancelHelpArmClick:(id)sender {
    [self hideHelpViewOnStartDuel];
}

-(void)shutDownTimer;
{
    [timer invalidate];
}

-(void)oponnentFollStart
{
    follAccelCheck = NO;
    soundStart = NO;
    
    [timer invalidate];
    [player stop];
    [player setCurrentTime:0.0];
}

-(void)oponnentFollEnd
{
    oponnentFoll = NO;
}

-(void)startDuel
{
    if (duelIsStarted) return;
    
    UIViewController *curentVC=[self.navigationController visibleViewController];
    if ([curentVC isEqual:self]) {
        DLog(@"FIRE !!!!!");
        duelIsStarted = YES;
        [gunDrumViewController hideGun];
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fire.mp3", [[NSBundle mainBundle] resourcePath]]];
        NSError *error;
        [player stop];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [player play];
        [self vibrationStart];
        [self.gunButton setEnabled:YES];
        if(!delegate) shotTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(opponentShot) userInfo:nil repeats:YES];
        moveTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(moveOponent) userInfo:nil repeats:YES];
        opponentShape.hidden = NO;
        womanShape.hidden = NO;
    }
}

-(void)readyToStart
{
    NSLog(@"startDuel");
    soundStart = YES;
    startInterval = [NSDate timeIntervalSinceReferenceDate];
    gunDrumViewController.chargeTime = time - 0.7;
    [player stop];
    [player setCurrentTime:0.0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Duel.mp3", [[NSBundle mainBundle] resourcePath]]];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player play];
    if(!delegate) timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(shotTimer) userInfo:nil repeats:YES];
    duelIsStarted = NO;
    fireSound = NO;
    acelStatus = YES;
    shotTime = 0;
    
    [self hideHelpViewOnStartDuel];
    
    [gunDrumViewController openGun];
}

#pragma ActiveDuelViewControllerDelegate
-(BOOL)accelerometerSendPositionSecond
{
    return accelerometerState;
}

-(void)releaseComponents
{
    [self setFloatView:nil];
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [self setFireImageView:nil];
    [self setBloodImageView:nil];
    [self setBloodCImageView:nil];
    [self setSmokeImage:nil];
    [self setGlassImageViewHeader:nil];
    [self setGlassImageViewBottom:nil];
    [self setGunButton:nil];
    [self setOpStatsLabel:nil];
    [self setUserStatsLabel:nil];
    [self setTitleSteadyFire:nil];
    [self setLblBehold:nil];
    [self setCrossImageView:nil];
    [self setGlassImageViewAllBackground:nil];
    [self setUserLiveImageView:nil];
    [womanShape releaseComponents];
    womanShape = nil;
    [opponentShape releaseComponents];
    opponentShape = nil;
    plView = nil;
    [super viewDidUnload];

}

@end
