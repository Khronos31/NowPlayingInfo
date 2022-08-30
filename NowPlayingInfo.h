#ifndef NOWPLAYINGINFO_H
#define NOWPLAYINGINFO_H

#import <CoreFoundation/CoreFoundation.h>

#ifdef __OBJC__

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NowPlayingInfo: NSObject
+ (NowPlayingInfo *)sharedInstance;
- (BOOL) isPlaying;
- (NSDictionary *)nowPlayingInfo;
- (NSDictionary *)nowPlayingApplication;
- (NSString *)title;
- (NSString *)artist;
- (NSString *)album;
- (UIImage *)artwork;
- (NSString *)artworkType;
@end

#endif /* __OBJC__ */

bool isPlaying();
CFDictionaryRef nowPlayingInfo();
CFDictionaryRef nowPlayingApplication();
CFStringRef nowPlayingTitle();
CFStringRef nowPlayingArtist();
CFStringRef nowPlayingAlbum();
CFDataRef nowPlayingArtwork();
CFStringRef nowPlayingArtworkType();

#endif /* NOWPLAYINGINFO_H */
