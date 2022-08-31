#import <Foundation/Foundation.h>
#import <MediaRemote/MediaRemote.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import "NowPlayingInfo.h"

static CPDistributedMessagingCenter *messagingCenter;

@implementation NowPlayingInfo

+ (NowPlayingInfo *)sharedInstance {
  static NowPlayingInfo *sharedInstance;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    sharedInstance = [[self alloc] init];
    messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.khronos31.nowplayinginfo"];
    rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
  });
  return sharedInstance;
}

- (BOOL)isPlaying {
  if ([messagingCenter sendMessageAndReceiveReplyName:@"isPlaying" userInfo:nil]) {
    return YES;
  } else {
    return NO;
  }
}

- (NSDictionary *)nowPlayingInfo {
  return [messagingCenter sendMessageAndReceiveReplyName:@"nowPlayingInfo" userInfo:nil];
}

- (NSDictionary *)nowPlayingApplication {
  return [messagingCenter sendMessageAndReceiveReplyName:@"nowPlayingApplication" userInfo:nil]; 
}

- (NSString *)title {
  return self.nowPlayingInfo[@"kMRMediaRemoteNowPlayingInfoTitle"];
}

- (NSString *)artist {
  return self.nowPlayingInfo[@"kMRMediaRemoteNowPlayingInfoArtist"];
}

- (NSString *)album {
  return self.nowPlayingInfo[@"kMRMediaRemoteNowPlayingInfoAlbum"];
}

- (NSData *)artwork {
  return self.nowPlayingInfo[@"kMRMediaRemoteNowPlayingInfoArtworkData"];
}

- (NSString *)artworkType {
  return self.nowPlayingInfo[@"kMRMediaRemoteNowPlayingInfoArtworkMIMEType"];
}

@end

bool isPlaying() {
  return [NowPlayingInfo sharedInstance].isPlaying;
}

CFDictionaryRef nowPlayingInfo() {
  NSDictionary *npInfo = [NowPlayingInfo sharedInstance].nowPlayingInfo;
  return (CFDictionaryRef)CFBridgingRetain(npInfo);
}

CFDictionaryRef nowPlayingApplication() {
  NSDictionary *npApp = [NowPlayingInfo sharedInstance].nowPlayingApplication;
  return (CFDictionaryRef)CFBridgingRetain(npApp);
}

CFStringRef nowPlayingTitle() {
  NSString *npTitle = [NowPlayingInfo sharedInstance].title;
  return (CFStringRef)CFBridgingRetain(npTitle);
}

CFStringRef nowPlayingArtist() {
  NSString *npArtist = [NowPlayingInfo sharedInstance].artist;
  return (CFStringRef)CFBridgingRetain(npArtist);
}

CFStringRef nowPlayingAlbum() {
  NSString *npAlbum = [NowPlayingInfo sharedInstance].album;
  return (CFStringRef)CFBridgingRetain(npAlbum);
}

CFDataRef nowPlayingArtwork() {
  NSData *npArtwork = [NowPlayingInfo sharedInstance].artwork;
  return (CFDataRef)CFBridgingRetain(npArtwork);
}

CFStringRef nowPlayingArtworkType() {
  NSString *npArtworkType = [NowPlayingInfo sharedInstance].artworkType;
  return (CFStringRef)CFBridgingRetain(npArtworkType);
}
