#ifndef NOWPLAYINGINFO_H
#define NOWPLAYINGINFO_H

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NowPlayingInfo: NSObject
+ (NSString *)nowPlayingApplication;
+ (NSString *)title;
+ (NSString *)artist;
+ (NSString *)album;
+ (UIImage *)artwork;
+ (NSString *)artworkType;
@end

#endif /* NOWPLAYINGINFO_H */
