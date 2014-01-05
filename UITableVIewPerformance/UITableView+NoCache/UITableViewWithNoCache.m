
#import "UITableViewWithNoCache.h"
#import "AppDelegate.h"

@interface UITableViewWithNoCache () {
    NSArray *_objects;
    NSMutableArray *_images;
}
@end

@implementation UITableViewWithNoCache

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _objects = [AppDelegate sampleImageUrls];
    _images = [NSMutableArray array];
}

-(void)dealloc
{
    [_images removeAllObjects];
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
    static NSString *CellIdentifier = @"ImageCacheCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"Image #%ld", indexPath.row];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.tag = indexPath.row;

    if(indexPath.row < _images.count ){
        id imageObject = [_images objectAtIndex:indexPath.row];
        if( ![imageObject isEqual:[NSNull null]]){
            cell.imageView.image = imageObject;
        } else {
            cell.imageView.image = [UIImage imageNamed:@"placeholder"];
        }
    } else {
        cell.imageView.image = [UIImage imageNamed:@"placeholder"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL* url = [NSURL URLWithString:[_objects objectAtIndex:indexPath.row]];
            NSData *data    = [NSData dataWithContentsOfURL:url];
            if(!data){
                [_images addObject:[NSNull alloc]];
                return;
            }
            UIImage *img    = [[UIImage alloc] initWithData:data];
            [_images addObject:img];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(cell.tag == indexPath.row){
                    [cell.imageView setImage:img];
                    [cell setNeedsDisplay];
                } else {
                    NSLog(@"Cell%ld is recycled", cell.tag);
                }
            });
        });
    }

    return cell;
}


@end
