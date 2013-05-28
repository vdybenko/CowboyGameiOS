//
//  FinalViewDataSource.m
//  Bounty Hunter
//
//  Created by Bezpalchuk Olexandr on 09.04.13.
//
//

#import "FinalViewDataSource.h"
#import "DuelRewardLogicController.h"

@implementation FinalViewDataSource

@synthesize pointsForMatch, moneyExch, oldMoney,oldPoints;
@synthesize playerAccount, oponentAccount;
@synthesize reachNewLevel, userWon, tryButtonEnabled, teaching, isDuelWinWatched;


-(id)initWithUserTime:(int)userTimePar
       andOponentTime:(int)oponentTime
          andTeaching:(BOOL)teach
           andAccount:(AccountDataSource *)userAccount
         andOpAccount:(AccountDataSource *)opAccount
{
    self = [super init];
    if (self){
        

        teaching = teach;
        userTime = userTimePar;
        playerAccount = userAccount;
        oponentAccount = opAccount;
        tryButtonEnabled = YES;
        
        oldMoney = playerAccount.money;
        oldPoints = playerAccount.accountPoints;
        reachNewLevel = NO;
        
        NSLog(@"oldMoney %d oldPoints %d", oldMoney, oldPoints);
        
        if (teaching&&(oponentAccount.bot)) {
            duelWithBotCheck=YES;
        }else{
            duelWithBotCheck=NO;
        }
//        
        transaction = [[CDTransaction alloc] init];
        transaction.trMoneyCh = [NSNumber numberWithInt:10];
        transaction.trDescription = [[NSString alloc] initWithFormat:@"Duel"];
        
        duel = [[CDDuel alloc] init];
        duel.dOpponentId = [[NSString alloc] initWithFormat:@""];
//                
        DLog(@"U %d O %d", userTime, oponentTime);
        
        if ((userTime != 0)&& (userTime != 999999) && (userTime < oponentTime)&& (oponentTime != 999999)) {
            userWon = YES;
            
        }
        else
            if ((userTime == 0) && (oponentTime != 0) && (oponentTime != 999999)&& (userTime != 999999)) {
                userWon = NO;
                
            }
        
        if ((oponentTime != 0) && (oponentTime != 999999) && (userTime > oponentTime)&& (userTime != 999999)) {
            userWon = NO;
        }
        else
            if ((userTime != 0) && (userTime != 999999) && (oponentTime == 0)&& (oponentTime != 999999)) {
                userWon = YES;
            }
        
        if ((userTime == 999999) && (oponentTime != 999999)) {
            userWon = YES;
        }
        if ((oponentTime == 999999) && (userTime != 999999)){
            userWon = NO;
        }
        if ((userTime == 999999) && (oponentTime == 999999))
        {
            userWon = YES;
        }
        
    }
    return self;
}

#pragma mark -

-(void)prepeareForWinScene;
{
    tryButtonEnabled = NO;
    userWon = YES;
}

-(void)prepeareForLoseScene{
    tryButtonEnabled = NO;
    userWon = NO;
}

-(void)loseScene;
{
    isDuelWinWatched = YES;
    moneyExch  = playerAccount.money < 10 ? 1: playerAccount.money / 10.0;
    pointsForMatch=0;

    if (!teaching||(duelWithBotCheck)) {
        oponentAccount.money += moneyExch;
        
        if(playerAccount.money>=moneyExch){
            playerAccount.money -= moneyExch;
            transaction.trType = [NSNumber numberWithInt:-1];
            transaction.trMoneyCh = [NSNumber numberWithInt:-moneyExch];
        }else{
            if (playerAccount.money > 0) {
                transaction.trType = [NSNumber numberWithInt:-1];
                transaction.trMoneyCh = [NSNumber numberWithInt:playerAccount.money];
            }
            playerAccount.money=0;
        }
        
        [self increaseLoseCount];
        
        DLog(@"Oponent Win - User money %d Oponent money %d", playerAccount.money, oponentAccount.money);
        
        pointsForMatch=[self getPointsForLose];
    }
    
}

-(void)winScene;
{
    isDuelWinWatched = NO;
    moneyExch  = oponentAccount.money < 10 ? 1: oponentAccount.money / 10.0;
    pointsForMatch=0;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/FinalVC_finaly" forKey:@"page"]];
    if(!teaching||(duelWithBotCheck)){
        // added for GC
        if (![GCHelper sharedInstance].GClocalPlayer.isAuthenticated) {
            [[GCHelper sharedInstance] authenticateLocalUser];
        }else{
            [[GCHelper sharedInstance] reportScore:playerAccount.money forCategory:GC_LEADEBOARD_MONEY];
        }
        
        // above
        
        playerAccount.money += moneyExch;
        oponentAccount.money -= moneyExch;
        
        [self checkMaxWin:moneyExch];
        
        //transaction.trType = [NSNumber numberWithInt:moneyExch / abs(moneyExch)];                       //////////////////transactions
        transaction.trType = [NSNumber numberWithInt:1];
        transaction.trMoneyCh = [NSNumber numberWithInt:moneyExch];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"dontShowFeedAtFirst"]) {
            [[StartViewController sharedInstance] setShowFeedAtFirst:YES];
        }
        DLog(@"You Win - User money %d Oponent money %d", playerAccount.money, oponentAccount.money);
        
        [playerAccount saveMoney];
        
        [self increaseWinCount];
        
        pointsForMatch=[self getPointsForWin];
    }
}


-(void)lastScene;
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DUEL_VIEW_NOT_FIRST"];
    
    if (!teaching||(duelWithBotCheck)) {
        
        transaction.trOpponentID = [NSString stringWithString:(oponentAccount.accountID) ? [NSString stringWithString:oponentAccount.accountID]:@""];
        transaction.trLocalID = [NSNumber numberWithInt:[playerAccount increaseGlNumber]];
        [playerAccount.transactions addObject:transaction];
        
        CDTransaction *opponentTransaction = [CDTransaction new];
        [opponentTransaction setTrDescription:[NSString stringWithString:transaction.trDescription]];
        
        if ([transaction.trType intValue] == 1) [opponentTransaction setTrType:[NSNumber numberWithInt:-1]];
        else   [opponentTransaction setTrType:[NSNumber numberWithInt:1]];
        
        [opponentTransaction setTrMoneyCh:[NSNumber numberWithInt:-[transaction.trMoneyCh intValue]]];
        opponentTransaction.trOpponentID = [NSString stringWithString:(playerAccount.accountID) ? [NSString stringWithString:playerAccount.accountID]:@""];
        opponentTransaction.trLocalID = [NSNumber numberWithInt:-1];
        [oponentAccount.transactions addObject:opponentTransaction];
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [playerAccount saveTransaction];
        
        [def synchronize];
            
        [playerAccount saveMoney];
        
        [def synchronize];
        
        [playerAccount sendTransactions:playerAccount.transactions];
        if (oponentAccount.bot) [oponentAccount sendTransactions:oponentAccount.transactions];

        [[StartViewController sharedInstance] modifierUser:playerAccount];
        if(oponentAccount.bot) [[StartViewController sharedInstance] modifierUser:oponentAccount];
    }
    
}

#pragma mark -

-(void)checkMaxWin:(int)pMoneyExch;
{
    if (playerAccount.accountBigestWin==0){
        playerAccount.accountBigestWin=pMoneyExch;
    }
    else
    {
        if (pMoneyExch>playerAccount.accountBigestWin) {
            playerAccount.accountBigestWin=pMoneyExch;
        }
    }
    [playerAccount saveAccountBigestWin];
}

-(void)increaseLoseCount;
{
    if (playerAccount.accountDraws==0){
        playerAccount.accountDraws=1;
    }
    else
    {
        playerAccount.accountDraws++;
    }
    [playerAccount saveAccountDraws];
}

-(void)increaseWinCount;

{
    if ( playerAccount.accountWins==0){
        playerAccount.accountWins=1;
    }
    else
    {
        playerAccount.accountWins++;
    }
    [playerAccount saveAccountWins];
}
#pragma mark - check Level, Points change and other saved features

-(NSInteger)getPointsForWin;
{
    NSInteger oldL=playerAccount.accountPoints;
    int winPonits=[DuelRewardLogicController getPointsForWinWithOponentLevel:oponentAccount.accountLevel];
    playerAccount.accountPoints+=winPonits;
    [playerAccount saveAccountPoints];
    
    [self compareNewLevel:playerAccount.accountPoints withOldLevel:oldL];
    
    return winPonits;
}

-(NSInteger)getPointsForLose;
{
    NSInteger oldL=playerAccount.accountPoints;
    int losePonits=[DuelRewardLogicController getPointsForLoseWithOponentLevel:oponentAccount.accountLevel];
    playerAccount.accountPoints+=losePonits;
    [playerAccount saveAccountPoints];
    
    [self compareNewLevel:playerAccount.accountPoints withOldLevel:oldL];
    
    return losePonits;
}

-(void)compareNewLevel:(NSInteger)newL withOldLevel:(NSInteger) oldL;
{
    pointForEachLevels=[DuelRewardLogicController getStaticPointsForEachLevels];
    
    for ( NSNumber *pointMoney in pointForEachLevels) {
        if (([pointMoney intValue]<=newL)&&([pointMoney intValue]>oldL)) {
            int playerNewLevel=[pointForEachLevels indexOfObject:pointMoney]+1;
            if (playerNewLevel < kCountOfLevelsMinimal || playerNewLevel > kCountOfLevels ){
                playerNewLevel = kCountOfLevels;
            }
            NSLog(@"playerNewLevel %d pointMoney %d",playerNewLevel,[pointMoney intValue]);
            playerAccount.accountLevel=playerNewLevel;
            [playerAccount saveAccountLevel];
            
            reachNewLevel=YES;
            // added for GC
            if (![GCHelper sharedInstance].GClocalPlayer.isAuthenticated) {
                [[GCHelper sharedInstance] authenticateLocalUser];
            }else{
                [[GCHelper sharedInstance] reportAchievementIdentifier:[[GCHelper sharedInstance].GC_ACH objectAtIndex:playerAccount.accountLevel] percentComplete:100.0f];
            }
            // above
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark -
@end
