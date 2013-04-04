//
//  ActiveDuelViewController.m
//  Cowboy Duels
//
//  Created by Sergey Sobol on 10.01.13.
//
//

#import "ActiveDuelViewController.h"
#import "UIImage+Sprite.h"
#import "UIButton+Image+Title.h"
#import "math.h"
#import <QuartzCore/QuartzCore.h>
#import "DuelRewardLogicController.h"
#import "FinalViewController.h"
#import "OponentCoordinateView.h"
#import "StartViewController.h"
#import "GunDrumViewController.h"
#import "WomanShape.h"
#import "OpponentShape.h"
#import "GoodCowboy.h"
#import "ArrowToOpponent.h"
#import "BarellsObject.h"
#import "CactusObject.h"
#import "AirBallon.h"
#import "HorseShape.h"
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
        
    BOOL arrowAnimationContinue;
    
    BOOL foll;
    BOOL duelTimerEnd;
    BOOL duelEnd;

    NSMutableArray *barellObjectArray;
    NSMutableArray *cactusObjectArray;
    
    BarellsObject *barellObject;

    CactusObject *cactusObject;
    
//depends on opponent stats:
    int countOfBarrels;
    int countOfCactuses;

    AirBallon *airBallon;
    
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
    
    HorseShape *horseShape;
    GoodCowboy *goodCowboyShape;
    WomanShape *womanShape;
    OpponentShape *opponentShape;
  
    __weak IBOutlet UIImageView *blinkBottom;
    __weak IBOutlet UIImageView *blinkTop;
    __weak IBOutlet ArrowToOpponent *arrowToOpponent;
    
    
}

@property (unsafe_unretained, nonatomic) IBOutlet UIView *floatView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *fireImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *bloodImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *bloodCImageView;
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
@property (weak, nonatomic) IBOutlet UILabel *lbUserLifeLeft;

@property (weak, nonatomic) IBOutlet UIButton *btnSkip;


@end

@implementation ActiveDuelViewController
@synthesize delegate;
@synthesize glassImageViewAllBackground;
@synthesize lbUserLifeLeft;
@synthesize btnSkip;

static CGFloat userLiveImageViewStartWidth;
static CGFloat blinkTopOriginY;
static CGFloat blinkBottomOriginY;

-(id)initWithAccount:(AccountDataSource *)userAccount oponentAccount:(AccountDataSource *)pOponentAccount
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
    [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pano_f%@",syfics] ofType:@"png"]]] face:PLCubeFaceOrientationFront];
    [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pano_b%@",syfics] ofType:@"png"]]] face:PLCubeFaceOrientationBack];
    [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pano_l%@",syfics] ofType:@"png"]]] face:PLCubeFaceOrientationLeft];
    [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pano_r%@",syfics] ofType:@"png"]]] face:PLCubeFaceOrientationRight];
    [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pano_u%@",syfics] ofType:@"png"]]] face:PLCubeFaceOrientationUp];
    [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pano_d%@",syfics] ofType:@"png"]]] face:PLCubeFaceOrientationDown];
    [plView setPanorama:cubicPanorama];
    
    [self hideHelpViewOnStartDuel];
    
    int iPhone5Delta = [UIScreen mainScreen].bounds.size.height - 480;
    CGRect deltaFrame = plView.frame;
    deltaFrame.size.height += iPhone5Delta;
    [plView setFrame:deltaFrame];
    
    CLLocationCoordinate2D oponentCoords;

    oponentCoords.latitude = 1;//(((float) rand()) / RAND_MAX) * 360 - 180;
    oponentCoords.longitude = 1;// (((float) rand()) / RAND_MAX) * 360 - 180;
	oponentsViewCoordinates = [NSMutableArray arrayWithCapacity:1];
    
    NSArray *barriersArray = [DuelProductDownloaderController loadBarrierArray];
    
    for (CDBarrierDuelProduct *barrierDuelProduct in barriersArray) {
        switch (barrierDuelProduct.dType) {
            case BarrierDuelProductTypeBarrel:
                countOfBarrels = barrierDuelProduct.dCountOfUse;
                break;
            case BarrierDuelProductTypeCactus:
                countOfCactuses = barrierDuelProduct.dCountOfUse;
                break;
            default:
                break;
        }
    }
    
    barellObjectArray = [[NSMutableArray alloc] initWithCapacity:countOfBarrels];
    cactusObjectArray = [[NSMutableArray alloc] initWithCapacity:countOfCactuses];

    CGRect barelFrame;
    int indexBarrel = 0;
    barelFrame = barellObject.frame;
    barelFrame.origin.x = opponentShape.frame.origin.x;
    barelFrame.origin.y = 120;
    countOfBarrels = 5;
    countOfCactuses = 5;
    int randomBarrels = arc4random()%3 + 1;
    for (int i = 0; i < countOfBarrels; i++){

        if (indexBarrel == 0) {
            barellObject = [[BarellsObject alloc] initWithFrame:barelFrame];
            barellObject.bonusImg.hidden = YES;
        }
        indexBarrel++;
        barellObject.barellImgMiddle.hidden = YES;
        barellObject.barellImgBottom.hidden = YES;
        barellObject.barellImgHighest.hidden = YES;
                
        if (indexBarrel <=3)
        {
            if (indexBarrel==1) {
                barellObject.barellImgBottom.hidden = NO;
                
                if (countOfBarrels - i == 1 || randomBarrels == 1) {
                    
                    [barellObjectArray addObject:barellObject];
                    barelFrame.origin.x = barelFrame.origin.x + 80;
                    [self.floatView addSubview:barellObject];
                    
                    indexBarrel = 0;
                    randomBarrels = arc4random()%3 + 1;
                }
                
            }
            if (indexBarrel==2) {
                barellObject.barellImgBottom.hidden = NO;
                barellObject.barellImgMiddle.hidden = NO;
                
                if (countOfBarrels - i == 2 || randomBarrels == 2) {
                    
                    [barellObjectArray addObject:barellObject];
                    barelFrame.origin.x = barelFrame.origin.x + 80;
                    [self.floatView addSubview:barellObject];
                    
                    indexBarrel = 0;
                    randomBarrels = arc4random()%3 + 1;
                }

            }
            if (indexBarrel==3) {
                barellObject.barellImgMiddle.hidden = NO;
                barellObject.barellImgBottom.hidden = NO;
                barellObject.barellImgHighest.hidden = NO;
                
                [barellObjectArray addObject:barellObject];
                barelFrame.origin.x = barelFrame.origin.x + 80;
                [self.floatView addSubview:barellObject];

                indexBarrel = 0;
                randomBarrels = arc4random()%3 + 1;
            }
        }
    }
    
    for (int i=0; i<countOfCactuses; i++) {
        CGRect cactusFrame;
        cactusFrame = cactusObject.frame;
        
        if (i > 0) {
            cactusObject = [cactusObjectArray objectAtIndex:i-1];
            cactusFrame.origin.x = cactusObject.frame.origin.x + 80;
            cactusFrame.origin.y = 150;
            
        }else{
            cactusFrame.origin.x = 40 + opponentShape.frame.origin.x;
            cactusFrame.origin.y = 150;
            
        }
        cactusObject = [[CactusObject alloc] initWithFrame:cactusFrame];
        
        cactusObject.cactusImg.tag = 1;
        [self.floatView addSubview:cactusObject];
        [cactusObjectArray addObject:cactusObject];
    }

    CGRect airBallonFrame;
    airBallonFrame = airBallon.frame;
    airBallonFrame.origin.x = 300;
    airBallonFrame.origin.y = -100;
    airBallon = [[AirBallon alloc] initWithFrame:airBallonFrame];
     airBallon.airBallonImg.tag = 1;
    [self.floatView addSubview:airBallon];
    
    OponentCoordinateView *poi = [OponentCoordinateView oponentCoordinateWithView:self.floatView at:[[CLLocation alloc] initWithLatitude:oponentCoords.latitude longitude:oponentCoords.longitude]];
    [oponentsViewCoordinates addObject:poi];
    [plView setOponentCoordinates:oponentsViewCoordinates];
    
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
-(void)preparationBloodAnimation{

    UIImage *spriteSheetBlood;
    UIImage *spriteSheetBloodC;
    
    if (opponentShape.typeOfBody == OpponentShapeTypeScarecrow)
    {
        spriteSheetBlood = [UIImage imageNamed:@"blood_aScrCr"];
        spriteSheetBloodC = [UIImage imageNamed:@"blood_cScrCr"];
        
    }
    else
    {
        spriteSheetBlood = [UIImage imageNamed:@"blood_a"];
        spriteSheetBloodC = [UIImage imageNamed:@"blood_c"];
    }
    
    NSArray *arrayWithSpritesBlood = [spriteSheetBlood spritesWithSpriteSheetImage:spriteSheetBlood
                                                                        spriteSize:CGSizeMake(64, 64)];
    [self.bloodImageView setAnimationImages:arrayWithSpritesBlood];
    float animationDurationBlood = [self.bloodImageView.animationImages count] * 0.100; // 100ms per frame
    [self.bloodImageView setAnimationRepeatCount:1];
    [self.bloodImageView setAnimationDuration:animationDurationBlood];
    arrayWithSpritesBlood = nil;
    spriteSheetBlood = nil;
    
    NSArray *arrayWithSpritesBloodC = [spriteSheetBloodC spritesWithSpriteSheetImage:spriteSheetBloodC
                                                                          spriteSize:CGSizeMake(64, 64)];
    [self.bloodCImageView setAnimationImages:arrayWithSpritesBloodC];
    float animationDurationBloodC = [self.bloodCImageView.animationImages count] * 0.100; // 100ms per frame
    [self.bloodCImageView setAnimationRepeatCount:1];
    [self.bloodCImageView setAnimationDuration:animationDurationBloodC];
    arrayWithSpritesBloodC = nil;
    spriteSheetBloodC = nil;



}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ignoreTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(userIgnorePunish) userInfo:nil repeats:NO];
    foll = NO;
    duelTimerEnd = NO;
    duelEnd = NO;
    follAccelCheck = NO;
    accelerometerState = NO;
    soundStart = NO;
    isGunCanShotOfFrequently = YES;
    self.crossImageView.hidden = YES;
    
    self.gunButton.hidden = YES;
    opponentShape.imgBody.hidden = NO;
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
    [goodCowboyShape randomPositionWithView:womanShape];
    [horseShape randomPositionWithView:goodCowboyShape];
    
    CGRect horseFrame = horseShape.frame;
    horseFrame.origin.y = opponentShape.frame.origin.y + 65;
    horseShape.frame = horseFrame;
    
	[plView startAnimation];
    
    [activityIndicatorView hideView];
    [self.gunButton setEnabled:NO];
    
    userLiveImageViewStartWidth = self.userLiveImageView.frame.size.width;
    self.lbUserLifeLeft.text = [NSString stringWithFormat:@"%d",shotCountBulletForOpponent*3];
    
    self.opStatsLabel.text = [NSString stringWithFormat: @"A: +%d\rD: +%d",opAccount.accountWeapon.dDamage,opAccount.accountDefenseValue];
    self.userStatsLabel.text = [NSString stringWithFormat: @"A: +%d\nD: +%d",playerAccount.accountWeapon.dDamage,playerAccount.accountDefenseValue];
    [self.titleSteadyFire setHidden:YES];
    [self.lblBehold setHidden:YES];
    

    [self.lblBehold setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:25]];
    self.lblBehold.text = NSLocalizedString(@"Behold!", @"");
    self.lblBehold.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
    self.lblBehold.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
  
    steadyScale = 1.0;
    
    [self hideGoodBodies];
    opponentShape.hidden = YES;
    arrowToOpponent.hidden = YES;
    [arrowToOpponent setDirection:ArrowToOpponentDirectionRight];
    
    if(!delegate)
    {
        if (!opAccount.bot)
            opponentTime=99999;
        }
   [plView startSensorialRotation];
    
    [opponentShape setStatusBody:OpponentShapeStatusLive];
    [opponentShape cleareDamage];    
    [opponentShape refreshLiveBarWithLives:maxShotCount];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self readyToStart];
    
    NSString *st=@"/ActiveDuelVC";
    if ( [LoginAnimatedViewController sharedInstance].isDemoPractice == YES){
        st=@"/ActiveDuelVC_first_duel";
    }else{
        if ([opAccount isPlayerForPractice]) {
            st=@"/ActiveDuelVC_practice";
        }else{
            if (opAccount.bot){
                st=@"/ActiveDuelVC_bot";
            }else{
                st=@"/ActiveDuelVC";
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:st forKey:@"page"]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [shotTimer invalidate];
    [moveTimer invalidate];
    [ignoreTimer invalidate];
    [timer invalidate];
    plView = (PLView *)self.view;
    [plView stopSensorialRotation];
    [plView stopAnimation];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    CGRect frame = self.userLiveImageView.frame;
    frame.size.width = userLiveImageViewStartWidth;
    self.userLiveImageView.frame = frame;
}

- (void)viewDidUnload {
    [self releaseComponents];
    blinkBottom = nil;
    blinkBottom = nil;
    opponentShape = nil;
    goodCowboyShape = nil;
    arrowToOpponent = nil;
    [self setLbUserLifeLeft:nil];
    horseShape = nil;
    [self setBtnSkip:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DLog(@"memory warning");
    //[self releaseComponents];
    // Dispose of any resources that can be recreated.
}

#pragma mark
-(void)countUpBulets;
{
    int countBullets = [DuelRewardLogicController countUpBuletsWithOponentLevel:opAccount.accountLevel defense:opAccount.accountDefenseValue playerAtack:playerAccount.accountWeapon.dDamage];
    
    shotCountBullet =  countBullets;
    maxShotCount = countBullets;
    int countBulletsForOpponent;
   
    if ( [LoginAnimatedViewController sharedInstance].isDemoPractice == NO)
    {
        if ([opAccount isPlayerForPractice]) {
            countBulletsForOpponent = 4;
            opponentShape.typeOfBody = OpponentShapeTypeScarecrow;
            shotCountBullet = 3;
            maxShotCount = 3;
        }else{
            countBulletsForOpponent = [DuelRewardLogicController countUpBuletsWithOponentLevel:playerAccount.accountLevel defense:playerAccount.accountDefenseValue playerAtack:opAccount.accountWeapon.dDamage];
            opponentShape.typeOfBody = OpponentShapeTypeManLow;
        }
    }else{
        countBulletsForOpponent = 5;
        opponentShape.typeOfBody = OpponentShapeTypeScarecrow;
        maxShotCount = 3;
        shotCountBullet = 3;
   }
    shotCountBulletForOpponent =  countBulletsForOpponent;
    maxShotCountForOpponent = countBulletsForOpponent;
    [self preparationBloodAnimation];
}

-(float)abs:(float)d
{
    if (d<0) return -1.0 * d;
    else return d;
}

- (IBAction)shotButtonClick:(id)sender {
    if (isGunCanShotOfFrequently) {
        [self startGunFrequentlyBlockTime];
            
        [gunDrumViewController shotAnimation];
        [self hideSteadyImage];
        
        switch (shotCountForSound) {
            case 1:
                [self.titleSteadyFire setHidden:YES];
                [self.lblBehold setHidden:YES];
              
                
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
    [gunDrumViewController explanePracticeClean];
    //Obstracles
    for (UIImageView *obstracle in self.floatView.subviews) {
        if(obstracle.tag != 1) continue;
        CGRect obstracleFrame = obstracle.frame;
        obstracleFrame.origin.x = obstracle.frame.origin.x - (self.floatView.bounds.size.width / 2 - self.floatView.center.x);
        obstracleFrame.origin.y = obstracle.frame.origin.y - (self.floatView.bounds.size.height / 2 - self.floatView.center.y);
        if (CGRectContainsPoint(obstracleFrame, shotPoint)) {
            return;
        }
        
    }
    
    BOOL shotOnObstracle = NO;

    CGRect baloonFrame = [airBallon convertRect:airBallon.airBallonImg.frame toView:self.view];
    
    if (CGRectContainsPoint(baloonFrame, shotPoint) && !airBallon.airBallonImg.hidden && !shotOnObstracle) {
        [airBallon explosionAnimation];
        shotOnObstracle = YES;
    }
    
    for (CactusObject *cactus in cactusObjectArray) {

        CGRect cactusFrame = [cactus convertRect:cactus.cactusImg.frame toView:self.view];
        
        if (CGRectContainsPoint(cactusFrame, shotPoint) && !cactus.cactusImg.hidden && !shotOnObstracle) {
            [cactus explosionAnimation];
            shotOnObstracle = YES;
        }
    }
    for (BarellsObject *barell in barellObjectArray) {
        //Global IF shot on Barrel
        CGRect barelHighestFrame = [barell convertRect:barell.barellImgHighest.frame toView:self.view];
        CGRect barelMiddleFrame = [barell convertRect:barell.barellImgMiddle.frame toView:self.view];
        CGRect barelBottomFrame = [barell convertRect:barell.barellImgBottom.frame toView:self.view];
        
        if (!barell.barellImgHighest.hidden
            && CGRectContainsPoint(barelHighestFrame, shotPoint)
            && !shotOnObstracle)
        {
            barell.barellPosition = BarellPositionHighest;
            [barell explosionAnimation];
            shotOnObstracle = YES;
           
        }
        
        if (!barell.barellImgMiddle.hidden
            && CGRectContainsPoint(barelMiddleFrame, shotPoint)
            && !shotOnObstracle)
        {
            barell.barellPosition = BarellPositionMiddle;
            [barell explosionAnimation];
            shotOnObstracle = YES;
        
        }
        
        if (!barell.barellImgBottom.hidden
            && CGRectContainsPoint(barelBottomFrame, shotPoint)
            && !shotOnObstracle)
        {
            barell.barellPosition = BarellPositionBottom;
            [barell explosionAnimation];
            shotOnObstracle = YES;
            
        }

    }
    if (shotOnObstracle == YES) {
        return;
    }
    
    BOOL shotInHorse = ([horseShape shotInShapeWithPoint:shotPoint superViewOfPoint:self.view] && !horseShape.hidden);
    if (shotInHorse) {
        
        return;
    }
    BOOL resultWoman = ([womanShape shotInShapeWithPoint:shotPoint superViewOfPoint:self.view] && !womanShape.hidden);
    if (resultWoman) {
        [self opponentShot];
        if(delegate) [delegate sendShotSelf];        
        return;
    }
    BOOL resultGoodCowboy = ([goodCowboyShape shotInShapeWithPoint:shotPoint superViewOfPoint:self.view] && !goodCowboyShape.hidden);
    if (resultGoodCowboy) {
        [self opponentShot];
        if(delegate) [delegate sendShotSelf];
        return;
    }
    
    if (([self abs:(shotPoint.x - targetPoint.x)] < targetWeidth / 2) && ([self abs:(shotPoint.y - targetPoint.y)] < targetHeight / 2)) {
        
        if(delegate)
        {
            [delegate sendShot];
        }
        
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
            if (horseShape.hidden && opponentShape.typeOfBody == OpponentShapeTypeScarecrow) {
                [self performSelector:@selector(showGoodBodies) withObject:nil afterDelay:1.0f];
            }
        }
        [self shotToOponent];

        
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

    shotCountBulletForOpponent--;
    
    CGRect frame = self.userLiveImageView.frame;
    frame.size.width = (float)((shotCountBulletForOpponent)*userLiveImageViewStartWidth)/maxShotCountForOpponent;
    self.userLiveImageView.frame = frame;
    
    self.lbUserLifeLeft.text = [NSString stringWithFormat:@"%d",shotCountBulletForOpponent*3];
    
    CGRect frameLife = self.lbUserLifeLeft.frame;
    frameLife.size.width = frame.size.width;
    self.lbUserLifeLeft.frame = frameLife;
    
    if(!shotCountBulletForOpponent){
        [self userLost];
        GameCenterViewController *gameCenterViewController;
        if (self.delegate) gameCenterViewController = [GameCenterViewController sharedInstance:[AccountDataSource sharedInstance] andParentVC:self];
        
        BOOL teaching = YES;
        if (!self.delegate)
            gameCenterViewController = nil;
        else
            teaching = NO;
        
        FinalViewController *finalViewController = [[FinalViewController alloc] initWithUserTime:(shotTime) andOponentTime:999999 andGameCenterController:gameCenterViewController andTeaching:teaching andAccount: playerAccount andOpAccount:opAccount];

        [self performSelector:@selector(dismissWithController:) withObject:finalViewController afterDelay:1.0];
        [timer invalidate];
        [moveTimer invalidate];
    }
}

-(void)shotToOponent
{
 
    shotCountBullet--;
    
    userHitCount++;
    
    [opponentShape changeLiveBarWithUserHitCount:userHitCount maxShotCount:maxShotCount];
    
        
    if(!shotCountBullet) {
        if (duelEnd) return;
        duelEnd = YES;
        [activityIndicatorView setText:@""];
        [activityIndicatorView showView];
        //[self horizontalFlip];
        DLog(@"Kill!!!");
        DLog(@"Shot Time = %d.%d", (shotTime) / 1000, (shotTime));
        GameCenterViewController *gameCenterViewController;
        if (self.delegate) gameCenterViewController = [GameCenterViewController sharedInstance:[AccountDataSource sharedInstance] andParentVC:self];
        BOOL teaching = YES;
        if (!self.delegate)
            gameCenterViewController = nil;
        else
            teaching = NO;
        FinalViewController *finalViewController = [[FinalViewController alloc] initWithUserTime:(shotTime) andOponentTime:opponentTime andGameCenterController:gameCenterViewController andTeaching:teaching andAccount: playerAccount andOpAccount:opAccount];
        
        [self performSelector:@selector(dismissWithController:) withObject:finalViewController afterDelay:2.0];
        [timer invalidate];
        [moveTimer invalidate];
        
        [self opponentLost];
    }

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
        GameCenterViewController *gameCenterViewController;
        if (self.delegate) gameCenterViewController = [GameCenterViewController sharedInstance:[AccountDataSource sharedInstance] andParentVC:self];
        BOOL teaching = YES;
        if (!self.delegate) gameCenterViewController = nil;
        else teaching = NO;
        FinalViewController *finalViewController = [[FinalViewController alloc] initWithUserTime:0 andOponentTime:10 andGameCenterController:gameCenterViewController andTeaching:teaching andAccount: playerAccount andOpAccount:opAccount];
        
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
        frame.origin.y = 120;
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
            frame.origin.y = 120;
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
    activityInterval = (nowInterval-startInterval) * 1000;
    shotTime = (int)activityInterval;
    
    UIViewController *curentVC=[self.navigationController visibleViewController];
    if ((!duelIsStarted) && (!foll)&&([curentVC isEqual:self])) {
        DLog(@"FIRE !!!!!");
        duelIsStarted = YES;
        self.crossImageView.hidden = NO;
        [ignoreTimer invalidate];
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fire.mp3", [[NSBundle mainBundle] resourcePath]]];
        NSError *error;
        [player stop];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [player play];
        [self vibrationStart];
        [self.gunButton setEnabled:YES];
        [self.userLiveImageView setHidden:NO];
        opponentShape.hidden = NO;
        
        if (opponentShape.typeOfBody != OpponentShapeTypeScarecrow) {
            [self showGoodBodies];
        }else{
            [arrowToOpponent changeImgForPractice];
       
            UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
            
            [btnSkip setTitleByLabel:@"SKIP" withColor:buttonsTitleColor fontSize:24];
            [self.btnSkip setEnabled:YES];
            [self.btnSkip setHidden:NO];
            [self.view bringSubviewToFront:btnSkip];
        }
        
        if(!delegate && opponentShape.typeOfBody != OpponentShapeTypeScarecrow) shotTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(opponentShot) userInfo:nil repeats:YES];
        moveTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(moveOponent) userInfo:nil repeats:YES];
        
        
    }
    if ((shotTime * 0.001 >= 60.0) && (!duelTimerEnd) && (soundStart)) {
        if ([delegate respondsToSelector:@selector(duelTimerEnd)])
            [delegate duelTimerEnd];
        duelTimerEnd = YES;
        [timer invalidate];
    }
    
    [arrowToOpponent updateRelateveToView:opponentShape.imgBody mainView:self.view];
    arrowToOpponent.hidden = NO;
}

#pragma mark

-(void)hideHelpViewOnStartDuel;
{
    arrowAnimationContinue = NO;    
}

-(void)showHelpViewOnStartDuel;
{
    [gunDrumViewController showGun];
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
    [opponentShape moveOponentInBackground];
    [womanShape moveWoman];
    [goodCowboyShape moveGoodCowboy];
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
}

-(void) showGoodBodies
{
    [gunDrumViewController explanePractice];
    womanShape.hidden = NO;
    goodCowboyShape.hidden = NO;
    horseShape.hidden = NO;
}

-(void) hideGoodBodies
{
    womanShape.hidden = YES;
    horseShape.hidden = YES;
    goodCowboyShape.hidden = YES;
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

- (IBAction)btnSkipClicked:(id)sender {
    
    if ([LoginAnimatedViewController sharedInstance].isDemoPractice){
        [self.navigationController popToViewController:[LoginAnimatedViewController sharedInstance] animated:YES];
        [self releaseComponents];
    }
    else{
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
        [self releaseComponents];
    }
    
}

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
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fire.mp3", [[NSBundle mainBundle] resourcePath]]];
        NSError *error;
        [player stop];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [player play];
        [self vibrationStart];
        [self.gunButton setEnabled:YES];

        [self.userLiveImageView setHidden:NO];

        if(!delegate && opponentShape.typeOfBody != OpponentShapeTypeScarecrow){
            shotTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(opponentShot) userInfo:nil repeats:YES];
            moveTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(moveOponent) userInfo:nil repeats:YES];
            [self showGoodBodies];
        }
        opponentShape.hidden = NO;
    }
}

-(void)readyToStart
{
    NSLog(@"readyToStart");
    soundStart = YES;
    startInterval = [NSDate timeIntervalSinceReferenceDate];
    [player stop];
    player.numberOfLoops = 999;
    [player setCurrentTime:0.0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Duel.mp3", [[NSBundle mainBundle] resourcePath]]];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player play];
    
    [self hideHelpViewOnStartDuel];
    
    [gunDrumViewController openGun];
    
    __block id  selfBlock = self;
    
    gunDrumViewController.didFinishBlock = ^(){
        [selfBlock startTimerInBlock];
    };
}

-(void)startTimerInBlock
{
    //if(!delegate)
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(shotTimer) userInfo:nil repeats:YES];
    duelIsStarted = NO;
    fireSound = NO;
    acelStatus = YES;
    shotTime = 0;
    [player stop];
}
#pragma ActiveDuelViewControllerDelegate
-(BOOL)accelerometerSendPositionSecond
{
    return accelerometerState;
}

-(void)releaseComponents
{
    [oponentsViewCoordinates removeAllObjects];
    [plView stopSensorialRotation];
    [self setFloatView:nil];
    [self setFireImageView:nil];
    [self setBloodImageView:nil];
    [self setBloodCImageView:nil];
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
    [self setLbUserLifeLeft:nil];
    
    [goodCowboyShape releaseComponents];
    goodCowboyShape = nil;
    
    [womanShape releaseComponents];
    womanShape = nil;
    
    [horseShape releaseComponents];
    horseShape = nil;
    
    [opponentShape releaseComponents];
    opponentShape = nil;
    
    plView = nil;
    
    [gunDrumViewController releaseComponents];
    gunDrumViewController = nil;
    
    shotAudioPlayer1 = nil;
    
    shotAudioPlayer2 = nil;
    
    shotAudioPlayer3 = nil;

    brockenGlassAudioPlayer = nil;
    
    opAccount = nil;
    playerAccount = nil;
    
    shotTimer = nil;
    moveTimer = nil;
    ignoreTimer = nil;
    
    gunDrumViewController = nil;
    profileViewController = nil;
    activityIndicatorView = nil;
    
    oponentsViewCoordinates = nil;
    
    blinkBottom = nil;
    blinkTop = nil;

    self.floatView = nil;
    self.fireImageView = nil;
    self.bloodImageView = nil;
    self.bloodCImageView = nil;
    self.glassImageViewAllBackground = nil;
    self.glassImageViewHeader = nil;
    self.glassImageViewBottom = nil;
    self.gunButton = nil;
    self.opStatsLabel = nil;
    self.userStatsLabel = nil;
    self.titleSteadyFire = nil;
    self.lblBehold = nil;
    self.crossImageView = nil;
    self.userLiveImageView = nil;
}

@end
