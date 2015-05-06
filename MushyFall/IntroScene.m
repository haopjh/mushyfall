//
//  IntroScene.m
//  MushyFall
//
//  Created by Jun Hao Peh on 14/3/14.
//  Copyright (c) 2014 Oyster Productions. All rights reserved.
//

#import "IntroScene.h"
#import "MushyFall.h"

@interface IntroScene ()
@property BOOL contentCreated;
@end

@implementation IntroScene

- (void)didMoveToView:(SKView *)view
{
	if (!self.contentCreated)
	{
		[self createSceneContents];
		self.contentCreated = YES;
	}
}

- (void)createSceneContents
{
	self.backgroundColor = [SKColor blackColor];
	self.scaleMode = SKSceneScaleModeAspectFit;
	[self addChild: [self newIntroNode]];
	
	SKNode *introNode = [self childNodeWithName:@"introNode"];
	
	if (introNode != nil)
	{
		introNode.name = nil;
		[introNode runAction:[SKAction waitForDuration:1] completion:^{
			SKScene *mushyFallScene = [[MushyFall alloc] initWithSize:self.size];
			SKTransition *door = [SKTransition doorsOpenHorizontalWithDuration:0.5];
			[self.view presentScene:mushyFallScene transition:door];
		}];
			
	}
}

- (SKLabelNode *) newIntroNode
{
	SKLabelNode *introNode = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
	introNode.text = @"Play Now!";
	introNode.fontSize = 42;
	introNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
	introNode.name = @"introNode";
	
	

	return introNode;
}

@end
