//
//  SimpleKML.m
//
//  Created by Justin R. Miller on 6/29/10.
//  Copyright 2010, Code Sorcery Workshop, LLC and Development Seed, Inc.
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//  
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//      * Neither the names of Code Sorcery Workshop, LLC or Development Seed,
//        Inc., nor the names of its contributors may be used to endorse or
//        promote products derived from this software without specific prior
//        written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SimpleKML.h"
#import "SimpleKMLFeature.h"
#import "ZipFile.h"
#import "FileInZipInfo.h"
#import "ZipReadStream.h"

@interface SimpleKML ()

@property (nonatomic, strong) NSURL *sourceURL;

- (id)initWithContentsOfFile:(NSString *)path error:(NSError **)error;
+ (NSString *)topLevelKMLFilePathInArchiveAtPath:(NSString *)archivePath;

@end

#pragma mark -

@implementation SimpleKML

@synthesize feature;
@synthesize source;
@synthesize sourceURL;

+ (SimpleKML *)KMLWithContentsOfURL:(NSURL *)URL error:(NSError **)error
{
    return [[self alloc] initWithContentsOfURL:URL error:error];
}

+ (SimpleKML *)KMLWithContentsOfFile:(NSString *)path error:(NSError **)error
{
    return [[self alloc] initWithContentsOfFile:path error:error];
}

- (id)initWithContentsOfURL:(NSURL *)URL error:(NSError **)error
{
    self = [super init];
    
    if (self != nil)
    {
        sourceURL = URL;
        feature   = nil;
        
        if ([[[[URL relativePath] pathExtension] lowercaseString] isEqualToString:@"kml"])
        {
            source = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:NULL];
        }
        else if ([[[[URL relativePath] pathExtension] lowercaseString] isEqualToString:@"kmz"])
        {
            NSData *sourceData = [SimpleKML dataFromArchiveAtPath:[URL relativePath] 
                                                     withFilePath:[SimpleKML topLevelKMLFilePathInArchiveAtPath:[URL relativePath]]];
            
            if (sourceData)
                source = [[NSString alloc] initWithData:sourceData encoding:NSUTF8StringEncoding];
            
            else
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Unable to locate top-level KML file in KMZ archive" 
                                                                     forKey:NSLocalizedFailureReasonErrorKey];
                
                if (error)
                    *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                
                return nil;
            }
        }
        else 
        {
            if (error)
                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLUnknownFileType userInfo:nil];
            
            return nil;
        }
        
        NSError *parseError = nil;
        
        CXMLDocument *document = [[CXMLDocument alloc] initWithXMLString:source
                                                                 options:0
                                                                   error:&parseError];
        
        // return nil if we can't properly parse this file
        //
        if (parseError)
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Unable to parse XML: %@", parseError]
                                                                 forKey:NSLocalizedFailureReasonErrorKey];
            
            if (error)
                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
            
            return nil;
        }
        
        CXMLElement *rootElement = [document rootElement];
        
        // find the first element node child of the root
        //
        CXMLNode *featureNode = nil;
        
        // some KML documents seem to leave off the required top-level <kml> element
        //
        if ([[rootElement name] isEqualToString:@"kml"])
        {
            for (CXMLNode *child in [rootElement children])
            {
                if ([child kind] == CXMLElementKind)
                {
                    featureNode = child;
                    break;
                }
            }
        }

        // just support a top-level <Document> for now if <kml> is missing
        //
        else if ([[rootElement name] isEqualToString:@"Document"])
            featureNode = rootElement;
        
        if ( ! featureNode)
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (root element has no valid child node)" 
                                                                 forKey:NSLocalizedFailureReasonErrorKey];
            
            if (error)
                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
            
            return nil;
        }
        
        // build up our Feature if we have one
        //
        Class featureClass = NSClassFromString([NSString stringWithFormat:@"SimpleKML%@", [featureNode name]]);
        
        parseError = nil;
        
        feature = [[featureClass alloc] initWithXMLNode:featureNode sourceURL:sourceURL error:&parseError];
        
        if (parseError)
        {
            if (error)
                *error = parseError;
            
            return nil;
        }
        
        // we can only handle Feature for now
        //
        if ( ! featureClass || ! [feature isKindOfClass:[SimpleKMLFeature class]])
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Root element contains a child object unknown to this library" 
                                                                 forKey:NSLocalizedFailureReasonErrorKey];
            
            if (error)
                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLUnknownObject userInfo:userInfo];
            
            return nil;
        }
    }
    
    return self;
}

- (id)initWithContentsOfFile:(NSString *)path error:(NSError **)error
{
    return [self initWithContentsOfURL:[NSURL fileURLWithPath:path] error:error];
}

#pragma mark -

+ (UIColor *)colorForString:(NSString *)colorString;
{
    // color string should be eight or nine characters (RGBA in hex, with or without '#' prefix)
    //
    if ([colorString length] < 8 || [colorString length] > 9)
        return nil;
    
    colorString = [colorString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    NSMutableArray *parts = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < 8; i = i + 2)
    {
        NSString *part = [colorString substringWithRange:NSMakeRange(i, 2)];
        
        unsigned wholeValue;
        
        [[NSScanner scannerWithString:part] scanHexInt:&wholeValue];
        
        if (wholeValue > 255)
            return nil;
        
        [parts addObject:[NSNumber numberWithFloat:((CGFloat)wholeValue / (CGFloat)255)]];
    }
    
    UIColor *color = [UIColor colorWithRed:[[parts objectAtIndex:3] floatValue]
                                     green:[[parts objectAtIndex:2] floatValue]
                                      blue:[[parts objectAtIndex:1] floatValue]
                                     alpha:[[parts objectAtIndex:0] floatValue]];
    
    return color;
}

+ (NSString *)topLevelKMLFilePathInArchiveAtPath:(NSString *)archivePath
{
    ZipFile *archive = [[ZipFile alloc] initWithFileName:archivePath mode:ZipFileModeUnzip];
    
    NSArray *files = [archive listFileInZipInfos];
    
    for (FileInZipInfo *file in files)
    {
        // look for either "<archive name>/<file name>.kml" or just plain "<file name>.kml"
        //
        if ([[[file name] componentsSeparatedByString:@"/"] count] < 3 && [[[file name] pathExtension] isEqualToString:@"kml"])
        {
            [archive close];
            
            return [file name];
        }
    }
    
    return nil;
}

+ (NSData *)dataFromArchiveAtPath:(NSString *)archivePath withFilePath:(NSString *)filePath
{
    ZipFile *archive = [[ZipFile alloc] initWithFileName:archivePath mode:ZipFileModeUnzip];
    
    if ( ! [archive locateFileInZip:filePath])
    {
        [archive close];
        
        return nil;
    }
    
    FileInZipInfo *info = [archive getCurrentFileInZipInfo];
    
    ZipReadStream *stream = [archive readCurrentFileInZip];
    
    NSMutableData *data = [NSMutableData dataWithLength:info.length];
    
    [stream readDataWithBuffer:data];
    
    [stream finishedReading];
    
    [archive close];
    
    return [NSData dataWithData:data];
}

@end