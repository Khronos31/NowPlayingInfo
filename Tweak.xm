#import <MediaRemote/MediaRemote.h>
#import <SpringBoard/SBApplication.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>

#define LOG_PATH @"/var/mobile/Library/nplog/log.plist"

@interface SBMediaController
@property (retain) NSDictionary *currentPlayingInfo;
+ (id)sharedInstance;
- (id/*SBApplication **/)nowPlayingApplication;
- (void)setNowPlayingInfo:(NSDictionary *)arg1;
- (BOOL)isPlaying;
@end

%hook SBMediaController
%property (retain) NSDictionary *currentPlayingInfo;

- (void)setNowPlayingInfo:(NSDictionary *)arg1 {
  %orig;

  MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef nowPlayingInfo) {
    if (self.currentPlayingInfo) [self.currentPlayingInfo release];
    self.currentPlayingInfo = [(__bridge NSDictionary *)nowPlayingInfo copy];
  });

  NSURL *url = [NSURL fileURLWithPath:LOG_PATH];
  [self.currentPlayingInfo writeToURL:url error:nil];
}

%end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
  %orig;

  CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.khronos31.nowplayinginfo"];
  rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
  [messagingCenter runServerOnCurrentThread];
  [messagingCenter registerForMessageName:@"nowPlayingInfo" target:self selector:@selector(nowPlayingInfo)];
  [messagingCenter registerForMessageName:@"nowPlayingApplication" target:self selector:@selector(nowPlayingApplication)];
  [messagingCenter registerForMessageName:@"isPlaying" target:self selector:@selector(isPlaying)];

  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preference/com.khronos31.nowplayinginfo.plist"];
  if (!prefs) prefs = [[NSMutableDictionary alloc] init];
}

%new
- (NSDictionary *)nowPlayingInfo {
  return [[%c(SBMediaController) sharedInstance] currentPlayingInfo];
}

%new
- (NSDictionary *)nowPlayingApplication {
  SBApplication *app = [[%c(SBMediaController) sharedInstance] nowPlayingApplication];
  if (app) {
    return @{
      @"bundleIdentifier": app.bundleIdentifier,
      @"displayName": app.displayName
    };
  } else {
    return nil;
  }
}

%new
- (NSDictionary *)isPlaying {
  if ([[%c(SBMediaController) sharedInstance] isPlaying]) {
    return @{};
  } else {
    return nil;
  }
}

%end
