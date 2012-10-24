//
//  CDDuelProduct.h
//  Cowboy Duels
//
//  Created by Taras on 24.10.12.
//
//

#import <Foundation/Foundation.h>

@interface CDDuelProduct : NSObject<NSCoding>

@property(nonatomic, strong) NSString *dName;
@property(nonatomic, strong) NSString *dDescription;
@property(nonatomic, strong) NSString *dIconLocal;
@property(nonatomic, strong) NSString *dIconURL;
@property(nonatomic) NSInteger dPrice;
@property(nonatomic, strong) NSString *dPurchaseUrl;
@property(nonatomic, ) NSInteger dEffect;

@end
