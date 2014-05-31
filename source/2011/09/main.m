#import <Foundation/Foundation.h>
#import <Block.h>
#import "iTunes.h"
#import "iTunesTrackProxy.h"

NSArray* getTracks()
{
  iTunesApplication *itunes;
  itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
  
  // Retrieve a list of movies in our iTunes library.
  NSArray *sources = [[itunes sources] get];
  NSPredicate *predicate = [NSPredicate 
                      predicateWithFormat:@"name == 'Library' && kind == %i", 
                      iTunesESrcLibrary];
                  
  NSArray *libs = [sources filteredArrayUsingPredicate:predicate];

  NSMutableArray *theMovies = [NSMutableArray array];
  NSArray *playlists;
  NSArray *movieLists;
  
  for (iTunesSource *source in libs) {
    playlists = [source playlists];
    movieLists = [playlists filteredArrayUsingPredicate:
                  [NSPredicate predicateWithFormat:@"name == 'Movies'"]];

    for (iTunesPlaylist *playlist in movieLists) {
      for (iTunesTrack *track in [playlist tracks]) {
        [theMovies addObject:track];
      } 
    }
  }
  
  return theMovies;
};

NSArray* getProxiedTracks()
{
  iTunesApplication *itunes;
  itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
  
  // Retrieve a list of movies in our iTunes library.
  NSArray *sources = [[itunes sources] get];
  NSPredicate *predicate = [NSPredicate 
                      predicateWithFormat:@"name == 'Library' && kind == %i", 
                      iTunesESrcLibrary];
                  
  NSArray *libs = [sources filteredArrayUsingPredicate:predicate];

  NSMutableArray *theMovies = [NSMutableArray array];
  NSArray *playlists;
  NSArray *movieLists;
  
  for (iTunesSource *source in libs) {
    playlists = [source playlists];
    movieLists = [playlists filteredArrayUsingPredicate:
                  [NSPredicate predicateWithFormat:@"name == 'Movies'"]];

    for (iTunesPlaylist *playlist in movieLists) {
      for (iTunesTrack *track in [playlist tracks]) {
        iTunesTrackProxy *proxy = [[[iTunesTrackProxy alloc] 
                                      initWithTrack:track] autorelease];
        [theMovies addObject:proxy];
      } 
    }
  }
  
  return theMovies;

}

double sortArrayByName(NSArray *array)
{
  NSDate *start = [NSDate date];
  [array sortedArrayUsingComparator:^(id a, id b) {
    return [[a name] compare:[b name] options:NSCaseInsensitiveSearch]; 
  }];

  NSTimeInterval timeInterval = [start timeIntervalSinceNow];

  return timeInterval;

}


int main()
{
  NSArray *movies = getTracks();
  NSLog(@"We retrieved %lu unproxied movies", [movies count]);

  NSArray *proxies = getProxiedTracks();
  NSLog(@"We retrieved %lu proxied movies", [proxies count]);
  
  NSLog(@"Time elapsed for track sort: %f", sortArrayByName(movies));
  NSLog(@"Time elapsed for proxy sort: %f", sortArrayByName(proxies));
  NSLog(@"Time elapsed for proxy sort second run: %f", sortArrayByName(proxies));
  return 0;
}
