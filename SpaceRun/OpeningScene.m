//
//  OpeningScene.m
//  SpaceRun
//
//  Created by George Heeres on 4/15/15.
//  Copyright (c) 2015 George Heeres. All rights reserved.
//

#import "OpeningScene.h"
#import "StarFieldNode.h"

@interface OpeningScene()

@property (nonatomic,strong) UIView* slantedView;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;

@end

@implementation OpeningScene

-(void) didMoveToView:(SKView *)view {
  [super didMoveToView:view];
  
  self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endScene)];
  [self.view addGestureRecognizer:self.tapGesture];
    
self.backgroundColor = [UIColor colorWithRed:255/255.0 green:102/255.0 blue:178/255.0 alpha:1.0];

    
  StarFieldNode *starField = [StarFieldNode node];
  [self addChild:starField];
  
  self.slantedView = [[UIView alloc] initWithFrame:self.view.bounds];
  self.slantedView.opaque = NO;
  self.slantedView.backgroundColor = [UIColor clearColor];
  [self.view addSubview:self.slantedView];
  
  CATransform3D transform = CATransform3DIdentity;
  transform.m34 = -1.0 / 500.0;
  transform = CATransform3DRotate(transform, 45.0f * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
  [self.slantedView.layer setTransform:transform];
  
  self.textView = [[UITextView alloc] initWithFrame:CGRectInset(self.view.bounds, 30, 0)];
  self.textView.opaque = NO;
  self.textView.backgroundColor = [UIColor clearColor];
  self.textView.textColor = [UIColor yellowColor];
  self.textView.font = [UIFont fontWithName:@"AvenirNext-Medium" size:20];
  self.textView.text = @"A distress meow comes in from thousands of light "
                        "years away. The kittany is in jeopardy and needs "
                        "your help. Enemy kitties and a badtsmaru shower "
                        "threaten the work of the galaxy's greatest "
                        "scientific kitty minds.\n\n"
                        "Will you be able to reach "
                        "them in time to save the research?\n\n"
                        "Or has the galaxy lost it's only hope?";
  self.textView.userInteractionEnabled = NO;
  self.textView.center = CGPointMake(self.size.width / 2 + 15,
                                     self.size.height + (self.size.height / 2));
  [self.slantedView addSubview:self.textView];
  
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = view.bounds;
  gradient.colors = @[(id)[[UIColor clearColor] CGColor],
                      (id)[[UIColor whiteColor] CGColor]];
  gradient.startPoint = CGPointMake(0.5, 0.0);
  gradient.endPoint = CGPointMake(0.5, 0.2);
  [self.slantedView.layer setMask:gradient];
  
  [UIView animateWithDuration:10 delay:0
          options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
          animations:^{
    self.textView.center = CGPointMake(self.size.width /2,
                                       0 - (self.size.height / 2));
  } completion:^(BOOL finished) {
    if (finished) {
      NSLog(@"Opening cut scene ended.");
      [self endScene];
    }
  }];
}

-(void) willMoveFromView:(SKView *)view {
  [super willMoveFromView:view];
  
  [self.view removeGestureRecognizer:self.tapGesture];
  self.tapGesture = nil;

  [self.textView.layer removeAllAnimations];
  [self.slantedView removeFromSuperview];
  self.slantedView = nil;
  self.textView = nil;
}

-(void) endScene {
  NSLog(@"Cleaning up opening scene.");
  [self.view removeGestureRecognizer:self.tapGesture];
  self.tapGesture = nil;

  [self.textView.layer removeAllAnimations];
  
  self.sceneEndCallback();
  [UIView animateWithDuration:0.3 animations:^{
    self.textView.alpha = 0;
  } completion:^(BOOL finished) {
    NSAssert(self.sceneEndCallback, @"No end callback defined for opening scene.");
    self.sceneEndCallback();
  }];
}

@end
