#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "FBConnect.h"
#import "OGHelper.h"

@protocol IconDownloaderDelegate;

@class ItemImage;


/**
	Implement image lazy loading for table views
 */
@interface IconDownloader : NSObject <FBRequestDelegate>
{
	/**
		Index of particular row of TableView we need to download image for.
	 */
    NSIndexPath *indexPathInTableView;
	/**
		Instance of IconDownloaderDelegate object
	 */
    id <IconDownloaderDelegate> delegate;
	/**
		Object with downloaded image
	 */
	ItemImage * itemIcon;
    /**
     name of Player to download icon
	 */
	NSString * namePlayer;
    NSString * avatarURL;
    /**
     image downloaded
	 */
    UIImage * imageDownloaded;
    
    NSMutableData *receivedData;
}

@property (nonatomic ,strong) NSIndexPath *indexPathInTableView;
@property (nonatomic ,strong) NSString * namePlayer;
@property (nonatomic ,strong) NSString * avatarURL;
@property (nonatomic ,strong) UIImage * imageDownloaded;
@property (nonatomic, strong) id <IconDownloaderDelegate> delegate;

- (void)startDownloadFBIcon;
- (void)startDownloadSimpleIcon;

@end

@protocol IconDownloaderDelegate 
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
@end