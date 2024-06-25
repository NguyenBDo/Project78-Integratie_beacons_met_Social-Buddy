# Events
Events are how notifications and actions are drivin within the buddy bot.
The companion app can make events

### Event Types
The social buddy project works with event types. Sent by the Firebase instance on the backend. These events are created by both the Social Buddy Companion app. These events are communicated through the firebase and both devices listen to the same Firestore record. That's been synced between the companion app and the buddy bot itself. 


## Events Controller
The event controller handles the backend logic of events through a firebase stream and it also controls the view with the appropriate processed event


## Events View
The events view is where the logic of triggering events are run, it specifies what to show depending on what the event controller has processed

The event view initializes a controller, and it manipulates it's ui state based on it's internal controller


#### Event queing
The main meat and potatoes of the Events itself is the event loop located in the Events controller. Essentially the controller 
