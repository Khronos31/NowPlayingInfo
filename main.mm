#import <Foundation/Foundation.h>
#import "NowPlayingInfo.h"

void print_usage(int argc, char *argv[], char *envp[]) {
  fprintf(stderr, "Usage: %s [title|artist|album|playingapp]", argv[0]);
  exit(1);
}

int main(int argc, char *argv[], char *envp[]) {
  const char *title = [NowPlayingInfo title].UTF8String;
  const char *artist = [NowPlayingInfo artist].UTF8String;
  const char *album = [NowPlayingInfo album].UTF8String;
  const char *playingApp = [NowPlayingInfo nowPlayingApplication].UTF8String;
  printf("Title: %s\nArtist: %s\nAlbum: %s\nPlayingApp: %s\n", title, artist, album, playingApp);
  return 0;
}
