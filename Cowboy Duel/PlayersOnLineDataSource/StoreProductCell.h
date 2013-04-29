//
//  TopPlayerCell.h
//  Cowboy Duel 1
//
//  Created by Taras on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreDataSource.h"
#import "CDDuelProduct.h"

@interface StoreProductCell : UITableViewCell
@property (strong,nonatomic) IBOutlet UIButton * buyProduct;

+(StoreProductCell*)cell;
+(NSString*) cellID;

-(void)populateWithProduct:(CDDuelProduct *)product targetToBuyButton:(id)delegate cellType:(StoreDataSourceTypeTables)cellType;
-(void) initMainControls;
-(void) initWithOutBackGround;
@end
