//
//  GameScene.m
//  SpaceRun
//
//  Created by George Heeres on 4/8/15.
//  Copyright (c) 2015 George Heeres. All rights reserved.
//

#import "GameScene.h"
#import "SKNode+Math.h"
#import "SKEmitterNode+File.h"
#import "StarFieldNode.h"
#import "GameOverNode.h"
#import "HUDNode.h"

@interface GameScene() {
  BOOL log;
  BOOL godMode;
}

@property (nonatomic) CGFloat dropRate;

@property (nonatomic,weak) UITouch* shipTouch;
@property (nonatomic) NSTimeInterval lastUpdateTime;
@property (nonatomic) NSTimeInterval lastShotTime;

@property (nonatomic,strong) SKAction* shootSound;
@property (nonatomic,strong) SKAction* shipExplodeSound;
@property (nonatomic,strong) SKAction* obstacleExplodedSound;
@property (nonatomic,strong) SKEmitterNode* shipExplodeTemplate;
@property (nonatomic,strong) SKEmitterNode* obstacleExplodeTemplate;

@property (nonatomic) CGFloat shipSize;
@property (nonatomic) CGFloat shipSpeed;
@property (nonatomic) CGFloat shipFireRate;
@property (nonatomic) CGFloat photonIntervalSpeed;

@property (nonatomic) CGFloat powerupSize;
@property (nonatomic) CGFloat minimumPowerupSpeed;
@property (nonatomic) CGFloat maximumPowerupSpeed;
@property (nonatomic) CGFloat powerupDuration;

@property (nonatomic) CGFloat enemySize;
@property (nonatomic) CGFloat enemyShipDuration;

@property (nonatomic) CGFloat minimumAsteroidSize;
@property (nonatomic) CGFloat maximumAsteroidSize;
@property (nonatomic) CGFloat minimumAsteroidSpeed;
@property (nonatomic) CGFloat maximumAsteroidSpeed;
@property (nonatomic) CGFloat minimumAsteroidRotationSpeed;
@property (nonatomic) CGFloat maximumAsteroidRotationSpeed;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation GameScene

-(id) initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    self.backgroundColor = [UIColor colorWithRed:255/255.0 green:102/255.0 blue:178/255.0 alpha:1.0];
    
    //godMode = YES;
    log = NO;

    [self initialize];
  }
  return(self);
}

-(void) didMoveToView:(SKView *)view {
  [super didMoveToView:view];
  
  StarFieldNode* starField = [StarFieldNode node];
  [self addChild:starField];
  
  if (log) NSLog(@"Game scene initialized. Size: %f x %f", self.size.width, self.size.height);
  
  SKSpriteNode* ship = [self createShip];
  [self addChild:ship];
  
  HUDNode *hud = [self createHUD];
  [self addChild:hud];
  [hud layoutForScene];
  [hud startGame];
}

-(HUDNode*) createHUD {
  HUDNode *hud = [HUDNode node];
  hud.name = @"hud";
  hud.zPosition = 100;
  hud.position = CGPointMake(self.size.width / 2, self.size.height / 2);
  return(hud);
}

-(void) initialize {
  // Sounds
  self.shootSound = [SKAction playSoundFileNamed:@"shoot.m4a" waitForCompletion:NO];
  self.obstacleExplodedSound = [SKAction playSoundFileNamed:@"obstacleExplode.m4a" waitForCompletion:NO];
  self.shipExplodeSound = [SKAction playSoundFileNamed:@"shipExplode.m4a" waitForCompletion:NO];
  
  // Particle Emitters
  self.obstacleExplodeTemplate = [SKEmitterNode nodeWithFileNamed:@"obstacleExplode.sks"];
  self.shipExplodeTemplate = [SKEmitterNode nodeWithFileNamed:@"shipExplode.sks"];
  
  self.dropRate =  (_difficulty + 1) * 25;

  self.photonIntervalSpeed = 0.5;

  self.shipSize = 40;
  self.shipSpeed = 200;
  self.shipFireRate = 0.5;

  self.powerupSize = 20;
  self.powerupDuration = 5;
  self.minimumPowerupSpeed = 10;
  self.maximumPowerupSpeed = 20;
  
  self.enemySize = 30;
  self.enemyShipDuration = 7;
  
  self.minimumAsteroidSize = 15;
  self.maximumAsteroidSize = 44;
  self.minimumAsteroidSpeed = 3;
  self.maximumAsteroidSpeed = 4;
  self.minimumAsteroidRotationSpeed = 1;
  self.maximumAsteroidRotationSpeed = 2;
}

-(void) willMoveFromView:(SKView *)view {
  [super willMoveFromView:view];
  
  [self.view removeGestureRecognizer:self.tapGesture];
  self.tapGesture = nil;
  
  if (log) NSLog(@"Remove all child actions.");
  [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    SKNode* child = obj;
    [child removeAllActions];
  }];
  if (log) NSLog(@"Remove all children nodes.");
  [self removeAllChildren];
}

-(SKSpriteNode*) createShip {
  NSString* name = @"Spaceship";
  
  SKSpriteNode *ship = [SKSpriteNode spriteNodeWithImageNamed:name];
  ship.position = CGPointMake(self.size.width/2, self.size.height/2);
  ship.size = CGSizeMake(self.shipSize, self.shipSize);
  ship.name = @"ship";

  SKEmitterNode* thrust = [SKEmitterNode nodeWithFileNamed:@"Thrust.sks"];
  thrust.position = CGPointMake(0, -1 * (ship.size.height / 2));
  [ship addChild:thrust];
  
  return(ship);
}

-(SKSpriteNode*) getShip {
  SKSpriteNode* ship = (SKSpriteNode*) [self childNodeWithName:@"ship"];
  if (ship == nil) {
    //ship = [self createShip];
  }
  return(ship);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  SKSpriteNode* ship = (SKSpriteNode*) [self childNodeWithName:@"ship"];
  if (ship != nil) {
    self.shipTouch = [touches anyObject];
  }
}

-(void) moveShipTowardPoint:(CGPoint)location byTimeDelta:(NSTimeInterval)timeDelta {
  SKSpriteNode* ship = [self getShip];
  CGFloat distanceLeft = [ship getDistanceToPoint:location];
  // Avoid jitter
  if (distanceLeft > 4) {
    ship.position = [ship getPositionOnWayToPoint:location atSpeed:self.shipSpeed overTime:timeDelta];
  }
}

-(SKSpriteNode*) createPhoton {
  SKSpriteNode* ship = [self getShip];
  
  SKSpriteNode* photon = [SKSpriteNode spriteNodeWithImageNamed:@"Photon"];
  photon.name = @"photon";
  CGFloat frontOfShipY = ship.position.y + (ship.size.height / 2) + (photon.size.height / 2);
  photon.position = CGPointMake(ship.position.x, frontOfShipY);
  
  SKAction *fly = [SKAction moveByX:0 y:self.size.height + photon.size.height duration:self.photonIntervalSpeed];
  SKAction *remove = [SKAction removeFromParent];
  SKAction* fireAndRemove = [SKAction sequence:@[ fly, remove ]];
  [photon runAction:fireAndRemove];

  return(photon);
}

-(SKSpriteNode*) createRandomSizedAsteroid {
  SKSpriteNode* asteroid = [SKSpriteNode spriteNodeWithImageNamed:@"Asteroid"];
  asteroid.name = @"obstacle";
  CGFloat side = self.minimumAsteroidSize + arc4random_uniform(self.maximumAsteroidSize - self.minimumAsteroidSize);
  asteroid.size = CGSizeMake(side, side);
  return(asteroid);
}

-(SKSpriteNode*) createPowerup {
  SKSpriteNode* powerup = [SKSpriteNode spriteNodeWithImageNamed:@"Powerup"];
  powerup.name = @"powerup";
  powerup.size = CGSizeMake(self.powerupSize, self.powerupSize);
  return(powerup);
}

-(SKSpriteNode*) createEnemy {
  SKSpriteNode* enemy = [SKSpriteNode spriteNodeWithImageNamed:@"Enemy"];
  enemy.name = @"obstacle";
  enemy.size = CGSizeMake(self.enemySize, self.enemySize);
  return(enemy);
}

-(CGPoint) getRandomEntryPoint:(CGSize)forSize {
  CGFloat width = self.size.width;
  CGFloat quarterWidth = width / 4;
  CGFloat x = arc4random_uniform(width+(quarterWidth*2)) - quarterWidth; // Entry point -1/4 to 1/4 width of screen.
  return(CGPointMake(x, self.size.height + forSize.height));
}

-(CGPoint) getRandomExitPoint:(CGSize)forSize {
  return(CGPointMake(arc4random_uniform(self.size.width), 0 - forSize.width));
}

-(void) dropItem {
  u_int32_t random = arc4random_uniform(100);
  if (random <= 5) {
    [self dropPowerup];
  }
  else if (random < 15) {
    [self dropEnemyShip];
  }
  else {
    [self dropAsteroid];
  }
}

-(void) dropEnemyShip {
  SKSpriteNode* enemy = [self createEnemy];
  enemy.position = [self getRandomEntryPoint:enemy.size];
  
  if (log) NSLog(@"Enemy created");
  SKAction* followPath = [SKAction followPath:[self getEnemyShipMovementPath] asOffset:YES orientToPath:YES duration:self.enemyShipDuration];
  SKAction* remove = [SKAction removeFromParent];
  SKAction* all = [SKAction sequence:@[followPath, remove]];
  [enemy runAction:all];
  
  [self addChild:enemy];
}

-(void) dropPowerup {
  SKSpriteNode* powerup = [self createPowerup];
  powerup.position = [self getRandomEntryPoint:powerup.size];
  CGPoint exit = [self getRandomExitPoint:powerup.size];
  
  if (log) NSLog(@"Powerup created at %f,%f heading to %f,%f with angle %f.", powerup.position.x, powerup.position.y, exit.x, exit.y, [powerup getAngleToPoint:exit]);
  SKAction* move = [SKAction moveTo:exit duration:self.minimumPowerupSpeed+arc4random_uniform(self.maximumPowerupSpeed - self.minimumAsteroidSpeed)];
  SKAction* remove = [SKAction removeFromParent];
  
  [powerup runAction:[SKAction sequence:@[ move, remove ]]];
  
  [self addChild:powerup];
}

-(void) dropAsteroid {
  SKSpriteNode* asteroid = [self createRandomSizedAsteroid];
  asteroid.position = [self getRandomEntryPoint:asteroid.size];
  CGPoint exit = [self getRandomExitPoint:asteroid.size];

  if (log) NSLog(@"Asteroid created at %f,%f heading to %f,%f with angle %f.", asteroid.position.x, asteroid.position.y, exit.x, exit.y, [asteroid getAngleToPoint:exit]);
  SKAction* move = [SKAction moveTo:exit duration:self.minimumAsteroidSpeed+arc4random_uniform(self.maximumAsteroidSpeed - self.minimumAsteroidSpeed)];
  SKAction* remove = [SKAction removeFromParent];
  SKAction* travelAndRemove = [SKAction sequence:@[ move, remove ]];
  
  SKAction* spin = [SKAction rotateByAngle:3 duration:self.minimumAsteroidRotationSpeed + arc4random_uniform(self.maximumAsteroidRotationSpeed - self.minimumAsteroidRotationSpeed)];
  SKAction* spinForever = [SKAction repeatActionForever:spin];
  
  [asteroid runAction:[SKAction group:@[ travelAndRemove, spinForever]]];
  
  [self addChild:asteroid];
}

-(void) shoot {
  SKSpriteNode* photon = [self createPhoton];
  [self addChild:photon];
  [self runAction:self.shootSound];
}

-(CGPathRef) getEnemyShipMovementPath {
  UIBezierPath* bezierPath = [UIBezierPath bezierPath];
  [bezierPath moveToPoint: CGPointMake(0.5, -0.5)];
  [bezierPath addCurveToPoint: CGPointMake(-2.5, -59.5)
                controlPoint1: CGPointMake(0.5, -0.5)
                controlPoint2: CGPointMake(4.55, -29.48)];
  [bezierPath addCurveToPoint: CGPointMake(-27.5, -154.5)
                controlPoint1: CGPointMake(-9.55, -89.52)
                controlPoint2: CGPointMake(-43.32, -115.43)];
  [bezierPath addCurveToPoint: CGPointMake(30.5, -243.5)
                controlPoint1: CGPointMake(-11.68, -193.57)
                controlPoint2: CGPointMake(17.28, -186.95)];
  [bezierPath addCurveToPoint: CGPointMake(-52.5, -379.5)
                controlPoint1: CGPointMake(43.72, -300.05)
                controlPoint2: CGPointMake(-47.71, -335.76)];
  [bezierPath addCurveToPoint: CGPointMake(54.5, -449.5)
                controlPoint1: CGPointMake(-57.29, -423.24)
                controlPoint2: CGPointMake(-8.14, -482.45)];
  [bezierPath addCurveToPoint: CGPointMake(-5.5, -348.5)
                controlPoint1: CGPointMake(117.14, -416.55)
                controlPoint2: CGPointMake(52.25, -308.62)];
  [bezierPath addCurveToPoint: CGPointMake(10.5, -494.5)
                controlPoint1: CGPointMake(-63.25, -388.38)
                controlPoint2: CGPointMake(-14.48, -457.43)];
  [bezierPath addCurveToPoint: CGPointMake(0.5, -559.5)
                controlPoint1: CGPointMake(23.74, -514.16)
                controlPoint2: CGPointMake(6.93, -537.57)];
  [bezierPath addCurveToPoint: CGPointMake(-2.5, -644.5)
                controlPoint1: CGPointMake(-5.2, -578.93)
                controlPoint2: CGPointMake(-2.5, -644.5)];
  return bezierPath.CGPath;
}

-(void) checkCollisions {
  SKSpriteNode* ship = [self getShip];
  [self enumerateChildNodesWithName:@"obstacle" usingBlock:^(SKNode *obstacle, BOOL *stop) {
    if ((! godMode) && [ship intersectsNode:obstacle]) {
      if (log) NSLog(@"Collision with obstacle detected.");
      
      self.shipTouch = nil;
      [ship removeFromParent];
      [obstacle removeFromParent];
      [self runAction:self.shipExplodeSound];
      
      SKEmitterNode* explosion = [self.shipExplodeTemplate copy];
      explosion.position = ship.position;
      [explosion dieOutInDuration:1];
      [self addChild:explosion];
      
      [self endGame];
    }
    [self enumerateChildNodesWithName:@"photon" usingBlock:^(SKNode *photon, BOOL *stop) {
      if ([photon intersectsNode:obstacle]) {
        if (log) NSLog(@"Photon took out obstacle.");
        
        [photon removeFromParent];
        [obstacle removeFromParent];
        [self runAction:self.obstacleExplodedSound];
        
        SKEmitterNode* explosion = [self.obstacleExplodeTemplate copy];
        explosion.position = obstacle.position;
        [explosion dieOutInDuration:0.1];
        [self addChild:explosion];
        
        HUDNode* hud = (HUDNode*) [self childNodeWithName:@"hud"];
        NSInteger score = 10 * hud.elapsedTime * (self.difficulty + 1);
        [hud addPoints:score];
        if (log) NSLog(@"Value of destroyed object was %d", score);
        
        *stop = YES;
      }
    }];
  }];
  [self enumerateChildNodesWithName:@"powerup" usingBlock:^(SKNode *powerup, BOOL *stop) {
    if ([ship intersectsNode:powerup]) {
      [powerup removeFromParent];

      if (log) NSLog(@"Powerup activated!");
      self.shipFireRate = 0.1;
      SKAction* powerDown = [SKAction runBlock:^{
        if (log) NSLog(@"Powerup expired.");
        self.shipFireRate = 0.5;
      }];
      SKAction* wait = [SKAction waitForDuration:self.powerupDuration];
      SKAction* waitAndPowerdown = [SKAction sequence:@[wait,powerDown]];
      [ship removeActionForKey:@"waitAndPowerdown"];
      [ship runAction:waitAndPowerdown withKey:@"waitAndPowerdown"];
      
      HUDNode* hud = (HUDNode*) [self childNodeWithName:@"hud"];
      [hud showPowerupTimer:5.0];
    }
  }];
}

-(void) update:(NSTimeInterval)currentTime {
  if (self.lastUpdateTime == 0) self.lastUpdateTime = currentTime;
  
  NSTimeInterval timeDelta = currentTime - self.lastUpdateTime;
  if (self.shipTouch) {
    [self moveShipTowardPoint:[self.shipTouch locationInNode:self] byTimeDelta:timeDelta];
    if (currentTime - self.lastShotTime > self.shipFireRate) {
      [self shoot];
      self.lastShotTime = currentTime;
    }
  }
  
  if (arc4random_uniform(1000) <= self.dropRate) {
    [self dropItem];
  }
  [self checkCollisions];
  
  self.lastUpdateTime = currentTime;
}

-(void) tapped {
  NSAssert(_endGameCallback, @"endGameCallback not set.");
  self.endGameCallback();
}

-(void) endGame {
  NSLog(@"Game over.");
  
  self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
  [self.view addGestureRecognizer:self.tapGesture];
  
  GameOverNode *node = [GameOverNode node];
  node.position = CGPointMake(self.size.width / 2, self.size.height / 2);
  [self addChild:node];

  HUDNode* hud = (HUDNode *)[self childNodeWithName:@"hud"];
  [hud endGame];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSNumber* highScore = [defaults valueForKey:@"highScore"];
  if (highScore.integerValue < hud.score) {
    [defaults setValue:@(hud.score) forKey:@"highScore"];
  }
}

@end
