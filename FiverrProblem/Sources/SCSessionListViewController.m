//
//  SCSessionListViewController.m
//  SCRecorderExamples
//
//  Created by Simon CORSIN on 14/08/14.
//
//

#import "SCSessionListViewController.h"
#import "SCRecordSessionManager.h"
#import "SCSessionTableViewCell.h"

@interface SCSessionListViewController ()

@end

@implementation SCSessionListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save current" style:UIBarButtonItemStyleBordered target:self action:@selector(saveCurrentRecordSession)];
    // Do any additional setup after loading the view.
}

- (void)saveCurrentRecordSession {
  
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

   
 
    NSDictionary *recordSessionMetadata = [[SCRecordSessionManager sharedInstance].savedRecordSessions objectAtIndex:indexPath.row];
    
    SCRecordSession *newRecordSession = [SCRecordSession recordSession:recordSessionMetadata];
    _recorder.session = newRecordSession;
    
    
    [self dismissViewControllerAnimated:true completion:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SCSessionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Session"];
    NSDictionary *recordSession = [[SCRecordSessionManager sharedInstance].savedRecordSessions objectAtIndex:([SCRecordSessionManager sharedInstance].savedRecordSessions.count - indexPath.row - 1)];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm"];
    
       cell.backgroundColor = [UIColor clearColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.dateLabel.text = [formatter stringFromDate:recordSession[SCRecordSessionDateKey]];
    
    NSArray *recordSegments = recordSession[SCRecordSessionSegmentsKey];
    
    cell.segmentsCountLabel.text = [NSString stringWithFormat:@"%d segments", (int)[recordSegments count]];
    
    cell.durationLabel.text = [NSString stringWithFormat:@"%fs", [recordSession[SCRecordSessionDurationKey] doubleValue]];
    
    if (recordSegments.count > 0) {
        NSDictionary *dictRepresentation = recordSegments.firstObject;
        NSString *directory = recordSession[SCRecordSessionDirectoryKey];
        SCRecordSessionSegment *segment = [[SCRecordSessionSegment alloc] initWithDictionaryRepresentation:dictRepresentation directory:directory];
        
        [cell.videoPlayerView.player setItemByAsset:segment.asset];
    }
    
    return cell;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Fades out top and bottom cells in table view as they leave the screen
    NSArray *visibleCells = [self.tableView visibleCells];
    
    if (visibleCells != nil  &&  [visibleCells count] != 0) {       // Don't do anything for empty table view
        
        /* Get top and bottom cells */
        UITableViewCell *topCell = [visibleCells objectAtIndex:0];
        UITableViewCell *bottomCell = [visibleCells lastObject];
        
        /* Make sure other cells stay opaque */
        // Avoids issues with skipped method calls during rapid scrolling
        for (UITableViewCell *cell in visibleCells) {
            cell.contentView.alpha = 1.0;
        }
        
        /* Set necessary constants */
        NSInteger cellHeight = topCell.frame.size.height - 1;   // -1 To allow for typical separator line height
        NSInteger tableViewTopPosition = self.tableView.frame.origin.y;
        NSInteger tableViewBottomPosition = self.tableView.frame.origin.y + self.tableView.frame.size.height;
        
        /* Get content offset to set opacity */
        CGRect topCellPositionInTableView = [self.tableView rectForRowAtIndexPath:[self.tableView indexPathForCell:topCell]];
        CGRect bottomCellPositionInTableView = [self.tableView rectForRowAtIndexPath:[self.tableView indexPathForCell:bottomCell]];
        CGFloat topCellPosition = [self.tableView convertRect:topCellPositionInTableView toView:[self.tableView superview]].origin.y;
        CGFloat bottomCellPosition = ([self.tableView convertRect:bottomCellPositionInTableView toView:[self.tableView superview]].origin.y + cellHeight);
        
        /* Set opacity based on amount of cell that is outside of view */
        CGFloat modifier = 2.5;     /* Increases the speed of fading (1.0 for fully transparent when the cell is entirely off the screen,
                                     2.0 for fully transparent when the cell is half off the screen, etc) */
        CGFloat topCellOpacity = (1.0f - ((tableViewTopPosition - topCellPosition) / cellHeight) * modifier);
        CGFloat bottomCellOpacity = (1.0f - ((bottomCellPosition - tableViewBottomPosition) / cellHeight) * modifier);
        
        /* Set cell opacity */
        if (topCell) {
            topCell.contentView.alpha = topCellOpacity;
        }
        if (bottomCell) {
            bottomCell.contentView.alpha = bottomCellOpacity;
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *recordSession = [[SCRecordSessionManager sharedInstance].savedRecordSessions objectAtIndex:indexPath.row];
    
    NSArray *urls = recordSession[SCRecordSessionSegmentFilenamesKey];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    for (NSString *path in urls) {
        [manager removeItemAtPath:path error:nil];
    }
    
    [[SCRecordSessionManager sharedInstance] removeRecordSessionAtIndex:indexPath.row];
    
    if ([_recorder.session.identifier isEqualToString:[recordSession objectForKey:SCRecordSessionIdentifierKey]]) {
        _recorder.session = nil;
    }
    
    [tableView beginUpdates];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [tableView endUpdates];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [SCRecordSessionManager sharedInstance].savedRecordSessions.count;
}

@end
