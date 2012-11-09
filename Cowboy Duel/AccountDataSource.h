#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "SBJSON.h"
#import "JSON.h"
#import "CDTransaction.h"
#import "CDDuel.h"
#import "ValidationUtils.h"
#import "CDAchivment.h"
#import "CDWeaponProduct.h"

@class StartViewController;
@interface AccountDataSource : NSObject

@property(nonatomic, readonly) NSInteger accountDataSourceID;
@property(nonatomic) int money;
@property(nonatomic, copy) NSString *accountName;
@property(strong, nonatomic) NSString *sessionID;
@property(strong, nonatomic) NSString *accountID;
@property(nonatomic) NSInteger accountLevel; 
@property(nonatomic) NSInteger accountPoints; 
@property(nonatomic) NSInteger accountWins; 
@property(nonatomic) NSInteger accountDraws; 
@property(nonatomic) NSInteger accountBigestWin; 
@property(nonatomic) NSInteger removeAds;

@property(nonatomic) NSInteger accountDefenseValue;
@property(nonatomic) NSInteger curentIdWeapon;
@property(strong, nonatomic) CDWeaponProduct *accountWeapon;

@property(nonatomic) BOOL isTryingWeapon;

@property(strong, nonatomic) NSString *avatar;
@property(strong, nonatomic) NSString *age; 
@property(strong, nonatomic) NSString *homeTown;
@property(nonatomic) NSInteger friends; 
@property(strong, nonatomic) NSString *facebookName;

@property(strong,nonatomic) NSMutableArray *transactions;
@property(strong,nonatomic) NSMutableArray *duels;
@property(strong, nonatomic) NSNumber *glNumber;
@property(strong,nonatomic) NSMutableArray *achivments;

@property(strong,nonatomic) NSMutableArray *teachingTimes;
@property(strong,nonatomic) NSMutableArray *finalInfoTable;

+ (AccountDataSource *)sharedInstance;
- (id)initWithLocalPlayer;
- (void)loadAllParametrs;
- (NSArray *)fetchArray:(NSMutableArray *)array;
- (void)sendTransactions:(NSMutableArray *)transactions;
- (void)sendDuels:(NSMutableArray *)duels;
- (NSArray *)fetchDuelArray:(NSMutableArray *)array;

- (NSString *)dateFormatDay;
- (NSString *)dateFormat;

- (void)makeLocalAccountID;
- (NSString *)verifyAccountID;
- (int)stringToInt:(NSString *)string;

- (void)saveID;
- (void)saveAccountName;
- (void)saveMoney;
- (void)saveAccountLevel;
- (void)saveAccountPoints;
- (void)saveAccountWins;
- (void)saveAccountDraws;
- (void)saveAccountBigestWin;
- (void)saveRemoveAds;
- (void)saveAvatar;
- (void)saveAge;
- (void)saveHomeTown;
- (void)saveFriends;
- (void)saveFacebookName;
- (void)saveDeviceType;
- (void)saveWeapon;
- (void)loadWeapon;
- (void)saveDefense;
- (void)loadDefense;
- (void)saveTransaction;

- (CDWeaponProduct*)loadAccountWeapon;
-(NSUInteger(^)(NSArray *, NSInteger))findObs;

-(void)putchAvatarImageToInitStartVC:(StartViewController*)startVC;
-(BOOL)isAvatarImage:(NSString*)imagePath;
-(BOOL)putchAvatarImageSendInfo;
@end
