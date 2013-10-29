
//
//  ActiveDuelViewController.m
//  Bounty Hunter
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
#import "UIView+ColorOfPoint.h"
#import "FinalStatsView.h"
#import "FinalViewDataSource.h"
#import "DuelProductWinViewController.h"

#define targetHeight 260
#define targetWeidth 100
#define MOVE_DISTANCE 100
@interface ActiveDuelViewController ()
{
    BOOL isOpenHint;
    float startPoint;
    BOOL firstAccel;
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
    
    BOOL tryAgain;
    BOOL isTryAgainEnabled;

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
    BOOL isOpponentShotFrequency;
    
    BOOL oponnentFoll;
    BOOL oponnentFollSend;
    
    int opponentTime;
    
    HorseShape *horseShape;
    GoodCowboy *goodCowboyShape;
    WomanShape *womanShape;
    OpponentShape *opponentShape;
    
    FinalStatsView *finalView;
    FinalViewDataSource *finalViewDataSource;
    UIImageView *blurredBack;
    UIImageView *finalStatusBack;
    UILabel *gameStatusLable;
  
    __weak IBOutlet UIImageView *blinkBottom;
    __weak IBOutlet UIImageView *blinkTop;
    __weak IBOutlet ArrowToOpponent *arrowToOpponent;
    __weak IBOutlet JoyStickView *vJoySctick;
    
    UIViewController *presentVC;
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
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@end

@implementation ActiveDuelViewController
@synthesize delegate;
@synthesize glassImageViewAllBackground;
@synthesize lbUserLifeLeft;
@synthesize btnSkip,btnTry,btnBack;

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
        
        isOpponentShotFrequency = YES;
        isTryAgainEnabled = YES;
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
                barellObject.barellCount = 1;
                [barellObject showBarrels];
                if (countOfBarrels - i == 1 || randomBarrels == 1) {
                    
                    [barellObjectArray addObject:barellObject];
                    barelFrame.origin.x = barelFrame.origin.x + 80;
                    [self.floatView addSubview:barellObject];
                    
                    indexBarrel = 0;
                    randomBarrels = arc4random()%3 + 1;
                }
                
            }
            if (indexBarrel==2) {
                barellObject.barellCount = 2;
                [barellObject showBarrels];

                if (countOfBarrels - i == 2 || randomBarrels == 2) {
                    [barellObjectArray addObject:barellObject];
                    barelFrame.origin.x = barelFrame.origin.x + 80;
                    [self.floatView addSubview:barellObject];
                    
                    indexBarrel = 0;
                    randomBarrels = arc4random()%3 + 1;
                }

            }
            if (indexBarrel==3) {
                barellObject.barellCount = 3;
                
                [barellObject showBarrels];
                
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
    
    [opponentShape refreshWithAccountPlayer:opAccount];
    
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
    [self.view bringSubviewToFront:vJoySctick];
    [vJoySctick setDelegate:plView];

    blinkTopOriginY = blinkTop.frame.origin.y;
    blinkBottomOriginY = blinkBottom.frame.origin.y;
    
    tryAgain = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    if(!tryAgain){
        [self reInitViewWillAppear:animated];
    }
}

-(void)reInitViewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.hidden = NO;
    if (tryAgain) {
        for (BarellsObject *barell in barellObjectArray) {
            [barell showBarrels];
            if (barell.hidden) {
                barell.hidden = NO;
            }
        }
        
        for (CactusObject *cactus in cactusObjectArray) {
            if (cactus.cactusImg.hidden) {
                cactus.cactusImg.hidden = NO;
            }
        }
        if (airBallon.airBallonImg.hidden) {
            airBallon.airBallonImg.hidden = NO;
        }
    }
    else
    {
        blurredBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bloorOnBlackView.png"]];
        blurredBack.hidden = YES;
        int iPhone5Delta = [UIScreen mainScreen].bounds.size.height - 480;
        CGRect deltaFrame = blurredBack.frame;
        deltaFrame.size.height += iPhone5Delta;
        blurredBack.frame = deltaFrame;
        [self.view addSubview:blurredBack];
        
        finalStatusBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lg_title_view.png"]];
        finalStatusBack.frame = CGRectMake(0.0, 0.0, 320, 72);
        finalStatusBack.backgroundColor = [UIColor clearColor];
        
        CGRect frame = finalStatusBack.frame;
        frame.origin.y += 5;
        gameStatusLable = [[UILabel alloc] initWithFrame:frame];
        gameStatusLable.textAlignment = UITextAlignmentCenter;
        gameStatusLable.textColor = [UIColor whiteColor];
        gameStatusLable.backgroundColor = [UIColor clearColor];
        [gameStatusLable setFont:[UIFont fontWithName: @"DecreeNarrow" size:30]];
        
        finalStatusBack.hidden = YES;
        gameStatusLable.hidden = YES;
        
        [self.view addSubview:finalStatusBack];
        [self.view addSubview:gameStatusLable];
    }
    
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
    [self.lbUserLifeLeft setHidden:YES];
    
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
    if (tryAgain) {
        CGRect frame = self.userLiveImageView.frame;
        frame.size.width = userLiveImageViewStartWidth;
        self.userLiveImageView.frame = frame;
    }else
        userLiveImageViewStartWidth = self.userLiveImageView.frame.size.width;
    self.lbUserLifeLeft.text = [NSString stringWithFormat:@"%d",shotCountBulletForOpponent*3];
    
    self.opStatsLabel.text = [NSString stringWithFormat: @"A: +%d\rD: +%d",opAccount.accountAtackValue,opAccount.accountDefenseValue];
    self.userStatsLabel.text = [NSString stringWithFormat: @"A: +%d\nD: +%d",playerAccount.accountAtackValue,playerAccount.accountDefenseValue];
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
    
    UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];

    [btnTry setTitleByLabel:@"TRY" withColor:buttonsTitleColor fontSize:24];
    if([LoginAnimatedViewController sharedInstance].isDemoPractice){
        [btnTry changeTitleByLabel:@"LOGIN"];
    }
    [btnBack setTitleByLabel:@"BACK" withColor:buttonsTitleColor fontSize:24];
    if (tryAgain) {
        [self readyToStart];
    }
    finalViewDataSource.oldMoney = playerAccount.money;
    finalViewDataSource.oldPoints = playerAccount.accountPoints;
    
    presentVC = nil;
    finalView = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    if (!tryAgain) {
        [self readyToStart];
    }
    
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
    
    tryAgain = NO;

    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:st forKey:@"page"]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload {
    [self releaseComponents];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DLog(@"memory warning");
    //[self releaseComponents];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark ActiveDuelViewControllerDelegate
-(void)countUpBulets;
{
    int countBullets = [DuelRewardLogicController countUpBuletsWithOponentLevel:opAccount.accountLevel defense:opAccount.accountDefenseValue playerAtack:playerAccount.accountAtackValue];
    
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
            [arrowToOpponent changeImgForPractice];
        }else{
            countBulletsForOpponent = [DuelRewardLogicController countUpBuletsWithOponentLevel:playerAccount.accountLevel defense:playerAccount.accountDefenseValue playerAtack:opAccount.accountAtackValue];
            opponentShape.typeOfBody = OpponentShapeTypeManLow;
            UIImage *image = [opponentShape.visualViewCharacter imageFromCharacter];
            [arrowToOpponent changeImg:image];
        }
    }else{
        countBulletsForOpponent = 4;
        opponentShape.typeOfBody = OpponentShapeTypeScarecrow;
        maxShotCount = 3;
        shotCountBullet = 3;
        [arrowToOpponent changeImgForPractice];
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
    if (isOpenHint == YES) {
        [self cleanPracticeHints];
    }else if (isGunCanShotOfFrequently) {
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
   // [gunDrumViewController textPracticeClean];
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
    BOOL shotInShape;
    
    CGRect baloonFrame = [airBallon convertRect:airBallon.airBallonImg.frame toView:self.view];
    
    if (!shotOnObstracle && !airBallon.airBallonImg.hidden && CGRectContainsPoint(baloonFrame, shotPoint)) {
        shotInShape = [airBallon shotInObstracleWithPoint:shotPoint superViewOfPoint:self.view];
        if (shotInShape){
            [airBallon explosionAnimation];
            shotOnObstracle = YES;
        }
    }
    
    for (CactusObject *cactus in cactusObjectArray) {

        CGRect cactusFrame = [cactus convertRect:cactus.cactusImg.frame toView:self.view];
        
        if (!shotOnObstracle && !cactus.cactusImg.hidden && CGRectContainsPoint(cactusFrame, shotPoint)) {
            
            shotInShape = [cactus shotInObstracleWithPoint:shotPoint superViewOfPoint:self.view];
            if (shotInShape){
                [cactus explosionAnimation];
                shotOnObstracle = YES;
            }
        }
    }
    for (BarellsObject *barell in barellObjectArray) {
        if (!barell.barellImgHighest.hidden && !shotOnObstracle && shotInShape)
        {
            barell.barellPosition = BarellPositionHighest;
            shotInShape = [barell shotInObstracleWithPoint:shotPoint superViewOfPoint:self.view];

            if (shotInShape){
                [barell explosionAnimation];
                shotOnObstracle = YES;
            }
           
        }
        
        if (!barell.barellImgMiddle.hidden && !shotOnObstracle)
        {
            barell.barellPosition = BarellPositionMiddle;
            shotInShape = [barell shotInObstracleWithPoint:shotPoint superViewOfPoint:self.view];
            if (shotInShape){
                [barell explosionAnimation];
                shotOnObstracle = YES;
            }
        }
        
        if (!barell.barellImgBottom.hidden && !shotOnObstracle)
        {
            barell.barellPosition = BarellPositionBottom;
            shotInShape = [barell shotInObstracleWithPoint:shotPoint superViewOfPoint:self.view];
            if (shotInShape){
                [barell explosionAnimation];
                shotOnObstracle = YES;
            }
        }

    }
    if (shotOnObstracle == YES) {
        return;
    }
    
    int damageForShotInHorse = [horseShape damageForShotInShapeWithPoint:shotPoint superViewOfPoint:self.view];
    if (damageForShotInHorse!=NSNotFound && !horseShape.hidden) {
        return;
    }
    int damageForShotInWoman = [womanShape damageForShotInShapeWithPoint:shotPoint superViewOfPoint:self.view];
    if (damageForShotInWoman!=NSNotFound && !womanShape.hidden) {
        if (opponentShape.typeOfBody == OpponentShapeTypeScarecrow) {
            [gunDrumViewController shootOnCivil];
            btnSkip.hidden = YES;
            isOpenHint = YES;
            
        }
        [self  playerGetDamage:damageForShotInWoman];
        if(delegate) [delegate sendShotSelf];
        return;
    }
    int damageForShotInGoodCowboy = [goodCowboyShape damageForShotInShapeWithPoint:shotPoint superViewOfPoint:self.view];
    
    if (damageForShotInGoodCowboy!=NSNotFound  && !goodCowboyShape.hidden ) {
        if (opponentShape.typeOfBody == OpponentShapeTypeScarecrow) {
            [gunDrumViewController shootOnCivil];
            btnSkip.hidden = YES;
            isOpenHint = YES;
        }

        [self playerGetDamage:damageForShotInGoodCowboy];
        
        if(delegate) [delegate sendShotSelf];
        return;
    }
    
    int resultOpponent = [opponentShape damageForShotInShapeWithPoint:shotPoint superViewOfPoint:self.view];

    if (resultOpponent!=NSNotFound) {
        
        [self startRandomBloodAnimation];
        int opponentDamage = [opponentShape damageForHitTheOponentWithPoint:shotPoint mainView:self.view];
        
        if(delegate)
        {
            [delegate sendShotWithDamage:opponentDamage];
        }
        
        [self shotToOponentWithDamage:opponentDamage];
//=======
//        CGPoint targetPoint;
//        targetPoint.x = opponentShape.center.x - (self.floatView.bounds.size.width / 2 - self.floatView.center.x);
//        targetPoint.y = opponentShape.center.y - (self.floatView.bounds.size.height / 2 - self.floatView.center.y);
//        
//        CGPoint centerOfScreanPoint;
//        centerOfScreanPoint.x = self.crossImageView.bounds.origin.x + self.crossImageView.center.x;
//        centerOfScreanPoint.y = self.crossImageView.bounds.origin.y + self.crossImageView.center.y;
//        
//        CGRect opponentBodyFrame = [[opponentShape.visualViewCharacter superview] convertRect:opponentShape.visualViewCharacter.frame toView:self.view];
//        
//        if (CGRectContainsPoint(opponentBodyFrame, shotPoint)) {
//            [self startRandomBloodAnimation];
//            [opponentShape hitTheOponentWithPoint:shotPoint mainView:self.view];
//        }
//        [self shotToOponent];
//
//        
//>>>>>>> changeGameImage
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
    int randPosition = rand() % ((int)(self.floatView.bounds.size.width));
    //randPosition = randPosition + winSize.width / 2 + opponentShape.bounds.size.width / 2;
    
    opponentCenter.x = randPosition;
    opponentShape.center = opponentCenter;
//    opponentShape.center = self.view.center;

}

-(void)opponentShotWithDamage:(int)damage;
{
    if (duelEnd) return;
    [opponentShape shot];
    BOOL result = [self playerGetDamage:damage];
    if (!result && isOpponentShotFrequency) {
        [self performSelector:@selector(opponentShotWithDamage:) withObject:nil afterDelay:frequencyOpponentShoting()];
    }
}

-(BOOL)playerGetDamage:(int)pDamage
{
//    Yes when duel is finish
    if (duelEnd) return YES;

    int damage = pDamage;
    if (!delegate) {
        //        When opponent shots you i practice
        damage = 2;
    }
    
    shotCountBulletForOpponent-=damage;
    
    if (shotCountBulletForOpponent<0) {
        shotCountBulletForOpponent = 0;
    }
    
    CGRect frame = self.userLiveImageView.frame;
    frame.size.width = (float)((shotCountBulletForOpponent)*userLiveImageViewStartWidth)/maxShotCountForOpponent;
    self.userLiveImageView.frame = frame;
    
    self.lbUserLifeLeft.text = [NSString stringWithFormat:@"%d",shotCountBulletForOpponent*3];
    
    CGRect frameLife = self.lbUserLifeLeft.frame;
    frameLife.size.width = frame.size.width;
    self.lbUserLifeLeft.frame = frameLife;
    
    if(shotCountBulletForOpponent<=0){
        [self userLost];
      
        if (opponentShape.typeOfBody == OpponentShapeTypeScarecrow) {
            [self cleanPracticeHints];
        }
        GameCenterViewController *gameCenterViewController;
        if (self.delegate) gameCenterViewController = [GameCenterViewController sharedInstance:[AccountDataSource sharedInstance] andParentVC:self];
        
        BOOL teaching = YES;
        if (!self.delegate)
            gameCenterViewController = nil;
        else
            teaching = NO;
        
        finalViewDataSource = [[FinalViewDataSource alloc] initWithUserTime:(shotTime) andOponentTime:999999 andTeaching:teaching andAccount: playerAccount andOpAccount:opAccount];
        [self performSelector:@selector(showFinalView:) withObject:finalViewDataSource afterDelay:1.0];
        return YES;
    }else{
        return NO;
    }
}

-(void)shotToOponentWithDamage:(int)pDamage;
{
    int damage = pDamage;
    if (damage==NSNotFound) {
//    when you shot in peace inhabitants
        damage = 3;
    }
    shotCountBullet-=damage;
    
    userHitCount+=damage;
    
    [opponentShape changeLiveBarWithUserHitCount:userHitCount maxShotCount:maxShotCount];
    
    if(shotCountBullet<=0) {
        if (duelEnd) return;
        duelEnd = YES;
        
        if (opponentShape.typeOfBody == OpponentShapeTypeScarecrow) {
            [self cleanPracticeHints];
        }else{
            [self opponentLost];
        }
        
        GameCenterViewController *gameCenterViewController;
        if (self.delegate) gameCenterViewController = [GameCenterViewController sharedInstance:[AccountDataSource sharedInstance] andParentVC:self];
        BOOL teaching = YES;
        if (!self.delegate)
            gameCenterViewController = nil;
        else
            teaching = NO;

        finalViewDataSource = [[FinalViewDataSource alloc] initWithUserTime:(shotTime) andOponentTime:opponentTime andTeaching:teaching andAccount: playerAccount andOpAccount:opAccount];
        [self performSelector:@selector(showFinalView:) withObject:finalViewDataSource afterDelay:1.0];
    }else{
        if (opponentShape.typeOfBody == OpponentShapeTypeScarecrow) {
            [self performSelector:@selector(showGoodBodies) withObject:nil afterDelay:0.5f];
        }
    }

}

-(void)opponentLost
{
    arrowToOpponent.hidden = YES;
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
        
        finalViewDataSource = [[FinalViewDataSource alloc] initWithUserTime:0 andOponentTime:10 andTeaching:teaching andAccount: playerAccount andOpAccount:opAccount];
        [self performSelector:@selector(showFinalView:) withObject:finalViewDataSource afterDelay:2.0];
    }
}

-(void)stopDuel;
{
    [plView stopSensorialRotation];
    [plView stopAnimation];
    [timer invalidate];
    [moveTimer invalidate];
    [self.gunButton setEnabled:NO];
}

-(void)stopDuelWithBlock;
{
    [plView stopSensorialRotationWithBlock];
    [plView stopAnimation];
    [timer invalidate];
    [moveTimer invalidate];
    [self.gunButton setEnabled:NO];

}

-(void)userLost
{
    if (duelEnd) return;
    duelEnd = YES;
    [blinkBottom setHidden:NO];
    [blinkTop setHidden:NO];
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

-(void)duelCancel;
{
    btnTry.enabled = NO;
    isTryAgainEnabled = NO;
    if(finalView){
        finalView.isTryAgainEnabled = NO;
    }
    if([presentVC respondsToSelector:@selector(blockTryAgain)]){
        [presentVC performSelector:@selector(blockTryAgain)];
    }
}

#pragma mark - FinalVC
-(void)showFinalView: (FinalViewDataSource *) fvDataSource;
{
    if(!finalView){
        [self stopDuel];
        
        finalViewDataSource = fvDataSource;
        
        self.userLiveImageView.hidden = YES;
        self.lbUserLifeLeft.hidden = YES;
        
        CGRect finalFrame = CGRectMake(12, 90, 294, 165);
        
        finalView = [[FinalStatsView alloc] initWithFrame:finalFrame andDataSource:fvDataSource];
        finalView.isTryAgainEnabled = isTryAgainEnabled;
        finalView.activeDuelViewController = self;
        
        finalView.center = self.crossImageView.center;
        finalView.hidden = YES;
        
        blurredBack.hidden = NO;
        
        btnBack.hidden = NO;
        btnTry.hidden = NO;
        btnSkip.hidden = YES;
        
        [self.view bringSubviewToFront:btnBack];
        [self.view bringSubviewToFront:btnTry];
        
        btnBack.enabled = YES;
        btnTry.enabled = YES;
        btnSkip.enabled = NO;
        
        [self revealFinalView:YES];
        
        self.gunButton.hidden = YES;
        self.gunButton.enabled = NO;
        
        [shotTimer invalidate];
        [moveTimer invalidate];
        [ignoreTimer invalidate];
        [timer invalidate];
        if ([LoginAnimatedViewController sharedInstance].isDemoPractice){
            [self performSelector:@selector(scaleView:) withObject:btnTry  afterDelay:1.5];
        }
    }
}

-(void)revealFinalView: (BOOL )animated
{
    [self.view addSubview:finalView];
    
    if (animated){
        //preparations:
        CGRect frameBefore = CGRectMake(11, -190, finalView.frame.size.width, finalView.frame.size.height);
        finalView.frame = frameBefore;
        finalView.hidden = NO;
        btnTry.alpha = 0;
        btnBack.alpha = 0;
        gameStatusLable.alpha = 0;
        finalStatusBack.alpha = 0;
        gameStatusLable.hidden = NO;
        finalStatusBack.hidden = NO;
        
        if (finalViewDataSource.userWon) {
            gameStatusLable.text = @"You win";
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Win.mp3", [[NSBundle mainBundle] resourcePath]]];
            NSError *error;
            [player stop];
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
            [player play];


        }else{
            gameStatusLable.text = @"You lost";
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Lose.mp3", [[NSBundle mainBundle] resourcePath]]];
            NSError *error;
            [player stop];
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
            [player play];

        }
        //
        [UIView animateWithDuration:0.5 animations:^{
            CGPoint pointDown = self.view.center;
            pointDown.y += 20;
            finalView.center = pointDown;
            
        }completion:^(BOOL complete){
            [UIView animateWithDuration:0.2 animations:^{
                CGPoint pointUp = finalView.center;
                pointUp.y -= 40;
                finalView.center = pointUp;
                btnBack.alpha = 1;
                btnTry.alpha = 1;
                gameStatusLable.alpha = 1;
                finalStatusBack.alpha = 1;
                
            }completion:^(BOOL complete){
                [UIView animateWithDuration:0.2 animations:^{
                    CGPoint pointView = finalView.center;
                    pointView.y += 20;
                    finalView.center = pointView;

                    
                }completion:^(BOOL complete){
                    
                    [finalView startAnimations];

                }];
            }];
        }];
    }else
        finalView.hidden = NO;
}


-(void)hideFinalView{
    
    finalView.hidden = YES;
    [finalView removeFromSuperview];
    
    btnBack.hidden = YES;
    btnTry.hidden = YES;
    btnSkip.hidden = YES;
    
    btnBack.enabled = NO;
    btnTry.enabled = NO;
    btnSkip.enabled = NO;
    
    self.gunButton.hidden = NO;
    self.gunButton.enabled = YES;
    
    blurredBack.hidden = YES;
    finalStatusBack.hidden = YES;
    gameStatusLable.hidden = YES;
    self.userLiveImageView.hidden = NO;
    
    self.lbUserLifeLeft.text = [NSString stringWithFormat:@"%d",maxShotCountForOpponent*3];

    self.lbUserLifeLeft.hidden = NO;

    [self.glassImageViewHeader setHidden:YES];
    [self.glassImageViewBottom setHidden:YES];
    [glassImageViewAllBackground setHidden:YES];
    
    [blinkBottom setHidden:YES];
    [blinkTop setHidden:YES];
    
    [player stop];
}

-(void)showViewController:(UIViewController *)viewController
{
    if ([[self.navigationController visibleViewController] isKindOfClass:[ActiveDuelViewController class]] && ![finalView isHidden] && !tryAgain) {
        [self presentModalViewController:viewController animated:YES];
        presentVC = viewController;
        [self hideFinalView];
        viewController = nil;
    }
}

-(void)removeViewController;
{
    if (presentVC) {
        [presentVC dismissModalViewControllerAnimated:YES];
        [presentVC performSelector:@selector(releaseComponents)];
    }
}

#pragma mark

-(void)restartCountdown;
{    
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
        
        [self.lbUserLifeLeft setHidden:NO];
        self.lbUserLifeLeft.text = [NSString stringWithFormat:@"%d",shotCountBulletForOpponent*3];
        self.lbUserLifeLeft.textAlignment = UITextAlignmentCenter;
        self.lbUserLifeLeft.frame = CGRectMake(0, 0, self.userLiveImageView.frame.size.width, self.userLiveImageView.frame.size.height);
        
        opponentShape.hidden = NO;
        
        if (opponentShape.typeOfBody != OpponentShapeTypeScarecrow) {
            [self showGoodBodies];
        }else{
             btnSkip.hidden = YES;
            [gunDrumViewController firstStepOnPractice];
            isOpenHint = YES;
       
            UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
            
            [btnSkip setTitleByLabel:@"SKIP" withColor:buttonsTitleColor fontSize:24];
          //  [self.btnSkip setEnabled:YES];
          //  [self.btnSkip setHidden:NO];
            [self.view bringSubviewToFront:btnSkip];
        }
        
        if(!delegate && opponentShape.typeOfBody != OpponentShapeTypeScarecrow && isOpponentShotFrequency){
            [self performSelector:@selector(opponentShotWithDamage:) withObject:nil afterDelay:frequencyOpponentShoting()];
        } 
        moveTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(moveOponent) userInfo:nil repeats:YES];
        
        
    }
    if ((shotTime * 0.001 >= 60.0) && (!duelTimerEnd) && (soundStart)) {
        if ([delegate respondsToSelector:@selector(duelTimerEnd)])
            [delegate duelTimerEnd];
        duelTimerEnd = YES;
        [timer invalidate];
    }
    if (opponentShape.opponentShapeStatus==OpponentShapeStatusDead) {
        arrowToOpponent.hidden = YES;
    }else{
        [arrowToOpponent updateRelateveToView:opponentShape.imgBody mainView:self.view];
        arrowToOpponent.hidden = NO;
    }
}

#pragma mark
-(void)cleanPracticeHints;
{
    btnSkip.hidden = NO;
    [self.btnSkip setEnabled:YES];
    isOpenHint = NO;
    [gunDrumViewController textPracticeClean];
}
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
//        if(!arrowAnimationContinue) return;
        [UIView animateWithDuration:0.4 animations:^{
            viewForAnimation.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }completion:^(BOOL complete){
//            if(arrowAnimationContinue){
//                [self scaleView:viewForAnimation];
//            }
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
    if (opponentShape.typeOfBody == OpponentShapeTypeScarecrow)
    {
        [gunDrumViewController secondStepOnPractice];
        btnSkip.hidden = YES;
        isOpenHint = YES;
    }
    
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

-(void)preparationBloodAnimation{
    
    if (opponentShape.typeOfBody == OpponentShapeTypeScarecrow)
    {
        NSArray *imgDieArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"blod_cFrame1Sc.png"], [UIImage imageNamed:@"blod_cFrame2Sc.png"],[UIImage imageNamed:@"blod_cFrame3Sc.png"],
                                [UIImage imageNamed:@"blod_cFrame4Sc.png"], [UIImage imageNamed:@"blod_cFrame5Sc.png"],[UIImage imageNamed:@"blod_cFrame6Sc.png"], nil];
        
        self.bloodCImageView.animationImages = imgDieArray;
        self.bloodCImageView.animationDuration = 0.6f;
        [self.bloodCImageView setAnimationRepeatCount:1];
        imgDieArray = nil;
        
        NSArray *imgDieArray2 = [NSArray arrayWithObjects:[UIImage imageNamed:@"blod_aFrame1Scr.png"], [UIImage imageNamed:@"blod_aFrame2Scr.png"],[UIImage imageNamed:@"blod_aFrame3Scr.png"],
                                 [UIImage imageNamed:@"blod_aFrame4Scr.png"], [UIImage imageNamed:@"blod_aFrame5Scr.png"],[UIImage imageNamed:@"blod_aFrame6Scr.png"], nil];
        
        self.bloodImageView.animationImages = imgDieArray2;
        self.bloodImageView.animationDuration = 0.6f;
        [self.bloodImageView setAnimationRepeatCount:1];
        imgDieArray2 = nil;
        
        
    }
    else
    {
        NSArray *imgDieArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"blod_cFrame1Real.png"], [UIImage imageNamed:@"blod_cFrame2Real.png"],[UIImage imageNamed:@"blod_cFrame3Real.png"],
                                [UIImage imageNamed:@"blod_cFrame4Real.png"], [UIImage imageNamed:@"blod_cFrame5Real.png"],[UIImage imageNamed:@"blod_cFrame6Real.png"], nil];
        
        self.bloodCImageView.animationImages = imgDieArray;
        self.bloodCImageView.animationDuration = 0.6f;
        [self.bloodCImageView setAnimationRepeatCount:1];
        imgDieArray = nil;
        
        NSArray *imgDieArray2 = [NSArray arrayWithObjects:[UIImage imageNamed:@"blod_aFrame1Real.png"], [UIImage imageNamed:@"blod_aFrame2Real.png"],[UIImage imageNamed:@"blod_aFrame3Real.png"],
                                 [UIImage imageNamed:@"blod_aFrame4Real.png"], [UIImage imageNamed:@"blod_aFrame5Real.png"],[UIImage imageNamed:@"blod_aFrame6Real.png"], nil];
        
        self.bloodImageView.animationImages = imgDieArray2;
        self.bloodImageView.animationDuration = 0.6f;
        [self.bloodImageView setAnimationRepeatCount:1];
        imgDieArray = nil;
    }
    
}

#pragma mark - Frequently of gun

-(void)finishGunFrequentlyBlockTime
{
    isGunCanShotOfFrequently = YES;
}

-(void)startGunFrequentlyBlockTime
{
    isGunCanShotOfFrequently = NO;
    [self performSelector:@selector(finishGunFrequentlyBlockTime) withObject:Nil afterDelay:0.2];
}

#pragma mark - Frequently of opponent shoting

float frequencyOpponentShoting()
{
    float f =(20 + arc4random() % 20) * 0.1f;
    return f;
}

#pragma mark - IBAction

- (IBAction)btnSkipClicked:(id)sender {
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                     }];
    [self.navigationController popViewControllerAnimated:NO];
    
    //[self releaseComponents];

    
}

-(IBAction)backButtonClick:(id)sender
{
    self.view.hidden = YES;
    //Transitions only!
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    if (([userDef integerForKey:@"FirstRunForPractice"] != 1)&&([userDef integerForKey:@"FirstRunForPractice"] != 2)) {
        [userDef setInteger:1 forKey:@"FirstRunForPractice"];
        [userDef synchronize];
    }
    
    [self stopDuelWithBlock];
    
    [self hideFinalView];

    UINavigationController *nav = ((TestAppDelegate *)[[UIApplication sharedApplication] delegate]).navigationController;
    
    if ([LoginAnimatedViewController sharedInstance].isDemoPractice){
        [nav popToViewController:[nav.viewControllers objectAtIndex:2] animated:YES];
    }else{
        [nav popToViewController:[nav.viewControllers objectAtIndex:1] animated:YES];
    }
    
    GameCenterViewController *gameCenterViewController;
    if (self.delegate){
        gameCenterViewController = [GameCenterViewController sharedInstance:[AccountDataSource sharedInstance] andParentVC:self];
        [gameCenterViewController matchCanseled];
    }
    
    [self releaseComponents];
}

-(IBAction)tryButtonClick:(id)sender
{
    if([LoginAnimatedViewController sharedInstance].isDemoPractice){
        if ([[StartViewController sharedInstance] connectedToWiFi]) {
            
            activityIndicatorView = [[ActivityIndicatorView alloc] init];
            
            CGRect frame=activityIndicatorView.frame;
            frame.origin=CGPointMake(0, 0);
            activityIndicatorView.frame=frame;
            
            [self.view addSubview:activityIndicatorView];
        }
        [[LoginAnimatedViewController sharedInstance] loginButtonClick:sender];
        return;
    }
    tryAgain = YES;
    GameCenterViewController *gameCenterViewController;
    if (self.delegate) gameCenterViewController = [GameCenterViewController sharedInstance:[AccountDataSource sharedInstance] andParentVC:self];
    
    BOOL teaching = YES;
    if (!self.delegate)
        gameCenterViewController = nil;
    else
        teaching = NO;
        
    DLog(@"tryButtonClick");
    
    [self hideFinalView];

    if(teaching)
    {
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        if (([userDef integerForKey:@"FirstRunForPractice"] != 1)&&([userDef integerForKey:@"FirstRunForPractice"] != 2)) {
            [userDef setInteger:1 forKey:@"FirstRunForPractice"];
            [userDef synchronize];
        }
        
        [playerAccount.finalInfoTable removeAllObjects];
        [self reInitViewWillAppear:YES];
    }
    else
        if (gameCenterViewController)
        {
            [gameCenterViewController matchStartedTry];
        }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/FinalVC_tryAgain" forKey:@"page"]];

}

#pragma mark -

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
        [self.lbUserLifeLeft setHidden:NO];
        if(!delegate && opponentShape.typeOfBody != OpponentShapeTypeScarecrow && isOpponentShotFrequency){
            [self performSelector:@selector(opponentShotWithDamage:) withObject:nil afterDelay:frequencyOpponentShoting()];
            moveTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(moveOponent) userInfo:nil repeats:YES];
            [self showGoodBodies];
        }
        opponentShape.hidden = NO;
    }
}

-(void)readyToStart
{
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
    
    __block id selfBlock = self;
    
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
    CGRect frame = self.userLiveImageView.frame;
    frame.size.width = userLiveImageViewStartWidth;
    self.userLiveImageView.frame = frame;
    
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
    
    [gunDrumViewController releaseComponents];
    gunDrumViewController = nil;
    
    shotAudioPlayer1 = nil;
    
    shotAudioPlayer2 = nil;
    
    shotAudioPlayer3 = nil;

    brockenGlassAudioPlayer = nil;
    
    opAccount = nil;
    playerAccount = nil;
    
    
    [shotTimer invalidate];
    [moveTimer invalidate];
    [ignoreTimer invalidate];
    [timer invalidate];
    [plView stopAnimation];
    
    shotTimer = nil;
    moveTimer = nil;
    ignoreTimer = nil;
    
    gunDrumViewController = nil;
    profileViewController = nil;
    activityIndicatorView = nil;
    
    oponentsViewCoordinates = nil;
    
    blinkBottom = nil;
    blinkTop = nil;
    
    blurredBack = nil;
    gameStatusLable = nil;
    finalStatusBack = nil;

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
    self.lbUserLifeLeft = nil;
    finalView = nil;
    presentVC = nil;
    finalViewDataSource = nil;
    [barellObject releaseComponents];
    barellObject = nil;
    [cactusObject releaseComponents];
    cactusObject = nil;
    [airBallon releaseComponents];
    airBallon = nil;
    
    [oponentsViewCoordinates removeAllObjects];
    
    [[GameCenterViewController sharedInstance:nil andParentVC:nil] releaseComponents];
    
    self.view = nil;
    plView = nil;
}

@end
