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

    NSStatusItem *theItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [theItem setImage:[NSImage imageNamed:@"menu"]];
    [theItem setHighlightMode:YES];
    [theItem setMenu:statusBarMenu];

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
    // screen size
    NSRect screenRect = [[NSScreen mainScreen] frame];

    // font size = 20
    NSFont       *font       = [NSFont systemFontOfSize:20.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    NSSize       strSize     = [str sizeWithAttributes:attributes];

    NSLog(@"size: %f, %f", strSize.width, strSize.height);

    // 描画開始位置(右端から、ランダムな高さで)
    double origin_y = (screenRect.size.height - strSize.height) * rand() / RAND_MAX;
    CGRect rect     = CGRectMake(screenRect.size.width, origin_y, strSize.width + 10.0, strSize.height + 10.0);
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSRectFromCGRect(rect)
                                                   styleMask:NSBorderlessWindowMask
                                                     backing:NSBackingStoreRetained
                                                       defer:YES];
    [window setIgnoresMouseEvents:YES];               // mouse eventを無視
    [window setBackgroundColor:[NSColor clearColor]]; // 透明windowに
    [window setOpaque:NO];                            // 透過させる
    [window setLevel:NSScreenSaverWindowLevel];       // 常に最前面に表示
    [window orderFront:nil];

    NSText  *text   = [[[NSText alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0.0, 0.0, rect.size.width, rect.size.height))] autorelease];
    NSArray *colors = [NSArray arrayWithObjects:
                               [NSColor redColor],       [NSColor greenColor],    [NSColor blueColor],
                               [NSColor cyanColor],      [NSColor magentaColor],  [NSColor yellowColor],
                               [NSColor brownColor],     [NSColor orangeColor],   [NSColor purpleColor],
                               [NSColor blackColor],     [NSColor whiteColor],    nil];
    [text setTextColor:[colors objectAtIndex:rand() % [colors count]]];
    [text setString:str];
    [text setFont:font];
    [text setBackgroundColor:[NSColor clearColor]];
    [[window contentView] addSubview:text];

    NSRect srcViewFrame = NSRectFromCGRect(rect);
    NSRect desViewFrame = srcViewFrame;
    desViewFrame.origin.x = - rect.size.width;
    NSDictionary* viewDict = [NSDictionary dictionaryWithObjectsAndKeys:
        window, NSViewAnimationTargetKey,
        [NSValue valueWithRect:srcViewFrame], NSViewAnimationStartFrameKey,
        [NSValue valueWithRect:desViewFrame], NSViewAnimationEndFrameKey,
        nil];
    NSViewAnimation *animation =
        [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:viewDict, nil]] autorelease];
 
    [animation setAnimationBlockingMode:NSAnimationNonblocking];
    [animation setAnimationCurve:NSAnimationLinear];
    [animation setDuration:screenRect.size.width / 100.0];
    [animation setDelegate:self];
    [animation startAnimation];
}

- (void)animationDidEnd:(NSAnimation *)animation {
    for (NSDictionary *dict in [(NSViewAnimation *)animation viewAnimations]) {
        NSWindow *window = [dict objectForKey:NSViewAnimationTargetKey];
        [window close];
    }
}

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

@end
