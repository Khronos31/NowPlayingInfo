#ifndef NOWPLAYINGINFO_H
#define NOWPLAYINGINFO_H

#ifdef __OBJC__

#import <Foundation/Foundation.h>

@interface NowPlayingInfo: NSObject
+ (NowPlayingInfo *)sharedInstance;
- (BOOL) isPlaying;
- (NSDictionary *)nowPlayingInfo;
- (NSDictionary *)nowPlayingApplication;
- (NSString *)title;
- (NSString *)artist;
- (NSString *)album;
- (NSData *)artwork;
- (NSString *)artworkType;
@end

#endif /* __OBJC__ */

#import <CoreFoundation/CoreFoundation.h>

bool isPlaying();
CFDictionaryRef nowPlayingInfo();
CFDictionaryRef nowPlayingApplication();
CFStringRef nowPlayingTitle();
CFStringRef nowPlayingArtist();
CFStringRef nowPlayingAlbum();
CFDataRef nowPlayingArtwork();
CFStringRef nowPlayingArtworkType();

#endif /* NOWPLAYINGINFO_H */
