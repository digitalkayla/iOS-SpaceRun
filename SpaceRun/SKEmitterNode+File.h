//
//  SKEmitterNode+File.h
//  SpaceRun
//
//  Created by George Heeres on 4/12/15.
//  Copyright (c) 2015 George Heeres. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKEmitterNode(File)

+(SKEmitterNode *) nodeWithFile:(NSString *)filename;
-(void) dieOutInDuration:(NSTimeInterval)duration;

@end

@implementation SKEmitterNode(File)

+(SKEmitterNode *) nodeWithFile:(NSString *)filename {
  NSString* basename = [filename stringByDeletingPathExtension];
  NSString* extension = [filename pathExtension];
  if ([extension length] == 0) {
    extension = @"sks";
  }
  
  NSString* path = [[NSBundle mainBundle] pathForResource:basename ofType:extension];
  SKEmitterNode* node = (id)[NSKeyedUnarchiver unarchiveObjectWithFile:path];
  return(node);
}

-(void) dieOutInDuration:(NSTimeInterval)duration {
  SKAction *firstWait = [SKAction waitForDuration:duration];
  __weak SKEmitterNode *weakSelf = self;
  SKAction *stop = [SKAction runBlock:^{
    weakSelf.particleBirthRate = 0;
  }];
  SKAction *secondWait = [SKAction waitForDuration:self.particleLifetime];
  SKAction *remove = [SKAction removeFromParent];
  [self runAction:[SKAction sequence:@[ firstWait, stop, secondWait, remove]]];
}

@end
