//
//  GameScene.h
//  SpaceRun
//

//  Copyright (c) 2015 George Heeres. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene

@property (nonatomic) NSInteger difficulty;
@property (nonatomic,copy) dispatch_block_t endGameCallback;

@end
