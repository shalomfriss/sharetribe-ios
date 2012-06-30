//
//  MessagesView.m
//  Kassi
//
//  Created by Janne Käki on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessagesView.h"

#import "Message.h"
#import "MessageThread.h"
#import "User.h"
#import "NSDate+Extras.h"
#import "UIView+XYWidthHeight.h"
#import <QuartzCore/QuartzCore.h>

#define kSeparatorTag      7

@implementation MessagesView

@synthesize backgroundView;
@synthesize pointerView;

@synthesize avatarViews;
@synthesize usernameLabels;
@synthesize dateLabels;
@synthesize textLabels;

@synthesize composeField;
@synthesize composeFieldContainer;
@synthesize sendMessageButton;
@synthesize cancelMessageButton;
@synthesize recipientLabel;
@synthesize subjectLabel;

@dynamic messages;
@dynamic messageThread;
@dynamic sendButtonTitle;
@dynamic composeFieldPlaceholder;
@synthesize showComposerButtons;
@synthesize showUserAvatars;

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        
        self.width = 300;
        
        // self.pointerView = [[UIView alloc] init];
        // pointerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pointing-corner"]];
        // pointerView.frame = CGRectMake(12, 0, 27, 14);
        // [self addSubview:pointerView];
        
        self.backgroundView = [[UIView alloc] init];
        backgroundView.frame = CGRectMake(0, 0, self.width, 86);
        backgroundView.backgroundColor = kKassiBrownColor;
        backgroundView.layer.cornerRadius = 5;
        [self addSubview:backgroundView];
        
        self.avatarViews = [NSMutableArray array];
        self.usernameLabels = [NSMutableArray array];
        self.dateLabels = [NSMutableArray array];
        self.textLabels = [NSMutableArray array];
                
        self.composeFieldContainer = [[UITextField alloc] init];
        composeFieldContainer.frame = CGRectMake(50, 0, self.width-50-10, 31);
        composeFieldContainer.borderStyle = UITextBorderStyleRoundedRect;
        composeFieldContainer.font = [UIFont systemFontOfSize:13];
        composeFieldContainer.userInteractionEnabled = NO;
        [self addSubview:composeFieldContainer];
        
        self.composeField = [[UITextView alloc] init];
        composeField.frame = CGRectMake(50, 0, self.width-50-10, 31);
        composeField.backgroundColor = [UIColor clearColor];
        composeField.font = [UIFont systemFontOfSize:13];
        composeField.keyboardAppearance = UIKeyboardAppearanceAlert;
        // composeField.contentInset = UIEdgeInsetsMake(-2, 10, -2, 10);
        composeField.delegate = self;
        [self addSubview:composeField];
        
        self.sendMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendMessageButton.frame = CGRectMake(50, self.height-40, 150, 30);
        sendMessageButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        sendMessageButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [sendMessageButton setBackgroundImage:[[UIImage imageNamed:@"dark-brown.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
        [sendMessageButton addTarget:self action:@selector(sendMessagePressed) forControlEvents:UIControlEventTouchUpInside];
        sendMessageButton.hidden = YES;
        [self addSubview:sendMessageButton];
        
        self.cancelMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelMessageButton.frame = CGRectMake(50+sendMessageButton.width+10, self.height-40, self.width-50-20-sendMessageButton.width, 30);
        cancelMessageButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        cancelMessageButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [cancelMessageButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelMessageButton setBackgroundImage:[[UIImage imageNamed:@"dark-brown.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
        [cancelMessageButton addTarget:self action:@selector(cancelMessagePressed) forControlEvents:UIControlEventTouchUpInside];
        cancelMessageButton.hidden = YES;
        [self addSubview:cancelMessageButton];
        
        self.recipientLabel = [[UILabel alloc] init];
        recipientLabel.frame = CGRectMake(10, 0, self.width-20, 20);
        recipientLabel.font = [UIFont boldSystemFontOfSize:13];
        recipientLabel.backgroundColor = [UIColor clearColor];
        recipientLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:recipientLabel];
        recipientLabel.hidden = YES;

        self.subjectLabel = [[UILabel alloc] init];
        subjectLabel.frame = CGRectMake(10, 0, self.width-20, 20);
        subjectLabel.font = [UIFont boldSystemFontOfSize:13];
        subjectLabel.backgroundColor = [UIColor clearColor];
        subjectLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:subjectLabel];
        subjectLabel.hidden = YES;
        
        self.showComposerButtons = YES;
        self.showUserAvatars = YES;
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
}

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    backgroundView.height = frame.size.height;
}

- (NSArray *)messages
{
    return messages;
}

- (void)setMessages:(NSArray *)newMessages
{
    messages = newMessages;
    
    int leftEdgeX = (showUserAvatars) ? 50 : 10;
    int yOffset = 10;
    
    for (int i = 0; i <= messages.count; i++) {  // Note: one extra for the "add comment" field
        
        UIImageView *avatarView;
        if (i < avatarViews.count) {
            avatarView = [avatarViews objectAtIndex:i];
        } else {
            avatarView = [[UIImageView alloc] init];
            avatarView.layer.borderColor = kKassiLightBrownColor.CGColor;
            avatarView.layer.borderWidth = 1;
            avatarView.frame = CGRectMake(10, 0, 30, 30);
            [self addSubview:avatarView];
            [avatarViews addObject:avatarView];
        }
        avatarView.y = yOffset;
        avatarView.hidden = !showUserAvatars;
        
        if (i == messages.count) {
            avatarView.image = [UIImage imageNamed:@"default-avatar-small"];  // Note: should be the user's own pic
            break;
        }
        
        Message *message = [messages objectAtIndex:i];
        avatarView.image = message.sender.avatar;
        
        UILabel *usernameLabel;
        if (i < usernameLabels.count) {
            usernameLabel = [usernameLabels objectAtIndex:i];
        } else {
            usernameLabel = [[UILabel alloc] init];
            usernameLabel.font = [UIFont boldSystemFontOfSize:13];
            usernameLabel.textColor = kKassiDarkBrownColor;
            usernameLabel.backgroundColor = [UIColor clearColor];
            usernameLabel.frame = CGRectMake(leftEdgeX, 24, self.width-leftEdgeX-10, 16);
            [self addSubview:usernameLabel];
            [usernameLabels addObject:usernameLabel];
        }
        usernameLabel.text = message.sender.name;
        usernameLabel.y = yOffset-2;
        usernameLabel.hidden = NO;

        UILabel *dateLabel;
        if (i < dateLabels.count) {
            dateLabel = [dateLabels objectAtIndex:i];
        } else {
            dateLabel = [[UILabel alloc] init];
            dateLabel.font = [UIFont systemFontOfSize:12];
            dateLabel.textColor = kKassiDarkBrownColor;
            dateLabel.backgroundColor = [UIColor clearColor];
            dateLabel.textAlignment = UITextAlignmentRight;
            dateLabel.frame = CGRectMake(leftEdgeX, 24, self.width-leftEdgeX-12, 16);
            [self addSubview:dateLabel];
            [dateLabels addObject:dateLabel];
        }
        dateLabel.text = message.date.agestamp;
        dateLabel.y = yOffset-2;
        dateLabel.hidden = NO;
        
        yOffset += 29;
        
        UILabel *textLabel;
        if (i < textLabels.count) {
            textLabel = [textLabels objectAtIndex:i];
        } else {
            textLabel = [[UILabel alloc] init];
            textLabel.font = [UIFont systemFontOfSize:13];
            textLabel.textColor = [UIColor blackColor];
            textLabel.backgroundColor = [UIColor clearColor];
            textLabel.frame = CGRectMake(leftEdgeX, 24, self.width-leftEdgeX-10, 50);
            textLabel.numberOfLines = 0;
            textLabel.lineBreakMode = UILineBreakModeWordWrap;
            [self addSubview:textLabel];
            [textLabels addObject:textLabel];
        }
        textLabel.text = message.text;
        textLabel.y = yOffset;
        textLabel.height = [textLabel.text sizeWithFont:textLabel.font constrainedToSize:CGSizeMake(textLabel.width, 10000) lineBreakMode:UILineBreakModeWordWrap].height;
        textLabel.hidden = NO;
        
        UIView *separator = [avatarView viewWithTag:kSeparatorTag];
        if (separator == nil) {
            separator = [[UIView alloc] init];
            separator.backgroundColor = [UIColor whiteColor];
            separator.frame = CGRectMake(-10, 0, self.width, 1);
            separator.tag = kSeparatorTag;
            [avatarView addSubview:separator];
        }
        
        yOffset = MAX(avatarView.y+avatarView.height, textLabel.y+textLabel.height);
        separator.y = yOffset-avatarView.y+10;
        yOffset += 21;
    }
    
    if (messageThread != nil) {
        
        recipientLabel.y = yOffset;
        yOffset += recipientLabel.height;
        subjectLabel.y = yOffset;
        yOffset += subjectLabel.height+10;
        
        recipientLabel.text = [NSString stringWithFormat:@"To: %@", messageThread.recipient.name];
        subjectLabel.text = messageThread.subject;
        
        recipientLabel.hidden = NO;
        subjectLabel.hidden = NO;
        
    } else {
        
        recipientLabel.hidden = YES;
        subjectLabel.hidden = YES;
    }
    
    composeField.x = leftEdgeX;
    composeFieldContainer.x = composeField.x;
    
    composeField.width = self.width-leftEdgeX-10;
    composeFieldContainer.width = composeField.width;
    
    composeField.y = yOffset;    
    composeField.height = 31;
    
    composeFieldContainer.y = yOffset;    
    composeFieldContainer.height = 31;
    
    self.height = yOffset + composeField.height + 10;
    
    for (int i = messages.count+1; i < avatarViews.count; i++) {
        [[avatarViews objectAtIndex:i] setHidden:YES];
    }
    for (int i = messages.count; i < usernameLabels.count; i++) {
        [[usernameLabels objectAtIndex:i] setHidden:YES];
    }
    for (int i = messages.count; i < dateLabels.count; i++) {
        [[dateLabels objectAtIndex:i] setHidden:YES];
    }
    for (int i = messages.count; i < textLabels.count; i++) {
        [[textLabels objectAtIndex:i] setHidden:YES];
    }
}

- (MessageThread *)messageThread
{
    return messageThread;
}

- (void)setMessageThread:(MessageThread *)newMessageThread
{
    messageThread = newMessageThread;
    
    self.messages = messageThread.messages;
}

- (NSString *)sendButtonTitle
{
    return [sendMessageButton titleForState:UIControlStateNormal];
}

- (void)setSendButtonTitle:(NSString *)sendButtonTitle
{
    [sendMessageButton setTitle:sendButtonTitle forState:UIControlStateNormal];
}

- (NSString *)composeFieldPlaceholder
{
    return composeFieldContainer.placeholder;
}

- (void)setComposeFieldPlaceholder:(NSString *)composeFieldPlaceholder
{
    composeFieldContainer.placeholder = composeFieldPlaceholder;
}

- (IBAction)sendMessagePressed
{
    [delegate messagesView:self didSaveMessageText:composeField.text];
    composeField.text = nil;
    [composeField resignFirstResponder];
}

- (IBAction)cancelMessagePressed
{
    composeField.text = nil;
    [composeField resignFirstResponder];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{   
    int heightForButtons = (showComposerButtons) ? 40 : 0;
    composeField.height = 416-216-10-heightForButtons-10;
    composeFieldContainer.height = composeField.height;
    
    sendMessageButton.hidden = !showComposerButtons;
    cancelMessageButton.hidden = !showComposerButtons;
    
    self.height = composeField.y + composeField.height + heightForButtons + 10;
    
    composeFieldContainer.text = @" ";
    
    [delegate messagesViewDidBeginEditing:self];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [delegate messagesViewDidChange:self];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    composeField.height = 31;
    composeFieldContainer.height = composeField.height;
    
    sendMessageButton.hidden = YES;
    cancelMessageButton.hidden = YES;
    
    self.height = composeField.y + composeField.height + 10;
    
    composeFieldContainer.text = nil;
    
    [delegate messagesViewDidEndEditing:self];
}

@end