@interface NowPlayingInfo: NSObject
+ (NSString *)nowPlayingApplication;
+ (NSString *)title;
+ (NSString *)artist;
+ (NSString *)album;
+ (UIImage *)artwork;
@end
