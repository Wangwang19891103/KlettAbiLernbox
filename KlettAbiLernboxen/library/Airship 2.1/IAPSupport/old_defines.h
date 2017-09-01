//
//  old_defines.h
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 23.09.14.
//
//

#ifndef KlettAbiLernboxen_old_defines_h
#define KlettAbiLernboxen_old_defines_h

#define kUpdateFGColor RGBA(255, 131, 48, 1)
#define kUpdateBGColor RGBA(255, 228, 201, 1)

#define kInstalledFGColor RGBA(60, 150, 60, 1)
#define kInstalledBGColor RGBA(185, 220, 185, 1)

#define kDownloadingFGColor RGBA(45, 138, 193, 1)
#define kDownloadingBGColor RGBA(173, 213, 237, 1)

#define kPriceFGColor [UIColor darkTextColor]
#define kPriceBorderColor RGBA(185, 185, 185, 1)
#define kPriceBGColor RGBA(217, 217, 217, 1)

#define IF_IOS4_OR_GREATER(...)

#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

#define RGBA(r,g,b,a) [UIColor colorWithRed: r/255.0f green: g/255.0f \
blue: b/255.0f alpha: a]

#endif
