//
//  HUDNode.m
//  SpaceRun
//
//  Created by George Heeres on 4/16/15.
//  Copyright (c) 2015 George Heeres. All rights reserved.
//

#import "HUDNode.h"

@interface HUDNode() {
  NSTimeInterval startTime;
  NSTimeInterval powerupLastUpdated;
}

@property (nonatomic) NSNumberFormatter *timeFormatter;
@property (nonatomic) NSNumberFormatter *scoreFormatter;
@end

@implementation HUDNode

-(instancetype)init {
  if (self = [super init]) {
    self.score = 0;
    self.powerupTimeRemaining = 0;
    
    self.timeFormatter = [[NSNumberFormatter alloc] init];
    self.timeFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    self.timeFormatter.minimumFractionDigits = 1;
    self.timeFormatter.maximumFractionDigits = 1;
 
    self.scoreFormatter = [[NSNumberFormatter alloc] init];
    self.scoreFormatter.numberStyle = NSNumberFormatterDecimalStyle;

    SKNode *scoreGroup = [self createScoreGroup];
    [self addChild:scoreGroup];

    SKNode *elapsedGroup = [self createElapsedGroup];
    [self addChild:elapsedGroup];
  }
  return(self);
}

-(SKNode*) createScoreGroup {
  SKNode *scoreGroup = [SKNode node];
  scoreGroup.name = @"scoreGroup";

  SKLabelNode *scoreTitle = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Medium"];
  scoreTitle.fontSize = 12;
  scoreTitle.fontColor = [SKColor greenColor];
  scoreTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  scoreTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
  scoreTitle.text = @"SCORE";
  scoreTitle.position = CGPointMake(0, 4);
  [scoreGroup addChild:scoreTitle];

  SKLabelNode *scoreValue = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
  scoreValue.fontSize = 20;
  scoreValue.fontColor = [SKColor whiteColor];
  scoreValue.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  scoreValue.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
  scoreValue.name = @"scoreValue";
  scoreValue.text = @"0";
  scoreValue.position = CGPointMake(0, -4);
  [scoreGroup addChild:scoreValue];
  
  return(scoreGroup);
}

-(SKNode*) createElapsedGroup {
  SKNode *elapsedGroup = [SKNode node];
  elapsedGroup.name = @"elapsedGroup";

  SKLabelNode *elapsedTitle = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Medium"];
  elapsedTitle.fontSize = 12;
  elapsedTitle.fontColor = [SKColor whiteColor];
  elapsedTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
  elapsedTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
  elapsedTitle.text = @"TIME";
  elapsedTitle.position = CGPointMake(0, 4);
  [elapsedGroup addChild:elapsedTitle];
  
  SKLabelNode *elapsedValue = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
  elapsedValue.fontSize = 20;
  elapsedValue.fontColor = [SKColor whiteColor];
  elapsedValue.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
  elapsedValue.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
  elapsedValue.name = @"elapsedValue";
  elapsedValue.text = @"0.0s";
  elapsedValue.position = CGPointMake(0, -4);
  [elapsedGroup addChild:elapsedValue];
  
  return(elapsedGroup);
}

-(SKNode*) createPowerupGroup:(NSTimeInterval)time {
  SKNode *powerupGroup = [SKNode node];
  powerupGroup.name = @"powerupGroup";
  
  SKLabelNode *powerupTitle = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Medium"];
  powerupTitle.fontSize = 12;
  powerupTitle.fontColor = [SKColor redColor];
  powerupTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
  powerupTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
  powerupTitle.text = @"Power Up!";
  powerupTitle.position = CGPointMake(0, 4);
  [powerupGroup addChild:powerupTitle];
  
  SKLabelNode *powerupValue = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
  powerupValue.fontSize = 20;
  powerupValue.fontColor = [SKColor redColor];
  powerupValue.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
  powerupValue.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
  powerupValue.name = @"powerupValue";
  powerupValue.text = @"0.0s left";
  powerupValue.position = CGPointMake(0, -4);
  [powerupGroup addChild:powerupValue];
  
  return(powerupGroup);
}

-(void) layoutForScene {
  NSAssert(self.scene, @"Cannot be called unless added to scene.");
  
  CGSize sceneSize = self.scene.size;
  NSLog(@"HUD.layoutForScene - sceneSize(%f x %f)", sceneSize.width, sceneSize.height);
  CGSize groupSize = CGSizeZero;
  
  SKNode *scoreGroup = [self childNodeWithName:@"scoreGroup"];
  groupSize = [scoreGroup calculateAccumulatedFrame].size;
  scoreGroup.position = CGPointMake(0 - sceneSize.width / 2 + 20,
                                    sceneSize.height / 2 - groupSize.height);
  
  SKNode *elapsedGroup = [self childNodeWithName:@"elapsedGroup"];
  groupSize = [elapsedGroup calculateAccumulatedFrame].size;
  elapsedGroup.position = CGPointMake(sceneSize.width / 2 - 20,
                                      sceneSize.height / 2 - groupSize.height);
}

-(void) addPoints:(NSInteger)points {
  self.score += points;
  
  SKLabelNode *scoreValue = (SKLabelNode*) [self childNodeWithName:@"scoreGroup/scoreValue"];
  scoreValue.text = [NSString stringWithFormat:@"%@", [self.scoreFormatter stringFromNumber:@(self.score)]];
  
  SKAction *scale = [SKAction scaleTo:1.1 duration:0.02];
  SKAction *shrink = [SKAction scaleTo:1.0 duration:0.07];
  [scoreValue runAction:[SKAction sequence:@[ scale, shrink]]];
}

-(void) startGame {
  startTime = [NSDate timeIntervalSinceReferenceDate];
  
  SKLabelNode *elapsedValue = (SKLabelNode*) [self childNodeWithName:@"elapsedGroup/elapsedValue"];

  __weak HUDNode *weakSelf = self;
  SKAction *update = [SKAction runBlock:^{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    weakSelf.elapsedTime = now - startTime;

    elapsedValue.text = [NSString stringWithFormat:@"%@s", [weakSelf.timeFormatter stringFromNumber:@(self.elapsedTime)]];
  }];
  SKAction *delay = [SKAction waitForDuration:0.05];
  SKAction *updateAndDelay = [SKAction sequence:@[ update, delay ]];
  SKAction *timer = [SKAction repeatActionForever:updateAndDelay];
  [self runAction:timer withKey:@"elapsedGameTimer"];
}

-(void) endGame {
  [self removeActionForKey:@"elapsedGameTimer"];
  SKNode *powerupGroup = [self childNodeWithName:@"powerupGroup"];
  if (powerupGroup != nil) {
    [powerupGroup removeActionForKey:@"powerupTime"];

    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:0.3];
    [powerupGroup runAction:fadeOut];
  }
}

-(SKNode*) getPowerupGroup:(NSTimeInterval)time {
  SKNode *powerupGroup = [self childNodeWithName:@"powerupGroup"];
  if (powerupGroup == nil) {
    CGSize sceneSize = self.scene.size;

    powerupGroup = [self createPowerupGroup:time];
    CGSize groupSize = [powerupGroup calculateAccumulatedFrame].size;
    powerupGroup.position = CGPointMake(0, sceneSize.height / 2 - groupSize.height);
    [self addChild:powerupGroup];
  }
  return(powerupGroup);
}

-(NSTimeInterval) showPowerupTimer:(NSTimeInterval)time {
  SKNode* powerupGroup = [self getPowerupGroup:time];
  if (powerupGroup == nil) return(0);
  
  if (self.powerupTimeRemaining > 0) {
    self.powerupTimeRemaining = time;
    return(self.powerupTimeRemaining);
  }
  
  SKLabelNode *powerupValue = (SKLabelNode*) [powerupGroup childNodeWithName:@"powerupValue"];
  [powerupGroup removeActionForKey:@"powerupTimer"];
  self.powerupTimeRemaining = time;
  powerupLastUpdated = [NSDate timeIntervalSinceReferenceDate];
  
  __weak HUDNode *weakSelf = self;
  SKAction *update = [SKAction runBlock:^{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    self.powerupTimeRemaining -= (now - powerupLastUpdated);
    powerupLastUpdated = now;

    if (self.powerupTimeRemaining < 0) {
      weakSelf.powerupTimeRemaining = 0;
      [weakSelf removeActionForKey:@"powerupTimer"];
      
      [powerupGroup removeFromParent];
    }
    powerupValue.text = [NSString stringWithFormat:@"%@s left", [weakSelf.timeFormatter stringFromNumber:@(self.powerupTimeRemaining)]];
  }];
  SKAction *scale = [SKAction scaleTo:1.1 duration:0.1];
  SKAction *shrink = [SKAction scaleTo:1.0 duration:0.05];
  [powerupValue runAction:[SKAction sequence:@[ scale, shrink]]];
    
  SKAction *delay = [SKAction waitForDuration:0.05];
  SKAction *updateAndDelay = [SKAction sequence:@[ update, delay ]];
  SKAction *timer = [SKAction repeatActionForever:updateAndDelay];
  [powerupGroup runAction:timer withKey:@"powerupTimer"];

  return(self.powerupTimeRemaining);
}

@end
