//
//  CDBuiderPurchaseGold.m
//  Bounty Hunter 1.2
//
//  Created by Taras on 1/8/14.
//
//

#import "CDBuiderPurchaseGold.h"

@implementation CDBuiderPurchaseGold
@synthesize dNameForImage;
@synthesize dUrl;
@synthesize dMoneyTextForPrurchase;
@synthesize dMoneyToAdd;
@synthesize dId;

-(id)initWithArray:(NSArray*)arrayOfParametrs;
{
    self = [super init];
    if (self) {
        
        
        dNameForImage = [arrayOfParametrs objectAtIndex:0];
        dUrl = [arrayOfParametrs objectAtIndex:1];
        dMoneyTextForPrurchase = NSLocalizedString(@"LODING", @"");

        dMoneyToAdd = [[arrayOfParametrs objectAtIndex:3] integerValue];
        dId = [[arrayOfParametrs objectAtIndex:2] integerValue];
    }
    return self;
}

-(void)releaseComponents
{
    dNameForImage = nil;
    dUrl = nil;
    dMoneyTextForPrurchase = nil;
}

-(UIImage*) imageForObject;
{
    return [UIImage imageNamed:dNameForImage];
}

@end
