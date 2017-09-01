//
//  PieChart.h
//  KlettAbiLernboxen
//
//  Created by Wang on 25.11.12.
//
//

#import <UIKit/UIKit.h>

@interface PieChart : UIView <PropertyBoardChangeObserver> {
    
    float _gray, _green, _red;
}


- (id) initWithGray:(uint) gray Green:(uint) green Red:(uint) red;

@end
