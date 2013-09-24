//
//  MyClass.h
//  Bounty Hunter
//
//  Created by Taras on 17.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ActivityIndicatorView : UIView {
    UILabel *lbTopText;
}

- (id)init;
- (id)initWithoutRotate;
- (void)setText:(NSString *)text;
- (void)showView;
- (void)hideView;
@end
