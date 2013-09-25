#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "OGHelper.h"

@protocol IconDownloaderDelegate;

/**
	Implement image lazy loading for table views
 */
@interface IconDownloader : NSObject <FBRequestDelegate,MemoryManagement>
{
	/**
		Index of particular row of TableView we need to download image for.
	 */
    NSIndexPath *indexPathInTableView;
	/**
		Instance of IconDownloaderDelegate object
	 */
    __weak id <IconDownloaderDelegate> delegate;
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
@property (nonatomic, weak) id <IconDownloaderDelegate> delegate;

- (void)startDownloadFBIcon;
- (void)startDownloadSimpleIcon;

@end

@protocol IconDownloaderDelegate 
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
@end