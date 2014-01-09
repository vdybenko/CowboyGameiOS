//
//  CDBuiderPurchaseGold.h
//  Bounty Hunter 1.2
//
//  Created by Taras on 1/8/14.
//
//

#import <Foundation/Foundation.h>

@interface CDBuiderPurchaseGold : NSObject<MemoryManagement>

@property (weak,nonatomic) NSString *dNameForImage;
@property (weak,nonatomic) NSString *dUrl;
@property (weak,nonatomic) NSString *dMoneyTextForPrurchase;
@property (nonatomic) int dMoneyToAdd;
@property (nonatomic) NSInteger dId;

-(id)initWithArray:(NSArray*)arrayOfParametrs;
-(UIImage*) imageForObject;
@end
