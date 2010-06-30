/*!
 * Checks the status of all DirectoryService nodes, and exits with a non-zero
 * status if any are inaccessible. This is a command-line analog of the
 * "Network Accounts Available" view at the login window.
 *
 * Copyright (c) 2010 Ben Gollmer.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#import <Foundation/Foundation.h>
#import <OpenDirectory/OpenDirectory.h>
#import <SystemConfiguration/SystemConfiguration.h>

/* Thanks to
 * http://boredzo.org/blog/archives/2008-01-20/asl-logging
 */
#define vlog(format, ...) if(verbose) { fprintf(stderr, "%s\n", \
            [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]); }

/*!
 * Waits for all network services to become available.
 * 
 * This is the moral equivalent of `ipconfig waitall`; it's probably only
 * useful if you are running dsstatus immediately upon system boot, but can
 * prevent spurious DirectoryService failures in that case.
 *
 * N.B. no timeouts are currently implemented; this function will hang forever
 * if SystemConfiguration never reports all network services as configured.
 */
static void waitall()
{
  SCDynamicStoreRef session;
  CFPropertyListRef plist = NULL;
  
  session = SCDynamicStoreCreate(kCFAllocatorDefault,
                                 CFSTR("dsstatus"),
                                 NULL,
                                 NULL);
  /* Punt */
  if(session == NULL) return;
  
  /* Cheeseball hack to avoid setting up a CFRunLoop() for this simple task */
  while(plist == NULL)
  {
    plist = SCDynamicStoreCopyValue(session, CFSTR("Plugin:IPConfiguration"));
    if(plist == NULL) sleep(1);
  }
  
  CFRelease(plist);
  CFRelease(session);
  return;
}

int main (int argc, const char * argv[])
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  ODSession *session = [ODSession defaultSession];
  ODNode *node;
  NSError *err;
  BOOL verbose = NO;
  
  if(argc > 1 && strcmp(argv[1], "-v") == 0)
  {
    verbose = YES;
  }
  
  vlog(@"Waiting for network...");
  waitall();
  vlog(@"Network ready.");
  
  NSArray *nodeNames = [session nodeNamesAndReturnError:&err];
  if(nodeNames == nil)
  {
    vlog(@"Error getting node name list: %@", [err localizedDescription]);
    return [err code];
  }
  
  for(NSString *name in nodeNames)
  {
    vlog(@"Checking %@...", name);
    node = [ODNode nodeWithSession:session name:name error:&err];
    if(node == nil)
    {
      if(verbose) vlog(@"%@", [err localizedDescription]);
      return [err code];
    }
  }
  
  vlog(@"All DirectoryService nodes are available.");
  [pool drain];
  return 0;
}
