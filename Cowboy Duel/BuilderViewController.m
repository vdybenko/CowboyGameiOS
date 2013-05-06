//
//  BuilderViewController.m
//  Bounty Hunter
//
//  Created by Alex Novitsky on 5/6/13.
//
//

#import "BuilderViewController.h"

@interface BuilderViewController ()

@property (weak, nonatomic) IBOutlet UIView *gunView1;
@property (weak, nonatomic) IBOutlet UIView *sideView;
@property (weak, nonatomic) IBOutlet UIScrollView *gunsScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *hatsScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *jaketScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *shirtScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *faceScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *shoesScroll;


@end

@implementation BuilderViewController
- (IBAction)touchCloseSideView:(id)sender {
    [self sideCloseAnimation];
}

- (IBAction)touchHatBtn:(id)sender {
    self.hatsScroll.hidden = NO;
    [self sideOpenAnimation];
    
}
- (IBAction)touchFaceBtn:(id)sender {
    self.faceScroll.hidden = NO;
      [self sideOpenAnimation];
}
- (IBAction)touchShirtBtn:(id)sender {
    self.shirtScroll.hidden = NO;
      [self sideOpenAnimation];
}
- (IBAction)touchJaketBtn:(id)sender {
    self.jaketScroll.hidden = NO;
      [self sideOpenAnimation];
}
- (IBAction)touchShoesBtn:(id)sender {
    self.shoesScroll.hidden = NO;
      [self sideOpenAnimation];
}
- (IBAction)touchGunsBtn:(id)sender {
    self.gunsScroll.hidden = NO;
      [self sideOpenAnimation];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
   
    }
    return self;
}

- (void)viewDidLoad
{
   
     
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)sideOpenAnimation{

    [UIView animateWithDuration:0.6 animations:^{
       CGRect frame = self.sideView.frame;
        frame.origin.x -= 100;
        self.sideView.frame = frame;
        
    }completion:^(BOOL finished) {
    }];



}
-(void)sideCloseAnimation{
    
    [UIView animateWithDuration:0.6 animations:^{
        CGRect frame = self.sideView.frame;
        frame.origin.x += 100;
        self.sideView.frame = frame;
        
    }completion:^(BOOL finished) {
          self.hatsScroll.hidden = YES;
          self.jaketScroll.hidden = YES;
          self.faceScroll.hidden = YES;
          self.shoesScroll.hidden = YES;
          self.shirtScroll.hidden = YES;
          self.gunsScroll.hidden = YES;
        
    }];
    
    
    
}
- (void)viewDidUnload {
    [self setGunView1:nil];
    [self setSideView:nil];
    [self setGunsScroll:nil];
    [self setHatsScroll:nil];
    [self setJaketScroll:nil];
    [self setShirtScroll:nil];
    [self setFaceScroll:nil];
    [self setShoesScroll:nil];
    [super viewDidUnload];
}
@end
