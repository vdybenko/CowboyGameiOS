//
//  CDBarrierDuelProduct.h
//  Bounty Hunter
//
//  Created by Sergey Sobol on 25.03.13.
//
//

#import "CDDuelProduct.h"
typedef enum{
    BarrierDuelProductTypeNone,
    BarrierDuelProductTypeBarrel,
    BarrierDuelProductTypeCactus,
    BarrierDuelProductTypeMen,
    BarrierDuelProductTypeWomen,
    BarrierDuelProductTypeHorse
}BarrierDuelProductType;

@interface CDBarrierDuelProduct : CDDuelProduct
@property(nonatomic) BarrierDuelProductType dType;
@end
