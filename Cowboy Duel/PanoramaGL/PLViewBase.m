/*
 * PanoramaGL library
 * Version 0.1
 * Copyright (c) 2010 Javier Baez <javbaezga@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "PLViewBaseProtected.h"
#import "PLRenderer.h"
#import "PLLog.h"
#import "OponentCoordinateView.h"
#import "GBDeviceInfo_iOS.h"

#define Magnitude(X, Y, Z) (sqrt((X)*(X) + (Y)*(Y) + (Z)*(Z)))

#define ARC4RANDOM_MAX 0x100000000

#define DEGREES_TO_RADIANS (M_PI/180.0)
#define WGS84_A    (6378137.0)                // WGS 84 semi-major axis constant in meters
#define WGS84_E (8.1819190842622e-2)    // WGS 84 eccentricity

#define REFRESH_TIME (4.0 / 60.0)

typedef float mat4f_t[16];    // 4x4 matrix in column major order
typedef float vec4f_t[4];    // 4D vector

UIAccelerometer *accelerometer;


static UIAccelerationValue rollingX = 0.0;
static UIAccelerationValue rollingY = 0.0;
static UIAccelerationValue rollingZ = 0.0;

@interface PLViewBase()
{
    mat4f_t projectionTransform;
    mat4f_t cameraTransform;
    vec4f_t *oponentCoordinates;
    NSArray *oponentCoordinateViews;
    NSArray *arrTest;
    CLLocation *location;
    float startX;
    
    BOOL isSensorialRotationBlocking;
    
    CGPoint ptDirectionJoyStick;
    CMRotationMatrix mtRotationJoyStick;
    NSTimer *timerJoyStick;
}
-(void)doGyroUpdate;
-(void)doSimulatedGyroUpdate;

@end

@implementation PLViewBase

@synthesize panorama = scene;

@synthesize animationInterval;
@synthesize animationFrameInterval;

@synthesize isBlocked;

@synthesize isAccelerometerEnabled, isAccelerometerLeftRightEnabled, isAccelerometerUpDownEnabled;
@synthesize accelerometerSensitivity;
@synthesize motionTrackingInterval;

@synthesize startPoint, endPoint;
@synthesize startFovPoint, endFovPoint;

@synthesize isScrollingEnabled;
@synthesize minDistanceToEnableScrolling;

@synthesize isInertiaEnabled;
@synthesize inertiaInterval;

@synthesize isResetEnabled, isShakeResetEnabled;
@synthesize numberOfTouchesForReset;

@synthesize isValidForFov;

@synthesize shakeThreshold;

@synthesize isDisplayLinkSupported;
@synthesize isAnimating;

@synthesize isSensorialRotationRunning;

@synthesize delegate;

@synthesize isValidForTransition;

@synthesize touchStatus;

@synthesize isPointerVisible;
@synthesize menView;
@synthesize vJoyStick;

#pragma mark -
#pragma mark init methods

-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
        [self initializeValues];
    return self;
}

-(id)initWithCoder:(NSCoder*)coder
{
    if(self = [super initWithCoder:coder])
        [self initializeValues];
    return self;
}

-(void)initializeValues
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    scene = nil;
    renderer = nil;
    
    displayLink = nil;
    displayLinkSupported = ([[[UIDevice currentDevice] systemVersion] compare:@"3.1" options:NSNumericSearch] != NSOrderedAscending);
    
    animationInterval = kDefaultAnimationTimerInterval;
    animationFrameInterval = kDefaultAnimationFrameInterval;
    isDisplayLinkSupported = YES;
    
    isAccelerometerEnabled = NO;
    isAccelerometerLeftRightEnabled = YES;
    isAccelerometerUpDownEnabled = NO;
    accelerometerSensitivity = kDefaultAccelerometerSensitivity;
    motionTrackingInterval = kDefaultAccelerometerInterval;
    
    isScrollingEnabled = NO;
    minDistanceToEnableScrolling = kDefaultMinDistanceToEnableScrolling;
    
    isInertiaEnabled = YES;
    inertiaInterval = kDefaultInertiaInterval;
    
    isValidForTouch = NO;
    isSensorialRotationBlocking = NO;
    
    isResetEnabled = isShakeResetEnabled = YES;
    numberOfTouchesForReset = kDefaultNumberOfTouchesForReset;
    
    shakeData = PLShakeDataMake(0);
    shakeThreshold = kShakeThreshold;
    
    touchStatus = PLTouchStatusNone;
    
    isPointerVisible = NO;
    
    isValidForTransition = NO;
    isValidForTransitionString = @"";
    
    [self reset];
    
    createProjectionMatrix(projectionTransform, 60.0f*DEGREES_TO_RADIANS, self.bounds.size.width*1.0f / self.bounds.size.height, 0.25f, 1000.0f);
    location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
}

#pragma mark -
#pragma mark reset methods

-(void)reset
{
    [self resetWithoutAlpha];
    [self resetSceneAlpha];
}

-(void)resetWithoutAlpha
{
    [self stopAnimationInternally];
    isValidForFov = isValidForScrolling = isScrolling = isValidForInertia = NO;
    startPoint = endPoint = CGPointMake(0.0f, 0.0f);
    startFovPoint = endFovPoint = CGPointMake(0.0f, 0.0f);
    fovDistance = 0.0f;
    if(scene && scene.currentCamera)
        [scene.currentCamera reset];
    if([self getIsValidForTransition])
    {
        if(currentTransition)
            [currentTransition stop];
        else
            [self setIsValidForTransition:NO];
    }
}

-(void)resetSceneAlpha
{
    if(scene)
        [scene resetAlpha];
}

#pragma mark - methods for oponents Views

- (void)setOponentCoordinates:(NSArray *)pois
{
    //    for (OponentCoordinateView *poi in [placesOfInterest objectEnumerator]) {
    //        [poi.view removeFromSuperview];
    //    }
    
    oponentCoordinateViews = pois;
    arrTest = oponentCoordinateViews;
    pois = nil;
    [self updateOponentCoordinates];
}

- (void)updateOponentCoordinates
{
    
    if (oponentCoordinates != NULL) {
        free(oponentCoordinates);
    }
    oponentCoordinates = (vec4f_t *)malloc(sizeof(vec4f_t)*oponentCoordinateViews.count);
    
    int i = 0;
    
    double myX, myY, myZ;
    latLonToEcef(location.coordinate.latitude, location.coordinate.longitude, 0.0, &myX, &myY, &myZ);
    
    // Array of NSData instances, each of which contains a struct with the distance to a POI and the
    // POI's index into placesOfInterest
    // Will be used to ensure proper Z-ordering of UIViews
    typedef struct {
        float distance;
        int index;
    } DistanceAndIndex;
    NSMutableArray *orderedDistances = [NSMutableArray arrayWithCapacity:oponentCoordinateViews.count];
    
    // Compute the world coordinates of each place-of-interest
    for (OponentCoordinateView *poi in [oponentCoordinateViews objectEnumerator]) {
        double poiX, poiY, poiZ, e, n, u;
        
        latLonToEcef(poi.location.coordinate.latitude, poi.location.coordinate.longitude, 0.0, &poiX, &poiY, &poiZ);
        ecefToEnu(location.coordinate.latitude, location.coordinate.longitude, myX, myY, myZ, poiX, poiY, poiZ, &e, &n, &u);
        
        oponentCoordinates[i][0] = (float)n;
        oponentCoordinates[i][1]= -(float)e;
        oponentCoordinates[i][2] = 0.0f;
        oponentCoordinates[i][3] = 1.0f;
        
        // Add struct containing distance and index to orderedDistances
        DistanceAndIndex distanceAndIndex;
        distanceAndIndex.distance = sqrtf(n*n + e*e);
        distanceAndIndex.index = i;
        [orderedDistances insertObject:[NSData dataWithBytes:&distanceAndIndex length:sizeof(distanceAndIndex)] atIndex:i++];
    }
    //
    // Sort orderedDistances in ascending order based on distance from the user
    [orderedDistances sortUsingComparator:(NSComparator)^(NSData *a, NSData *b) {
        const DistanceAndIndex *aData = (const DistanceAndIndex *)a.bytes;
        const DistanceAndIndex *bData = (const DistanceAndIndex *)b.bytes;
        if (aData->distance < bData->distance) {
            return NSOrderedAscending;
        } else if (aData->distance > bData->distance) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

// References to ECEF and ECEF to ENU conversion may be found on the web.

// Converts latitude, longitude to ECEF coordinate system
void latLonToEcef(double lat, double lon, double alt, double *x, double *y, double *z)
{
    double clat = cos(lat * DEGREES_TO_RADIANS);
    double slat = sin(lat * DEGREES_TO_RADIANS);
    double clon = cos(lon * DEGREES_TO_RADIANS);
    double slon = sin(lon * DEGREES_TO_RADIANS);
    
    double N = WGS84_A / sqrt(1.0 - WGS84_E * WGS84_E * slat * slat);
    
    *x = (N + alt) * clat * clon;
    *y = (N + alt) * clat * slon;
    *z = (N * (1.0 - WGS84_E * WGS84_E) + alt) * slat;
}

// Coverts ECEF to ENU coordinates centered at given lat, lon
void ecefToEnu(double lat, double lon, double x, double y, double z, double xr, double yr, double zr, double *e, double *n, double *u)
{
    double clat = cos(lat * DEGREES_TO_RADIANS);
    double slat = sin(lat * DEGREES_TO_RADIANS);
    double clon = cos(lon * DEGREES_TO_RADIANS);
    double slon = sin(lon * DEGREES_TO_RADIANS);
    double dx = x - xr;
    double dy = y - yr;
    double dz = z - zr;
    
    *e = -slon*dx  + clon*dy;
    *n = -slat*clon*dx - slat*slon*dy + clat*dz;
    *u = clat*clon*dx + clat*slon*dy + slat*dz;
}


#pragma mark -
#pragma mark property method

-(void)setPanorama:(NSObject<PLIPanorama> *)panorama
{
    if(panorama)
    {
        @synchronized(self)
        {
            BOOL tempIsAnimating = isAnimating;
            if(tempIsAnimating)
                [self stopAnimation];
            [self stopSensorialRotation];
            if(renderer)
                [renderer stop];
            if(scene)
            {
                [scene release];
                scene = nil;
            }
            scene = [panorama retain];
            if(renderer)
            {
                renderer.scene = scene;
                [renderer start];
            }
            else
            {
                renderer = [[PLRenderer alloc] initWithView:self scene:scene];
                [renderer resizeFromLayer];
            }
            if(tempIsAnimating)
                [self startAnimation];
            else
                [self drawViewInternallyNTimes:2];
        }
    }
}

-(NSObject<PLIScene> *)scene
{
    return scene;
}

-(NSObject<PLIRenderer> *)renderer
{
    return renderer;
}

-(PLCamera *)getCamera
{
    if(scene)
        return scene.currentCamera;
    return nil;
}

-(void)setSceneAlpha:(float)value
{
    if(scene)
        scene.alpha = value;
}

-(BOOL)getIsValidForTransition
{
    return isValidForTransition;
}

-(void)setIsValidForTransition:(BOOL)value
{
    @synchronized(isValidForTransitionString)
    {
        isValidForTransition = value;
    }
}

-(void)setNumberOfTouchesForReset:(uint8_t)value
{
    if(value > 2)
        numberOfTouchesForReset = value;
}

-(BOOL)getIsDisplayLinkSupported
{
    return displayLinkSupported;
}

-(BOOL)isMultipleTouchEnabled
{
    return YES;
}

-(UIInterfaceOrientation)currentDeviceOrientation
{
    return [UIApplication sharedApplication].statusBarOrientation;
}

-(NSTimer *)animationTimer
{
    return animationTimer;
}

-(void)setAnimationTimer:(NSTimer *)newTimer
{
    if(animationTimer)
    {
        [animationTimer invalidate];
        animationTimer = nil;
    }
    animationTimer = newTimer;
}

-(id)displayLink
{
    return displayLink;
}

-(void)setDisplayLink:(id)value
{
    if(displayLink)
    {
        [displayLink invalidate];
        displayLink = nil;
    }
    displayLink = value;
}

-(void)setAnimationInterval:(NSTimeInterval)interval
{
    animationInterval = interval;
}

-(void)setAnimationFrameInterval:(NSUInteger)value
{
    if(value >= 1)
    {
        animationFrameInterval = value;
        if(isDisplayLinkSupported && displayLinkSupported)
            animationInterval = (kDefaultAnimationTimerIntervalByFrame) * value;
    }
}

-(BOOL)setAccelerometerDelegate:(id <UIAccelerometerDelegate>)accelerometerDelegate
{
    return NO;
    UIAccelerometer* accelerometer = [UIAccelerometer sharedAccelerometer];
    if(accelerometer)
    {
        accelerometer.delegate = accelerometerDelegate;
        accelerometer.updateInterval = motionTrackingInterval;
        return YES;
    }
    return NO;
}

-(void)setMotionTrackingInterval:(NSTimeInterval)value
{
    motionTrackingInterval = value;
    [self activateMotionTracking];
}

-(void)setAccelerometerSensitivity:(float)value
{
    accelerometerSensitivity = [PLMath valueInRange:value range:PLRangeMake(kAccelerometerSensitivityMinValue, kAccelerometerSensitivityMaxValue)];
}

+(Class)layerClass
{
    return [CAEAGLLayer class];
}

#pragma mark -
#pragma mark draw methods

-(void)drawView
{
    if(isScrolling && delegate && [delegate respondsToSelector:@selector(view:shouldScroll:endPoint:)] && ![delegate view:self shouldScroll:startPoint endPoint:endPoint])
        return;
    [self drawViewInternally];
    if(isScrolling && delegate && [delegate respondsToSelector:@selector(view:didScroll:endPoint:)])
        [delegate view:self didScroll:startPoint endPoint:endPoint];
}

-(void)drawViewNTimes:(NSUInteger)times
{
    for(int i = 0; i < times; i++)
        [self drawView];
}

-(void)drawViewInternally
{
    if(scene && !isValidForFov && !isSensorialRotationRunning)
    {
        PLCamera *camera = scene.currentCamera;
        [camera rotateWithStartPoint:startPoint endPoint:endPoint];
        if(delegate && [delegate respondsToSelector:@selector(view:didRotateCamera:rotation:)])
            [delegate view:self didRotateCamera:camera rotation:[camera getAbsoluteRotation]];
    }
    if(renderer)
        [renderer render];
}

-(void)drawViewInternallyNTimes:(NSUInteger)times
{
    for(int i = 0; i < times; i++)
        [self drawViewInternally];
}

#pragma mark -
#pragma mark render buffer methods

-(void)regenerateRenderBuffer
{
    if(renderer)
        [renderer resizeFromLayer];
}

#pragma mark -
#pragma mark layout methods

-(void)layoutSubviews
{
    if(renderer)
        [renderer resizeFromLayer];
    if(!isMotionTrackingActivated)
    {
        [self activateMotionTracking];
        isMotionTrackingActivated = YES;
    }
    [self drawViewInternallyNTimes:2];
    [super layoutSubviews];
}

#pragma mark -
#pragma mark animation methods

-(void)startAnimation
{
    if(isAnimating)
        return;
    
    if(isDisplayLinkSupported && displayLinkSupported)
    {
        self.displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView)];
        [displayLink setFrameInterval:animationFrameInterval];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
    
    if(isScrollingEnabled)
        isValidForScrolling = YES;
    [self stopInertia];
    
    isAnimating = YES;
}

-(void)stopAnimation
{
    if(isAnimating)
    {
        if(isDisplayLinkSupported && displayLinkSupported)
            self.displayLink = nil;
        else
            self.animationTimer = nil;
        [self stopOnlyAnimation];
        isAnimating = NO;
    }
    [self stopInertia];
}

-(void)stopOnlyAnimation
{
    if(isScrollingEnabled)
    {
        isValidForScrolling = NO;
        if(!isInertiaEnabled)
            isValidForTouch = NO;
    }
    else
        isValidForTouch = NO;
}

-(void)stopAnimationInternally
{
    //[self stopInertia];
    //[self stopOnlyAnimation];
    [self stopAnimation];
}

#pragma mark -
#pragma mark fov methods

-(BOOL)calculateFov:(NSSet *)touches
{
    if([touches count] == 2)
    {
        startFovPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
        endFovPoint = [[[touches allObjects] objectAtIndex:1] locationInView:self];
        
        fovCounter++;
        if(fovCounter < kDefaultFovMinCounter)
        {
            fovDistance = [PLMath distanceBetweenPoints:startFovPoint :endFovPoint];
            return NO;
        }
        
        float distance = [PLMath distanceBetweenPoints:startFovPoint :endFovPoint];
        
        if(ABS(distance - fovDistance) < scene.currentCamera.minDistanceToEnableFov)
            return NO;
        
        distance = ABS(fovDistance) <= distance ? distance : -distance;
        BOOL isZoomIn = (distance >= 0);
        BOOL isNotCancelable = YES;
        
        if(delegate && [delegate respondsToSelector:@selector(view:shouldRunZooming:isZoomIn:isZoomOut:)])
            isNotCancelable = [delegate view:self shouldRunZooming:distance isZoomIn:isZoomIn isZoomOut:!isZoomIn];
        
        if(isNotCancelable)
        {
            fovDistance = distance;
            [scene.currentCamera addFovWithDistance:fovDistance];
            if(delegate && [delegate respondsToSelector:@selector(view:didRunZooming:isZoomIn:isZoomOut:)])
                [delegate view:self didRunZooming:fovDistance isZoomIn:isZoomIn isZoomOut:!isZoomIn];
            return YES;
        }
    }
    return NO;
}

#pragma mark -
#pragma mark action methods

-(BOOL)executeDefaultAction:(NSSet *)touches eventType:(PLTouchEventType)type
{
    NSUInteger touchCount = [touches count];
    if(touchCount >= numberOfTouchesForReset)
    {
        if(!isSensorialRotationRunning)
            [self executeResetAction:touches];
    }
    else if(touchCount == 2)
    {
        BOOL isNotCancelable = YES;
        if(delegate && [delegate respondsToSelector:@selector(viewShouldBeginZooming:)])
            isNotCancelable = [delegate viewShouldBeginZooming:self];
        if(isNotCancelable)
        {
            if(type == PLTouchEventTypeMoved)
                [self calculateFov:touches];
            else if(type == PLTouchEventTypeBegan)
            {
                startFovPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
                endFovPoint = [[[touches allObjects] objectAtIndex:1] locationInView:self];
                if(delegate && [delegate respondsToSelector:@selector(view:didBeginZooming:endPoint:)])
                    [delegate view:self didBeginZooming:startFovPoint endPoint:endFovPoint];
            }
            if(!isValidForFov)
            {
                [self startAnimation];
                isValidForFov = YES;
            }
        }
    }
    else if(touchCount == 1)
    {
        if(type == PLTouchEventTypeMoved)
        {
            if(isValidForFov || (startPoint.x == 0 && endPoint.y == 0))
                startPoint = [self getLocationOfFirstTouch:touches];
            if(!displayLink && !animationTimer)
                [self startAnimation];
        }
        else if(type == PLTouchEventTypeEnded && startPoint.x == 0 && endPoint.y == 0)
            startPoint = [self getLocationOfFirstTouch:touches];
        isValidForFov = NO;
        return NO;
    }
    return YES;
}

-(BOOL)executeResetAction:(NSSet *)touches
{
    if(isResetEnabled && [touches count] >= numberOfTouchesForReset)
    {
        BOOL isNotCancelable = YES;
        if(delegate && [delegate respondsToSelector:@selector(viewShouldReset:)])
            isNotCancelable = [delegate viewShouldReset:self];
        if(isNotCancelable)
        {
            [self stopAnimationInternally];
            [self reset];
            [self drawViewInternally];
            if(delegate && [delegate respondsToSelector:@selector(viewDidReset:)])
                [delegate viewDidReset:self];
            return YES;
        }
    }
    return NO;
}

#pragma mark -
#pragma mark touch methods

-(BOOL)isTouchInView:(NSSet *)touches
{
    for(UITouch *touch in touches)
        if(touch.view != self)
            return NO;
    return YES;
}

-(CGPoint)getLocationOfFirstTouch:(NSSet *)touches
{
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    return [touch locationInView:touch.view];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(delegate && [delegate respondsToSelector:@selector(view:touchesBegan:withEvent:)])
        [delegate view:self touchesBegan:touches withEvent:event];
    
    if(isBlocked || !scene || [self getIsValidForTransition])
        return;
    
    NSSet *eventTouches = [event allTouches];
    
    if(![self isTouchInView:eventTouches])
        return;
    
    if(delegate && [delegate respondsToSelector:@selector(view:shouldBeginTouching:withEvent:)] && ![delegate view:self shouldBeginTouching:eventTouches withEvent:event])
        return;
    
    switch([[eventTouches anyObject] tapCount])
    {
        case 1:
            touchStatus = PLTouchStatusSingleTapCount;
            if(isValidForScrolling)
            {
                [self stopAnimationInternally];
                startPoint = endPoint;
                isScrolling = NO;
                if(delegate && [delegate respondsToSelector:@selector(view:didEndScrolling:endPoint:)])
                    [delegate view:self didEndScrolling:startPoint endPoint:endPoint];
            }
            else if(inertiaTimer)
            {
                [self stopAnimationInternally];
                startPoint = endPoint;
                if(delegate && [delegate respondsToSelector:@selector(view:didEndInertia:endPoint:)])
                    [delegate view:self didEndInertia:startPoint endPoint:endPoint];
            }
            break;
        case 2:
            touchStatus = PLTouchStatusDoubleTapCount;
            break;
    }
    
    [self stopAnimationInternally];
    
    isValidForTouch = YES;
    touchStatus = PLTouchStatusBegan;
    fovCounter = 0;
    
    if(![self executeDefaultAction:eventTouches eventType:(PLTouchEventType)PLTouchStatusBegan])
    {
        startPoint = endPoint = [self getLocationOfFirstTouch:eventTouches];
        if([[eventTouches anyObject] tapCount] == 1)
        {
            touchStatus = PLTouchStatusFirstSingleTapCount;
            if(renderer)
                [renderer render];
            touchStatus = PLTouchStatusSingleTapCount;
        }
        [self startAnimation];
    }
    else if(isSensorialRotationRunning)
        [self startAnimation];
    
    if(delegate && [delegate respondsToSelector:@selector(view:didBeginTouching:withEvent:)])
        [delegate view:self didBeginTouching:eventTouches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(delegate && [delegate respondsToSelector:@selector(view:touchesMoved:withEvent:)])
        [delegate view:self touchesMoved:touches withEvent:event];
    
    if(isBlocked || !scene || [self getIsValidForTransition])
        return;
    
    NSSet *eventTouches = [event allTouches];
    
    if(![self isTouchInView:eventTouches])
        return;
    
    touchStatus = PLTouchStatusMoved;
    
    if(delegate && [delegate respondsToSelector:@selector(view:shouldTouch:withEvent:)] && ![delegate view:self shouldTouch:eventTouches withEvent:event])
        return;
    
    if(![self executeDefaultAction:eventTouches eventType:PLTouchEventTypeMoved])
        endPoint = [self getLocationOfFirstTouch:eventTouches];
    
    if(delegate && [delegate respondsToSelector:@selector(view:didTouch:withEvent:)])
        [delegate view:self didTouch:eventTouches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(delegate && [delegate respondsToSelector:@selector(view:touchesEnded:withEvent:)])
        [delegate view:self touchesEnded:touches withEvent:event];
    
    if(isBlocked || !scene || [self getIsValidForTransition])
        return;
    
    NSSet *eventTouches = [event allTouches];
    
    if(![self isTouchInView:eventTouches])
        return;
    
    touchStatus = PLTouchStatusEnded;
    
    if(delegate && [delegate respondsToSelector:@selector(view:shouldEndTouching:withEvent:)] && ![delegate view:self shouldEndTouching:eventTouches withEvent:event])
        return;
    
    if(isValidForFov)
    {
        if([eventTouches count] == [touches count])
        {
            startPoint = endPoint = CGPointMake(0.0f, 0.0f);
            isValidForFov = isValidForTouch = NO;
            if(!isSensorialRotationRunning)
                [self stopAnimationInternally];
        }
    }
    else
    {
        if(![self executeDefaultAction:eventTouches eventType:PLTouchEventTypeEnded])
        {
            endPoint = [self getLocationOfFirstTouch:eventTouches];
            BOOL isNotCancelable = YES;
            
            if(isScrollingEnabled && delegate && [delegate respondsToSelector:@selector(view:shouldBeingScrolling:endPoint:)])
                isNotCancelable = [delegate view:self shouldBeingScrolling:startPoint endPoint:endPoint];
            
            if(isScrollingEnabled && isNotCancelable)
            {
                BOOL isValidForMove = ([PLMath distanceBetweenPoints:startPoint :endPoint] <= minDistanceToEnableScrolling);
                if(isInertiaEnabled)
                {
                    [self stopOnlyAnimation];
                    if(isValidForMove)
                        isValidForTouch = NO;
                    else
                    {
                        isNotCancelable = NO;
                        if(delegate && [delegate respondsToSelector:@selector(view:shouldBeginInertia:endPoint:)])
                            isNotCancelable = [delegate view:self shouldBeginInertia:startPoint endPoint:endPoint];
                        if(isNotCancelable)
                            [self startInertia];
                    }
                }
                else
                {
                    if(isValidForMove)
                        [self stopOnlyAnimation];
                    else
                    {
                        isScrolling = YES;
                        if(delegate && [delegate respondsToSelector:@selector(view:didBeginScrolling:endPoint:)])
                            [delegate view:self didBeginScrolling:startPoint endPoint:endPoint];
                    }
                }
            }
            else
            {
                startPoint = endPoint;
                [self stopOnlyAnimation];
                if(delegate && [delegate respondsToSelector:@selector(view:didEndMoving:endPoint:)])
                    [delegate view:self didEndMoving:startPoint endPoint:endPoint];
            }
        }
    }
    
    if(delegate && [delegate respondsToSelector:@selector(view:didEndTouching:withEvent:)])
        [delegate view:self didEndTouching:eventTouches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self stopAnimationInternally];
    isValidForFov = isValidForTouch = NO;
}

#pragma mark -
#pragma mark inertia methods

-(void)startInertia
{
    [self stopInertia];
    float interval = inertiaInterval / [PLMath distanceBetweenPoints:startPoint :endPoint];
    if(interval < 0.01f)
    {
        inertiaStepValue = 0.01f / interval;
        interval = 0.01f;
    }
    else
        inertiaStepValue = 1.0f;
    inertiaTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(inertia) userInfo:nil repeats:YES];
    
    if(delegate && [delegate respondsToSelector:@selector(view:didBeginInertia:endPoint:)])
        [delegate view:self didBeginInertia:startPoint endPoint:endPoint];
}

-(void)stopInertia
{
    if(inertiaTimer)
    {
        [inertiaTimer invalidate];
        inertiaTimer = nil;
    }
}

-(void)inertia
{
    if(delegate && [delegate respondsToSelector:@selector(view:shouldRunInertia:endPoint:)] && ![delegate view:self shouldRunInertia:startPoint endPoint:endPoint])
        return;
    
    float m = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x);
    float b = (startPoint.y * endPoint.x - endPoint.y * startPoint.x) / (endPoint.x - startPoint.x);
    float x, y, add;
    
    if(ABS(endPoint.x - startPoint.x) >= ABS(endPoint.y - startPoint.y))
    {
        add = (endPoint.x > startPoint.x ? -inertiaStepValue : inertiaStepValue);
        x = endPoint.x + add;
        if((add > 0.0f && x > startPoint.x) || (add <= 0.0f && x < startPoint.x))
        {
            [self stopInertia];
            isValidForTouch = NO;
            
            if(delegate && [delegate respondsToSelector:@selector(view:didEndInertia:endPoint:)])
                [delegate view:self didEndInertia:startPoint endPoint:endPoint];
            
            return;
        }
        y = m * x + b;
    }
    else
    {
        add = (endPoint.y > startPoint.y ? -inertiaStepValue : inertiaStepValue);
        y = endPoint.y + add;
        if((add > 0.0f && y > startPoint.y) || (add <= 0.0f && y < startPoint.y))
        {
            [self stopInertia];
            isValidForTouch = NO;
            
            if(delegate && [delegate respondsToSelector:@selector(view:didEndInertia:endPoint:)])
                [delegate view:self didEndInertia:startPoint endPoint:endPoint];
            
            return;
        }
        x = (y - b)/m;
    }
    endPoint = CGPointMake(x, y);
    [self drawView];
    
    if(delegate && [delegate respondsToSelector:@selector(view:didRunInertia:endPoint:)])
        [delegate view:self didRunInertia:startPoint endPoint:endPoint];
}

#pragma mark -
#pragma mark accelerometer methods

-(void)activateMotionTracking
{
    
}

-(void)deactiveMotionTracking
{
}

#define kSensorialRotationErrorMargin 5

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
}

-(void)didMotionChangePoint:(CGPoint)point;
{
    float randomX = [self randFloatBetween:0.5 and:3.5];
    
    CGPoint pt = [vJoyStick getDirectPoint];
    
    ptDirectionJoyStick.x += pt.x;
    ptDirectionJoyStick.y += pt.y;
    
    float yaw = 0;//horizontal
    float pitchWithK = ptDirectionJoyStick.y * 3;
    float pitch = pitchWithK;//vertical
    float rollWithK = ptDirectionJoyStick.x/9;
    float roll = rollWithK * 180 / M_PI;//horizontal
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [scene.currentCamera rotateWithPitch:-pitch yaw:-yaw roll:roll];
    });
    
    transformFromCMRotationMatrix(cameraTransform, &mtRotationJoyStick);

    for (OponentCoordinateView *oponentView in oponentCoordinateViews) {
        mat4f_t projectionCameraTransform;
        multiplyMatrixAndMatrix(projectionCameraTransform, projectionTransform, cameraTransform);
        
        vec4f_t v;
        multiplyMatrixAndVector(v, projectionCameraTransform, oponentCoordinates[0]);
        
        float x = -rollWithK * 1.0;
        
        float y = pitchWithK * 0.014;
        
        if(v[2] > 0){
            if(!startX && (y <= 0.7)) startX = x + randomX;
            
            [oponentView.view setHidden:NO];
            x += startX;
            CGPoint newPosition = CGPointMake(x * self.bounds.size.width, self.bounds.size.height-(y * self.bounds.size.height + 220));
            dispatch_async(dispatch_get_main_queue(), ^{
                if([oponentView respondsToSelector:@selector(view)])
                    [oponentView.view setCenter:newPosition];
            });
        }
        else if([oponentView respondsToSelector:@selector(view)]) [oponentView.view setHidden:YES];
    }
}

#pragma mark -
#pragma mark sensorial rotation methods

-(void)startSensorialRotation
{
    if(!isSensorialRotationRunning && !isSensorialRotationBlocking)
    {
        startX = 0;
        isSensorialRotationRunning = YES;
        
        timerJoyStick = [NSTimer scheduledTimerWithTimeInterval:REFRESH_TIME target:self selector:@selector(didMotionChangePoint:) userInfo:Nil repeats:YES];
        [timerJoyStick fire];
        mtRotationJoyStick = rotationMatrixDefault();
        
//        motionManager = [[CMMotionManager alloc] init];
//        
//        // Tell CoreMotion to show the compass calibration HUD when required to provide true north-referenced attitude
//        motionManager.showsDeviceMovementDisplay = NO;
//        
//        motionManager.deviceMotionUpdateInterval = REFRESH_TIME;
//        motionManager.accelerometerUpdateInterval = REFRESH_TIME;
//        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error)
//         {
//             float randomX = [self randFloatBetween:0.5 and:3.5];
//             CMAttitude *currentAttitude = motion.attitude;
//
//             if (currentAttitude == nil)
//             {
//                 NSLog(@"Could not get device orientation.");
//                 return;
//             }
//             else {
//                 float yaw = currentAttitude.yaw * 180 / M_PI;
//                 float pitch = motion.gravity.z * 90;
//                 float roll = currentAttitude.roll * 180 / M_PI;
//                 
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [scene.currentCamera rotateWithPitch:pitch yaw:-yaw roll:-roll];
//                 });
//             }
//             
//             CMRotationMatrix r = motion.attitude.rotationMatrix;
//             transformFromCMRotationMatrix(cameraTransform, &r);
//             NSLog(@"%f %f %f %f %f %f %f %f %f",r.m11,r.m12,r.m13,r.m21,r.m22,r.m23,r.m31,r.m32,r.m33);
//             for (OponentCoordinateView *oponentView in oponentCoordinateViews) {
//                 mat4f_t projectionCameraTransform;
//                 multiplyMatrixAndMatrix(projectionCameraTransform, projectionTransform, cameraTransform);
//                 
//                 vec4f_t v;
//                 multiplyMatrixAndVector(v, projectionCameraTransform, oponentCoordinates[0]);
//                 
//                 float x = (v[0] / v[3] + 1.0f) * 0.4f;
//                 
//                 float y = -motion.gravity.z;
//                 
//                 if(v[2] > 0){
//                     if(!startX && (y <= 0.7)) startX = x + randomX;
//                     
//                     [oponentView.view setHidden:NO];
//                     x += startX;
//                     CGPoint newPosition = CGPointMake(x * self.bounds.size.width, self.bounds.size.height-(y * self.bounds.size.height + 220));
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                         if([oponentView respondsToSelector:@selector(view)])
//                             [oponentView.view setCenter:newPosition];
//                     });
//                 }
//                 else if([oponentView respondsToSelector:@selector(view)]) [oponentView.view setHidden:YES];
//             }
//             
//         }];
    }
}
-(float) randFloatBetween:(float)low and:(float)high
{
    float diff = high - low;
    return (((double)arc4random() / ARC4RANDOM_MAX) * diff) + low;
}

// Creates a projection matrix using the given y-axis field-of-view, aspect ratio, and near and far clipping planes
void createProjectionMatrix(mat4f_t mout, float fovy, float aspect, float zNear, float zFar)
{
    float f = 1.0f / tanf(fovy/2.0f);
    
    mout[0] = f / aspect;
    mout[1] = 0.0f;
    mout[2] = 0.0f;
    mout[3] = 0.0f;
    
    mout[4] = 0.0f;
    mout[5] = f;
    mout[6] = 0.0f;
    mout[7] = 0.0f;
    
    mout[8] = 0.0f;
    mout[9] = 0.0f;
    mout[10] = (zFar+zNear) / (zNear-zFar);
    mout[11] = -1.0f;
    
    mout[12] = 0.0f;
    mout[13] = 0.0f;
    mout[14] = 2 * zFar * zNear /  (zNear-zFar);
    mout[15] = 0.0f;
}


// Initialize mout to be an affine transform corresponding to the same rotation specified by m
void transformFromCMRotationMatrix(vec4f_t mout, const CMRotationMatrix *m)
{
    mout[0] = (float)m->m11;
    mout[1] = (float)m->m21;
    mout[2] = (float)m->m31;
    mout[3] = 0.0f;
    
    mout[4] = (float)m->m12;
    mout[5] = (float)m->m22;
    mout[6] = (float)m->m32;
    mout[7] = 0.0f;
    
    mout[8] = (float)m->m13;
    mout[9] = (float)m->m23;
    mout[10] = (float)m->m33;
    mout[11] = 0.0f;
    
    mout[12] = 0.0f;
    mout[13] = 0.0f;
    mout[14] = 0.0f;
    mout[15] = 1.0f;
}

// Matrix-vector and matrix-matricx multiplication routines
void multiplyMatrixAndVector(vec4f_t vout, const mat4f_t m, const vec4f_t v)
{
    vout[0] = m[0]*v[0] + m[4]*v[1] + m[8]*v[2] + m[12]*v[3];
    vout[1] = m[1]*v[0] + m[5]*v[1] + m[9]*v[2] + m[13]*v[3];
    vout[2] = m[2]*v[0] + m[6]*v[1] + m[10]*v[2] + m[14]*v[3];
    vout[3] = m[3]*v[0] + m[7]*v[1] + m[11]*v[2] + m[15]*v[3];
}

void multiplyMatrixAndMatrix(mat4f_t c, const mat4f_t a, const mat4f_t b)
{
    uint8_t col, row, i;
    memset(c, 0, 16*sizeof(float));
    
    for (col = 0; col < 4; col++) {
        for (row = 0; row < 4; row++) {
            for (i = 0; i < 4; i++) {
                c[col*4+row] += a[i*4+row]*b[col*4+i];
            }
        }
    }
}

CMRotationMatrix rotationMatrixDefault()
{
    CMRotationMatrix mat = {
        0.999114, 0.038270, -0.017526,
        0.006061, 0.281232, 0.959621,
        0.041654, -0.958877, 0.280750};
    
    return mat;
}

CMRotationMatrix rotationMatrixFromGravity(float x, float y, float z)
{
    //    CMRotationMatrix mat = {
    //        xAxis.x, yAxis.x, zAxis.x,
    //        xAxis.y, yAxis.y, zAxis.y,
    //        xAxis.z, yAxis.z, zAxis.z};
    //
    //    return mat;
}

/**
 * IMPORTANT: Gyroscope was not tested because, I do not have a device that support it. The function doGyroUpdate needs be tested and fix it.
 */

-(void)doGyroUpdate
{
    if(scene)
    {
        //CMRotationRate rotationRate = motionManager.gyroData.rotationRate;
        CMAttitude *attitude = motionManager.deviceMotion.attitude;
        double pitch = attitude.pitch * 180.0 / M_PI - 90.0;
        double yaw = attitude.yaw * 180.0 / M_PI - 180.0;
        [PLLog debug:@"PLViewBase::doGyroUpdate" format:@"pitch = %f yaw = %f", pitch, yaw, nil];
        [scene.currentCamera lookAtWithPitch:pitch yaw:yaw];
    }
}


-(void)doSimulatedGyroUpdate
{
    if(scene && lastAccelerometerPitch != -1 && firstMagneticHeading != -1)
    {
        float step = (ABS(lastAccelerometerPitch - accelerometerPitch) <= 5 ? 0.25f : 1.0f);
        if(lastAccelerometerPitch > accelerometerPitch)
            accelerometerPitch += step;
        else if(lastAccelerometerPitch < accelerometerPitch)
            accelerometerPitch -= step;
        [scene.currentCamera lookAtWithPitch:accelerometerPitch - 90 yaw:-magneticHeading];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading
{
    if(firstMagneticHeading == -1)
    {
        firstMagneticHeading = heading.magneticHeading;
        magneticHeading = 0.0f;
    }
    else if(lastAccelerometerPitch > 50)
        magneticHeading = heading.magneticHeading - firstMagneticHeading;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if([error code] == kCLErrorDenied)
        [self stopSensorialRotation];
    else if([error code] == kCLErrorHeadingFailure)
    {
    }
}

-(void)stopSensorialRotation
{
    if(isSensorialRotationRunning)
    {
        //oponentCoordinateViews = nil;
        startPoint = endPoint = CGPointMake(0.0f, 0.0f);
        isSensorialRotationRunning = NO;
        sensorType = PLSensorTypeUnknow;
        if(motionTimer)
        {
            [motionTimer invalidate];
            motionTimer = nil;
        }
        if(timerJoyStick)
        {
            [timerJoyStick invalidate];
            timerJoyStick = nil;
        }
        if(motionManager)
        {
            [motionManager stopDeviceMotionUpdates];
            [motionManager release];
            motionManager = nil;
        }
        if(locationManager)
        {
            [locationManager stopUpdatingHeading];
            [locationManager release];
            locationManager = nil;
        }
    }
}

-(void)stopSensorialRotationWithBlock
{
    [self stopSensorialRotation];
    isSensorialRotationBlocking = YES;
}

#pragma mark -
#pragma mark shake methods

-(void)setShakeThreshold:(float)value
{
    if(value > 0.0f)
        shakeThreshold = value;
}

-(BOOL)resetWithShake:(UIAcceleration *)acceleration
{
    if(!isShakeResetEnabled || !isResetEnabled)
        return NO;
    
    BOOL result = NO;
    long currentTime = (long)(CACurrentMediaTime() * 1000);
    
    if ((currentTime - shakeData.lastTime) > kShakeDiffTime)
    {
        long diffTime = (currentTime - shakeData.lastTime);
        shakeData.lastTime = currentTime;
        
        shakeData.shakePosition.x = acceleration.x;
        shakeData.shakePosition.y = acceleration.y;
        shakeData.shakePosition.z = acceleration.z;
        
        float speed = ABS(shakeData.shakePosition.x + shakeData.shakePosition.y + shakeData.shakePosition.z - shakeData.shakeLastPosition.x - shakeData.shakeLastPosition.y - shakeData.shakeLastPosition.z) / diffTime * 10000;
        if (speed > shakeThreshold)
        {
            [self reset];
            [self drawViewInternally];
            result = YES;
        }
        
        shakeData.shakeLastPosition.x = shakeData.shakePosition.x;
        shakeData.shakeLastPosition.y = shakeData.shakePosition.y;
        shakeData.shakeLastPosition.z = shakeData.shakePosition.z;
    }
    return result;
}

#pragma mark -
#pragma mark transition methods

-(BOOL)executeTransition:(PLTransition *)transition
{
    if(!scene || !renderer || !transition || [self getIsValidForTransition])
        return NO;
    
    [self setIsValidForTransition:YES];
    isValidForTouch = NO;
    
    startPoint = endPoint = CGPointMake(0.0f, 0.0f);
    
    currentTransition = [transition retain];
    currentTransition.delegate = self;
    [currentTransition executeWithView:self scene:scene];
    
    return YES;
}

-(void)transition:(PLTransition *)transition didBeginTransition:(PLTransitionType)type
{
    if(delegate && [delegate respondsToSelector:@selector(view:didBeginTransition:)])
        [delegate view:self didBeginTransition:transition];
}

-(void)transition:(PLTransition *)transition didProcessTransition:(PLTransitionType)type progressPercentage:(NSUInteger)progressPercentage
{
    if(delegate && [delegate respondsToSelector:@selector(view:didProcessTransition:progressPercentage:)])
        [delegate view:self didProcessTransition:transition progressPercentage:progressPercentage];
}

-(void)transition:(PLTransition *)transition didEndTransition:(PLTransitionType)type
{
    [self setIsValidForTransition:NO];
    if(currentTransition)
    {
        [currentTransition release];
        currentTransition = nil;
    }
    if(delegate && [delegate respondsToSelector:@selector(view:didEndTransition:)])
        [delegate view:self didEndTransition:transition];
}

#pragma mark -
#pragma mark dealloc methods

-(void)dealloc
{
    [self stopAnimation];
    [self reset];
    [self deactiveMotionTracking];
    if(isValidForTransitionString)
        [isValidForTransitionString release];
    if(currentTransition)
    {
        [currentTransition stop];
        [currentTransition release];
    }
    if(renderer)
    {
        [renderer stop];
        [renderer release];
    }
    if(scene)
        [scene release];
    [super dealloc];
}

@end
