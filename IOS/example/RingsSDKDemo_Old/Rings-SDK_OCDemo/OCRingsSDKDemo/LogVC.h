//
//  LogVC.h
//  OCRingsSDKDemo
//
//  Created by JianDan on 2025/3/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *log_TV;


- (void)clearTodayLog;
@end

NS_ASSUME_NONNULL_END
