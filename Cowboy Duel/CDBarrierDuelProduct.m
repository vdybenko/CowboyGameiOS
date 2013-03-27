//
//  CDBarrierDuelProduct.m
//  Bounty Hunter
//
//  Created by Sergey Sobol on 25.03.13.
//
//

#import "CDBarrierDuelProduct.h"

@implementation CDBarrierDuelProduct
@synthesize dType;
-(void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeInteger:self.dType forKey:@"TYPE"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    self.dType = [decoder decodeIntegerForKey:@"TYPE"];
    return self;
}

-(id)init
{
    self = [super init];
    self.dType = BarrierDuelProductTypeNone;
    return self;
}

@end
