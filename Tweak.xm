#import <Foundation/Foundation.h>

#import <AppSupport/CPDistributedMessagingCenter.h>
#import <MediaRemote/MediaRemote.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBMediaController.h>

#import <rocketbootstrap/rocketbootstrap.h>

static NSString * const kNPIDirectory = @"/var/mobile/Library/NowPlayingInfo";
static NSString * const kNPIPreferencesFile = @"/var/mobile/Library/Preferences/com.khronos31.nowplaying.plist";

@interface SpringBoard
@property (retain) NSDictionary *nowPlayingInfo;
@property (retain) NSNumber *previousPlayedIdentifier;
@property (retain) NSNumber *latestPlayedIdentifier;
- (id/*SBApplication **/)nowPlayingApplication;
- (BOOL)isPlaying;
@end

%hook SpringBoard
%property (retain) NSDictionary *nowPlayingInfo;
%property (retain) NSNumber *previousPlayedIdentifier;
%property (retain) NSNumber *latestPlayedIdentifier;

- (void)applicationDidFinishLaunching:(id)application {
    %orig;

    CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.khronos31.nowplaying"];
    rocketbootstrap_distributedmessagingcenter_apply(messagingCenter);
    [messagingCenter runServerOnCurrentThread];
    [messagingCenter registerForMessageName:@"nowPlayingInfo"
                                     target:self
                                   selector:@selector(nowPlayingInfo)];
    [messagingCenter registerForMessageName:@"nowPlayingApplication"
                                     target:self
                                   selector:@selector(nowPlayingApplication)];
    [messagingCenter registerForMessageName:@"isPlaying"
                                     target:self
                                   selector:@selector(isPlaying)];

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(nowPlayingInfoDidChange)
                               name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification
                             object:nil];
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

static void writeNowPlayingInfoToFile(NSDictionary *info) {
    [[NSFileManager defaultManager] createDirectoryAtPath:kNPIDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    [info writeToURL:[NSURL fileURLWithPath:[kNPIDirectory stringByAppendingPathComponent:@"latest.plist"]]
               error:nil];
} 

static void addNowPlayingInfoToHistoryFile(NSDictionary *info) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd.'plist'";
    NSString *histdir = [NSString pathWithComponents:@[kNPIDirectory, @"history"]];
    NSString *histfile = [NSString pathWithComponents:@[histdir, [formatter stringFromDate:[NSDate date]]]];

    NSMutableArray *history = [[NSMutableArray alloc] initWithContentsOfFile:histfile];
    if (!history) {
        history = [[NSMutableArray alloc] init];
    }

    NSMutableDictionary *latestPlaying = nil;
    latestPlaying = [info mutableCopy];
    [latestPlaying removeObjectForKey:@"kMRMediaRemoteNowPlayingInfoArtworkData"];
    [history addObject:latestPlaying];

    [[NSFileManager defaultManager] createDirectoryAtPath:histdir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    [history writeToURL:[NSURL fileURLWithPath:histfile] error:nil];

    [latestPlaying release];
    [history release];
    [formatter release];
}

%new
- (void)nowPlayingInfoDidChange {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(CFDictionaryRef nowPlayingInfo) {
        if (self.nowPlayingInfo) {
            [self.nowPlayingInfo release];
        }
        self.nowPlayingInfo = [(__bridge NSDictionary *)nowPlayingInfo copy];
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)));
    dispatch_release(semaphore);

    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:kNPIPreferencesFile];
    if (!prefs) {
        prefs = [[NSMutableDictionary alloc] init];
    }

    if (!self.nowPlayingInfo) {
        self.previousPlayedIdentifier = nil;
        self.latestPlayedIdentifier = nil;
    }

    BOOL isPlayingNewTrack = NO;
    if (self.nowPlayingInfo && self.isPlaying) {
        self.previousPlayedIdentifier = self.latestPlayedIdentifier;
        self.latestPlayedIdentifier = self.nowPlayingInfo[@"kMRMediaRemoteNowPlayingInfoUniqueIdentifier"];

        if ((self.previousPlayedIdentifier == nil)
            || ![self.latestPlayedIdentifier isEqualToNumber:self.previousPlayedIdentifier]) {
            isPlayingNewTrack = YES;
        }
    }

    if (![prefs[@"enabled"] isEqual:@YES]) {
        return;
    }

    writeNowPlayingInfoToFile(self.nowPlayingInfo);

    if ([prefs[@"RecordPlaybackHistory"] isEqual:@YES] && isPlayingNewTrack) {
        addNowPlayingInfoToHistoryFile(self.nowPlayingInfo);
    }

    [prefs release];
}

%end
