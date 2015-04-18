//
//  StarField.m
//  SpaceRun
//
//  Created by George Heeres on 4/12/15.
//  Copyright (c) 2015 George Heeres. All rights reserved.
//

#import "StarFieldNode.h"

@interface StarFieldNode() {
  NSInteger _probability;
  CGFloat _minimumStarSize;
  CGFloat _maximumStarSize;
}
@end

@implementation StarFieldNode

-(instancetype) init {
  if (self = [super init]) {
    _probability = 30;
    _minimumStarSize = 2;
    _maximumStarSize = 6;
    
    __weak StarFieldNode* weakSelf = self;
    SKAction* update = [SKAction runBlock:^{
      // Generate a star 30% of the time.
      if (arc4random_uniform(100) < _probability) {
        [weakSelf launchStar];
      }
    }];
    SKAction* delay = [SKAction waitForDuration:0.01];
    SKAction* updateLoop = [SKAction sequence:@[ delay, update ]];

    [self runAction:[SKAction repeatActionForever:updateLoop]];
  }
  return(self);
}

-(SKSpriteNode*) createStar:(CGPoint)position {
  SKSpriteNode* star = [SKSpriteNode spriteNodeWithImageNamed:@"ShootingStar"];
  star.position = position;
  star.size = CGSizeMake(_minimumStarSize, _maximumStarSize);
  star.alpha = 0.1 + (arc4random_uniform(10) / 10.0f);
  [self addChild:star];
  return(star);
}

-(void) launchStar {
  CGFloat x = arc4random_uniform(self.scene.size.width);
  CGFloat maxY = self.scene.size.height;
  CGPoint randomStart = CGPointMake(x, maxY);

  SKSpriteNode* star = [self createStar:randomStart];
  CGFloat y = 0 - maxY - star.size.height;
  CGFloat duration = 0.1 + arc4random_uniform(10) / 10.0f;
  SKAction *move = [SKAction moveByX:0 y:y duration:duration];
  SKAction *remove = [SKAction removeFromParent];
  [star runAction:[SKAction sequence:@[move, remove]]];
}

@end
