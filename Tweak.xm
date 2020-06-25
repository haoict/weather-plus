#import "Tweak.h"

/**
 * Load Preferences
 */
BOOL enable;
NSDictionary *dateFormat;
NSDictionary *dateRowStyle;

static void reloadPrefs() {
  NSDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH] ?: [@{} mutableCopy];

  enable = [[settings objectForKey:@"enable"] ?: @(YES) boolValue];
  dateFormat = [settings objectForKey:@"dateFormat"] ?: [@{} mutableCopy];
  dateRowStyle = [settings objectForKey:@"dateRowStyle"] ?: [@{} mutableCopy];
}

%group Enable
  %hook WADayForecastView
    - (void)setForecast:(WADayForecast *)arg1 temperatureUnit:(int)arg2 {
      NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
      dayComponent.day = arg1.dayNumber;

      NSDate *nextDate = [[NSCalendar currentCalendar] dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];

      NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:dateFormat[@"format"] ?: @"MM/dd"];
      NSString *stringFromDate = [dateFormatter stringFromDate:nextDate];

      %orig;

      switch ([dateRowStyle[@"style"] intValue]) {
        case 0: {
          self.dayNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.dayNameLabel.text, stringFromDate];
          break;
        }
        case 1: {
          self.dayNameLabel.text = [NSString stringWithFormat:@"%@ - %@", self.dayNameLabel.text, stringFromDate];
          break;
        }
        case 2: {
          self.dayNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.dayNameLabel.text, stringFromDate];
          break;
        }
        case 3: {
          self.dayNameLabel.text = [NSString stringWithFormat:@"%@ %@", stringFromDate, self.dayNameLabel.text];
          break;
        }
        case 4: {
          self.dayNameLabel.text = [NSString stringWithFormat:@"%@ - %@", stringFromDate, self.dayNameLabel.text];
          break;
        }
        case 5: {
          self.dayNameLabel.text = [NSString stringWithFormat:@"(%@) %@", stringFromDate, self.dayNameLabel.text];
          break;
        }
        default: {
          self.dayNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.dayNameLabel.text, stringFromDate];
          break;
        }
      }
    }
  %end
%end

%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) reloadPrefs, CFSTR(PREF_CHANGED_NOTIF), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  reloadPrefs();

  if (enable) {
    %init(Enable);
  }
}

