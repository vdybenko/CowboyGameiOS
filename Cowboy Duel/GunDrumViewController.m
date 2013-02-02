//
//  GunDrumViewController.m
//  Cowboy Duels
//
//  Created by Taras on 31.01.13.
//
//

#import "GunDrumViewController.h"

@interface GunDrumViewController ()
{
    BOOL runAnimationDump;
    double angle;
}
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *colectionBullets;
@property (weak, nonatomic) IBOutlet UIView *vLoadGun;
@property (weak, nonatomic) IBOutlet UILabel *lbLoadGun;
@property (weak, nonatomic) IBOutlet UIImageView *ivLine;
@property (weak, nonatomic) IBOutlet UIView *drumBullets;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;
@property (weak, nonatomic) IBOutlet UIView *gun;
@end

//points
static CGPoint pntDumpOpen;
static const CGPoint pntDumpClose = {187,128};
static CGPoint pntGunOpen;
static const CGPoint pntGunClose = {-26,123};
static const CGPoint pntGunHide = {-26,480};
static const CGPoint pntViewShow = {0,0};
static const CGPoint pntViewHide = {0,480};

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
@synthesize ivLine;

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
        
        drumBullets.center= pntDumpClose;
        
        frame=self.view.frame;
        frame.origin = pntViewHide;
        self.view.frame = frame;
        
        lbLoadGun.text = NSLocalizedString(@"text", @"");
        ivLine.transform = CGAffineTransformIdentity;
        ivLine.transform = CGAffineTransformMakeScale(1.0, -1.0);
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
    [self setIvLine:nil];
    [super viewDidUnload];
}

-(void)releaseComponents
{
    [self viewDidUnload];
}

#pragma mark
-(void)openGun;
{
    isCharging = YES;
    [UIView animateWithDuration:timeOpenGun animations:^{
        arrow.hidden = YES;
        vLoadGun.hidden = YES;
        CGRect frame=gun.frame;
        frame.origin = pntGunOpen;
        gun.frame = frame;
        
        drumBullets.hidden = NO;
        
        drumBullets.center = pntDumpOpen;
    }completion:^(BOOL finished) {
        CGFloat timeForCharge = chargeTime;
        [self chargeBulletsForTime:timeForCharge];
    }];
}

-(void)closeDump;
{
    runAnimationDump = NO;
    isCharging = NO;
    arrow.hidden = NO;
    vLoadGun.hidden = NO;
    [UIView animateWithDuration:timeOpenDump animations:^{
        drumBullets.center= pntDumpClose;
    }completion:^(BOOL finished) {
        drumBullets.hidden = YES;
        [self hideBullets];
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
    if (time != 0) {
        timeChargeBullets = time/[colectionBullets count];
        timeSpinDump = time*0.17;
    }
    
    runAnimationDump = YES;
    arrow.hidden = YES;
    vLoadGun.hidden = YES;
    [self spinAnimation];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        for (UIImageView *bullet in colectionBullets) {
            if (!isCharging){
                break;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                bullet.hidden = NO;
            });
            [NSThread sleepForTimeInterval:timeChargeBullets];
        }
        if (isCharging) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideGun];
            });
        }
    });
}

-(void)spinAnimation
{
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
                         if (runAnimationDump)[self spinSecondAnimation];
                     }];
}

-(void)spinSecondAnimation
{
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
                         if (runAnimationDump)[self spinAnimation];
                     }];
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
    runAnimationDump = NO;
    isCharging = NO;
    [UIView animateWithDuration:timeOpenDump animations:^{
        drumBullets.center= pntDumpClose;
    }completion:^(BOOL finished) {
        drumBullets.hidden = YES;
        [self hideBullets];
        [UIView animateWithDuration:timeCloseGun animations:^{
            CGRect frame=gun.frame;
            frame.origin = pntGunClose;
            gun.frame = frame;
        }completion:^(BOOL finished) {
            CGRect frame=self.view.frame;
            frame.origin = pntViewHide;
            self.view.frame = frame;
        }];
    }];
}

-(void)closeController;
{
    [self.view removeFromSuperview];
}

@end
