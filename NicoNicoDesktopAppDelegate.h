//
//  NicoNicoDesktopAppDelegate.h
//  NicoNicoDesktop
//
//  Created by sugyan on 10/10/21.
//

#import <Cocoa/Cocoa.h>

@interface NicoNicoDesktopAppDelegate : NSObject <NSApplicationDelegate, NSStreamDelegate, NSAnimationDelegate> {
}

- (void)displayString:(NSString *)str;

@end
