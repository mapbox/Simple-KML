#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CXMLDocument_CreationExtensions.h"
#import "CXMLNode_CreationExtensions.h"
#import "CXHTMLDocument.h"
#import "CXMLDocument.h"
#import "CXMLDocument_PrivateExtensions.h"
#import "CXMLElement.h"
#import "CXMLElement_CreationExtensions.h"
#import "CXMLElement_ElementTreeExtensions.h"
#import "CXMLNamespaceNode.h"
#import "CXMLNode.h"
#import "CXMLNode_PrivateExtensions.h"
#import "CXMLNode_XPathExtensions.h"
#import "CTidy.h"
#import "TouchXML.h"

FOUNDATION_EXPORT double TouchXMLVersionNumber;
FOUNDATION_EXPORT const unsigned char TouchXMLVersionString[];

