//
//  GameOverNode.m
//  SpaceRun
//
//  Created by George Heeres on 4/15/15.
//  Copyright (c) 2015 George Heeres. All rights reserved.
//

#import "GameOverNode.h"

@implementation GameOverNode

-(instancetype)init {
  if (self = [super init]) {
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Heavy"];
    label.fontSize = 32;
    label.fontColor = [SKColor whiteColor];
    label.text = @"Game Over";
    [self addChild:label];
    
    label.alpha = 0;
    label.xScale = 0.2;
    label.yScale = 0.2;
    
    SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:2];
    SKAction *scaleIn = [SKAction scaleTo:1 duration: 2];
    [label runAction:[SKAction group:@[ fadeIn, scaleIn ]]];
    
    SKLabelNode *instructions = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Medium"];
    instructions.fontSize = 14;
    instructions.fontColor = [SKColor whiteColor];
    instructions.text = @"Tap to try again.";
    instructions.position = CGPointMake(0, -45);
    [self addChild:instructions];
    
    instructions.alpha = 0;
    SKAction *wait = [SKAction waitForDuration:2.5];
    SKAction *appear = [SKAction fadeAlphaTo:1 duration:0.2];
    SKAction *popUp = [SKAction scaleTo:1.1 duration:0.1];
    SKAction *dropDown = [SKAction scaleTo:1 duration:0.1];
    [instructions runAction:[SKAction sequence:@[ wait, appear, popUp, dropDown ]]];
  }
  return(self);
}
@end
