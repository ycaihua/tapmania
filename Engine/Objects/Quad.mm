//
//  Quad.mm
//  TapMania
//
//  Created by Alex Kremer on 23.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "Quad.h"
#import <OpenGLES/ES1/glext.h>
#import "Texture2D.h"
#import "TMFramedTexture.h"

@implementation Quad

@synthesize contentSize=m_oSize, pixelsWide=m_unWidth, pixelsHigh=m_unHeight;

- (id) initWithWidth:(NSUInteger)inWidth andHeight:(NSUInteger)inHeight {
	GLint					saveName;
	BOOL					sizeToFit = NO;
	int						i = 0;
	
	if((self = [super init])) {
		glGenTextures(1, &m_unName);
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
		glBindTexture(GL_TEXTURE_2D, m_unName);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		
		m_oSize = CGSizeMake(inWidth, inHeight);
		m_unWidth = inWidth;
		m_unHeight = inHeight;

		if((m_unWidth != 1) && (m_unWidth & (m_unWidth - 1))) {
			i = 1;
			while((sizeToFit ? 2 * i : i) < m_unWidth)
				i *= 2;
			m_unWidth = i;
		}
		
		m_unHeight = m_oSize.height;
		if((m_unHeight != 1) && (m_unHeight & (m_unHeight - 1))) {
			i = 1;
			while((sizeToFit ? 2 * i : i) < m_unHeight)
				i *= 2;
			m_unHeight = i;
		}
	
		TMLog(@"Quad requested for %d/%d => %d/%d", inWidth, inHeight, m_unWidth, m_unHeight);
		
		// empty data
		void* data = (void*) calloc( m_unWidth*m_unHeight*4 , sizeof(GLubyte) );
		
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, m_unWidth, m_unHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, (void*)data);
		glBindTexture(GL_TEXTURE_2D, saveName);
		
		m_fMaxS = m_oSize.width / (float)m_unWidth;
		m_fMaxT = m_oSize.height / (float)m_unHeight;
		
		free(data);
	}			
	
	return self;
}

// Copy the whole texture resized to the given size at the given location of the quad
- (void) copyTextureSize:(CGSize)inSize toPoint:(CGPoint)inPoint fromTexture:(Texture2D*)texture {
	
//	GLuint oldFramebuffer, framebuffer;
//	
//	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, (GLint *) &oldFramebuffer);	
//	glGenFramebuffersOES(1, &framebuffer);
//	glBindFramebufferOES(GL_FRAMEBUFFER_OES, framebuffer);

	// Copy texels to framebuffer and then to our quad
	glBindTexture(GL_TEXTURE_2D, texture.name);
	
	glEnable(GL_BLEND);
	[texture drawInRect:CGRectMake(0,0,inSize.width, inSize.height)];
	glDisable(GL_BLEND);
	
	glBindTexture(GL_TEXTURE_2D, m_unName);
	glCopyTexSubImage2D(GL_TEXTURE_2D, 0, inPoint.x, inPoint.y, 0, 0, inSize.width, inSize.height);		
	
	// restore
//	glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFramebuffer);
//	glDeleteFramebuffersOES(1, &framebuffer);
}

// Copy a frame of the texture to the given location in the quad
- (void) copyFrame:(int)frameId toPoint:(CGPoint)inPoint fromTexture:(TMFramedTexture*)texture {
	CGSize frameSize = CGSizeMake( texture.contentSize.width/[texture cols], texture.contentSize.height/[texture rows] );
	GLuint oldFramebuffer, fbo;

	TMLog(@"Frame size = %f/%f", frameSize.width, frameSize.height);
	
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, (GLint *) &oldFramebuffer);	

	// generate FBO
	glGenFramebuffersOES(1, &fbo);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);
	
	// associate texture with FBO
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, m_unName, 0);
		
	// check if it worked (probably worth doing :) )
	GLuint status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
	if (status != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		// didn't work
	}
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);
	
	// Copy texels to framebuffer and then to our quad
	glEnable(GL_BLEND);
	TMLog(@"Draw frame at %f/%f-%fx%f", inPoint.x, inPoint.y, frameSize.width, frameSize.height);
	[texture drawFrame:frameId inRect:CGRectMake(inPoint.x-frameSize.width/2, inPoint.y, frameSize.width, frameSize.height)];
	
	glDisable(GL_BLEND);
	
	// restore
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFramebuffer);
	glDeleteFramebuffersOES(1, &fbo);
}


/* 
 * Drawing of the quad 
 */
- (void) drawAtPoint:(CGPoint)point {
	GLfloat	 coordinates[] = {
		0,			0,
		m_fMaxS,	0,
		0,			m_fMaxT,
		m_fMaxS,	m_fMaxT  
	};	
	
	GLfloat		width = (GLfloat)m_unWidth * m_fMaxS,
				height = (GLfloat)m_unHeight * m_fMaxT;
	GLfloat		vertices[] = {	
		-width / 2 + point.x,	-height / 2 + point.y,	0.0,
		width / 2 + point.x,	-height / 2 + point.y,	0.0,
		-width / 2 + point.x,	height / 2 + point.y,	0.0,
		width / 2 + point.x,	height / 2 + point.y,	0.0 
	};
	
	glBindTexture(GL_TEXTURE_2D, m_unName);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void) drawInRect:(CGRect)rect {
	GLfloat	 coordinates[] = {
		0,			0,
		m_fMaxS,	0,
		0,			m_fMaxT,
		m_fMaxS,	m_fMaxT  
	};	
	
	GLfloat	vertices[] = {	rect.origin.x,							rect.origin.y,							0.0,
		rect.origin.x + rect.size.width,		rect.origin.y,							0.0,
		rect.origin.x,							rect.origin.y + rect.size.height,		0.0,
	rect.origin.x + rect.size.width,		rect.origin.y + rect.size.height,		0.0 };
	
	glBindTexture(GL_TEXTURE_2D, m_unName);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void) drawInRect:(CGRect)rect rotation:(float)rotation {
	glPushMatrix();
	
	glTranslatef(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2, 0.0);
	glRotatef(rotation, 0, 0, 1);
	
	[self drawAtPoint:CGPointZero];
	glPopMatrix();
}

@end