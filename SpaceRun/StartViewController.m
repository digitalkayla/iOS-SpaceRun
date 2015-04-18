//
//  StartViewController.m
//  SpaceRun
//
//  Created by George Heeres on 4/14/15.
//  Copyright (c) 2015 George Heeres. All rights reserved.
//

#import "StartViewController.h"
#import "GameViewController.h"
#import "StarFieldNode.h"

@interface StartViewController()

@property (nonatomic, strong) SKView *backgroundView;

@end

@implementation StartViewController

-(void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self setHighScore];
  _backgroundView = [[SKView alloc] initWithFrame:self.view.bounds];
  
  SKScene* scene = [[SKScene alloc] initWithSize:self.view.bounds.size];
  scene.backgroundColor = [SKColor blackColor];
  scene.scaleMode = SKSceneScaleModeAspectFill;

  SKNode *starField = [StarFieldNode node];
  [scene addChild:starField];
  [self.backgroundView presentScene:scene];
  [self.view insertSubview:_backgroundView atIndex:0];
}

-(void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [_backgroundView removeFromSuperview];
  _backgroundView = nil;
}

-(void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  NSNumberFormatter *scoreFormatter = [[NSNumberFormatter alloc] init];
  scoreFormatter.numberStyle = NSNumberFormatterDecimalStyle;
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults registerDefaults:@{ @"highScore" : @0 }];
  NSNumber *highScore = [userDefaults valueForKey:@"highScore"];
  self.highScoreLabel.text = [NSString stringWithFormat:@"High Score: %@",
                              [scoreFormatter stringFromNumber:highScore]];
}

-(void) setHighScore {
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"PlayGameSegue"]) {
    GameViewController *controller = [segue destinationViewController];
    controller.difficulty = _difficulty.selectedSegmentIndex;
  }
}

@end
