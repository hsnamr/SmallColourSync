//
//  main.m
//  SmallICCer
//
//  ICC Color Profile Editor and Visualizer
//  Entry point for the application
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AppController.h"

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSApplication *application = [NSApplication sharedApplication];
    AppController *appController = [[AppController alloc] init];
    [application setDelegate:appController];
    [application run];
    [pool release];
    return 0;
}
