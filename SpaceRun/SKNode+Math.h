//
//  CGPoint_Math.h
//  SpaceRun
//
//  Created by George Heeres on 4/8/15.
//  Copyright (c) 2015 George Heeres. All rights reserved.
//

@interface SKNode(Math)

-(CGFloat) getAngleToPoint:(CGPoint)end;
-(CGFloat) getDistanceToPoint:(CGPoint)end;
-(CGPoint) getPositionOnWayToPoint:(CGPoint)end atSpeed:(CGFloat)speed overTime:(NSTimeInterval)time;


@end

@implementation SKNode(Math)
  
-(CGFloat) getAngleToPoint:(CGPoint)end {
  return(atan2(end.y - self.position.y, end.x - self.position.x));
}

-(CGFloat) getDistanceToPoint:(CGPoint)end {
  return(sqrt(pow(end.x - self.position.x, 2) +
              pow(end.y - self.position.y, 2)));
}

-(CGPoint) getPositionOnWayToPoint:(CGPoint)end atSpeed:(CGFloat)speed overTime:(NSTimeInterval)time {
  CGFloat distanceToTravel = time * speed;
  CGFloat angle = [self getAngleToPoint:end];
  CGFloat yOffset = distanceToTravel * sin(angle);
  CGFloat xOffset = distanceToTravel * cos(angle);
  return(CGPointMake(self.position.x + xOffset, self.position.y + yOffset));
}

@end