#import "Scanner.h"





// STUE

// workarounds:
//
// Tm --> always a space character " "









// STUE

static BOOL pointInsideRect(CGPoint point, CGRect rect) {
    
    if (point.x < rect.origin.x ||
        point.x > rect.origin.x + rect.size.width ||
        point.y < rect.origin.y ||
        point.y > rect.origin.y + rect.size.height) {
        
        return FALSE;
    }
    else return TRUE;
}


#pragma mark 

@interface Scanner ()

#pragma mark - Text showing

// Text-showing operators
void Tj(CGPDFScannerRef scanner, void *info);
void quot(CGPDFScannerRef scanner, void *info);
void doubleQuot(CGPDFScannerRef scanner, void *info);
void TJ(CGPDFScannerRef scanner, void *info);

#pragma mark Text positioning

// Text-positioning operators
void Td(CGPDFScannerRef scanner, void *info);
void TD(CGPDFScannerRef scanner, void *info);
void Tm(CGPDFScannerRef scanner, void *info);
void TStar(CGPDFScannerRef scanner, void *info);

#pragma mark Text state

// Text state operators
void BT(CGPDFScannerRef scanner, void *info);
void Tc(CGPDFScannerRef scanner, void *info);
void Tw(CGPDFScannerRef scanner, void *info);
void Tz(CGPDFScannerRef scanner, void *info);
void TL(CGPDFScannerRef scanner, void *info);
void Tf(CGPDFScannerRef scanner, void *info);
void Ts(CGPDFScannerRef scanner, void *info);
void ET(CGPDFScannerRef scanner, void *info);

#pragma mark Graphics state

// Special graphics state operators
void q(CGPDFScannerRef scanner, void *info);
void Q(CGPDFScannerRef scanner, void *info);
void cm(CGPDFScannerRef scanner, void *info);

@property (nonatomic, retain) Selection *currentSelection;
@property (nonatomic, readonly) RenderingState *currentRenderingState;
@property (nonatomic, readonly) Font *currentFont;
@property (nonatomic, readonly) CGPDFDocumentRef pdfDocument;
@property (nonatomic, copy) NSURL *documentURL;

/* Returts the operator callbacks table for scanning page stream */
@property (nonatomic, readonly) CGPDFOperatorTableRef operatorTable;

@end

#pragma mark

@implementation Scanner

#pragma mark - Initialization

- (id)initWithDocument:(CGPDFDocumentRef)document
{
	if ((self = [super init]))
	{
		pdfDocument = CGPDFDocumentRetain(document);
		self.content = [NSMutableString string];
	}
	return self;
}

- (id)initWithContentsOfFile:(NSString *)path
{
	if ((self = [super init]))
	{
		self.documentURL = [NSURL fileURLWithPath:path];
	}
	return self;
}

#pragma mark Scanner state accessors

- (RenderingState *)currentRenderingState
{
	return [self.renderingStateStack topRenderingState];
}

- (Font *)currentFont
{
	return self.currentRenderingState.font;
}

- (CGPDFDocumentRef)pdfDocument
{
	if (!pdfDocument)
	{
		pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)self.documentURL);
	}
	return pdfDocument;
}

/* The operator table used for scanning PDF pages */
- (CGPDFOperatorTableRef)operatorTable
{
	if (operatorTable)
	{
		return operatorTable;
	}
	
	operatorTable = CGPDFOperatorTableCreate();

	// Text-showing operators
	CGPDFOperatorTableSetCallback(operatorTable, "Tj", Tj);
	CGPDFOperatorTableSetCallback(operatorTable, "\'", quot);
	CGPDFOperatorTableSetCallback(operatorTable, "\"", doubleQuot);
	CGPDFOperatorTableSetCallback(operatorTable, "TJ", TJ);
	
	// Text-positioning operators
	CGPDFOperatorTableSetCallback(operatorTable, "Tm", Tm);
	CGPDFOperatorTableSetCallback(operatorTable, "Td", Td);		
	CGPDFOperatorTableSetCallback(operatorTable, "TD", TD);
	CGPDFOperatorTableSetCallback(operatorTable, "T*", TStar);
	
	// Text state operators
	CGPDFOperatorTableSetCallback(operatorTable, "Tw", Tw);
	CGPDFOperatorTableSetCallback(operatorTable, "Tc", Tc);
	CGPDFOperatorTableSetCallback(operatorTable, "TL", TL);
	CGPDFOperatorTableSetCallback(operatorTable, "Tz", Tz);
	CGPDFOperatorTableSetCallback(operatorTable, "Ts", Ts);
	CGPDFOperatorTableSetCallback(operatorTable, "Tf", Tf);
	
	// Graphics state operators
	CGPDFOperatorTableSetCallback(operatorTable, "cm", cm);
	CGPDFOperatorTableSetCallback(operatorTable, "q", q);
	CGPDFOperatorTableSetCallback(operatorTable, "Q", Q);
	
	CGPDFOperatorTableSetCallback(operatorTable, "BT", BT);
	CGPDFOperatorTableSetCallback(operatorTable, "ET", ET);
	
	return operatorTable;
}

/* Create a font dictionary given a PDF page */
- (FontCollection *)fontCollectionWithPage:(CGPDFPageRef)page
{
	CGPDFDictionaryRef dict = CGPDFPageGetDictionary(page);
	if (!dict)
	{
		NSLog(@"Scanner: fontCollectionWithPage: page dictionary missing");
		return nil;
	}
	CGPDFDictionaryRef resources;
	if (!CGPDFDictionaryGetDictionary(dict, "Resources", &resources))
	{
		NSLog(@"Scanner: fontCollectionWithPage: page dictionary missing Resources dictionary");
		return nil;	
	}
	CGPDFDictionaryRef fonts;
	if (!CGPDFDictionaryGetDictionary(resources, "Font", &fonts)) return nil;
	FontCollection *collection = [[FontCollection alloc] initWithFontDictionary:fonts];
	return [collection autorelease];
}

/* Scan the given page of the current document */
- (void)scanDocumentPage:(NSUInteger)pageNumber
{
	CGPDFPageRef page = CGPDFDocumentGetPage(self.pdfDocument, pageNumber);
    [self scanPage:page];
}

#pragma mark Start scanning

- (void)scanPage:(CGPDFPageRef)page
{
	// Return immediately if no keyword set
//	if (!keyword) return;
    
    [self.stringDetector reset];
    self.stringDetector.keyword = self.keyword;

    // Initialize font collection (per page)
	self.fontCollection = [self fontCollectionWithPage:page];
    
    // STUE
    self.cropBoxRect = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    
	CGPDFContentStreamRef contentStream = CGPDFContentStreamCreateWithPage(page);
	CGPDFScannerRef scanner = CGPDFScannerCreate(contentStream, self.operatorTable, self);
	CGPDFScannerScan(scanner);
	CGPDFScannerRelease(scanner); scanner = nil;
	CGPDFContentStreamRelease(contentStream); contentStream = nil;
}


// STUE

- (BOOL) isCurrentPositionOutsideOfCropbox {
    
    RenderingState* state = self.currentRenderingState;
    CGAffineTransform transform = CGAffineTransformConcat([state textMatrix], [state ctm]);
//    CGPoint origin = CGPointMake(transform.tx, transform.ty);
    CGPoint origin = CGPointMake(self.cropBoxRect.origin.x, transform.ty);
    
    if (pointInsideRect(origin, self.cropBoxRect)) {
        return FALSE;
    }
    else return TRUE;
}


#pragma mark StringDetectorDelegate

// STUE
- (BOOL) detectorShouldStartMatching:(StringDetector *)detector {
    
    if ([self isCurrentPositionOutsideOfCropbox])
        return FALSE;
    else 
        return TRUE;
}


- (void)detector:(StringDetector *)detector didScanCharacter:(unichar)character
{
	RenderingState *state = [self currentRenderingState];
	CGFloat width = [self.currentFont widthOfCharacter:character withFontSize:state.fontSize];
	width /= 1000;
	width += state.characterSpacing;
	if (character == 32)
	{
		width += state.wordSpacing;
	}
	[state translateTextPosition:CGSizeMake(width, 0)];
}

- (void)detector:(StringDetector *)detector didStartMatchingString:(NSString *)string
{
	Selection *sel = [[Selection alloc] initWithStartState:self.currentRenderingState];
	self.currentSelection = sel;
	[sel release];
}

- (void)detector:(StringDetector *)detector foundString:(NSString *)needle
{	
	RenderingState *state = [[self renderingStateStack] topRenderingState];
	[self.currentSelection finalizeWithState:state];

	if (self.currentSelection)
	{
		[self.selections addObject:self.currentSelection];
		self.currentSelection = nil;
	}
}

#pragma mark - Scanner callbacks

void BT(CGPDFScannerRef scanner, void *info)
{
    
    LOG(@"BT");
    LogM(@"scanner_tags", @"BT\n");
	[[(Scanner *)info currentRenderingState] setTextMatrix:CGAffineTransformIdentity replaceLineMatrix:YES];
}

/* Pops the requested number of values, and returns the number of values popped */
// !!!: Make sure this is correct, then use it
int popIntegers(CGPDFScannerRef scanner, CGPDFInteger *buffer, size_t length)
{
    bzero(buffer, length);
    CGPDFInteger value;
    int i = 0;
    while (i < length)
    {
        if (!CGPDFScannerPopInteger(scanner, &value)) break;
        buffer[i] = value;
        i++;
    }
    return i;
}

#pragma mark Text showing operators

void didScanSpace(float value, Scanner *scanner)
{
    LOG(@"(space");
    LogM(@"scanner_tags", @"didScanSpace: width=%f\n", value);
    float width = [scanner.currentRenderingState convertToUserSpace:value];
    [scanner.currentRenderingState translateTextPosition:CGSizeMake(-width, 0)];
    if (abs(value) >= [scanner.currentRenderingState.font widthOfSpace])
    {
        [scanner.stringDetector reset];
    }
}

/* Called any time the scanner scans a string */
void didScanString(CGPDFStringRef pdfString, Scanner *scanner)
{
	NSString *string = [[scanner stringDetector] appendPDFString:pdfString withFont:[scanner currentFont]];
    LOG2(@"string: _%@_", string);
    LogM(@"scanner_tags", @"didScanString:\t\t\t\t\t\t\t\t'%@'\n", string);
	[[scanner content] appendString:string];
}

void didScanNewline(Scanner *scanner)
{
    LOG(@"(newline)");
    LogM(@"scanner_tags", @"didScanNewLine\n");
    [[scanner content] appendString:@"\n"];
}


/* Show a string */
void Tj(CGPDFScannerRef scanner, void *info)
{
    LOG(@"Tj");
    LogM(@"scanner_tags", @"Tj\n");
	CGPDFStringRef pdfString = nil;
	if (!CGPDFScannerPopString(scanner, &pdfString)) return;
	didScanString(pdfString, info);
}

/* Equivalent to operator sequence [T*, Tj] */
void quot(CGPDFScannerRef scanner, void *info)
{
    LOG(@"quot");
    LogM(@"scanner_tags", @"quot\n");

	TStar(scanner, info);
	Tj(scanner, info);
}

/* Equivalent to the operator sequence [Tw, Tc, '] */
void doubleQuot(CGPDFScannerRef scanner, void *info)
{
    LOG(@"doubleQuot");
    LogM(@"scanner_tags", @"doubleQuot\n");

	Tw(scanner, info);
	Tc(scanner, info);
	quot(scanner, info);
}

/* Array of strings and spacings */
void TJ(CGPDFScannerRef scanner, void *info)
{
    LOG(@"TJ");
    LogM(@"scanner_tags", @"TJ\n");

	CGPDFArrayRef array = nil;
	CGPDFScannerPopArray(scanner, &array);
    size_t count = CGPDFArrayGetCount(array);
	for (int i = 0; i < count; i++)
	{
		CGPDFObjectRef object = nil;
		CGPDFArrayGetObject(array, i, &object);
		CGPDFObjectType type = CGPDFObjectGetType(object);
        switch (type)
        {
            case kCGPDFObjectTypeString:
            {
                CGPDFStringRef pdfString;
                if (CGPDFObjectGetValue(object, kCGPDFObjectTypeString, &pdfString))
                {
                    didScanString(pdfString, info);
                }
                break;
            }
            case kCGPDFObjectTypeReal:
            {
                CGPDFReal tx;
                if (CGPDFObjectGetValue(object, kCGPDFObjectTypeReal, &tx))
                {
                    didScanSpace(tx, info);
                }
                break;
            }
            case kCGPDFObjectTypeInteger:
            {
                CGPDFInteger tx;
                if (CGPDFObjectGetValue(object, kCGPDFObjectTypeInteger, &tx))
                {
                    didScanSpace(tx, info);
                }
                break;
            }
            default:
                NSLog(@"Scanner: TJ: Unsupported type: %d", type);
                break;
        }
	}
}

void ET(CGPDFScannerRef scanner, void *info) {
    
    LOG(@"ET");
    LogM(@"scanner_tags", @"ET\n");
    didScanNewline(info);
}


#pragma mark Text positioning operators

/* Move to start of next line */
void Td(CGPDFScannerRef scanner, void *info)
{
    LOG(@"Td");

	CGPDFReal tx = 0, ty = 0;
	CGPDFScannerPopNumber(scanner, &ty);
	CGPDFScannerPopNumber(scanner, &tx);
	[[(Scanner *)info currentRenderingState] newLineWithLeading:-ty indent:tx save:NO];
    LogM(@"scanner_tags", @"Td: tx=%f, ty=%f\n", tx, ty);
    didScanNewline(info);
}

/* Move to start of next line, and set leading */
void TD(CGPDFScannerRef scanner, void *info)
{
    LOG(@"TD");

	CGPDFReal tx, ty;
	if (!CGPDFScannerPopNumber(scanner, &ty)) return;
	if (!CGPDFScannerPopNumber(scanner, &tx)) return;
	[[(Scanner *)info currentRenderingState] newLineWithLeading:-ty indent:tx save:YES];
    LogM(@"scanner_tags", @"TD: tx=%f, ty=%f\n", tx, ty);
    didScanNewline(info);
}

/* Set line and text matrixes */
void Tm(CGPDFScannerRef scanner, void *info)
{
    LOG(@"Tm");
    
	CGPDFReal a, b, c, d, tx, ty;
	if (!CGPDFScannerPopNumber(scanner, &ty)) return;
	if (!CGPDFScannerPopNumber(scanner, &tx)) return;
	if (!CGPDFScannerPopNumber(scanner, &d)) return;
	if (!CGPDFScannerPopNumber(scanner, &c)) return;
	if (!CGPDFScannerPopNumber(scanner, &b)) return;
	if (!CGPDFScannerPopNumber(scanner, &a)) return;
	CGAffineTransform t = CGAffineTransformMake(a, b, c, d, tx, ty);
    LOG2(@"%@", NSStringFromCGAffineTransform(t));
    LogM(@"scanner_tags", @"Tm: oldTransform=%@, newTransform: %@\n", NSStringFromCGAffineTransform([(Scanner *)info currentRenderingState].textMatrix), NSStringFromCGAffineTransform(t));

	[[(Scanner *)info currentRenderingState] setTextMatrix:t replaceLineMatrix:YES];

    
    // WORKAROUND
    
    [[(Scanner*)info content] appendString:@" "];
}

/* Go to start of new line, using stored text leading */
void TStar(CGPDFScannerRef scanner, void *info)
{
    LOG(@"Tstar");
    LogM(@"scanner_tags", @"TStar\n");

	[[(Scanner *)info currentRenderingState] newLine];
    didScanNewline(info);                   // corrected by stue
}

#pragma mark Text State operators

/* Set character spacing */
void Tc(CGPDFScannerRef scanner, void *info)
{
    LOG(@"Tc");

	CGPDFReal charSpace;
	if (!CGPDFScannerPopNumber(scanner, &charSpace)) return;
    LogM(@"scanner_tags", @"Tc: charSpace=%f\n", charSpace);
	[[(Scanner *)info currentRenderingState] setCharacterSpacing:charSpace];
}

/* Set word spacing */
void Tw(CGPDFScannerRef scanner, void *info)
{
    LOG(@"Tw");

	CGPDFReal wordSpace;
	if (!CGPDFScannerPopNumber(scanner, &wordSpace)) return;
    LogM(@"scanner_tags", @"Tw: wordSpace=%f\n", wordSpace);

	[[(Scanner *)info currentRenderingState] setWordSpacing:wordSpace];
}

/* Set horizontal scale factor */
void Tz(CGPDFScannerRef scanner, void *info)
{
    LOG(@"Tz");

	CGPDFReal hScale;
	if (!CGPDFScannerPopNumber(scanner, &hScale)) return;
    LogM(@"scanner_tags", @"Tz: hScale=%f\n", hScale);

	[[(Scanner *)info currentRenderingState] setHorizontalScaling:hScale];
}

/* Set text leading */
void TL(CGPDFScannerRef scanner, void *info)
{
    LOG(@"TL");

	CGPDFReal leading;
	if (!CGPDFScannerPopNumber(scanner, &leading)) return;
    LogM(@"scanner_tags", @"TL: leading=%f\n", leading);

	[[(Scanner *)info currentRenderingState] setLeadning:leading];
}

/* Font and font size */
void Tf(CGPDFScannerRef scanner, void *info)
{

	CGPDFReal fontSize;
	const char *fontName;
	if (!CGPDFScannerPopNumber(scanner, &fontSize)) return;
	if (!CGPDFScannerPopName(scanner, &fontName)) return;
	
	RenderingState *state = [(Scanner *)info currentRenderingState];
	Font *font = [[(Scanner *)info fontCollection] fontNamed:[NSString stringWithUTF8String:fontName]];
	[state setFont:font];
	[state setFontSize:fontSize];

    LOG(@"Tf\t(size=%f)", (float)fontSize);
    LogM(@"scanner_tags", @"Tf: fontName=%s, size=%f\n", fontName, fontSize);

}

/* Set text rise */
void Ts(CGPDFScannerRef scanner, void *info)
{
    LOG(@"Ts");

	CGPDFReal rise;
	if (!CGPDFScannerPopNumber(scanner, &rise)) return;
    LogM(@"scanner_tags", @"Ts: rise=%f\n", rise);

	[[(Scanner *)info currentRenderingState] setTextRise:rise];
}


#pragma mark Graphics state operators

/* Push a copy of current rendering state */
void q(CGPDFScannerRef scanner, void *info)
{
    LOG(@"q");
    LogM(@"scanner_tags", @"q\n");

	RenderingStateStack *stack = [(Scanner *)info renderingStateStack];
	RenderingState *state = [[(Scanner *)info currentRenderingState] copy];
	[stack pushRenderingState:state];
	[state release];
}

/* Pop current rendering state */
void Q(CGPDFScannerRef scanner, void *info)
{
    LOG(@"Q");
    LogM(@"scanner_tags", @"Q\n");

	[[(Scanner *)info renderingStateStack] popRenderingState];
}

/* Update CTM */
void cm(CGPDFScannerRef scanner, void *info)
{

	CGPDFReal a, b, c, d, tx, ty;
	if (!CGPDFScannerPopNumber(scanner, &ty)) return;
	if (!CGPDFScannerPopNumber(scanner, &tx)) return;
	if (!CGPDFScannerPopNumber(scanner, &d)) return;
	if (!CGPDFScannerPopNumber(scanner, &c)) return;
	if (!CGPDFScannerPopNumber(scanner, &b)) return;
	if (!CGPDFScannerPopNumber(scanner, &a)) return;

	
    LOG(@"cm\t(a=%f, b=%f, c=%f, d=%f, tx=%f, ty=%f)", a, b, c, d, tx, ty);

	RenderingState *state = [(Scanner *)info currentRenderingState];
	CGAffineTransform t = CGAffineTransformMake(a, b, c, d, tx, ty);
	state.ctm = CGAffineTransformConcat(state.ctm, t);
    LogM(@"scanner_tags", @"cm: transform: %@\n", NSStringFromCGAffineTransform(t));
}


#pragma mark -
#pragma mark Memory management

- (RenderingStateStack *)renderingStateStack
{
	if (!renderingStateStack)
	{
		renderingStateStack = [[RenderingStateStack alloc] init];
	}
	return renderingStateStack;
}

- (StringDetector *)stringDetector
{
	if (!stringDetector)
	{
		stringDetector = [[StringDetector alloc] initWithKeyword:self.keyword];
		stringDetector.delegate = self;
	}
	return stringDetector;
}

- (NSMutableArray *)selections
{
	if (!selections)
	{
		selections = [[NSMutableArray alloc] init];
	}
	return selections;
}

- (void)dealloc
{
	CGPDFOperatorTableRelease(operatorTable);
	[currentSelection release];
	[fontCollection release];
	[renderingStateStack release];
	[keyword release]; keyword = nil;
	[stringDetector release];
	[documentURL release]; documentURL = nil;
	CGPDFDocumentRelease(pdfDocument); pdfDocument = nil;
	[content release];
    [selections release];
	[super dealloc];
}

@synthesize documentURL, keyword, stringDetector, fontCollection, renderingStateStack, currentSelection, selections /* rawTextContent */, content;

// STUE
@synthesize cropBoxRect;

@end
