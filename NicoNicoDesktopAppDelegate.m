//
//  NicoNicoDesktopAppDelegate.m
//  NicoNicoDesktop
//
//  Created by sugyan on 10/10/21.
//

#import "NicoNicoDesktopAppDelegate.h"
#import "TCPServer.h"

@implementation NicoNicoDesktopAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    srand(time(NULL));

    TCPServer *server = [[TCPServer alloc] init];
    [server setPort:25250];
    [server setDelegate:self];
    NSError *error;
    [server start:&error];
}

- (void)TCPServer:(TCPServer *)server didReceiveConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr {
    [istr setDelegate:self];
    [istr scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [istr open];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    switch(streamEvent) {
    case NSStreamEventHasBytesAvailable: {
        uint8_t   buf[1024];
        NSInteger len = [(NSInputStream *)theStream read:buf maxLength:1024];
        if(len) {
            NSData   *data = [NSData dataWithBytes:buf length:len];
            NSString *str  = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            [self displayString:str];
        }
        break;
    }
    default:
        break;
    }
}

- (void)displayString:(NSString *)str {
    NSScreen *screen = [NSScreen mainScreen];
    double height    = [screen frame].size.height * rand() / RAND_MAX;
    CGRect rect      = CGRectMake([screen frame].size.width, height, [screen frame].size.width, 50.0);
    NSWindow *window =
        [[NSWindow alloc] initWithContentRect:NSRectFromCGRect(rect)
                                    styleMask:NSTexturedBackgroundWindowMask
                                      backing:NSBackingStoreRetained
                                        defer:YES];
    NSText *text = [[[NSText alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0.0, 0.0, rect.size.width, rect.size.height))] autorelease];
    NSArray *colors = [NSArray arrayWithObjects:
                               [NSColor redColor],       [NSColor greenColor],    [NSColor blueColor],
                               [NSColor cyanColor],      [NSColor magentaColor],  [NSColor yellowColor],
                               [NSColor lightGrayColor], [NSColor darkGrayColor], [NSColor grayColor],
                               [NSColor brownColor],     [NSColor orangeColor],   [NSColor purpleColor],
                               [NSColor blackColor],     [NSColor whiteColor], nil];
    [text setHorizontallyResizable:YES];
    [text setString:str];
    [text setTextColor:[colors objectAtIndex:rand() % [colors count]]];
    [text setFont:[NSFont systemFontOfSize:20.0]];
    [text setBackgroundColor:[NSColor clearColor]];
    [[window contentView] addSubview:text];

    [window setLevel:NSScreenSaverWindowLevel];
    [window setBackgroundColor:[NSColor clearColor]];
    [window setOpaque:NO];
    [window orderFront:nil];

    NSRect srcViewFrame = NSRectFromCGRect(rect);
    NSRect desViewFrame = srcViewFrame;
    desViewFrame.origin.x = -[screen frame].size.width;
    NSDictionary* viewDict = [NSDictionary dictionaryWithObjectsAndKeys:
        window, NSViewAnimationTargetKey,
        [NSValue valueWithRect:srcViewFrame], NSViewAnimationStartFrameKey,
        [NSValue valueWithRect:desViewFrame], NSViewAnimationEndFrameKey,
        nil];
    NSViewAnimation *animation =
        [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:viewDict, nil]] autorelease];
 
    [animation setDuration:[screen frame].size.width / 75.0];
    [animation setAnimationCurve:NSAnimationLinear];
    [animation setDelegate:self];
    [animation startAnimation];
}

- (void)animationDidEnd:(NSAnimation *)animation {
    for (NSDictionary *dict in [(NSViewAnimation *)animation viewAnimations]) {
        NSWindow *window = [dict objectForKey:NSViewAnimationTargetKey];
        [window close];
    }
}

@end
