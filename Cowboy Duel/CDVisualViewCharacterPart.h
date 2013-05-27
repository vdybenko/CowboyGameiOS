//
//  CDVisualViewCharacterPart.h
//  Bounty Hunter
//
//  Created by Taras on 25.03.13.
//
//

#import <Foundation/Foundation.h>

#define indexOfLastStaticValues 3

@interface CDVisualViewCharacterPart : NSObject<MemoryManagement>
@property (weak,nonatomic) NSString *nameForImage;
@property (nonatomic) CGRect rectForImage;
@property (nonatomic) int money;
@property (nonatomic) NSInteger dId;
@property (nonatomic) NSInteger levelLock;
@property (nonatomic) NSInteger action;

-(id)initWithArray:(NSArray*)arrayOfParametrs;
-(UIImage*) imageForObject;
@end
