# Concepts + General Notes

Unstructured Notes to be worked into proper documentation

# Events

Anytime an activity is triggered. It can potentially emit an event. An event is nothing but a signal that can be listened to by other functions in order to trigger logic in step with the fired function. 

```dart
  static CustomEvent fromMap(Map<String, dynamic> map) {
    return CustomEvent(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      description: map['description'],
      startDate: map['startDate'] == null ? null : (map['startDate'] as Timestamp).toDate(),
      // timeHandled: map['timehandled'] == null ? null : (map['timehandled'] as Timestamp).toDate(),
      endDate: map['endDate'] == null ? null : (map['endDate'] as Timestamp).toDate(),
      nextRemindDate: map['nextRemindDate'] == null ? null : (map['nextRemindDate'] as Timestamp).toDate(),
      posAnswer: map['question_yes'],
      negAnswer: map['question_no'],
      type: EventType.values[map['type']],
      // status: map['status'] ! = null ? EventStatus.values[map['status']] : EventStatus.values[EventStatus.idle.index],
      // isHandled: map['isHandled'] ?? false,
      repeat: map['repeat'] ?? false,
      question: map['question'] ?? false,
      // animationState: map['animationState'] ?? false,
      eventResponse: map['eventResponse'] != null ? List.from(map['eventResponse']).map((e) => EventResponse.fromMap(e)).toList() : [],
    );
  }
```

# Model

Model defines what data can exist within a specific model object

e.g 

- `voucherModel` Defines the fields declared within a voucher object
- `customEvent` is a model that defines what an event can contain
- `poseDetection` is for recognizing poses with the buddy bot camera.

[](https://www.notion.so/5dc3fd90d5714325ac03932093be5474?pvs=21)

## Dependencies

Key Val Store (Think Global Variables for the app) [https://pub.dev/packages/get_storage](https://pub.dev/packages/get_storage)

[https://pub.dev/packages/get/example](https://pub.dev/packages/get/example)



### References

[https://api.dart.dev/stable/3.4.0/dart-async/Stream-class.html](https://api.dart.dev/stable/3.4.0/dart-async/Stream-class.html)

[https://api.dart.dev/stable/3.4.0/dart-async/StreamController-class.html](https://api.dart.dev/stable/3.4.0/dart-async/StreamController-class.html)

---

# The void

```
  FirebaseFirestore.instance.collection(FireStoreConstant.tBuddyBots).where(user.uid).get().then((value) async {
//  Getting user info from in the auth controller
```

Seems like that every controller has a .getPref scoped to their controller instances?, well seeing as it is initialized as a GetxController that might be high likely

Why is it structured like this though ;L 

```dart
// Auth Controller init

class AuthController extends GetxController {
	// This looks like it sets the default values that should be present when
	// instantiating an auth controller.
  late RxBool isButtonBusy = false.obs;
  // late RxBool isRespondingToEvent = false.obs;
  late RxBool canAnswerSecondAnswer = true.obs;
  late RxBool detectPermission = false.obs;
  late Rx<PermissionStatus> isCameraPermissionGranted = PermissionStatus.restricted.obs;
  late Rx<PermissionStatus> isMicroPhonePermissionGranted = PermissionStatus.restricted.obs;
  GetStorage getPref = GetStorage();
  late RxInt buddyBotMaxCount = FirebaseRemoteConfigService().buddyBotMaxCount.obs;
  // Rx<AnimationState> animationState = AnimationState.Idle.obs;

  Rx<ConnectivityResult> connectionStatus = ConnectivityResult.none.obs;
  RxBool isConnected = false.obs;

  RxBool isEnableGesture = true.obs;
  RxBool isOnlyFaceEvent = false.obs;
  RxBool isDebugMode = false.obs;
  RxBool isFaceDetected = false.obs;
```

FWIW getPref seems to refer to a k:v store scoped to their own object context

Auth Controller has a lot of logic suprisingly, like it seems to init some general states. but idk maybe because since it auths with a user outside it should init the fields first…

### Event Time Sorting

```dart
    ..sort((a, b) {
      ///sorting the time not the date
      ///Date can be previous one we need only time
      // TimeOfDay aTime = TimeOfDay(hour: a.startDate!.hour, minute: a.startDate!.minute);
      // TimeOfDay bTime = TimeOfDay(hour: b.startDate!.hour, minute: b.startDate!.minute);
      TimeOfDay aTime = a.nextRemindDate != null && (a.repeat ?? false)
          ? TimeOfDay(hour: a.nextRemindDate!.hour, minute: a.nextRemindDate!.minute)
          : TimeOfDay(hour: a.startDate!.hour, minute: a.startDate!.minute);
      TimeOfDay bTime = b.nextRemindDate != null && (b.repeat ?? false)
          ? TimeOfDay(hour: b.nextRemindDate!.hour, minute: b.nextRemindDate!.minute)
          : TimeOfDay(hour: b.startDate!.hour, minute: b.startDate!.minute);
      return aTime.compareTo(bTime);
```