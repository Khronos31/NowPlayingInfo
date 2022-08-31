#import <MediaRemote/MediaRemote.h>
#import <SpringBoard/SBApplication.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>

#define NOWPLAYINGINFO_DIR @"/var/mobile/Library/NowPlayingInfo"
#define HIST_DIR NOWPLAYINGINFO_DIR @"/history"
#define LATEST_PLAYED NOWPLAYINGINFO_DIR @"/latest.plist"
#define PREF_PATH @"/var/mobile/Library/Preference/com.khronos31.nowplaying.plist"

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

  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREF_PATH];
  if (!prefs) {
    prefs = [[NSMutableDictionary alloc] init];
  }

  MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef nowPlayingInfo) {
    if (self.currentPlayingInfo) [self.currentPlayingInfo release];
    self.currentPlayingInfo = [(__bridge NSDictionary *)nowPlayingInfo copy];
  });

  [[NSFileManager defaultManager] createDirectoryAtPath:NOWPLAYINGINFO_DIR withIntermediateDirectories:YES attributes:nil error:nil];
  [self.currentPlayingInfo writeToURL:[NSURL fileURLWithPath:LATEST_PLAYED] error:nil];
  [prefs release];
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
