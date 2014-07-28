//
//  THNotesTextView.h
//  THNotesTextViewExample
//
//  Created by Hannes Tribus on 12/05/14.
//  Copyright (c) 2014 3Bus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THNotesTextView : UITextView

@property (nonatomic, strong) UIColor *horizontalLineColor;
@property (nonatomic, strong) UIColor *verticalLineColor;

@property (nonatomic) UIEdgeInsets margins;
@property (nonatomic, getter = isDottedLines) BOOL dottedLines;

@end
