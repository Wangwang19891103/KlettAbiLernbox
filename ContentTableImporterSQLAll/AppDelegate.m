//
//  AppDelegate.m
//  ContentTableImporterSQLAll
//
//  Created by Wang on 20.09.12.
//
//

#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "DataManager.h"
#import "ContentsDataManager.h"
#import "ContentsModule.h"
#import "LogManager.h"


#define DB_NAME @"contents"
#define DELIMITER @"#"
//#define USE_SUBCATEGORIES TRUE


static NSString* __fileNames[7] = {
    
    @"contents_Biologie.csv",
    @"contents_Deutsch.csv",
    @"contents_Geschichte.csv",
    @"contents_Mathematik.csv",
    @"contents_Physik.csv",
    @"contents_Chemie.csv",
    @"contents_Englisch.csv"
};

static NSString* __moduleNames[7] = {

    @"Biologie",
    @"Deutsch",
    @"Geschichte",
    @"Mathematik",
    @"Physik",
    @"Chemie",
    @"Englisch"
};


@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[DataManager instanceNamed:@"contents"] clearStore];
    
    uint importedLines = 0;
    
    for (int i = 0; i < 7; ++i) {
    
        NSString* CSV_NAME = __fileNames[i];
        NSString* moduleName = __moduleNames[i];
    
        
        ContentsModule* module = [[DataManager instanceNamed:@"contents"] insertNewObjectForEntityName:@"ContentsModule"];
        module.name = moduleName;
        
        
        NSString* contentsPath = [[NSBundle mainBundle] pathForResource:CSV_NAME ofType:nil];
        NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [pathArray lastObject];
        NSString* contents = [NSString stringWithContentsOfFile:contentsPath encoding:NSUTF8StringEncoding error:nil];
        
        NSLog(@"contents path: %@", contentsPath);
        
        
        NSArray* lines = [contents componentsSeparatedByString:@"\n"];
        uint skipped = 0;
        uint pagePosition = 1;
        uint categoryPosition = 0;
        uint subcategoryPosition = 0;
        
        
        for (NSString* line in lines) {
            
            NSLog(@"%@", line);
            
            NSArray* dataset = [line componentsSeparatedByString:DELIMITER];
            if ([dataset count] <= 1) {
                NSLog(@"--- SKIPPING!");
                ++skipped;
                continue;
            }
            else {
                ++importedLines;
            }
            
            NSString* category1 = [dataset objectAtIndex:1];
            NSString* category2 = nil;
            NSString* title = nil;
            BOOL categoryWasCreated = FALSE;
            BOOL subcategoryWasCreated = FALSE;
            
            
            /* es wird davon ausgegangen, dass alle gleichen Categories und Subcategories in der CSV-Datei untereinander stehen */
            
            
            ContentsCategory* category = [ContentsDataManager fetchOrCreateCategoryWithName:category1 wasCreated:&categoryWasCreated];
            category.module = module;
            
            if (categoryWasCreated) {
                category.position = [NSNumber numberWithInt:categoryPosition];
                category.firstPageNumber = [NSNumber numberWithInt:pagePosition];
                category.numberOfPages = [NSNumber numberWithInt:0];
                category.firstSubcategoryNumber = [NSNumber numberWithInt:subcategoryPosition];
                category.numberOfSubcategories = [NSNumber numberWithInt:0];
                ++categoryPosition;
            }
            category.numberOfPages = [NSNumber numberWithInt:[category.numberOfPages intValue] + 1];
            
            
            ContentsPage* page = nil;
            
            BOOL USE_SUBCATEGORIES = (dataset.count == 4);
            
            /* using subcategories */
            if (USE_SUBCATEGORIES) {
                
                category2 = [dataset objectAtIndex:2];
                title = [dataset objectAtIndex:3];
                
                ContentsSubcategory* subcategory = [ContentsDataManager fetchOrCreateSubcategoryWithName:category2 forCategory:category wasCreated:&subcategoryWasCreated];
                
                if (subcategoryWasCreated) {
                    subcategory.position = [NSNumber numberWithInt:subcategoryPosition];
                    subcategory.firstPageNumber = [NSNumber numberWithInt:pagePosition];
                    subcategory.numberOfPages = [NSNumber numberWithInt:0];
                    category.numberOfSubcategories = [NSNumber numberWithInt:[category.numberOfSubcategories intValue] + 1];
                    ++subcategoryPosition;
                }
                subcategory.numberOfPages = [NSNumber numberWithInt:[subcategory.numberOfPages intValue] + 1];
                
                page = [ContentsDataManager createPageWithName:title forSubcategory:subcategory];
            }
            
            /* not using subcategories */
            else {
                
                title = [dataset objectAtIndex:2];
                
                page = [ContentsDataManager createPageWithName:title forCategory:category];
            }
            
            page.position = [NSNumber numberWithInt:pagePosition];
            
            ++pagePosition;
        }

    }
        
    NSLog(@"Imported %d lines", importedLines);
    
    [ContentsDataManager save];
    
    
    
    
    
    /* testing contents */
    
    NSLog(@"--------------------------------------------------------");
    
    NSArray* subcategories = [[DataManager instanceNamed:@"contents"] fetchDataForEntityName:@"ContentsSubcategory" withPredicate:nil sortedBy:@"position", nil];
    
    for (ContentsSubcategory* subcategory in subcategories) {
        
        LogM(@"test_subcategories", @"%@\n", subcategory.name);
    }
    
    
    LogM_write(@"test_subcategories");
    
    
    
    NSArray* pages = [[DataManager instanceNamed:@"contents"] fetchDataForEntityName:@"ContentsPage" withPredicate:nil sortedBy:@"position", nil];
    
    for (ContentsPage* page in pages) {
        
        LogM(@"test_pages", @"%@ (pos: %@, P1st: %@, Pcnt: %@, S1st: %@, Scnt: %@)  -  %@ (pos: %@, 1st: %@, cnt: %@)  -  %@ (pos: %@)\n",
             page.category.name,
             page.category.position,
             page.category.firstPageNumber,
             page.category.numberOfPages,
             page.category.firstSubcategoryNumber,
             page.category.numberOfSubcategories,
             page.subcategory.name,
             page.subcategory.position,
             page.subcategory.firstPageNumber,
             page.subcategory.numberOfPages,
             page.name,
             page.position
             );
    }
    
    NSLog(@"number of pages in DB: %d", pages.count);
    
    LogM_write(@"test_pages");
    
    return YES;
}

@end
