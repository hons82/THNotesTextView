//
//  THNotesTextView.m
//  THNotesTextViewExample
//
//  Created by Hannes Tribus on 12/05/14.
//  Copyright (c) 2014 3Bus. All rights reserved.
//

#import "THNotesTextView.h"

#define DEFAULT_VERTICAL_COLOR      [UIColor colorWithRed:178.0/255.0 green:210.0/255.0 blue:241.0/255.0 alpha:1.0f]
#define DEFAULT_HORIZONTAL_COLOR    [UIColor colorWithRed:255.0/255.0 green:214.0/255.0 blue:207.0/255.0 alpha:1.0f]
#define DEFAULT_MARGINS             UIEdgeInsetsMake(10.0f, 20.0f, 0.0f, 20.0f)

@implementation THNotesTextView

@synthesize horizontalLineColor = _horizontalLineColor;
@synthesize verticalLineColor = _verticalLineColor;
@synthesize dottedLines = _dottedLines;

+ (void)initialize {
    if (self == [THNotesTextView class])
    {
        id appearance = [self appearance];
        [appearance setContentMode:UIViewContentModeRedraw];
        [appearance setHorizontalLineColor:DEFAULT_HORIZONTAL_COLOR];
        [appearance setVerticalLineColor:DEFAULT_VERTICAL_COLOR];
        [appearance setMargins:DEFAULT_MARGINS];
    }
}

#pragma mark - Setup/Teardown

- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeNotification:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)awakeFromNib {
    [self setup];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)setContentSize:(CGSize)contentSize {
    contentSize = (CGSize) {
        .width = contentSize.width - self.margins.left - self.margins.right,
        .height = contentSize.height
    };
    NSLog(@"width: %f, height %f",contentSize.width,contentSize.height);
    [super setContentSize:contentSize];
}

- (void)setMargins:(UIEdgeInsets)margins {
    _margins = margins;
    self.contentInset = (UIEdgeInsets) {
        .top = self.margins.top,
        .left = self.margins.left,
        .bottom = self.margins.bottom,
        .right = self.margins.right - self.margins.left
    };
    self.textContainerInset = (UIEdgeInsets) {
        .top = self.margins.top,
        .left = 0,
        .bottom = self.margins.bottom,
        .right = self.margins.right + self.margins.left
    };
    
    [self setContentSize:self.contentSize];
}

- (void)scrollToCaretAnimated:(BOOL)animated {
    CGRect rect = [self caretRectForPosition:self.selectedTextRange.end];
    rect.size.height += self.textContainerInset.bottom;
    [self scrollRectToVisible:rect animated:animated];
}

- (UIColor *)horizontalLineColor {
    if (!_horizontalLineColor) _horizontalLineColor = DEFAULT_HORIZONTAL_COLOR;
    return _horizontalLineColor;
}

- (UIColor *)verticalLineColor {
    if (!_verticalLineColor) _verticalLineColor = DEFAULT_VERTICAL_COLOR;
    return _verticalLineColor;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat lineSpacing = 1.01f;
    if (self.horizontalLineColor) {
        CGContextSetLineWidth(context, 1.0f);
        if ([self isDottedLines]) {
            CGFloat dash[] = {1.0, 1.0};
            CGContextSetLineDash(context, 0.0, dash, 2);
        }
        
        CGContextBeginPath(context);
        CGContextSetStrokeColorWithColor(context, self.horizontalLineColor.CGColor);
        
        // Create un-mutated floats outside of the for loop.
        // Reduces memory access.
        CGFloat baseOffset = self.margins.top + self.font.descender + 1.0;
        CGFloat screenScale = [UIScreen mainScreen].scale;
        CGFloat boundsX = self.bounds.origin.x;
        CGFloat boundsWidth = self.bounds.size.width;
        
        // Only draw lines that are visible on the screen.
        // (As opposed to throughout the entire view's contents)
        NSInteger firstVisibleLine = MAX(1, (self.contentOffset.y / (self.font.lineHeight * lineSpacing)));
        NSInteger lastVisibleLine = ceilf((self.contentOffset.y + self.bounds.size.height) / (self.font.lineHeight * lineSpacing));
        for (NSInteger line = firstVisibleLine; line <= lastVisibleLine; ++line)
        {
            CGFloat linePointY = (baseOffset + (self.font.lineHeight * line * lineSpacing));
            // Rounding the point to the nearest pixel.
            // Greatly reduces drawing time.
            CGFloat roundedLinePointY = roundf(linePointY * screenScale) / screenScale;
            //NSLog(@"linePointYRounded %f (%f)",roundedLinePointY, linePointY);
            CGContextMoveToPoint(context, boundsX, roundedLinePointY);
            CGContextAddLineToPoint(context, boundsWidth, roundedLinePointY);
        }
        CGContextClosePath(context);
        CGContextStrokePath(context);
    }
    
    if (self.verticalLineColor) {
        if ([self isDottedLines]) {
            CGFloat dash[] = {0.5, 1.5};
            CGContextSetLineDash(context, 0.0, dash, 2);
        }
        
        // left
        CGContextBeginPath(context);
        CGContextSetStrokeColorWithColor(context, self.verticalLineColor.CGColor);
        CGContextMoveToPoint(context, -1.0f, self.contentOffset.y);
        CGContextAddLineToPoint(context, -1.0f, self.contentOffset.y + self.bounds.size.height);
        CGContextClosePath(context);
        CGContextStrokePath(context);
        
        // right
        CGContextBeginPath(context);
        CGContextSetStrokeColorWithColor(context, self.verticalLineColor.CGColor);
        CGContextMoveToPoint(context, -1.0f + self.contentSize.width, self.contentOffset.y);
        CGContextAddLineToPoint(context, -1.0f + self.contentSize.width, self.contentOffset.y + self.bounds.size.height);
        CGContextClosePath(context);
        CGContextStrokePath(context);
    }
}

#pragma mark - Notifications

- (void)textDidChangeNotification:(NSNotification*)notification {
    [self scrollToCaretAnimated:NO];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self setMargins:DEFAULT_MARGINS];
}

- (void)keyboardDidChangeFrame:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    CGRect keyboardFrameBeginRect =  [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey]CGRectValue];
    
    UIEdgeInsets tmp = DEFAULT_MARGINS;
    tmp.bottom = [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight ?
    keyboardFrameBeginRect.size.width : keyboardFrameBeginRect.size.height;
    tmp.right = tmp.right - tmp.left;
    [self setContentInset:tmp];
    [self scrollToCaretAnimated:NO];
}

@end
