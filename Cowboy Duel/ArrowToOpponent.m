//
//  ArrowToOpponent.m
//  Bounty Hunter
//
//  Created by Taras on 20.03.13.
//
//

#import "ArrowToOpponent.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
@interface ArrowToOpponent()
{
    IBOutlet UIView *mainSubView;
    __weak IBOutlet UIImageView *leftArrow;
    __weak IBOutlet UIImageView *rightArrow;
    __weak IBOutlet UIView *vBackIcon;
    
}
@end;
@implementation ArrowToOpponent
@synthesize ivOpponent;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        @autoreleasepool {
            NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"ArrowToOpponent" owner:self options:nil];
            UIView *nibView = [objects objectAtIndex:0];
            [self addSubview:nibView];
        }
        
        CGAffineTransform transformMirror = CGAffineTransformMakeScale(-1.0, 1.0);
        leftArrow.transform = transformMirror;
        
        vBackIcon.clipsToBounds = YES;
        vBackIcon.layer.cornerRadius = ivOpponent.frame.size.width/2;
    }
    return self;
}

-(void)changeImgForPractice;
{
    CGRect cropRect;
    if([Utils isiPhoneRetina]){
        cropRect = CGRectMake(180, 0, 260, 240);
    }else{
        cropRect = CGRectMake(85, 0, 140, 130);
    }
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect([[UIImage imageNamed:@"scarecrow.png"] CGImage], cropRect);
    CGRect smallBounds = CGRectMake(cropRect.origin.x, cropRect.origin.y, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImg = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    [ivOpponent setImage:smallImg];
    ivOpponent.clipsToBounds = YES;
    ivOpponent.layer.cornerRadius = ivOpponent.frame.size.width/2;
}

- (void) changeImg:(UIImage*)image;
{
    CGRect cropRect = CGRectMake((image.size.width*45)/183, 0, (image.size.width*70)/183, (image.size.width*70)/183);

    CGImageRef subImageRef;
    subImageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    CGRect smallBounds = CGRectMake(cropRect.origin.x, cropRect.origin.y, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImg = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    [ivOpponent setImage:smallImg];

    ivOpponent.clipsToBounds = YES;
    ivOpponent.layer.cornerRadius = ivOpponent.frame.size.width/2;
}

-(void)releaseComponents
{
    mainSubView = nil;
    leftArrow = nil;
    rightArrow = nil;
    ivOpponent = nil;
}

#pragma mark

- (void) setDirection:(ArrowToOpponentDirection)direction;
{
    switch (direction) {
        case ArrowToOpponentDirectionLeft:
            mainSubView.hidden = NO;
            rightArrow.hidden = YES;
            leftArrow.hidden = NO;
            break;
        case ArrowToOpponentDirectionRight:
            mainSubView.hidden = NO;
            rightArrow.hidden = NO;
            leftArrow.hidden = YES;
            break;
        case ArrowToOpponentDirectionCenter:
            mainSubView.hidden = YES;
            break;
        default:
            break;
    }
}

- (void) updateRelateveToView:(UIView*)view mainView:(UIView*)mainView;
{
    CGRect frame = [[view superview] convertRect:view.frame toView:mainView];
    CGRect winRect = [UIScreen mainScreen].bounds;
    if (CGRectIntersectsRect(winRect, frame)) {
        [self setDirection:ArrowToOpponentDirectionCenter];
    }else{
        float xNew;
        float yNew  = frame.origin.y + (frame.size.height/2);
        if (yNew<0) {
            yNew = 0;
        }else if ((yNew+self.frame.size.height)>winRect.size.height){
            yNew = winRect.size.height - self.frame.size.height;
        }
        if (frame.origin.x < 0) {
            xNew = 0;
            [self setDirection:ArrowToOpponentDirectionLeft];
        }else{
            xNew = winRect.size.width - self.frame.size.width;
            [self setDirection:ArrowToOpponentDirectionRight];
        }
        CGRect frame = self.frame;
        frame.origin = (CGPoint){xNew,yNew};
        self.frame = frame;
    }
}

@end
