//
//  TextFieldMultiLine.m
//  Cowboy Duel 1
//
//  Created by Taras on 13.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextFieldMultiLine.h"


@implementation TextFieldMultiLine
@synthesize acceptScrolls;


-(id)initWithFrame:(CGRect)rect{
    self = [super initWithFrame:rect];
    if (self) {
//        [self setScrollEnabled:NO];
        [self setScrollsToTop:NO];
    }
    return self;
}

-(void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {  
//    NSLog(@"scrollRectToVisible %f %f %f",[self contentSize].height,[self contentOffset].y,rect.origin.y );
    if (self.acceptScrolls && ![self.text isEqualToString:@""]){
        rect.origin.y=self.contentSize.height-57;
        [super scrollRectToVisible: rect animated: animated];
    }
}

@end
