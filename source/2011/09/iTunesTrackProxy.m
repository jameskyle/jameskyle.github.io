#import "iTunesTrackProxy.h"
#import "iTunes.h"

@implementation iTunesTrackProxy

- (id)initWithTrack:(iTunesTrack *)track
{  
  _track = [track retain];
  _cache = [[NSCache alloc] init];
  return self;
}

- (void)dealloc
{
  [_track release];
  [_cache release];
  [super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
  NSMethodSignature *sig;
  sig = [self.track methodSignatureForSelector:sel];
  return sig;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  return [self.track respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation 
{
  // Using the string representation of the selector as the NSCache key.
  NSString *key = NSStringFromSelector([invocation selector]);
  
  // First check and see if we've already cached the object
  id result = [_cache objectForKey:key];

  // If the object is cached, use it as the returnValue
  if (result) {
    [invocation setReturnValue:&result]; 

  } else {
    // if not cached, forward it to the track object, then cache the return
    [invocation invokeWithTarget:self.track];
    [invocation getReturnValue:&result];
    [_cache setObject:result forKey:key];
  }
}

- (void)setValueFromTrack:(NSInvocation *)invocation
{
  NSString *key = NSStringFromSelector([invocation selector]);

  NSString *returnType = [NSString 
                          stringWithUTF8String:[[invocation methodSignature] methodReturnType]];
  id result;
  
  // retrieve value from track object
  [invocation invokeWithTarget:self.track];
  
  // if object is of type NSObject.
  if ([returnType isEqualToString:@"@"]) {
    [invocation getReturnValue:&result];
    
    if (!result) {
      // retrieved value does not exist for track
      // set to default
      result = @"None";
      [invocation setReturnValue:&result];
    }
    
    [_cache setObject:result forKey:key];
    
  } else {
    void* buffer;
    NSUInteger length = [[invocation methodSignature] 
                         methodReturnLength];
    buffer = (void*)malloc(length);
    [invocation getReturnValue:buffer];
    
    id obj = [self mapBuffer:buffer type:returnType];
    // done with buffer
    free(buffer);
    
    // cache value
    [_cache setObject:obj forKey:key];
  }

}

- (id)mapBuffer:(voidPtr)buffer type:(NSString *)type
{
  id obj;
  
  TRACKDATA data;
  data.v = buffer;
  
  if ([type isEqualToString:@"c"]) {
    obj = [NSNumber numberWithChar:*data.c];
    
  } else if ([type isEqualToString:@"i"]) {
    obj = [NSNumber numberWithInt:*data.i];
    
  } else if ([type isEqualToString:@"s"]) {
    obj = [NSNumber numberWithShort:*data.s];
    
  } else if ([type isEqualToString:@"l"]) {
    obj = [NSNumber numberWithLong:*data.l];
    
  } else if ([type isEqualToString:@"q"]) {
    obj = [NSNumber numberWithLongLong:*data.q];
    
  } else if ([type isEqualToString:@"C"]) {
    obj = [NSNumber numberWithUnsignedChar:*data.C];
    
  } else if ([type isEqualToString:@"I"]) {
    obj = [NSNumber numberWithUnsignedInt:*data.I];
    
  } else if ([type isEqualToString:@"S"]) {
    obj = [NSNumber numberWithUnsignedShort:*data.S];
    
  } else if ([type isEqualToString:@"L"]) {
    obj = [NSNumber numberWithUnsignedLong:*data.L];
    
  } else if ([type isEqualToString:@"Q"]) {
    obj = [NSNumber numberWithUnsignedLongLong:*data.Q];
    
  } else if ([type isEqualToString:@"f"]) {
    obj = [NSNumber numberWithFloat:*data.f];
    
  } else if ([type isEqualToString:@"d"]) {
    obj = [NSNumber numberWithDouble:*data.d];
    
  } else if ([type isEqualToString:@"B"]) {
    // The BOOL type is a special case, so we do a little dance here.
    BOOL val;
    if (*data.B) {
      val = YES;
    } else {
      val = NO;
    }
    obj = [NSNumber numberWithBool:val];
  } else {
    // Raise an exception if we receive a data type we're not prepared for...
    [NSException 
     raise:@"Unhandled NSMethodSignature:methodReturnType:" 
     format:@"NSMethodSignature:methodReturnType: %@", type];
  }
  
  return obj;
}

- (void)setValueFromCacheObj:(id)obj invocation:(NSInvocation *)inv
{  
  NSString *returnType = [NSString 
                          stringWithUTF8String:[[inv methodSignature] methodReturnType]];
  
  if ([returnType isEqualToString:@"@"]) {
    [inv setReturnValue:&obj]; 
    
  } else {
    void *buffer = [self mapObject:obj type:returnType];
    [inv setReturnValue:buffer];
    // done with buffer
    free(buffer);
  }

}
- (void *)mapObject:(id)obj type:(NSString *)type
{
  void *buffer;

  if ([type isEqualToString:@"c"]) {
    buffer = (char *)malloc(sizeof(char));
    *(char *)buffer = [obj charValue];
    
  } else if ([type isEqualToString:@"i"]) {
    buffer = (int *)malloc(sizeof(int));
    *(int *)buffer = [obj intValue];
    
  } else if ([type isEqualToString:@"s"]) {
    buffer = (short *)malloc(sizeof(short));
    *(short *)buffer = [obj shortValue];
    
  } else if ([type isEqualToString:@"l"]) {
    buffer = (long *)malloc(sizeof(long));
    *(long *)buffer = [obj longValue];
    
  } else if ([type isEqualToString:@"q"]) {
    buffer = (long long *)malloc(sizeof(long long));
    *(long long *)buffer = [obj longLongValue];
    
  } else if ([type isEqualToString:@"C"]) {
    buffer = (unsigned char *)malloc(sizeof(unsigned char));
    *(unsigned char *)buffer = [obj unsignedCharValue];
    
  } else if ([type isEqualToString:@"I"]) {
    buffer = (unsigned int *)malloc(sizeof(unsigned int));
    *(unsigned int *)buffer = [obj unsignedIntValue];
    
  } else if ([type isEqualToString:@"S"]) {
    buffer = (unsigned short *)malloc(sizeof(unsigned short));
    *(unsigned short *)buffer = [obj unsignedShortValue];
    
  } else if ([type isEqualToString:@"L"]) {
    buffer = (unsigned long *)malloc(sizeof(unsigned long));
    *(unsigned long *)buffer = [obj unsignedLongValue];
    
  } else if ([type isEqualToString:@"Q"]) {
    buffer = (unsigned long long *)malloc(sizeof(unsigned long long));
    *(unsigned long long *)buffer = [obj unsignedLongLongValue];
    
  } else if ([type isEqualToString:@"f"]) {
    buffer = (float *)malloc(sizeof(float));
    *(float *)buffer = [obj floatValue];
    
  } else if ([type isEqualToString:@"d"]) {
    buffer = (double *)malloc(sizeof(double));
    *(double *)buffer = [obj doubleValue];
    
  } else if ([type isEqualToString:@"B"]) {
    _Bool val;
    if ([obj boolValue]) {
      val = true;
    } else {
      val = false;
    }
    buffer = (_Bool *)malloc(sizeof(_Bool));
    *(_Bool *)buffer = val;
    
  } else {
    [NSException 
     raise:@"Unhandled NSMethodSignature:methodReturnType:" 
     format:@"NSMethodSignature:methodReturnType: %@", type];
  }
  return buffer;
}

@synthesize track = _track;
@end

