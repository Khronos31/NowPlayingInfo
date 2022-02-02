#import <Foundation/Foundation.h>
#import "NowPlayingInfo.h"

int main(int argc, char *argv[], char *envp[]) {
  NSLog(@"%@, %@, %@, %@, %@",[NowPlayingInfo nowPlayingApplication], [NowPlayingInfo title], [NowPlayingInfo artist], [NowPlayingInfo album], [NowPlayingInfo artwork]);
}
