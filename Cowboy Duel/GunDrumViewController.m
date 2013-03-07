//
//  GunDrumViewController.m
//  Cowboy Duels
//
//  Created by Taras on 31.01.13.
//
//

#import "GunDrumViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface GunDrumViewController ()
{
    BOOL runAnimationDump;
    int firstAnimationCount;
    int secondAnimationCount;
    int drumAnimationCount;
    double angle;
    float steadyScale;
    float scaleDelta;
    NSTimer *scaleTimer;
    BOOL labelAnimationStarted;
}
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *colectionBullets;
@property (weak, nonatomic) IBOutlet UIView *vLoadGun;
@property (weak, nonatomic) IBOutlet UILabel *lbLoadGun;
@property (weak, nonatomic) IBOutlet UIView *drumBullets;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;
@property (weak, nonatomic) IBOutlet UIView *gun;
@property (weak, nonatomic) IBOutlet UIImageView *gunImage;
@end

//points
static CGPoint pntDumpOpen;
static const CGPoint pntDumpClose = {187,128};//center of image
static CGPoint pntGunOpen;
static const CGPoint pntGunClose = {-26,224};
static const CGPoint pntGunHide = {-26,400};
static const CGPoint pntViewShow = {0,0};
static const CGPoint pntViewHide = {0,400};

//angle
static const CGFloat gunRotationAngle = M_2_PI / 2;

//Time
static const CGFloat timeOpenGun = 0.4f;
static const CGFloat timeOpenDump = 0.4f;
static const CGFloat timeCloseGun = 0.2f;
static CGFloat timeChargeBullets = 0.5f;
static CGFloat timeSpinDump = 0.6f;


@implementation GunDrumViewController
@synthesize colectionBullets;
@synthesize drumBullets;
@synthesize gun;
@synthesize arrow;
@synthesize chargeTime;
@synthesize isCharging;
@synthesize vLoadGun;
@synthesize lbLoadGun;
@synthesize gunImage;

#pragma mark
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadView];

        isCharging = NO;
        
        pntGunOpen=gun.frame.origin;
        pntDumpOpen=drumBullets.center;
        
        CGRect frame=gun.frame;
        frame.origin = pntGunClose;
        gun.frame = frame;
        
        gunImage.layer.anchorPoint = CGPointMake(0.5, 1);
        frame = gunImage.frame;
        frame.origin.y += frame.size.height / 2;
        gunImage.frame = frame;
        drumBullets.center= pntDumpClose;
        
        frame=self.view.frame;
        frame.origin = pntViewHide;
        self.view.frame = frame;
        
        lbLoadGun.text = NSLocalizedString(@"Load", @"");
        steadyScale = 1.0;
        scaleDelta = 0.0;
        scaleTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(setScale) userInfo:nil repeats:YES];

        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDrumBullets:nil];
    [self setColectionBullets:nil];
    [self setArrow:nil];
    [self setVLoadGun:nil];
    [self setLbLoadGun:nil];
    [self setGunImage:nil];
    [self setTapRecognizer:nil];
    [super viewDidUnload];
}

-(void)releaseComponents
{
    [self viewDidUnload];
}

#pragma mark
-(void)openGun;
{
    [self.view.layer removeAllAnimations];
    [self hideBullets];
    [UIView animateWithDuration:timeOpenGun animations:^{
        arrow.hidden = YES;
        gunImage.transform = CGAffineTransformMakeRotation(gunRotationAngle);
        
        drumBullets.center = pntDumpOpen;
    }completion:^(BOOL finished) {
        CGFloat timeForCharge = chargeTime;
        [self chargeBulletsForTime:timeForCharge];
    }];
}

-(void)closeDump;
{
    isCharging = NO;
    
    [UIView animateWithDuration:timeOpenDump animations:^{
        drumBullets.center= pntDumpClose;
        gunImage.transform = CGAffineTransformMakeRotation(0);
        runAnimationDump = NO;
    }completion:^(BOOL finished) {
        isCharging = NO;
        [self hideBullets];
        
        arrow.hidden = NO;
        lbLoadGun.text = NSLocalizedString(@"Load", @"");
        [self changeLableAnimation:vLoadGun endReverce:YES];
        angle = 0;
        CGAffineTransform transform = drumBullets.transform;
        CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
        transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
        drumBullets.transform = transform;
        
        [UIView animateWithDuration:timeCloseGun animations:^{
            CGRect frame=gun.frame;
            frame.origin = pntGunClose;
            gun.frame = frame;
        }completion:^(BOOL finished) {
        }];
    }];
}

-(void)chargeBulletsForTime:(CGFloat)time;
{
    lbLoadGun.text = NSLocalizedString(@"Loading", @"");
    [self changeLableAnimation:vLoadGun endReverce:NO];
    if (time != 0) {
        timeChargeBullets = time/[colectionBullets count];
        timeSpinDump = time*0.17;
    }
    
    isCharging = YES;
    drumAnimationCount++;
    runAnimationDump = YES;
    arrow.hidden = YES;
    [self spinAnimation];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        for (UIImageView *bullet in colectionBullets) {
            if (!isCharging || (drumAnimationCount>=2)) {
                break;
                [self hideBullets];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isCharging){
                    bullet.hidden = NO;
                }
            });
            [NSThread sleepForTimeInterval:timeChargeBullets];
        }
        drumAnimationCount--;
    });
}

-(void)spinAnimation
{
    if ((runAnimationDump)&&(!CGAffineTransformEqualToTransform(CGAffineTransformMakeRotation(0), gunImage.transform))){
        if (firstAnimationCount<1) {
            firstAnimationCount++;
            [UIView animateWithDuration:timeSpinDump
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 angle -= 1.25;
                                 CGAffineTransform transform = drumBullets.transform;
                                 CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
                                 transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
                                 drumBullets.transform = transform;
                             } completion:^(BOOL finished) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     firstAnimationCount--;
                                     if ((runAnimationDump)&&(!CGAffineTransformEqualToTransform(CGAffineTransformMakeRotation(0), gunImage.transform)))
                                         [self spinSecondAnimation];
                                 });
                             }];
        }
    }
}

-(void)spinSecondAnimation
{
    if ((runAnimationDump)&&(!CGAffineTransformEqualToTransform(CGAffineTransformMakeRotation(0), gunImage.transform))){
        if (secondAnimationCount<1) {
            secondAnimationCount++;
            [UIView animateWithDuration:timeSpinDump
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 angle -= 1.25;
                                 CGAffineTransform transform = drumBullets.transform;
                                 CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
                                 transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
                                 drumBullets.transform = transform;
                             } completion:^(BOOL finished) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     secondAnimationCount--;
                                     if ((runAnimationDump)&&(!CGAffineTransformEqualToTransform(CGAffineTransformMakeRotation(0), gunImage.transform)))
                                         [self spinAnimation];
                                 });
                             }];
        }
    }
}

-(void)hideBullets
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        for (UIImageView *bullet in colectionBullets) {
            dispatch_async(dispatch_get_main_queue(), ^{
                bullet.hidden = YES;
            });
        }
    });
}

-(void)showGun;
{
    CGRect frame=self.view.frame;
    frame.origin = pntViewShow;
    self.view.frame = frame;
}

-(void)hideGun;
{
    [UIView animateWithDuration:timeOpenDump animations:^{
        vLoadGun.hidden = YES;
        drumBullets.center= pntDumpClose;
        gunImage.transform = CGAffineTransformMakeRotation(0);
        runAnimationDump = NO;
    }completion:^(BOOL finished) {
        isCharging = NO;
        [self hideBullets];
        angle = 0;
        CGAffineTransform transform = drumBullets.transform;
        CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
        transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
        drumBullets.transform = transform;

        [UIView animateWithDuration:timeCloseGun animations:^{
            CGRect frame=gun.frame;
            frame.origin.y += 50;
            gun.frame = frame;
        }completion:^(BOOL finished) {
            drumBullets.hidden = YES;
        }];
    }];
}

-(void)closeController;
{
    [self.view removeFromSuperview];
    [scaleTimer invalidate];
}

-(void)setScale
{
    if (steadyScale >= 1.3) scaleDelta = -0.01;
    if (steadyScale <= 1.0) scaleDelta = 0.02;
    steadyScale += scaleDelta;
    
    CGAffineTransform steadyTransform = CGAffineTransformMakeScale( steadyScale+scaleDelta*2, steadyScale+scaleDelta*2);
    self.arrow.transform = steadyTransform;
    
}

-(void)lableScaleInView:(UIView*)view
{
    __weak GunDrumViewController *bself = self;
    [UIView animateWithDuration:0.35
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1.15, 1.15);
                     }completion:^(BOOL complete) {
                         [bself lableScaleOutView:view];
                    }];
}

-(void)lableScaleOutView:(UIView*)view
{
    [UIView animateWithDuration:0.35
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     }completion:^(BOOL complete) {
                     }];
    
}

-(void)changeLableAnimation:(UIView*)view endReverce:(BOOL)reverce
{
    if(labelAnimationStarted) return;
    labelAnimationStarted = YES;
    CGRect startFrame = view.frame;
    [UIView animateWithDuration:0.35
                     animations:^{
                         CGRect frame = view.frame;
                         if (reverce) frame.origin.x = -400;
                         else frame.origin.x = 400;
                         view.frame = frame;
                         [UIView animateWithDuration:0.17
                                          animations:^{
                                              view.transform = CGAffineTransformMakeScale(1.5, 1.5);
                                          }completion:^(BOOL complete) {
                                              [UIView animateWithDuration:0.17
                                                               animations:^{
                                                                   view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                               }completion:^(BOOL complete) {
                                                               }];
                                          }];
                         
                     }completion:^(BOOL complete) {
                         [view setHidden:YES];
                         CGRect frame = view.frame;
                         if (reverce) frame.origin.x = frame.size.width;
                         else frame.origin.x = -frame.size.width;
                         view.frame = frame;
                         [view setHidden:NO];
                         [UIView animateWithDuration:0.35
                                          animations:^{
                                              view.frame = startFrame;
                                          }completion:^(BOOL complete) {
                                              labelAnimationStarted = NO;
                                          }];
                     }];
}

#pragma mark Responding to gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ((gestureRecognizer == self.tapRecognizer)&&(!vLoadGun.isHidden)) {
        return YES;
    }
    return NO;
}
- (IBAction)showGestureForTapRecognizer:(UITapGestureRecognizer *)sender {
    [self lableScaleInView:vLoadGun];
}
- (IBAction)tapOnView:(id)sender {
    [self lableScaleInView:vLoadGun];
}

@end
