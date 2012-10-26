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
@property (strong,nonatomic) IBOutlet UIView * backGround;
@property (strong,nonatomic) IBOutlet UIImageView * icon;
@property (strong,nonatomic) IBOutlet UILabel * coldTitle;
@property (strong,nonatomic) IBOutlet UILabel * gold;
@property (strong,nonatomic) IBOutlet UILabel * effectTitle;
@property (strong,nonatomic) IBOutlet UILabel * effect;
@property (strong,nonatomic) IBOutlet UILabel * name;
@property (strong,nonatomic) IBOutlet UILabel * description;
@property (strong,nonatomic) IBOutlet UIButton * buyProduct;
@property (nonatomic) StoreDataSourceTypeTables cellType;

+(StoreProductCell*)cell;
+(NSString*) cellID;

-(void)populateWithProduct:(CDDuelProduct *)product index:(NSIndexPath *)indexPath typeTable:(StoreDataSourceTypeTables)type;
-(void) initMainControls;
@end
