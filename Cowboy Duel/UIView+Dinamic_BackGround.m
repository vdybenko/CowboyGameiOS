//
//  UIView+Dinamic_BackGround.m
//  Cowboy Duel 1
//
//  Created by Taras on 25.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIView+Dinamic_BackGround.h"
#import "Utils.h"

@implementation UIView (dinamic_height_backgroud)

-(void)setDinamicHeightBackground;
{    
    UIImage *imageBackGround=[UIImage imageNamed:@"view_dinamic_height.png"];
    CGRect mainFrame=self.frame;
    CGRect frameToCrop;
    CGFloat heightSize;
    if ([Utils isiPhoneRetina]) {
        frameToCrop=CGRectMake(0, 0, 2*imageBackGround.size.width, mainFrame.size.height);
        heightSize = 2*imageBackGround.size.height;
    }else {
        frameToCrop=CGRectMake(0, 0, imageBackGround.size.width, mainFrame.size.height);
        heightSize = imageBackGround.size.height;
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageBackGround CGImage], frameToCrop);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    UIImageView *ivBody=[[UIImageView alloc] initWithImage:cropped];
    [ivBody setContentMode:UIViewContentModeScaleAspectFit];
    
    [self insertSubview:ivBody atIndex:0];
    CGImageRelease(imageRef);
    
    if (mainFrame.size.height<heightSize) {
        ivBody.layer.cornerRadius = 40.0;
        ivBody.layer.masksToBounds = YES;
        
        UIImageView *ivBottom=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"view_dinamic_height_bottom.png"]];
        CGRect frameBottom=ivBottom.frame;
        if ([Utils isiPhoneRetina]) {
            frameBottom.size = CGSizeMake(frameToCrop.size.width, 2*frameBottom.size.height);
        }else {
            frameBottom.size = CGSizeMake(frameToCrop.size.width, frameBottom.size.height);
        }
        frameBottom.origin.y=mainFrame.size.height-frameBottom.size.height;
        [ivBottom setFrame:frameBottom];
        [ivBottom setContentMode:UIViewContentModeScaleAspectFit];
        [self insertSubview:ivBottom aboveSubview:ivBody];
        
        ivBottom = nil;
    }
    ivBody = nil;
}

-(void)dinamicAttachToView:(UIView*)attachedToView withDirection:(DirectionToAnimate)direction;
{
    CGRect frameToAttach=self.frame;
    switch (direction) {
        case DirectionToAnimateLeft:
            frameToAttach.origin.x=attachedToView.frame.origin.x-frameToAttach.size.width-2;
            break;
        case DirectionToAnimateRight:  
            frameToAttach.origin.x=attachedToView.frame.origin.x+attachedToView.frame.size.width+2;
            break;
        default:
            break;
    }
    [self setFrame:frameToAttach];
}

-(CGSize)fitSizeToText:(UILabel*)label;
{
    UIFont *font = [label font]; 
    NSString *text=label.text;
    CGSize size = [text sizeWithFont:font];
    return size;
}
@end
