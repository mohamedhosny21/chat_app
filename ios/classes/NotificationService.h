#import <UserNotifications/UserNotifications.h>

@interface NotificationService : UNNotificationServiceExtension

@property(nonatomic) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property(nonatomic) UNMutableNotificationContent *bestAttemptContent;

@end
