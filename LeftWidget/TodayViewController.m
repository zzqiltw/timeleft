//
//  TodayViewController.m
//  LeftWidget
//
//  Created by 郑志勤 on 2017/4/24.
//  Copyright © 2017年 zzqiltw. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#import <EventKit/EventKit.h>
#import "Macro.h"
#import "NSDate+ZQ.h"
#import "ZQTimeTableViewCell.h"
#import <Masonry/Masonry.h>

@interface TodayViewController () <NCWidgetProviding, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) EKEventStore *store;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<EKEvent *> *events;

@end

@implementation TodayViewController

- (void)dealloc
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = [ZQTimeTableViewCell defaultHeight]; // 设置为一个接近“平均”行高的值
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [self.tableView registerClass:ZQTimeTableViewCell.class forCellReuseIdentifier:NSStringFromClass(ZQTimeTableViewCell.class)];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    
    @weakify(self);
    [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        @strongify(self);
        if (granted) { //授权是否成功
            //            [[NSTimer scheduledTimerWithTimeInterval:60 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self fetchRecentEvent];
            //            }] fire];
        }
    }];
    
    [super viewWillAppear:animated];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MIN(self.events.count, 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZQTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ZQTimeTableViewCell.class) forIndexPath:indexPath];
    
    cell.event = self.events[indexPath.row];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ZQTimeTableViewCell defaultHeight];
//    return UITableViewAutomaticDimension;
}

- (void)fetchRecentEvent
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *twoDays = [[NSDateComponents alloc] init];
    twoDays.day = 2;
    
    NSDateComponents *oneHundredYear = [[NSDateComponents alloc] init];
    oneHundredYear.year = 100;
    
    NSDate *twoDayFromNow = [calendar dateByAddingComponents:twoDays
                                                      toDate:[NSDate date]
                                                     options:0];
    
    self.events = [self requestForEventUtilDate:twoDayFromNow];
    if (self.events.count == 0) {
        NSDate *oneHundredYearFromNow = [calendar dateByAddingComponents:oneHundredYear toDate:[NSDate date] options:0];
        self.events = [self requestForEventUtilDate:oneHundredYearFromNow];
    }

//    self.preferredContentSize = CGSizeMake(0, MIN(2, self.events.count) * [ZQTimeTableViewCell defaultHeight]);

    [self.tableView reloadData];
//    EKEvent *event = events.firstObject;
//    if (event) {
//        self.dateLabel.text = event.title;
//        self.locationLabel.text = event.location;
//        self.timeLeftLabel.text = [NSString stringWithFormat:@"还有 %@", [event.startDate leftTimeSinceNow]];
//        self.startDateLabel.text = [event.startDate beautyLocalFormat];
//        self.endDateLabel.text = [event.endDate beautyLocalFormat];
//        
//    }
}


- (NSArray<EKEvent *> *)requestForEventUtilDate:(NSDate *)date
{
    
    NSPredicate *predicate = [self.store predicateForEventsWithStartDate:[NSDate date]
                                                                 endDate:date
                                                               calendars:nil];
    
    NSArray<EKEvent *> *events = [self.store eventsMatchingPredicate:predicate];
    return events;
}

- (EKEventStore *)store
{
    if (!_store) {
        _store = [[EKEventStore alloc] init];
    }
    return _store;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}



@end