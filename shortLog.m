//  shortLog.m
//  iRestaurateur
//  Created by Erwin Mazariegos on 8/16/13.
//  Copyright (c) 2013 Stratipad. All rights reserved.

#import "shortLog.h"
#import <sys/time.h>

void ShortNSLog(const char * functionName, int lineNumber, NSString * format, ...) {

	NSString *prefix = @"";
	NSString *body = @"";
	NSString *thread = @"";
	
	if (functionName) {
		prefix = [NSString stringWithFormat:@"%s:%d", functionName, lineNumber];
	} else {
		prefix = @" -->  ";
	}
	
	if (format) {
		va_list ap;
		va_start (ap, format);
		body = [[NSString alloc] initWithFormat:format arguments:ap];
		va_end (ap);
	}
	
	if (![NSThread isMainThread]) {
		thread = [NSString stringWithFormat:@"<%@>", [NSThread currentThread]];;
	}
	
	struct timeval detail_time;
	gettimeofday(&detail_time, NULL);

	time_t rawtime;
	struct tm *timeinfo;
	char timestamp[11];
	time(&rawtime);
	timeinfo = localtime(&rawtime);
	strftime(timestamp, 11, "%M:%S", timeinfo);
	
	fprintf(stderr, "%s.%03d %s%s%s\n", timestamp, detail_time.tv_usec / 1000, [prefix UTF8String], [thread UTF8String], [body UTF8String]);
}

@implementation shortLog

@end
