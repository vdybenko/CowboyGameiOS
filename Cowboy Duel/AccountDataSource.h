//
//  AccountDataSource.h
//  Test
//
//  Created by Sobol on 20.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "SBJSON.h"
#import "JSON.h"
#import "CDTransaction.h"
#import "CDDuel.h"
#import "ValidationUtils.h"
#import "GCHelper.h"
#import "CDAchivment.h"

typedef enum {
	SHERIF,
    ROBBER,
    ANONIM
} typeOfUser;


@protocol AccountDataSourceDelegate 
- (void)setMoneyLable:(NSString *)pLabel;
@end

@interface AccountDataSource : NSObject {
    
    NSInteger accountDataSourceID;
    int money;
    NSString *accountName;
    NSString * accountID;
    NSInteger accountLevel;
    typeOfUser userType;
    NSMutableArray *teachingTimes;
    NSMutableArray *finalInfoTable;
    NSString *typeImage;
    NSString * sessionID;
    int typeGun;
    
    NSMutableArray *transactions;
    NSMutableArray *duels;
    NSMutableArray *achivments;
    
    NSNumber * glNumber;
    int glIntNumber;
    
    id delegate;
    
    NSMutableDictionary *dicForRequests;
}


@property (nonatomic, readonly) NSInteger accountDataSourceID;
@property(nonatomic) int money;
@property(nonatomic, copy) NSString *accountName;
@property(nonatomic, readwrite) typeOfUser userType;
@property(strong,nonatomic) NSMutableArray *teachingTimes;
@property(strong,nonatomic) NSMutableArray *finalInfoTable;
@property(nonatomic,strong) NSString *typeImage;
@property(strong, nonatomic) NSString *sessionID;
@property(strong, nonatomic) NSString *accountID;
@property(nonatomic) NSInteger accountLevel; 
@property(nonatomic) NSInteger accountPoints; 
@property(nonatomic) NSInteger accountWins; 
@property(nonatomic) NSInteger accountDraws; 
@property(nonatomic) NSInteger accountBigestWin; 
@property(nonatomic) NSInteger removeAds;
@property(strong, nonatomic) NSString *avatar;
@property(strong, nonatomic) NSString *age; 
@property(strong, nonatomic) NSString *homeTown;
@property(nonatomic) NSInteger friends; 
@property(strong, nonatomic) NSString *facebookName;


@property(nonatomic) int typeGun;

@property(strong,nonatomic) NSMutableArray *transactions;
@property(strong,nonatomic) NSMutableArray *duels;
@property(strong, nonatomic) NSNumber *glNumber;
@property(strong,nonatomic) NSMutableArray *achivments;

@property(strong, nonatomic) id delegate;



+ (AccountDataSource *)sharedInstance;
-(id)initWithLocalPlayer;
- (NSArray *)fetchArray:(NSMutableArray *)array;
- (void)sendTransactions:(NSMutableArray *)transactions;
- (void)sendDuels:(NSMutableArray *)duels;
- (NSArray *)fetchDuelArray:(NSMutableArray *)array;

-(NSString *)dateFormatDay;
-(NSString *)dateFormat;

- (void)makeLocalAccountID;
- (NSString *)verifyAccountID;
- (int)stringToInt:(NSString *)string;





@end
