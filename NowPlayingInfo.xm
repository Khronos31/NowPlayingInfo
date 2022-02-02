#import <MediaRemote/MediaRemote.h>
#import <SpringBoard/SBMediaController.h>
#import <SpringBoard/SBApplication.h>
#import <rocketbootstrap/rocketbootstrap.h>

#define MACH_PORT_NAME "com.khronos31.nowplayinginfo"

static CFDataRef messageCallback(CFMessagePortRef port, SInt32 msgid, CFDataRef cfData, void *info) {
  CFStringRef key = CFStringCreateFromExternalRepresentation(NULL, cfData, kCFStringEncodingUTF16BE);
  __block CFDataRef data = nil;
  if (kCFCompareEqualTo == CFStringCompare(key, CFSTR("nowPlayingApplication"), 0)){
    SBApplication *app = [[%c(SBMediaController) sharedInstance] nowPlayingApplication];
    if (app) {
      CFStringRef str = (__bridge CFStringRef)[app displayName];
      data = CFStringCreateExternalRepresentation(NULL, str, kCFStringEncodingUTF16BE, '\0');
    }
  } else {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        if (information) {
          const void *value = CFDictionaryGetValue(information, key);
          if (value) {
            if (kCFCompareEqualTo == CFStringCompare(key, kMRMediaRemoteNowPlayingInfoTitle, 0) ||
                kCFCompareEqualTo == CFStringCompare(key, kMRMediaRemoteNowPlayingInfoAlbum, 0) ||
                kCFCompareEqualTo == CFStringCompare(key, kMRMediaRemoteNowPlayingInfoArtist, 0)) {
              data = CFStringCreateExternalRepresentation(NULL, (CFStringRef)value, kCFStringEncodingUTF16BE, '\0');
            } else if (kCFCompareEqualTo == CFStringCompare(key, kMRMediaRemoteNowPlayingInfoArtworkData, 0)) {
              data = (CFDataRef)value;
            }
          }
        }
      });
      dispatch_semaphore_signal(semaphore);
    });
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
  }
  return data;
}

%ctor {
  static CFMessagePortRef localPort = CFMessagePortCreateLocal(NULL, CFSTR(MACH_PORT_NAME), messageCallback, nil, NULL);
  CFRunLoopSourceRef runLoopSource = CFMessagePortCreateRunLoopSource(nil, localPort, 0);
  CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
  rocketbootstrap_cfmessageportexposelocal(localPort);
}
