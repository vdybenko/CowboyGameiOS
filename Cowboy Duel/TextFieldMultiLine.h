//
//  TextFieldMultiLine.h
//  Cowboy Duel 1
//
//  Created by Taras on 13.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TextFieldMultiLine : UITextView <UIScrollViewDelegate>{
    BOOL acceptScrolls;
}

@property (readwrite) BOOL acceptScrolls;
@end
