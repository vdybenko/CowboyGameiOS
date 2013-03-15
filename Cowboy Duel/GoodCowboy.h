//
//  GoodCowboy.h
//  Bounty Hunter
//
//  Created by Taras on 14.03.13.
//
//

#import "Shape.h"

@interface GoodCowboy : Shape
@property (weak, nonatomic) IBOutlet UIImageView *goodCowboyImg;

-(void)moveGoodCowboy;
-(void)goodCowboyAnimation;

@end
