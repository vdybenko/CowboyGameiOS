//
//  CDVisualViewCharacterPart.h
//  Bounty Hunter
//
//  Created by Taras on 25.03.13.
//
//

#import <Foundation/Foundation.h>

@interface CDVisualViewCharacterPart : NSObject<MemoryManagement>
@property (weak,nonatomic) NSString *nameForImage;
@property (nonatomic) CGRect rectForImage;
@property (nonatomic) int money;

-(id)initWithArray:(NSArray*)arrayOfParametrs;
-(UIImage*) imageForObject;
@end
