//
//  PropertyBoardViewController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 15.10.12.
//
//

#import "PropertyBoardViewController.h"
#import "PropertyBoard.h"
#import "PropertyBoardIntegerViewController.h"






#pragma mark - PropertyBoardViewController

@implementation PropertyBoardViewController

@synthesize tableView;


#pragma mark Initializers

- (id) init {
    
    if (self = [super initWithNibName:@"PropertyBoardViewController" bundle:[NSBundle mainBundle]]) {
        
        NSLog(@"PropertyBoardViewController -init");
    }
    
    return self;
}


#pragma mark View

- (void) viewDidLoad {

    NSLog(@"PropertyBoardViewController -viewDidLoad");

    [super viewDidLoad];
    
    [[PropertyBoard instance] addChangeObserver:self];
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    NSLog(@"PropertyBoardViewController -viewDidAppear");

    [self becomeFirstResponder];
}


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    alert(@"rotate");
}


- (NSUInteger) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}


- (BOOL) shouldAutorotate {
    
    return true;
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return true;
}



#pragma mark TableView Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PropertyBoardIntegerViewController* controller = [[PropertyBoardIntegerViewController alloc] initWithPropertyIndexPath:indexPath];
    
    [self.navigationController pushViewController:controller animated:TRUE];
}



#pragma mark TableView DataSource

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [PropertyBoard instance].properties.count + 1;
    // 1 more for "variables"
}


- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return @"Variables";
    }
    else {
    
        NSValue* objectPointer = [[PropertyBoard instance].properties.allKeys objectAtIndex:section - 1];
        NSString* className = NSStringFromClass([(id)[objectPointer pointerValue] class]);
        return [NSString stringWithFormat:@"%@ %@", className, objectPointer];
    }
}


- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        
        return [[PropertyBoard instance] numberOfVariables];
    }
    else {
    
        NSValue* objectPointer = [[PropertyBoard instance].properties.allKeys objectAtIndex:section - 1];
        return [[[PropertyBoard instance].properties objectForKey:objectPointer] count];
    }
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"cellForRowAtIndexPath: %@", indexPath);
    
    if (indexPath.section == 0) {
     
        NSString* variableName = [[PropertyBoard instance] variableNameAtIndex:indexPath.row];
        NSNumber* type = [[PropertyBoard instance] typeForVariableNamed:variableName];
        NSString* typeString = [[PropertyBoard instance] stringForType:type];
        id value = [[PropertyBoard instance] valueForVariableNamed:variableName];
        
        PropertyTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"VariableTableViewCell"];
        
        if (!cell) {
            
            cell = [[PropertyTableViewCell alloc] init];
        }
        
        cell.typeLabel.text = typeString;
        cell.classLabel.text = variableName;
        cell.valueLabel.text = [NSString stringWithFormat:@"%@", value];
        
        return cell;
    }
    else {
    
        NSValue* objectPointer = [[PropertyBoard instance].properties.allKeys objectAtIndex:indexPath.section - 1];
        NSDictionary* properties = [PropertyBoard instance].properties;
        NSArray* objectArray = [[PropertyBoard instance].properties objectForKey:objectPointer];
        NSDictionary* propertyDict = [objectArray objectAtIndex:indexPath.row];
        NSNumber* type = [propertyDict objectForKey:@"type"];
        NSString* typeString = [[PropertyBoard instance] stringForType:type];
        id object = [objectPointer pointerValue];
        NSString* class = NSStringFromClass([object class]);
        NSString* propertyKey = [propertyDict objectForKey:@"key"];
        int value = [[object valueForKey:propertyKey] intValue];
        
        PropertyTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"PropertyTableViewCell"];
        
        if (!cell) {
            
            cell = [[PropertyTableViewCell alloc] init];
        }
        
        cell.typeLabel.text = [NSString stringWithFormat:@"%@", typeString];
        cell.classLabel.text = class;
        cell.valueLabel.text = [NSString stringWithFormat:@"%d", value];
        
        return cell;
    }
}



#pragma mark Motion Events

- (BOOL) canBecomeFirstResponder {
    
    return TRUE;
}


- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    NSLog(@"motion began");
    
    [[PropertyBoard instance] toggleView];
}


- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    NSLog(@"motion ended");
}



#pragma mark Delegates

- (void) propertyChangedForObject:(id)object withKeyPath:(NSString *)keyPath {
    
    [tableView reloadData];
}


- (void) propertyDictionaryDidChange {
    
    [tableView reloadData];
}


- (void) variableValueChangedForName:(NSString *)name {
    
    [tableView reloadData];
}


- (void) variableDictionaryDidChange {
    
    [tableView reloadData];
}


@end




#pragma mark - PropertyTableViewCell

@implementation PropertyTableViewCell

@synthesize typeLabel;
@synthesize classLabel;
@synthesize valueLabel;


- (id) init {
    
    if ((self = [[[NSBundle mainBundle] loadNibNamed:@"PropertyTableViewCell" owner:nil options:nil] objectAtIndex:0])) {
        
    }
    
    return self;
}


- (void) prepareForReuse {
    
    typeLabel.text = @"";
    classLabel.text = @"";
    valueLabel.text = @"";
}

@end
