//
//  DuelStartViewController.m
//  Test
//
//  Created by Sobol on 08.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DuelStartViewController.h"
#import "DuelViewController.h"
#import "GameCenterViewController.h"
#import "UIButton+Image+Title.h"
#import "DuelRewardLogicController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Save.h"
#import "CustomNSURLConnection.h"
#import "UIView+Dinamic_BackGround.h"

@interface DuelStartViewController (PrivateMethods)

- (void)setOponentInfo;

@end

@implementation DuelStartViewController
@synthesize _ivOponent, delegate ,oponentNameOnLine, serverName, oponentAvailable, tryAgain;
@synthesize _btnStart, activityIndicatorView, _ivPlayer, _vBackground, _lbNamePlayer, _lbNameOponent, _btnBack;//, _lbMoneyOponent, _lbMoneyPlayer;
@synthesize _vWait, _pleaseWaitLabel, _waitLabel, lbOpponentDuelsWinCount;//, _vWaitLabelLines;
static const char *GC_URL =  BASE_URL"api/gc";

-(id)initWithAccount:(AccountDataSource *)userAccount andOpAccount:(AccountDataSource *)opAccount opopnentAvailable:(BOOL)available andServerType:(BOOL)server andTryAgain:(BOOL)tryA;
{
    if (self == [super initWithNibName:nil bundle:nil]) {
        oponentAvailable=available;
        tryAgain = tryA;
        serverType = server;
        playerAccount = userAccount;
        oponentAccount = opAccount;
    }
    return self;
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewDidLoad{
        
    if (oponentAvailable) {
        
    }
    else
    {
        runAnimation=YES;
        timerIndex = 0;
    }
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    
    if([uDef boolForKey:@"FirstRunForDuel"])  firstRun = YES;
    else firstRun = NO;
    [uDef setBool:FALSE forKey:@"FirstRunForDuel"];
    
    CGRect frame;
    //player image
   
    UIColor *buttonsTitleColor = [[UIColor alloc] initWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    [_btnBack setTitleByLabel:@"BACK"];
    [_btnBack changeColorOfTitleByLabel:buttonsTitleColor];
    
    [_btnStart setTitleByLabel:@"START"];
    [_btnStart changeColorOfTitleByLabel:buttonsTitleColor];

    UIFont *fontNames=[UIFont fontWithName: @"MyriadPro-Semibold" size:16];
    UIFont *fontSimpleText=[UIFont fontWithName: @"MyriadPro-Semibold" size:13];
    
    if (playerAccount.accountName != nil)
        _lbNamePlayer.text = playerAccount.accountName;
    else 
        _lbNamePlayer.text = @"YOU";
    
    _lbNamePlayer.font=fontNames;
    //_lbMoneyPlayer.text =  [NSString stringWithFormat:@"%@%d",@"$",playerAccount.money];
        
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Back2.mp3", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [player play];
    [player stop];
    [player setNumberOfLoops:999];
    [playerAccount.finalInfoTable removeAllObjects];
    
    
    activityIndicatorView = [[ActivityIndicatorView alloc] init];
    frame = activityIndicatorView.frame;
    frame.origin = CGPointMake(-80, 0);
    activityIndicatorView.frame=frame;
    [self.view  addSubview:activityIndicatorView];
            
    //title
    UIColor *mainColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    lbDuelStart.textColor = mainColor;
    lbDuelStart.text = NSLocalizedString(@"StartDuelTitle", nil);
    lbDuelStart.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    
    //User's labels
    _ivPlayer.contentMode = UIViewContentModeScaleAspectFit;
    if([[OGHelper sharedInstance] isAuthorized]){
        NSString *pathToImage=[[OGHelper sharedInstance] apiGraphGetImage:@"me"];
        UIImage *image=[UIImage loadImageFromDocumentDirectory:[pathToImage lastPathComponent]];
        [_ivPlayer setImage:image];
    }else {
        [_ivPlayer setImage:[UIImage imageNamed:@"pv_photo_default.png"]];
    }
    
    lbUserDuelsWin.text = NSLocalizedString(@"DuelsWonsTitle", nil);
    lbUserDuelsWin.font=fontSimpleText; 
    
    lbUserRank.text = [NSString stringWithFormat:@"%d",playerAccount.accountWins];
    NSString *Rank=[NSString stringWithFormat:@"%dRank",playerAccount.accountLevel];
    lbUserRank.text = NSLocalizedString(Rank, @"");
    lbUserRank.font=fontSimpleText;
    
    lbUserDuelsWinCount.text = [NSString stringWithFormat:@"%d",playerAccount.accountWins];
    lbUserDuelsWinCount.font=fontSimpleText;

    //Opponent's labels
    _lbNameOponent.text = oponentAccount.accountName;
    _lbNameOponent.font=fontNames;

    _ivOponent.contentMode = UIViewContentModeScaleAspectFit;
    
    NSString *nameOfRank=[NSString stringWithFormat:@"%dRank",oponentAccount.accountLevel];
    lbOpponentRank.text = NSLocalizedString(nameOfRank, @"");
    lbOpponentRank.font=fontSimpleText;

    lbOpponentDuelsWin.text = NSLocalizedString(@"DuelsWonsTitle", nil);    
    lbOpponentDuelsWin.font=fontSimpleText;

    lbOpponentDuelsWinCount.text = [NSString stringWithFormat:@"%d",oponentAccount.accountWins];
    lbOpponentDuelsWinCount.font=fontSimpleText;

    lbForTheMurder.text = NSLocalizedString(@"MotivationText1", nil);
    lbForTheMurder.font=fontSimpleText;

    lbReward.text = NSLocalizedString(@"MotivationText2", nil);
    lbReward.font=fontSimpleText;

    [self setOponentMoney:oponentAccount.money];

    lbGold.text = NSLocalizedString(@"MotivationGold", nil);
    lbGold.font=fontSimpleText;
    
    lbPoints.text = NSLocalizedString(@"MotivationPoints", nil);
    lbPoints.font=fontSimpleText;

    lbPointsCount.text = [NSString stringWithFormat:@"%d",[DuelRewardLogicController getPointsForWinWithOponentLevel:oponentAccount.accountLevel]];
    lbPointsCount.font = fontSimpleText;

    frame=lbPointsCount.frame;
    CGSize size=[lbPointsCount fitSizeToText:lbPointsCount];
    frame.size.width=size.width;
    [lbPointsCount setFrame:frame];
    
    [lbPoints dinamicAttachToView:lbPointsCount withDirection:DirectionToAnimateRight];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [mainDuelView setDinamicHeightBackground];
    [activityIndicatorView hideView];
    [self setOponentImage];
}

-(void)viewDidAppear:(BOOL)animated
{
    //[activityIndicatorView hideView];
    
    
    if (oponentAvailable) {
        [_btnStart setEnabled:YES];
        [_btnStart setHidden:NO];
        [_vWait setHidden:YES];
    }else{
        [_btnStart setHidden:YES];
        [_vWait setHidden:NO];
    }
    if ((!serverType)&&(!tryAgain)) {
        
        GameCenterViewController * gController = (GameCenterViewController *) delegate;
        
//        NSString *convertString = serverName;
//        NSUInteger bufferCount = sizeof(char) * ([convertString length] + 1);
//        char *utf8Buffer = malloc(bufferCount);
//        [convertString getCString:utf8Buffer 
//                        maxLength:bufferCount 
//                         encoding:NSUTF8StringEncoding];
//        char *hostName = strdup(utf8Buffer);
        const char *name = [serverName cStringUsingEncoding:NSUTF8StringEncoding];
        SSConnection *connection = [SSConnection sharedInstance];
        [connection sendData:(void *)(name) packetID:NETWORK_SET_PAIR ofLength:sizeof(char) * [serverName length]];
        //[gController matchStartedSinxron];
    }
    [[self.navigationController.viewControllers objectAtIndex:1] performSelector:@selector(playerStop)];
    [player play];
}


-(void)viewWillDisappear:(BOOL)animated
{
    runAnimation = NO;
    if (waitTimer) [waitTimer invalidate];
    [player stop];
}

-(void)viewDidDisappear:(BOOL)animated
{
    _ivOponent.image = nil;
    [_vWait setHidden:YES];
    [activityIndicatorView hideView];
}
#pragma mark - 


-(void)waitTimerTick
{
    if (!waitTimer) return;
    [self cancelButtonClick];
    [waitTimer invalidate];
    waitTimer = nil;
    
}


-(IBAction)startButtonClick;
{
    if (!serverType) waitTimer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(waitTimerTick) userInfo:nil repeats:NO];
    [delegate btnClickStart];
    [activityIndicatorView showView];
}

-(IBAction)cancelButtonClick;
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    
    [delegate duelCancel];
}

#pragma mark FConnect Methods

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    
    if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)) {
        result = [result objectAtIndex:0];
    }
    _ivOponent.image = [[UIImage alloc] initWithData:result];
    
    NSString *name=[[OGHelper sharedInstance ] getClearName:oponentAccount.accountID];
    NSString *path = [NSString stringWithFormat:@"%@/icon_%@.png",[[OGHelper sharedInstance] getSavePathForList],name];
    [UIImagePNGRepresentation(_ivOponent.image) writeToFile:path atomically:YES];
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    DLog(@"DuelStartViewController didFailWithError: %@  error %@"  , request,[error description]);
    _ivOponent.image = [UIImage imageNamed:@"pv_photo_default.png"];
    _ivOponent.transform = CGAffineTransformIdentity;
    _ivOponent.transform = CGAffineTransformMakeScale(-1.0, 1.0);
}

#pragma mark -
#pragma mark DuelStartViewControllerDelegate protocol Methods

#pragma mark -
#pragma mark DuelStartViewControllerDelegate protocol Methods

-(void)setOponent:(NSString*)iv Label1:(NSString*)uil1 Label1:(int)uil2;
{   
//    runAnimation = NO;
//    [_vWait setHidden:YES];
//    
//    pathFile=[NSString stringWithFormat:@"%@%@%@",@"pv_bm_",iv,@".png"];
//    [_ivOponent setImage:[UIImage imageNamed:pathFile]];
//    _ivOponent.transform = CGAffineTransformIdentity;
//    _ivOponent.transform = CGAffineTransformMakeScale(-1.0, 1.0);
//    
//    [self setOponentInfo];
//    [self.view bringSubviewToFront:activityIndicatorView ];
//    
//    _lbNameOponent.text = uil1;
//    //_lbMoneyOponent.text =  [NSString stringWithFormat:@"%@%d",@"$",uil2];
//    [_lbNameOponent setHidden:NO];
//    //[_lbMoneyOponent setHidden:NO];
//    
//    [_btnStart setEnabled:YES];
    
}

- (void)setOponentInfo 
{	
//    [_lbNameOponent setFont: [UIFont fontWithName: @"DecreeNarrow" size:22]];
//    UIColor *col=[[UIColor alloc] initWithRed:0.317 green:0.274 blue:0.184 alpha:1];
//    [_lbNameOponent setTextColor:col];
//    
//    //[_lbMoneyOponent setFont: [UIFont fontWithName: @"MyriadPro-Bold" size:15]];
//    col=[[UIColor alloc] initWithRed:0.317 green:0.274 blue:0.184 alpha:1];
//    //[_lbMoneyOponent setTextColor:col];
}
-(void)setMessageToOponent:(NSString*)pMessage;
{
    NSString *mesFull=[NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"HTML_MES_HEAD", @""),pMessage,NSLocalizedString(@"HTML_ASS", @"")];
}
-(void)cancelDuel;
{
//   Выводитса сообщение NSLocalizedString(@"RanAway", @"")
    [activityIndicatorView hideView];
    [_btnStart setEnabled:NO];
}

- (void)setMessageTry   
{	
    
}

-(void)setUserMoney:(int)money;
{   
    //_lbMoneyPlayer.text =  [NSString stringWithFormat:@"%@%d",@"$",money];
}

-(void)setOponentMoney:(int)money;
{
    int moneyExch  = playerAccount.money < 10 ? 1: money / 10.0;
// added for thousands separate   
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(moneyExch)]];
    lbGoldCount.text = formattedNumberString;
    
    CGRect frame=lbGoldCount.frame;

    lbGoldCount.font=[UIFont fontWithName: @"MyriadPro-Semibold" size:13];;
    CGSize size=[lbGoldCount fitSizeToText:lbGoldCount];
    frame.size.width=size.width;
    [lbGoldCount setFrame:frame];
    
    [lbGold dinamicAttachToView:lbGoldCount withDirection:DirectionToAnimateRight ];
}

-(void)setOponentImage;
{
    NSString *name = [[OGHelper sharedInstance ] getClearName:oponentAccount.accountID];
    NSString *path=[NSString stringWithFormat:@"%@/icon_%@.png",[[OGHelper sharedInstance] getSavePathForList],name];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){  
        UIImage *image=[UIImage loadImageFullPath:path];
        _ivOponent.image = image;
    }else {
        if ([oponentAccount.accountID rangeOfString:@"F"].location != NSNotFound) {
            iconDownloader = [[IconDownloader alloc] init];
            
            iconDownloader.namePlayer=name;
            iconDownloader.delegate = self;
            if ([oponentAccount.avatar isEqualToString:@""]) {
                NSString *urlOponent=[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",name];
                [iconDownloader setAvatarURL:urlOponent];
            }else {
                [iconDownloader setAvatarURL:oponentAccount.avatar];
            }
            [iconDownloader startDownloadSimpleIcon];
        }else {
            _ivOponent.image = [UIImage imageNamed:@"pv_photo_default.png"];
            _ivOponent.transform = CGAffineTransformIdentity;
            _ivOponent.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            
        }
    }   
}

- (void)viewDidUnload {
    mainDuelView = nil;
    lbUserRank = nil;
    lbUserDuelsWin = nil;
    lbUserDuelsWinCount = nil;
    lbOpponentRank = nil;
    lbOpponentDuelsWin = nil;
    lbOpponentDuelsWinCount = nil;
    lbForTheMurder = nil;
    lbReward = nil;
    lbGoldCount = nil;
    lbGold = nil;
    lbPointsCount = nil;
    lbPoints = nil;
    [super viewDidUnload];
}

#pragma mark IconDownloaderDelegate
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    _ivOponent.image = iconDownloader.imageDownloaded;    
}
@end
