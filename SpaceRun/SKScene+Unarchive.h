//
//  SKScene+Unarchive.h
//  SpaceRun
//
//  Created by George Heeres on 4/15/15.
//  Copyright (c) 2015 George Heeres. All rights reserved.
//

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
  /* Retrieve scene file path from the application bundle */
  NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
  /* Unarchive the file to an SKScene object */
  NSData *data = [NSData dataWithContentsOfFile:nodePath
                         options:NSDataReadingMappedIfSafe
                         error:nil];
  NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
  [arch setClass:self forClassName:@"SKScene"];
  SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
  [arch finishDecoding];
  
  return(scene);
}

@end