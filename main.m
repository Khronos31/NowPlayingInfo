#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NowPlayingInfo.h"

void print_usage(int argc, char *argv[], char *envp[]) {
    fprintf(
        stderr,
        "Usage: %s\n"
        "       %s [--<title|album|artist|app|url|combined>] [--format FORMAT] ...\n"
        "       %s --artwork\n"
        "\n"
        "In the FORMAT string, the following strings are replaced by the corresponding information.\n"
        "_TITLE_ _ALBUM_ _ARTIST_ _APP_ _URL_\n",
        argv[0], argv[0], argv[0]
    );
}

NSString *getContentURL(NSDictionary *npInfo, NSString *playingApp) {
    NSString *contentURL = nil;

    if ([playingApp isEqualToString:@"com.apple.Music"]) {
        NSNumber *songID = npInfo[@"kMRMediaRemoteNowPlayingInfoiTunesStoreIdentifier"];
        NSNumber *albumID = npInfo[@"kMRMediaRemoteNowPlayingInfoAlbumiTunesStoreAdamIdentifier"];
        if (songID && albumID) {
            contentURL = [NSString stringWithFormat:@"https://itunes.apple.com/album/%@?i=%@", albumID, songID];
            if (!npInfo[@"kMRMediaRemoteNowPlayingInfoiTunesStoreSubscriptionAdamIdentifier"]) {
                contentURL = [contentURL stringByAppendingString:@"&app=itunes"];
            }
        }
    } else if ([playingApp isEqualToString:@"com.spotify.client"]){
        NSString *trackID = [npInfo[@"kMRMediaRemoteNowPlayingInfoContentItemIdentifier"] componentsSeparatedByString:@":"].lastObject;
        if (trackID) {
            contentURL = [NSString stringWithFormat:@"https://open.spotify.com/track/%@", trackID];
        }
    }
    return contentURL;
}

NSString *makeSharingText(NSString *title, NSString *album, NSString *artist) {
    NSString *text = @"#NowPlaying";
    if (title) {
        text = [text stringByAppendingFormat:@" %@", title];
    }
    if (album) {
        text = [text stringByAppendingFormat:@" - %@", album];
    }
    if (artist) {
        text = [text stringByAppendingFormat:@" by %@", artist];
    }
    return text;
}

NSString *makeSharingTextWithFormat(NSString *format, NSString *title, NSString *album, NSString *artist, NSString *app, NSString *url) {
    if (!title) {
        title = @"";
    }
    if (!album) {
        album = @"";
    }
    if (!artist) {
        artist = @"";
    }
    if (!app) {
        app = @"";
    }
    if (!url) {
        url = @"";
    }
    format = [format stringByReplacingOccurrencesOfString:@"_TITLE_" withString:title];
    format = [format stringByReplacingOccurrencesOfString:@"_ALBUM_" withString:album];
    format = [format stringByReplacingOccurrencesOfString:@"_ARTIST_" withString:artist];
    format = [format stringByReplacingOccurrencesOfString:@"_APP_" withString:app];
    format = [format stringByReplacingOccurrencesOfString:@"_URL_" withString:url];
    return format;
}

int main(int argc, char *argv[], char *envp[]) {
    NSFileHandle *stdOut = [NSFileHandle fileHandleWithStandardOutput];
    NSArray *arguments = NSProcessInfo.processInfo.arguments;
    NowPlayingInfo *np = [NowPlayingInfo sharedInstance];
    NSDictionary *npInfo = np.nowPlayingInfo;
    NSString *title = npInfo[@"kMRMediaRemoteNowPlayingInfoTitle"];
    NSString *album = npInfo[@"kMRMediaRemoteNowPlayingInfoAlbum"];
    NSString *artist = npInfo[@"kMRMediaRemoteNowPlayingInfoArtist"];
    NSData *artwork = npInfo[@"kMRMediaRemoteNowPlayingInfoArtworkData"];
    NSDictionary *playingApp = np.nowPlayingApplication;
    NSString *url = getContentURL(npInfo, playingApp[@"bundleIdentifier"]);
    NSString *outputText = nil;

    if (arguments.count <= 1) {
        outputText = [NSString stringWithFormat:
            @"Title     : %@\n"
            @"Album     : %@\n"
            @"Artist    : %@\n"
            @"PlayingApp: %@\n",
            title, album, artist, playingApp[@"displayName"]
        ];
        [stdOut writeData:[outputText dataUsingEncoding:NSUTF8StringEncoding]];
        exit(0);
    }
    if ([arguments containsObject:@"--help"]) {
        print_usage(argc, argv, envp);
        exit(0);
    }
    if ([arguments containsObject:@"--artwork"]) {
        [stdOut writeData:artwork];
        exit(0);
    }
    for(int i = 1; i < arguments.count; i++) {
        NSString *text = nil;
        if ([arguments[i] isEqualToString:@"--title"]) {
            text = title;
        } else if ([arguments[i] isEqualToString:@"--album"]) {
            text = album;
        } else if ([arguments[i] isEqualToString:@"--artist"]) {
            text = artist;
        } else if ([arguments[i] isEqualToString:@"--app"]) {
            text = playingApp[@"displayName"];
        } else if ([arguments[i] isEqualToString:@"--url"]) {
            text = url;
        } else if ([arguments[i] isEqualToString:@"--combined"]) {
            text = makeSharingText(title, album, artist);
        } else if ([arguments[i] hasPrefix:@"--format"]) {
            NSString *format = nil;
            if ([arguments[i] isEqualToString:@"--format"]) {
                if (i + 1 >= arguments.count) {
                    print_usage(argc, argv, envp);
                    exit(2);
                }
                format = arguments[++i];
            } else if ([arguments[i] hasPrefix:@"--format="]) {
                format = [arguments[i] substringFromIndex:@"--format=".length];
            } else {
                print_usage(argc, argv, envp);
                exit(2);
            }
            text = makeSharingTextWithFormat(format, title, album, artist, playingApp[@"displayName"], url);
        } else {
            print_usage(argc, argv, envp);
            exit(2);
        }
        if (!text) {
            text = @"";
        }
        text = [text stringByAppendingString:@"\n"];
        [stdOut writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return 0;
}
