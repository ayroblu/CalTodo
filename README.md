Cal Todo
========

This is a todo app based on a calendar.
The tricky part of calendar events is that they're fixed in time, but most of the time I want to complete a task "when I'm at home" or "during work hours" or similar. This requires a more flexible set of scheduling requirements.

1. Need to make a "calendar"
2. Need to be able to schedule events on the calendar (form)
3. Edit form
4. Sync with Dropbox (and with CloudKit probably)
5. Set alarms / notifications

Ideas
-----
- Group by Work / Personal
- Account for public holidays + vacation
- Contextual events like Birthday (do nothing?) or public holidays (cancel meetings)
  - Working hours, for example to account for the commute (most people it doesn't vary that much...)
- Location - alerts to leave at a certain time, public transport etc?
- Repeat rules:
  - Every monday, next day for public holidays? - handle clashes?
  - Handle one off cancellations / movements
- Mark as time sensitive - can't "move", alternatively, non time sensitive ones can move around according to the group. Group doesn't matter for non time sensitive ones.
- Alert type - sound? vibration? macOS, or phone alert?
- Add notes

UI Model
--------
- Stack? Split view?
- Main view - list
- Settings view - especially defaults

TODO
----
1. Notification methods:
  - create notifications (specify seconds = number of notifications)
  - On open, cancel all notifications for that "group"
    - getAllPendingNotifications
  - Remote notifications can do background app stuff like vibrate.
  - Handle notification actions
2. Build a calendar UI (do I really want this?)
  - Could integrate with gcal? All edits trigger changes to gcal?
3. Add a calendar/todo add / edit UI
  - Time + duration
  - Timezones
4. TodoList page with date breaks
  - TodoList without time sensitive ones?
  - Subgroups? e.g. there's normal todos and then there's all including events
  - Add item to todolist
  - Reorder items

### Data
- List of notifications
  - Save in json file
- Make everything an "action" with "invalid" actions like delete an event that doesn't exist do nothing. (for syncing)
- Settings by group, e.g. default notification delay, "available" hours

Notification sound
------------------

> https://stackoverflow.com/questions/43952714/ios-10-usernotifications-custom-sound-in-background-mode
> https://stackoverflow.com/questions/46231153/how-to-add-sound-files-to-your-bundle-in-xcode
> https://developer.apple.com/documentation/usernotifications/unnotificationsound

```
ffmpeg -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -t 30 silence_30s.mp3
afconvert silence_30s.mp3 silence_30s.caf -d ima4 -f caff -v
```

References
----------
- Local notifications when app is in foreground: https://stackoverflow.com/questions/65782435/receive-local-notifications-within-own-app-view-or-how-to-register-a-unuserno
- https://developer.apple.com/documentation/usernotifications/scheduling_a_notification_locally_from_your_app
- [Background Modes Tutorial](https://www.kodeco.com/34269507-background-modes-tutorial-getting-started#toc-anchor-013)
- https://stackoverflow.com/questions/66057840/ios-how-do-you-implement-critical-alerts-for-your-app-when-you-dont-have-an-en
- https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_background_updates_to_your_app
  - Background push details
- [Advances in App Background Execution](https://developer.apple.com/videos/play/wwdc2019/707/)
  - BGTaskScheduler
- [Background execution demystified](https://developer.apple.com/videos/play/wwdc2020/10063/)
  - Apis
    - BGAppRefreshTask
    - background push
    - URLSession
    - BGProcessingTask
  - 7 Factors that determine background running
    - Critically low battery
    - Low Power Mode
    - App usage
    - App switcher
    - Background App Refresh switch
    - System budgets
    - Rate limiting
  - 4 Background modes
    - Background App Refresh tasks
      - Refresh news feed
    - Background pushes
      - probably what I want to use
    - Background URLSession's
      - Finish a photo download?
    - Background processing tasks
      - index db
- https://stackoverflow.com/questions/41378842/notification-service-extension-for-local-notification
  - Notification Content Extensions are interesting too
