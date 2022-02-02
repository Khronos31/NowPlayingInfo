#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NowPlayingInfo: NSObject
+ (NSString *)nowPlayingApplication;
+ (NSString *)title;
+ (NSString *)artist;
+ (NSString *)album;
+ (UIImage *)artwork;
@end
