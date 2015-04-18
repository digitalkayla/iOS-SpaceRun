//
//  StartViewController.h
//  SpaceRun
//
//  Created by George Heeres on 4/14/15.
//  Copyright (c) 2015 George Heeres. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface StartViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *difficulty;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;

@end
