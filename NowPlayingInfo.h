#ifndef NOWPLAYINGINFO_H
#define NOWPLAYINGINFO_H

#ifdef __OBJC__

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

#endif /* __OBJC__ */

const char *nowPlayingApplication();
const char *nowPlayingTitle();
const char *nowPlayingArtist();
const char *nowPlayingAlbum();
//unsigned long nowPlayingArtwork(char []);
const char *nowPlayingArtworkType();

#endif /* NOWPLAYINGINFO_H */
