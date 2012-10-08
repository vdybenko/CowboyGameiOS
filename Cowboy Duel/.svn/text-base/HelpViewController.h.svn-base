//
//  HelpViewController.h
//  Test
//
//  Created by Taras on 16.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StartViewController.h"


#define btnFBHelp @"http://www.youtube.com/watch?v=HZST2wcGAr4"


@interface HelpViewController : UIViewController {
    UIWindow *window;
    UIScrollView *__unsafe_unretained scrollView;
    UIPageControl *__unsafe_unretained pageControl;
    NSMutableArray *__unsafe_unretained viewControllers;
    BOOL pageControlUsed;
    int pageNumber;
    BOOL firstRun;
    CGRect frame;
    UILabel *label1;
    UIImage *imageBtn;
    id startVC;
        
    IBOutlet UIView *mainView;
    IBOutlet UIButton *_btnBack;
    IBOutlet UIButton *_btnVideo;
    IBOutlet UIButton *btnContact;
    IBOutlet UIWebView *_webViewMessage;
    IBOutlet UIView *_vBackground;
    IBOutlet UILabel *lbBackBtn;
    IBOutlet UILabel *lbVideoBtn;
    IBOutlet UILabel *lbContactButton;
    
    IBOutlet UILabel *lbTitleHelp;
}
@property (strong, nonatomic) IBOutlet UIButton *_btnBack;
@property (strong, nonatomic) IBOutlet UIButton *_btnVideo;
@property (strong, nonatomic) IBOutlet UIWebView *_webViewMessage;
@property (strong, nonatomic) IBOutlet UIView *_vBackground;
@property (unsafe_unretained, nonatomic) UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) UIPageControl *pageControl;
@property (unsafe_unretained, nonatomic) NSMutableArray *viewControllers;

- (id)init:(BOOL)firstStart startVC:(id)startVCl;
- (id)initPractice;
-(void) setHelpLabel:(int) i text:(NSString*) st;
-(void) setHelpOneLabel:(CGRect) frame text:(NSString*) st sizeFont:(int) fs;


@end
