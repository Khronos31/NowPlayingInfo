#import <MediaRemote/MediaRemote.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import "NowPlayingInfo.h"

#define MACH_PORT_NAME "com.khronos31.nowplayinginfo"

static CFMessagePortRef messagePort = nil;

static CFDataRef nowPlayingInfo(CFStringRef key) {
  if (messagePort && !CFMessagePortIsValid(messagePort)) {
    CFRelease(messagePort);
    messagePort = nil;
  }
  if (!messagePort) {
    messagePort = rocketbootstrap_cfmessageportcreateremote(NULL, CFSTR(MACH_PORT_NAME));
  }
  if (!messagePort || !CFMessagePortIsValid(messagePort)) {
    NSLog(@"NP Error: MessagePort is invalid");
    return 0; //kCFMessagePortIsInvalid;
  }
  CFDataRef cfData = CFStringCreateExternalRepresentation(NULL, key, kCFStringEncodingUTF16BE, '\0');
  CFDataRef rData = nil;
  CFMessagePortSendRequest(messagePort, 1/*type*/, cfData, 5, 5, kCFRunLoopDefaultMode, &rData);
  return rData;
}

@implementation NowPlayingInfo

+ (NSString *)nowPlayingApplication {
  CFDataRef cfData = nowPlayingInfo(CFSTR("nowPlayingApplication"));
  CFStringRef data = CFStringCreateFromExternalRepresentation(NULL, cfData, kCFStringEncodingUTF16BE);
  return (NSString *)data;
}

+ (NSString *)title {
  CFDataRef cfData = nowPlayingInfo(kMRMediaRemoteNowPlayingInfoTitle);
  CFStringRef data = CFStringCreateFromExternalRepresentation(NULL, cfData, kCFStringEncodingUTF16BE);
  return (NSString *)data;
}

+ (NSString *)artist {
  CFDataRef cfData = nowPlayingInfo(kMRMediaRemoteNowPlayingInfoArtist);
  CFStringRef data = CFStringCreateFromExternalRepresentation(NULL, cfData, kCFStringEncodingUTF16BE);
  return (NSString *)data;
}

+ (NSString *)album {
  CFDataRef cfData = nowPlayingInfo(kMRMediaRemoteNowPlayingInfoAlbum);
  CFStringRef data = CFStringCreateFromExternalRepresentation(NULL, cfData, kCFStringEncodingUTF16BE);
  return (NSString *)data;
}

+ (UIImage *)artwork {
  UIImage *nowPlayingArtwork = [[UIImage alloc] init];
  CFDataRef cfData = nowPlayingInfo(kMRMediaRemoteNowPlayingInfoArtworkData);
  nowPlayingArtwork = [UIImage imageWithData:(NSData *)cfData];
  return nowPlayingArtwork;
}

+ (NSString *)artworkType {
  CFDataRef cfData = nowPlayingInfo(kMRMediaRemoteNowPlayingInfoArtworkMIMEType);
  CFStringRef data = CFStringCreateFromExternalRepresentation(NULL, cfData, kCFStringEncodingUTF16BE);
  return (NSString *)data;
}

@end
