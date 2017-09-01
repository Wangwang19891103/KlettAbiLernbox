//
//  StatisticsViewController2.h
//  KlettAbiLernboxen
//
//  Created by Wang on 25.11.12.
//
//

#import <Foundation/Foundation.h>
#import "PieChart.h"
#import "CustomNavigationItem.h"


@interface StatisticsViewController2 : UIViewController <PropertyBoardChangeObserver> {
    
    UIScrollView* __strong _scrollView;
    UIView* __strong _contentView;
    
    PieChart* __strong _pieChart;
    
//    BOOL _shadowInitialized;
    
//    CustomNavigationItem* __strong _customNavigationItem;

}


@end
