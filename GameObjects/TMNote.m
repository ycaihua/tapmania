//
//  TMNote.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TMNote.h"


@implementation TMNote

@synthesize type, beatType, isHit, multiHitFlag, isHeld, hitTime, isHolding, isHoldLost;
@synthesize lastHoldTouchTime, lastHoldReleaseTime, startNoteRow, stopNoteRow, startYPosition, stopYPosition;

- (id) initWithNoteRow:(int) noteRow andType:(TMNoteType)lType {
	self = [super init];
	if(!self)
		return nil;
	
	startNoteRow = noteRow;
	stopNoteRow = -1;
	beatType = [TMNote getBeatType:noteRow];
	type = lType;
	
	isHit = NO;
	multiHitFlag = NO;
	isHolding = NO;
	isHeld = NO;
	isHoldLost = NO;
	hitTime = 0.0f;
	
	startYPosition = 0.0f;
	stopYPosition = 0.0f;
	
	return self;
}

- (void) multiHit {
	multiHitFlag = YES;
}

- (void) hit:(double)lHitTime {
	if(!isHit){
		isHit = YES;
		hitTime = lHitTime;
	}
}

- (void) startHolding:(double)lTouchTime {
	lastHoldTouchTime = lTouchTime;
	isHolding = YES;
	isHeld = YES; // Will be set to NO if released
}

- (void) stopHolding:(double)lReleaseTime {
	lastHoldReleaseTime = lReleaseTime;
	isHolding = NO;
	isHeld = NO;
}

- (void) markHoldLost {
	isHolding = NO;
	isHeld = NO;
	isHoldLost = YES;
}

+ (TMBeatType) getBeatType:(int) row {
	if(row % (kRowsPerMeasure/4) == 0)	return kBeatType_4th;
	if(row % (kRowsPerMeasure/8) == 0)	return kBeatType_8th;
	if(row % (kRowsPerMeasure/12) == 0)	return kBeatType_12th;
	if(row % (kRowsPerMeasure/16) == 0)	return kBeatType_16th;
	if(row % (kRowsPerMeasure/24) == 0)	return kBeatType_24th;
	if(row % (kRowsPerMeasure/32) == 0)	return kBeatType_32nd;
	if(row % (kRowsPerMeasure/48) == 0)	return kBeatType_48th;
	if(row % (kRowsPerMeasure/64) == 0)	return kBeatType_64th;
	return kBeatType_192nd;
}

+ (float) noteRowToBeat:(int) noteRow {
	return noteRow / (float)kRowsPerBeat;
}

+ (int) beatToNoteRow:(float) fBeat {
	return lrintf( fBeat * kRowsPerBeat );	
}

@end
