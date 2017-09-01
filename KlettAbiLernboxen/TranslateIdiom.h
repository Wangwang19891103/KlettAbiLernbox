//
//  TranslateIdiom.h
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 18.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//




#define is_ipad isIdiomIpad()
#define ti_int(i) translateIdiomInt(i)
#define ti_int2(i,j) translateIdiomInt2(i,j)
#define ti_float(f) translateIdiomFloat(f)
#define ti_relInt(i, align) translateIdiomRelativeInt(i, align)
#define ti_point(p) translateIdiomCGPoint(p, FALSE)
#define ti_point_ratio(p) translateIdiomCGPoint(p, TRUE)
#define ti_size(s) translateIdiomCGSize(s, FALSE)
#define ti_size_ratio(s) translateIdiomCGSize(s, TRUE)
#define ti_rect(r) translateIdiomCGRect(r, FALSE)
#define ti_rect_ratio(r) translateIdiomCGRect(r, TRUE)
//#define ti_point_relHCenter(p) translateIdiomCGPointRelativeToHCenter(p)
#define ti_relCoord(i, align) translateIdiomRelativeCoordinate(i, align) 
#define ti_image(s) translateIdiomImageFileName(s)
#define ti_font(f) translateIdiomFont(f)




typedef enum {
    
    TranslateIdiomAlignmentLeft = 1,
    TranslateIdiomAlignmentHCenter = 2,
    TranslateIdiomAlignmentRight = 4,
    TranslateIdiomAlignmentTop = 8,
    TranslateIdiomAlignmentVCenter = 16,
    TranslateIdiomAlignmentBottom = 32,
    TranslateIdiomAlignmentHorizontal = 64,
    TranslateIdiomAlignmentVertical = 128

} TranslateIdiomAlignment;


int screenWidth();
int screenHeight();

BOOL isIdiomIpad();

int translateIdiomInt(int value);
int translateIdiomInt2(int value, float scale);

float translateIdiomFloat(float value);

int translateIdiomRelativeInt(int value, TranslateIdiomAlignment align);

CGPoint translateIdiomCGPoint(CGPoint point, BOOL useRatio);

CGSize translateIdiomCGSize(CGSize size, BOOL useRatio);

CGRect translateIdiomCGRect(CGRect rect, BOOL useRatio);

//CGPoint translateIdiomCGPointRelativeToHCenter(CGPoint point);

int translateIdiomRelativeCoordinate(int i, TranslateIdiomAlignment alignment);

NSString* translateIdiomImageFileName(NSString* fileName);

UIFont* translateIdiomFont(UIFont* font);