#import "NowPlayingInfo.h"

void print_usage(int argc, char *argv[], char *envp[]) {
  fprintf(stderr, "Usage: %s [title|artist|album|playingapp]", argv[0]);
}

int main(int argc, char *argv[], char *envp[]) {
	NSFileHandle *stdOut = [NSFileHandle fileHandleWithStandardOutput];
  NowPlayingInfo *np = [NowPlayingInfo sharedInstance];
  NSDictionary *npInfo = np.nowPlayingInfo;
  NSString *title = npInfo[@"kMRMediaRemoteNowPlayingInfoTitle"];
  NSString *artist = npInfo[@"kMRMediaRemoteNowPlayingInfoArtist"];
  NSString *album = npInfo[@"kMRMediaRemoteNowPlayingInfoAlbum"];
  NSString *playingApp = np.nowPlayingApplication[@"displayName"];
  NSString *outputText = [NSString stringWithFormat:@"Title: %@\nArtist: %@\nAlbum: %@\nPlayingApp: %@\n", title, album, artist, playingApp];
  [stdOut writeData:[outputText dataUsingEncoding:NSUTF8StringEncoding]];
  return 0;
}
