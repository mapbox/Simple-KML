//
//  SimpleKMLOverlay.m
//
//  Created by Justin R. Miller on 7/22/11
//  Copyright 2011, Development Seed, Inc.
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

#import "SimpleKMLOverlay.h"

@implementation SimpleKMLOverlay

@synthesize color;
@synthesize icon;

- (id)initWithXMLNode:(CXMLNode *)node sourceURL:sourceURL error:(NSError **)error
{
    self = [super initWithXMLNode:node sourceURL:sourceURL error:error];
    
    if (self != nil)
    {
        color = nil;
        icon  = nil;
        
        for (CXMLNode *child in [node children])
        {
            if ([[child name] isEqualToString:@"color"])
            {
                NSString *colorString = [child stringValue];
                
                color = [SimpleKML colorForString:colorString];
            }
            else if ([[child name] isEqualToString:@"Icon"])
            {
                CXMLNode *href = nil;
                
                for (CXMLNode *grandchild in [child children])
                {
                    if ([grandchild kind] == CXMLElementKind)
                    {
                        href = grandchild;
                        break;
                    }
                }
                
                if ( ! href)
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (no href specified for Overlay Icon)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                }
                
                NSData *data = nil;
                
                if ([self cacheObjectForKey:[href stringValue]])
                    data = [self cacheObjectForKey:[href stringValue]];
                
                else
                {
                    NSURL *imageURL = [NSURL URLWithString:[href stringValue]];
                    
                    if ( ! imageURL)
                    {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (invalid Icon URL specified in Overlay)" 
                                                                             forKey:NSLocalizedFailureReasonErrorKey];
                        
                        if (error)
                            *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                        
                        return nil;
                    }
                    
                    if ([imageURL scheme])
                        data = [NSData dataWithContentsOfURL:imageURL];
                    
                    else if ([[sourceURL relativePath] hasSuffix:@".kmz"])
                        data = [SimpleKML dataFromArchiveAtPath:[sourceURL relativePath] withFilePath:[imageURL relativePath]];
                    
                    if (data)
                        [self setCacheObject:data forKey:[href stringValue]];
                    
                    else
                    {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (invalid Icon URL specified in Overlay)" 
                                                                             forKey:NSLocalizedFailureReasonErrorKey];
                        
                        if (error)
                            *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                        
                        return nil;
                    }
                }
                
                icon = [UIImage imageWithData:data];
                
                if ( ! icon)
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (unable to retrieve Icon specified for Overlay)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                }
            }
        }
    }
    
    return self;
}

@end