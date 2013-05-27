#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "SBJSON.h"
#import "JSON.h"
#import "CDTransaction.h"
#import "ValidationUtils.h"
#import "CDAchivment.h"
#import "CDWeaponProduct.h"
#import "GameSceneConfig.h"
#import "VisualViewDataSource.h"

@class StartViewController;
@interface AccountDataSource : NSObject <FBLoginViewDelegate>

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
@property(nonatomic) GameSceneConfig *accountSceneConfig;
@property(nonatomic) NSInteger removeAds;
@property(nonatomic) BOOL activeDuel;

@property(nonatomic) NSInteger accountDefenseValue;
@property(nonatomic) NSInteger accountAtackValue;
@property(nonatomic) NSInteger curentIdWeapon;
@property(strong, nonatomic) CDWeaponProduct *accountWeapon;

@property(nonatomic) BOOL isTryingWeapon;

@property(strong, nonatomic) NSString *avatar;
@property(strong, nonatomic) NSString *age; 
@property(strong, nonatomic) NSString *homeTown;
@property(nonatomic) NSInteger friends; 
@property(strong, nonatomic) NSString *facebookName;

@property(strong,nonatomic) NSMutableArray *transactions;
@property(nonatomic) int glNumber;
@property(strong,nonatomic) NSMutableArray *achivments;

@property(strong,nonatomic) NSMutableArray *teachingTimes;
@property(strong,nonatomic) NSMutableArray *finalInfoTable;

@property(nonatomic) BOOL bot;

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *facebookAccount;

@property (nonatomic, strong) id loginAnimatedViewController;
@property (nonatomic, strong) id<FBGraphUser> facebookUser;

//Visual view character
@property(nonatomic) int visualViewCap;
@property(nonatomic) int visualViewHead;
@property(nonatomic) int visualViewBody;
@property(nonatomic) int visualViewLegs;
@property(nonatomic) int visualViewShoose;
@property(nonatomic) int visualViewJackets;
@property(nonatomic) int visualViewGuns;
@property(nonatomic) int visualViewSuits;
@property(nonatomic) NSMutableArray *arrayOfBoughtProducts;

+ (AccountDataSource *)sharedInstance;
- (id)initWithLocalPlayer;
- (void)loadAllParametrs;
- (NSArray *)fetchArray:(NSMutableArray *)array;
- (void)sendTransactions:(NSMutableArray *)transactions;

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
- (void)cleareWeaponAndDefense;
- (void)saveTransaction;
- (void)saveGlNumber;
- (int)increaseGlNumber;

- (void)saveVisualView;
- (void)loadVisualView;
- (BOOL)isProductBought:(NSInteger)index;

- (int)recountDefenseAndAtack;
- (CDVisualViewCharacterPart*)loadProductWithIndex:(int)index type:(CharacterPart)type visualViewDataSource:(VisualViewDataSource*)datasource;

- (BOOL)isPlayerPlayDuel;
- (BOOL)isPlayerForPractice;

- (CDWeaponProduct*)loadAccountWeapon;
-(NSUInteger(^)(NSArray *, NSInteger))findObsByID;
-(NSUInteger(^)(NSArray *, NSString *))findObsByPurchase;

-(BOOL)isAvatarImage:(NSString*)imagePath;
-(BOOL)putchAvatarImageSendInfo;

-(BOOL)loginFacebookiOS6;

@end
