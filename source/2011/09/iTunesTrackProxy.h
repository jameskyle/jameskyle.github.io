#import <Foundation/Foundation.h>

@class iTunesTrack;

typedef union {
  char *c;
  int *i;
  short *s;
  long *l;
  long long *q;
  unsigned char *C;
  unsigned int *I;
  unsigned short *S;
  unsigned long *L;
  unsigned long long *Q;
  float *f;
  double *d;
  _Bool *B;
  void *v;
} TRACKDATA;

@interface iTunesTrackProxy : NSProxy {
  @private
  iTunesTrack *_track;
  NSCache *_cache;
}

- (id)initWithTrack:(iTunesTrack *)track;
- (id)mapBuffer:(voidPtr)buffer type:(NSString *)type;
- (void *)mapObject:(id)obj type:(NSString *)type;
- (void)setValueFromTrack:(NSInvocation *)invocation;
- (void)setValueFromCacheObj:(id)obj invocation:(NSInvocation *)inv;

@property(readonly) iTunesTrack *track;
@end

