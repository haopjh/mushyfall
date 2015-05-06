//
//  MushyFall.m
//  MushyFall
//
//  Created by Jun Hao Peh on 14/3/14.
//  Copyright (c) 2014 Oyster Productions. All rights reserved.
//

#import "MushyFall.h"

@interface MushyFall ()
@property BOOL contentCreated;
@property NSString *swipedDirection;
@property int MUSHROOMLIMIT;
@property int score;
@property int death;
@property int stageCount;
@property BOOL gameEnded;
@property BOOL stageEnded;

@end

@implementation MushyFall

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
	self.MUSHROOMLIMIT = 5;
	self.stageCount = 1;
	self.gameEnded = NO;
	self.stageEnded = YES;
	self.swipedDirection = @"";
	self.scene.name = @"baseScene";
	self.scaleMode = SKSceneScaleModeAspectFit;
	
	
	//Create Background
	self.backgroundColor = [SKColor whiteColor];
	SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background.png"];
	background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
	background.name = @"background";
	[self addChild:background];
	
	//Create sideNodes to store left/right mushrooms
	SKNode *sideNode  = [[SKNode alloc] init];
	sideNode.name = @"sideNode";
	[self.scene addChild:sideNode];
	
	//Create centerNodes to store center mushrooms
	SKNode *centerNode  = [[SKNode alloc] init];
	centerNode.name = @"centerNode";
	centerNode.position = CGPointMake(0, 0);
	[self.scene addChild:centerNode];
	
	
	//Create Score Label
	self.score = 0;
	SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
	scoreLabel.name = @"scoreLabel";
	scoreLabel.position = CGPointMake(50, self.size.height-50);
	scoreLabel.fontColor = [SKColor blackColor];
	scoreLabel.text = @"0";
	[self.scene addChild:scoreLabel];
	
	//Create Baskets
	SKSpriteNode *leftBasket = [SKSpriteNode spriteNodeWithImageNamed:@"tube.png"];
	leftBasket.position = CGPointMake(50, 50);
	leftBasket.color = [SKColor redColor];
	leftBasket.colorBlendFactor = 0.8;
	[self addChild:leftBasket];
	SKSpriteNode *rightBasket = [SKSpriteNode spriteNodeWithImageNamed:@"tube.png"];
	rightBasket.position = CGPointMake(self.frame.size.width-50, 50);
	rightBasket.color = [SKColor greenColor];
	rightBasket.colorBlendFactor = 0.5;
	[self addChild:rightBasket];
	[self startGame];
	
}

- (void)startGame
{
	if (!self.gameEnded){
		self.stageEnded = NO;
		//Create Label
		SKLabelNode *stageLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
		stageLabel.name = @"stageLabel";
		stageLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
		stageLabel.fontColor = [SKColor blackColor];
		stageLabel.text = [NSString stringWithFormat:@"Stage %i", self.stageCount];
		
		//Add Stage label
		[self addChild:stageLabel];
		SKAction *removeStageLabel = [SKAction sequence:@[
														  [SKAction waitForDuration:1],
														  [SKAction fadeOutWithDuration:0.25]
														  ]];
		//Remove Stage label
		[stageLabel runAction:removeStageLabel];
		
		
		
		//Create add mushroom label
		SKAction *makeMushrooms = [SKAction sequence: @[
														[SKAction performSelector:@selector(addMushroom) onTarget:self],
														[SKAction waitForDuration:1.0/self.stageCount]
														]];
		
		
		//Run mushroom generation
		[self runAction: [SKAction waitForDuration:0.75] completion:^{
			[self runAction: [SKAction repeatAction:makeMushrooms count:self.MUSHROOMLIMIT]];
		}];

	}
}

- (void)addMushroom
{
	SKSpriteNode *mushroom = [SKSpriteNode spriteNodeWithImageNamed:@"mushroom.png"];
	mushroom.position = CGPointMake(self.size.width/2, self.size.height-50);

	if ((float)rand()/RAND_MAX < 0.5)
	{
		mushroom.name = @"mushroom-red";
	}
	else
	{
		mushroom.name = @"mushroom-green";
		mushroom.color = [SKColor greenColor];
		mushroom.colorBlendFactor = 0.6;
	}
	
	SKAction *drop = [SKAction moveToY:-50 duration:7.5/self.stageCount];
	[mushroom runAction:drop];
	
	[[self childNodeWithName:@"centerNode"] addChild:mushroom];
}

- (void)didEvaluateActions
{
	//Checks if its in the right position after the bottom line
	[self enumerateChildNodesWithName:@"//mushroom-red" usingBlock:^(SKNode *node, BOOL *stop){
		
		if (node.position.y < 50)
		{
			if ([self valuatePosition:node])
				[self incScore];
			else
				[self loseGame];
		   [node removeFromParent];
		}
	}];
	[self enumerateChildNodesWithName:@"//mushroom-green" usingBlock:^(SKNode *node, BOOL *stop){
		
		if (node.position.y < 50)
		{
			if ([self valuatePosition:node])
				[self incScore];
			else
				[self loseGame];
			[node removeFromParent];
		}
	}];
	
	//Starts new stage
	if(self.stageEnded && !self.gameEnded){
		[self startGame];
	}
}

//Recognition of swipe Direction

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.swipedDirection = @"";
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode:self];
	if (location.x < self.frame.size.width/2)
	{
		self.swipedDirection = @"tappedLeft";
	}
	else
	{
		self.swipedDirection = @"tappedRight";
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint currentLocation = [touch locationInNode:self];
	CGPoint prevLocation = [touch previousLocationInNode:self];
	if (currentLocation.x < prevLocation.x)
		//swiped left
		self.swipedDirection = @"left";
	else
		//swiped right
		self.swipedDirection = @"right";
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([self.swipedDirection isEqual: @"left"])
		[self changeDirection:YES];
	else if ([self.swipedDirection isEqual: @"right"])
		[self changeDirection:NO];
	else if ([self.swipedDirection isEqual: @"tappedLeft"])
		[self changeDirection:YES];
	else if ([self.swipedDirection isEqual: @"tappedRight"])
		[self changeDirection:NO];
	else
		NSLog(@"Wierd Exception");

}

- (void)changeDirection:(BOOL) swipedDirection
{
	
	if (self.gameEnded)
	{
		[self reset];
		
	}
	else
	{
		NSArray *children = [self childNodeWithName:@"centerNode"].children;
		if (children.count > 0)
		{
			SKSpriteNode *child = children[0];
			SKAction *hoverRight = [SKAction moveToX:50 duration:0.2];
			SKAction *hoverLeft = [SKAction moveToX:self.size.width-50 duration:0.2];
			
			if (swipedDirection){
				[child runAction:hoverRight];
			}else{
				[child runAction:hoverLeft];
			}
			
			[child removeFromParent];
			[[self childNodeWithName:@"sideNode"] addChild:child];
		}
	}
}

- (BOOL) valuatePosition:(SKNode *) node
{
	if ([node.name isEqualToString:@"mushroom-red"] && node.position.x<self.size.width/2)
		return YES;
	else if ([node.name isEqualToString:@"mushroom-green"] && node.position.x>self.size.width/2)
		return YES;
	
	return NO;
}

- (void) incScore
{
	self.score += 1;
	SKLabelNode *label = (SKLabelNode*)[self childNodeWithName:@"scoreLabel"];
	label.text = [NSString stringWithFormat:@"%i",self.score];
	if(self.score %self.MUSHROOMLIMIT == 0){
		self.stageEnded = YES;
		self.stageCount += 1;
	}
}

- (void) loseGame
{
	[self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
		[node removeAllActions];
	}];
	[self removeAllActions];
	self.gameEnded = YES;
	
	SKLabelNode *endGameLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
	endGameLabel.fontColor = [SKColor blackColor];
	endGameLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
	endGameLabel.text = [NSString stringWithFormat:@"Final Score is %i", self.score];
	endGameLabel.fontSize = 24;
	[self addChild:endGameLabel];
	
//	SKSpriteNode *restartBtn = [SKSpriteNode spriteNodeWithImageNamed:@"restartbtn.png"];
//	restartBtn.name = @"restartBtn";
	
	
	
}

- (void) reset
{
	//Reset counters
	self.stageCount = 1;
	self.score = 0;
	[self removeAllChildren];
	[self createSceneContents];
}


@end
