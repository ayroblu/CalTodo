Cal Todo
========

This is a todo app based on a calendar.
The tricky part of calendar events is that they're fixed in time, but most of the time I want to complete a task "when I'm at home" or "during work hours" or similar. This requires a more flexible set of scheduling requirements.

1. Need to make a "calendar"
2. Need to be able to schedule events on the calendar (form)
3. Edit form
4. Sync with Dropbox (and with CloudKit probably)
5. Set alarms / notifications

UI Model
--------
- Stack? Split view?
- Main view - list
- Settings view - especially defaults

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
