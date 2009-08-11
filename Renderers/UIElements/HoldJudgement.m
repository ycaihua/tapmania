//
//  HoldJudgement.m
//  TapMania
//
//  Created by Alex Kremer on 22.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "HoldJudgement.h"
#import "ThemeManager.h"

@interface HoldJudgement (Private) 
- (void) drawHoldJudgement:(TMHoldJudgement)judgement forTrack:(TMAvailableTracks)track;
@end

static int mt_HoldJudgementX[kNumOfAvailableTracks], mt_HoldJudgementY;
static float mt_HoldJudgementMaxShowTime;

@implementation HoldJudgement

- (void) drawHoldJudgement:(TMHoldJudgement)judgement forTrack:(TMAvailableTracks)track {
	glEnable(GL_BLEND);
	[self drawFrame:judgement-1 atPoint:CGPointMake( mt_HoldJudgementX[track], mt_HoldJudgementY )];
	glDisable(GL_BLEND);
}

- (void) reset {
	int i;
	for(i=0; i<kNumOfAvailableTracks; ++i) {
		m_dElapsedTime[i] = 0.0f;
		m_nCurrentJudgement[i] = kHoldJudgementNone;
	}		
}

- (id) initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows {
	self = [super initWithImage:uiImage columns:columns andRows:rows];
	if(!self) 
		return nil;
	
	// Cache metrics
	mt_HoldJudgementX[kAvailableTrack_Left] = [[ThemeManager sharedInstance] intMetric:@"SongPlay HoldJudgement LeftX"];
	mt_HoldJudgementX[kAvailableTrack_Down] = [[ThemeManager sharedInstance] intMetric:@"SongPlay HoldJudgement DownX"];
	mt_HoldJudgementX[kAvailableTrack_Up] = [[ThemeManager sharedInstance] intMetric:@"SongPlay HoldJudgement UpX"];
	mt_HoldJudgementX[kAvailableTrack_Right] = [[ThemeManager sharedInstance] intMetric:@"SongPlay HoldJudgement RightX"];
	mt_HoldJudgementY = [[ThemeManager sharedInstance] intMetric:@"SongPlay HoldJudgement Y"];
	mt_HoldJudgementMaxShowTime = [[ThemeManager sharedInstance] floatMetric:@"SongPlay HoldJudgement MaxShowTime"];
	
	[self reset];
	
	return self;
}

- (void) setCurrentHoldJudgement:(TMHoldJudgement)judgement forTrack:(TMAvailableTracks)track {
	m_dElapsedTime[track] = 0.0f;
	m_nCurrentJudgement[track] = judgement;
}

/* TMRenderable method */
- (void) render:(float)fDelta {
	
	int i;
	for(i=0; i<kNumOfAvailableTracks; ++i) {			
		if(m_nCurrentJudgement[i] != kHoldJudgementNone) {
			[self drawHoldJudgement:m_nCurrentJudgement[i] forTrack:i];
		}
	}
}

/* TMLogicUpdater method */
- (void) update:(float)fDelta {

	int i;
	for(i=0; i<kNumOfAvailableTracks; ++i) {			

		// If we show some judgement we must fade it out after some period of time
		if(m_nCurrentJudgement[i] != kHoldJudgementNone) {
			m_dElapsedTime[i] += fDelta;
		
			if(m_dElapsedTime[i] >= mt_HoldJudgementMaxShowTime) {
				m_dElapsedTime[i] = 0.0f;
				m_nCurrentJudgement[i] = kHoldJudgementNone;
			}
		}
	}
}

@end
