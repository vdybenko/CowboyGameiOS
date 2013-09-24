//
//  UIView+Dinamic_BackGround.m
//  Bounty Hunter 1
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
    if ([Utils isiPhoneRetina]) {
        frameToCrop=CGRectMake(0, 0, 2*imageBackGround.size.width, 2*mainFrame.size.height);
    }else {
        frameToCrop=CGRectMake(0, 0, imageBackGround.size.width, mainFrame.size.height);
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageBackGround CGImage], frameToCrop);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    UIImageView *ivBody=[[UIImageView alloc] initWithImage:cropped];
    CGRect frame=CGRectMake(0, 0, imageBackGround.size.width, mainFrame.size.height);
    [ivBody setFrame:frame];
    
    [self insertSubview:ivBody atIndex:0];
    CGImageRelease(imageRef);
    
    if (mainFrame.size.height<=imageBackGround.size.height) {
        ivBody.layer.cornerRadius = 20.0;
        ivBody.layer.masksToBounds = YES;
        
        UIImageView *ivBottom=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"view_dinamic_height_bottom.png"]];
        CGRect frameBottom=ivBottom.frame;
        frameBottom.origin.y=mainFrame.size.height-frameBottom.size.height;
        [ivBottom setFrame:frameBottom];
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
