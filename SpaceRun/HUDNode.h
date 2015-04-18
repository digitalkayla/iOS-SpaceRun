//
//  HUDNode.h
//  SpaceRun
//
//  Created by George Heeres on 4/16/15.
//  Copyright (c) 2015 George Heeres. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface HUDNode : SKNode

@property (nonatomic) NSInteger score;
@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic) NSTimeInterval powerupTimeRemaining;

-(NSTimeInterval) showPowerupTimer:(NSTimeInterval)time;
-(void) layoutForScene;
-(void) addPoints:(NSInteger)points;
-(void) startGame;
-(void) endGame;

@end
