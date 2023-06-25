// Copyright (c) 2020 imagetasks


#import "AirSightResizeView.h"



@implementation AirSightResizeView{
    CGFloat circleWidth;
    CGFloat circleHeight;
    NSRect leftTopRect;
    NSRect rightTopRect;
    NSRect bottomLeftRect;
    NSRect bottomRightRect;
    NSRect topRect;
    NSRect leftRect;
    NSRect rightRect;
    NSRect bottomRect;
    NSRect centerRect;
    NSTimer *animationTimer;
    CGFloat currentPhase;
    NSPoint lastDragPoint;
    BOOL resizeOperation;
    BOOL dragOperation;
    NSPoint fromPoint;
    NSTrackingArea* trackingArea;
    NSCursor* cursorTopLeft, *cursorTopRight, *cursorTop, *cursorLeft;
    ASTracking tracking;
    NSRect referenceSelectionRect;
}




- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)cursorUpdate:(NSEvent *)event{
    
}

-(void)awakeFromNib{
    
    if (!_knobColor){
       if (@available(*, macOS 10.14)) {
            _knobColor = [NSColor controlAccentColor];
        } else {
            _knobColor = [NSColor systemBlueColor];
        }
    }
    
    circleWidth = 10;
    circleHeight = 10;
    
    _selectableFrame= NSMakeRect(0, 0, self.superview.frame.size.width, self.superview.frame.size.height);
    
    cursorTopLeft = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"cursor-topleft"] hotSpot:NSMakePoint(8,8)];
    cursorTopRight = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"cursor-topright"] hotSpot:NSMakePoint(8,8)];
    cursorLeft = [NSCursor resizeLeftRightCursor];
    cursorTop = [NSCursor resizeUpDownCursor];
    
    _selectedFrame = NSMakeRect(self.frame.origin.x+circleWidth/2, self.frame.origin.y+circleHeight/2, self.frame.size.width-circleWidth, self.frame.size.height-circleHeight);

}

-(void)setKnobColor:(NSColor *)knobColor{
    if (_knobColor != knobColor){
        _knobColor = knobColor;
        [self setNeedsDisplay:YES];
    }
}


-(void)setSelectableFrame:(NSRect)selectableRect{
    if (!CGRectEqualToRect(selectableRect,_selectableFrame))
        _selectableFrame = selectableRect;
}

-(void)setRespectsProportion:(BOOL)respectsProportion{
    if (respectsProportion != _respectsProportion){
        _respectsProportion = respectsProportion;
        [self setNeedsDisplay:YES];
    }
}

-(void)setSquareSelection:(BOOL)squareSelection{
    if (squareSelection != _squareSelection){
        _squareSelection = squareSelection;
        
        if (self.window && resizeOperation){
            NSPoint mPoint = [self.window convertRectFromScreen:NSMakeRect(NSEvent.mouseLocation.x, NSEvent.mouseLocation.y, 1, 1)].origin;
            [self updateOnResize:mPoint];
        } else {
            CGFloat side;
            if (self.selectedFrame.size.width > self.selectedFrame.size.height){
                side = self.selectedFrame.size.height;
            } else {
                side = self.selectedFrame.size.width;
            }
            [self setSelectedFrame:NSMakeRect(_selectedFrame.origin.x, _selectedFrame.origin.y, side, side)];
        }
    }
}

-(void)setSelectedFrame:(NSRect)selectedFrame{
    if (!CGRectEqualToRect(selectedFrame,_selectedFrame)){
        _selectedFrame = selectedFrame;
        [self setFrame:NSMakeRect(_selectedFrame.origin.x-circleWidth/2, _selectedFrame.origin.y-circleHeight/2, _selectedFrame.size.width+circleWidth, _selectedFrame.size.height+circleHeight)];
    }
}

-(void)setAnimated:(BOOL)a{
    
    if (a != _animated){
        _animated = a;
        if (_animated){
            [self startAnimation];
        } else {
            [self stopAnimation];
        }
    }
}


-(void)updateRecs{
    
    centerRect = NSMakeRect(circleWidth, circleHeight, self.bounds.size.width - circleWidth*2, self.bounds.size.height - circleHeight*2);
    
    bottomLeftRect = NSMakeRect(0, 0, circleWidth, circleHeight);
    leftTopRect = NSMakeRect(0, self.bounds.size.height-circleHeight, circleWidth, circleHeight);
    bottomRightRect = NSMakeRect(self.bounds.size.width-circleWidth, 0, circleWidth, circleHeight);
    rightTopRect = NSMakeRect(self.bounds.size.width-circleWidth, self.bounds.size.height-circleHeight, circleWidth, circleHeight);

    leftRect = NSMakeRect(0, (self.bounds.size.height/2)-circleHeight/2, circleWidth, circleHeight);
    rightRect = NSMakeRect(self.bounds.size.width-circleWidth, (self.bounds.size.height/2)-circleHeight/2, circleWidth, circleHeight);
    bottomRect = NSMakeRect((self.bounds.size.width/2)-circleWidth/2, 0, circleWidth, circleHeight);
    topRect = NSMakeRect((self.bounds.size.width/2)-circleWidth/2, self.bounds.size.height-circleHeight, circleWidth, circleHeight);
}

-(void)updateOnResize: (NSPoint) point{
    double x, y, width, height, pwidth, pheight;
     
    NSPoint newDragLocation = [[self superview] convertPoint:point fromView:nil];
     
     if (tracking == ASLeft || tracking == ASRight) {
         newDragLocation.y = _selectedFrame.origin.y + _selectedFrame.size.height;
     }
     
     if (tracking == ASTop || tracking == ASBottom) {
         newDragLocation.x = _selectedFrame.origin.x;
     }
     
     
     if (newDragLocation.x < _selectableFrame.origin.x) newDragLocation.x = _selectableFrame.origin.x;
     if (newDragLocation.y < _selectableFrame.origin.y) newDragLocation.y = _selectableFrame.origin.y;
     
     if (newDragLocation.x > _selectableFrame.origin.x + _selectableFrame.size.width) newDragLocation.x = _selectableFrame.origin.x + _selectableFrame.size.width;
     
     if (newDragLocation.y > _selectableFrame.origin.y + _selectableFrame.size.height) newDragLocation.y = _selectableFrame.origin.y + _selectableFrame.size.height;
      
     
     
     
     CGRect newSizeRect = CGRectMake(
                                     MIN(fromPoint.x, newDragLocation.x),
                                     MIN(fromPoint.y, newDragLocation.y),
                                     fabs(fromPoint.x - newDragLocation.x),
                                     fabs(fromPoint.y - newDragLocation.y));
     
     x = newSizeRect.origin.x;
     y = newSizeRect.origin.y;
     width = newSizeRect.size.width;
     height = newSizeRect.size.height;
     
     
     pheight = pwidth = 0;
     
     if (_squareSelection){
         if (width > height){
             pwidth = pheight = height;
         } else {
             pheight = pwidth = width;
         }
         
     } else if (_respectsProportion){
         CGFloat scaleW = width / referenceSelectionRect.size.width;
         CGFloat scaleH = height / referenceSelectionRect.size.height;
         
         CGFloat scale = 1;
         
         if (scaleW < scaleH){
             scale = scaleW;
         } else {
             scale = scaleH;
         }
         
         
         pwidth = referenceSelectionRect.size.width * scale;
         pheight = referenceSelectionRect.size.height * scale;
     }
     
     
     if (_squareSelection || _respectsProportion){
         if (fromPoint.y > newDragLocation.y){
             y = y - (pheight - height);
         }
         if (fromPoint.x > newDragLocation.x){
             x = x - (pwidth - width);
         }
         
         width = pwidth;
         height = pheight;
     }
     
     NSRect newRect = NSMakeRect(x, y, width, height);
     
     
     if([self.delegate respondsToSelector:@selector(selectionWillChange:resizeView:)]) {
         newRect = [self.delegate selectionWillChange:newRect resizeView:self];
     } else if([self.delegate respondsToSelector:@selector(selectionWillChange:)]) {
         newRect = [self.delegate selectionWillChange:newRect];
     }
     
     [self selectionChanged: newRect];
     
    resizeOperation = YES;
}

-(void)updateOnDrag: (NSPoint) point{
    NSPoint newDragLocation = [[self superview] convertPoint:point fromView:nil];

    NSPoint thisOrigin = _selectedFrame.origin;
    
    thisOrigin.x = newDragLocation.x - lastDragPoint.x;
    thisOrigin.y = newDragLocation.y - lastDragPoint.y;

    NSRect newRect = NSMakeRect(thisOrigin.x, thisOrigin.y, _selectedFrame.size.width, _selectedFrame.size.height);
            
    if (newRect.origin.x < _selectableFrame.origin.x) {
        newRect.origin.x = _selectableFrame.origin.x;
    }
        
    if (newRect.origin.x + newRect.size.width > _selectableFrame.origin.x + _selectableFrame.size.width) {
        newRect.origin.x = _selectableFrame.origin.x + _selectableFrame.size.width - newRect.size.width;
    }
    
    if (newRect.origin.y < _selectableFrame.origin.y) {
        newRect.origin.y = _selectableFrame.origin.y;
    } else if (newRect.origin.y + newRect.size.height > _selectableFrame.origin.y + _selectableFrame.size.height) {
        newRect.origin.y = _selectableFrame.origin.y + _selectableFrame.size.height - newRect.size.height;
    }
        

    if([self.delegate respondsToSelector:@selector(selectionWillChange:resizeView:)]) {
        newRect = [self.delegate selectionWillChange:newRect resizeView:self];
    } else if([self.delegate respondsToSelector:@selector(selectionWillChange:)]) {
        newRect = [self.delegate selectionWillChange:newRect];
    }
    
    if([self.delegate respondsToSelector:@selector(selectionWillMove:resizeView:)]) {
        newRect = [self.delegate selectionWillMove:newRect resizeView:self];
    } else if([self.delegate respondsToSelector:@selector(selectionWillMove:)]) {
        newRect = [self.delegate selectionWillMove:newRect];
    }
    
            
    [self selectionChanged: newRect];
         
         
    //lastDragPoint = newDragLocation;
}


-(void)setFrame:(NSRect)frame{
    [self updateTrackingAreas];
    [super setFrame:frame];
    
}

-(void)updateTrackingAreas {
    [self updateRecs];
    if (!resizeOperation) {
        [super updateTrackingAreas];
        
        [self removeTrackingArea:trackingArea];

        trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingAssumeInside | NSTrackingCursorUpdate owner:self userInfo:nil];
            
            
        [self addTrackingArea:trackingArea];

    }
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect frame = NSMakeRect(self.bounds.origin.x+circleWidth/2, self.bounds.origin.y+circleHeight/2, self.bounds.size.width-circleWidth, self.bounds.size.height-circleHeight);
    
    NSBezierPath* rectanglePath = [NSBezierPath bezierPathWithRect: NSMakeRect(NSMinX(frame), NSMinY(frame), NSWidth(frame), NSHeight(frame))];
    
    //dashed rect
    [rectanglePath setLineWidth: 1];
    CGFloat dash_pattern[]={5.,5.};
    NSInteger count = sizeof(dash_pattern)/sizeof(dash_pattern[0]);
    [rectanglePath setLineDash:(CGFloat*)dash_pattern count:count phase:currentPhase];
    [[[NSColor blackColor] colorWithAlphaComponent:0.6] set];
    [rectanglePath stroke];
    [rectanglePath setLineDash:(CGFloat*)dash_pattern count:count phase:currentPhase+5];
    
    [[[NSColor whiteColor] colorWithAlphaComponent:0.8] set];
    [rectanglePath stroke];

    //draw knobs
    NSBezierPath* circlePaths = [NSBezierPath bezierPath];
    
    if (self.frame.size.width >= circleWidth*2 && self.frame.size.height >= circleHeight*2){
        [circlePaths appendBezierPathWithOvalInRect: bottomLeftRect];
        [circlePaths appendBezierPathWithOvalInRect: leftTopRect];
        [circlePaths appendBezierPathWithOvalInRect: bottomRightRect];
        [circlePaths appendBezierPathWithOvalInRect: rightTopRect];
    }

    if (!_respectsProportion && !_squareSelection){
        if (self.frame.size.height >= circleHeight*3){
            [circlePaths appendBezierPathWithOvalInRect: leftRect];
            [circlePaths appendBezierPathWithOvalInRect: rightRect];
        }
        if (self.frame.size.width >= circleWidth*3){
            [circlePaths appendBezierPathWithOvalInRect: bottomRect];
            [circlePaths appendBezierPathWithOvalInRect: topRect];
        }
    }
    
    if (self.frame.size.width >= circleWidth*2 && self.frame.size.height >= circleHeight*2){
        [_knobColor set];
        [circlePaths fill];

        [circlePaths setClip];
        
        [[NSColor whiteColor]set];
        
        [circlePaths setLineWidth: 2];
        [circlePaths stroke];
    }
}


-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (void)mouseDown:(NSEvent *) theEvent {

    [self.superview mouseDown:theEvent];
    
    [self interactionDidStarted];
    
    [self stopAnimation];
    
    referenceSelectionRect = _selectedFrame;
    
    lastDragPoint = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
        
    lastDragPoint.x -= _selectedFrame.origin.x;
    lastDragPoint.y -= _selectedFrame.origin.y;
        
    if (tracking > 0 && tracking != ASCenter){
        resizeOperation = YES;
        if (tracking == ASTopLeft || tracking == ASLeft || tracking == ASTop) {
            fromPoint = NSMakePoint(_selectedFrame.origin.x + _selectedFrame.size.width, _selectedFrame.origin.y);
        } else if (tracking == ASTopRight || tracking == ASRight) {
            fromPoint = NSMakePoint(_selectedFrame.origin.x, _selectedFrame.origin.y);
        } else if (tracking == ASBottomLeft || tracking == ASBottom) {
        fromPoint = NSMakePoint(_selectedFrame.origin.x + _selectedFrame.size.width, _selectedFrame.origin.y + _selectedFrame.size.height);
        } else if (tracking == ASBottomRight) {
            fromPoint = NSMakePoint(_selectedFrame.origin.x,_selectedFrame.origin.y + _selectedFrame.size.height);
        }
    } else {
        if (tracking == ASCenter){
            dragOperation = YES;
            [[NSCursor closedHandCursor] set];
        } else {
            dragOperation = NO;
        }
        resizeOperation = NO;
    }
            

    if (NSPointInRect(lastDragPoint, centerRect)){
        if (dragOperation){
            [[NSCursor closedHandCursor] set];
        } else {
            [[NSCursor openHandCursor] set];
        }
    } else if (NSPointInRect(lastDragPoint, leftTopRect)){
        [cursorTopLeft set];
    } else if (NSPointInRect(lastDragPoint, topRect)&&!_respectsProportion && !_squareSelection){
        [cursorTop set];
    } else if (NSPointInRect(lastDragPoint, rightTopRect)){
        [cursorTopRight set];
    } else if (NSPointInRect(lastDragPoint, leftRect)&&!_respectsProportion && !_squareSelection){
        [cursorLeft set];
    } else if (NSPointInRect(lastDragPoint, rightRect)&&!_respectsProportion && !_squareSelection){
        [cursorLeft set];
    } else if (NSPointInRect(lastDragPoint, bottomLeftRect)){
        [cursorTopRight set];
    } else if (NSPointInRect(lastDragPoint, bottomRect)&&!_respectsProportion && !_squareSelection){
        [cursorTop set];
    } else if (NSPointInRect(lastDragPoint, bottomRightRect)){
        [cursorTopLeft set];
    } else {
        [[NSCursor arrowCursor] set];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    
    //[super mouseDragged:theEvent];
    
    if (!resizeOperation) {
        
        [self updateOnDrag:[theEvent locationInWindow]];
    } else {
        [self updateOnResize:[theEvent locationInWindow]];
    }
    
    
    
}

-(void)selectionChanged:(NSRect) newSelection{
    self.selectedFrame = NSMakeRect(newSelection.origin.x, newSelection.origin.y, newSelection.size.width, newSelection.size.height);
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(selectionDidChanged:resizeView:)]) {
            [self.delegate selectionDidChanged:self.selectedFrame resizeView:self];
        } else if([self.delegate respondsToSelector:@selector(selectionDidChanged:)]) {
            [self.delegate selectionDidChanged:self.selectedFrame];
        }
    }
}

- (void) interactionDidStarted{
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(interactionDidStarted:)]) {
            [self.delegate interactionDidStarted:self];
        } else if([self.delegate respondsToSelector:@selector(interactionDidStarted)]) {
            [self.delegate interactionDidStarted];
        }
    }
}

- (void) interactionDidEnded{
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(interactionDidEnded:)]) {
            [self.delegate interactionDidEnded:self];
        } else if([self.delegate respondsToSelector:@selector(interactionDidEnded)]) {
            [self.delegate interactionDidEnded];
        }
    }
}

-(void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
    
    [self interactionDidEnded];
    
    if (self.animated)[self startAnimation];
    
    resizeOperation = NO;
    dragOperation = NO;
    
    NSPoint p = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
    
    p.x -= self.frame.origin.x;
    p.y -= self.frame.origin.y;
    
    if (NSPointInRect(p, centerRect)){
        [[NSCursor openHandCursor] set];
    }
    
    [self updateTrackingAreas];
    
}

-(void)mouseMoved:(NSEvent *)theEvent{
    [super mouseMoved:theEvent];
    
    NSPoint p = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
    
    p.x -= self.frame.origin.x;
    p.y -= self.frame.origin.y;
    
    resizeOperation = NO;
    
    if (NSPointInRect(p, centerRect)){
        if (dragOperation){
            [[NSCursor closedHandCursor] set];
        } else {
            [[NSCursor openHandCursor] set];
        }
        tracking = ASCenter;
    } else if (NSPointInRect(p, leftTopRect)){
        [cursorTopLeft set];
        tracking = ASTopLeft;
    } else if (NSPointInRect(p, topRect)&&!_respectsProportion && !_squareSelection){
        [cursorTop set];
        tracking = ASTop;
    } else if (NSPointInRect(p, rightTopRect)){
        [cursorTopRight set];
        tracking = ASTopRight;
    } else if (NSPointInRect(p, leftRect)&&!_respectsProportion && !_squareSelection){
        [cursorLeft set];
        tracking = ASLeft;
    } else if (NSPointInRect(p, rightRect)&&!_respectsProportion && !_squareSelection){
        [cursorLeft set];
        tracking = ASRight;
    } else if (NSPointInRect(p, bottomLeftRect)){
        [cursorTopRight set];
        tracking = ASBottomLeft;
    } else if (NSPointInRect(p, bottomRect)&&!_respectsProportion && !_squareSelection){
        [cursorTop set];
        tracking = ASBottom;
    } else if (NSPointInRect(p, bottomRightRect)){
        [cursorTopLeft set];
        tracking = ASBottomRight;
    } else {
        tracking = ASOut;
        [[NSCursor arrowCursor] set];
    }
    
}



-(void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    
}

-(void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    
    [[NSCursor arrowCursor] set];
}

-(void)stopAnimation{
    if(animationTimer){
        if ([animationTimer isValid]) {
            [animationTimer invalidate];
        }
        animationTimer = nil;
    }
}

-(void)startAnimation{

    if (currentPhase == 1){
        currentPhase = 10;
    } else {
        currentPhase = currentPhase - 1;
    }
    
    [self setNeedsDisplay:YES];
    
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f
      target:self
      selector:@selector(startAnimation)
                                   userInfo:nil
                                    repeats:NO];
}


@end


