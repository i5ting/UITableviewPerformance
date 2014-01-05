
#import "UITableViewWithTmCache.h"
#import "TMCache.h"
#import "AppDelegate.h"

@interface UITableViewWithTmCache () {
    NSArray *_objects;
}
@end

@implementation UITableViewWithTmCache

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _objects = [AppDelegate sampleImageUrls];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TmCacheCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Image #%ld", indexPath.row];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.tag = indexPath.row;
    [cell.imageView setImage:[UIImage imageNamed:@"placeholder"]];
    
    [[TMCache sharedCache] objectForKey:[_objects objectAtIndex:indexPath.row]
                                  block:^(TMCache *cache, NSString *key, id object) {
                                      if (object) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [cell setNeedsDisplay];
                                              [cell.imageView setImage:object];
                                          });
                                          return;
                                      }
                                      
                                      NSURL* url = [NSURL URLWithString:[_objects objectAtIndex:indexPath.row]];
                                      NSData *data    = [NSData dataWithContentsOfURL:url];
                                      if(!data){
                                          return;
                                      }
                                      
                                      UIImage *img    = [[UIImage alloc] initWithData:data scale:[[UIScreen mainScreen] scale]];
                                      NSLog(@"setting view image %@", NSStringFromCGSize(img.size));
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          if(cell.tag == indexPath.row){
                                              [cell.imageView setImage:img];
                                              [cell setNeedsDisplay];
                                          } else {
                                              NSLog(@"Cell%ld is recycled", cell.tag);
                                          }
                                      });
                                      
                                      [[TMCache sharedCache] setObject:img forKey:[_objects objectAtIndex:indexPath.row]];
                                  }];


    return cell;
}


@end
