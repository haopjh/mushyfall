//
//  ViewController.m
//  MushyFall
//
//  Created by Jun Hao Peh on 14/3/14.
//  Copyright (c) 2014 Oyster Productions. All rights reserved.
//

#import "ViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "IntroScene.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	//Configure the view
	SKView *view = (SKView *)self.view;
	if (!view.scene)
	{
		view.showsFPS = YES;
		view.showsNodeCount = YES;
		
		//Create and configure the scene
		SKScene *scene = [IntroScene sceneWithSize:view.bounds.size];
		scene.scaleMode = SKSceneScaleModeAspectFit;
		
		//Present the scene
		[view presentScene:scene];
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
