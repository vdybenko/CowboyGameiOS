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
@property(nonatomic, strong) NSString *dImageLocal;
@property(nonatomic, strong) NSString *dImageURL;
@property(nonatomic) NSInteger dID;
@property(nonatomic) NSInteger dPrice;
@property(nonatomic) NSInteger dLevelLock;
@property(nonatomic, strong) NSString *dPurchaseUrl;

-(NSString*) saveNameThumb;
-(NSString*) saveNameImage;

@end
