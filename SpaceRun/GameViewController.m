//
//  GameViewController.m
//  SpaceRun
//
//  Created by George Heeres on 4/8/15.
//  Copyright (c) 2015 George Heeres. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "StartViewController.h"
#import "OpeningScene.h"
#import "SKScene+Unarchive.h"

@implementation GameViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Configure the view.
  SKView * skView = (SKView *)self.view;
  skView.showsFPS = YES;
  skView.showsNodeCount = YES;
  /* Sprite Kit applies additional optimizations to improve rendering performance */
  skView.ignoresSiblingOrder = YES;
  
  SKScene *blackScene = [[SKScene alloc] initWithSize:skView.bounds.size];
  blackScene.backgroundColor = [UIColor colorWithRed:255/255.0 green:102/255.0 blue:178/255.0 alpha:1.0];  [skView presentScene:blackScene];
}

-(void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  __weak SKView *skView = (SKView*) self.view;
  
  OpeningScene *scene = [OpeningScene sceneWithSize:skView.bounds.size];
  scene.scaleMode = SKSceneScaleModeAspectFill;
  SKTransition *transition = [SKTransition fadeWithDuration:1];
  [skView presentScene:scene transition:transition];
  
  scene.sceneEndCallback = ^{
    [self startGame:skView];
  };
}

-(void) startGame:(SKView*)skView {
  // Create and configure the scene.
  GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
  scene.size = skView.bounds.size;
  scene.scaleMode = SKSceneScaleModeAspectFill;
  scene.difficulty = _difficulty;
  
  __weak GameViewController* weakSelf = self;
  scene.endGameCallback = ^{
    [(SKView*)weakSelf.view presentScene:nil];
    [weakSelf dismissViewControllerAnimated:NO completion:nil];
  };
  
  [skView presentScene:scene];
}

- (BOOL)shouldAutorotate {
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      return UIInterfaceOrientationMaskAllButUpsideDown;
  }
  return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

@end
