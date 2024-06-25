# Fresh Install initialization flowchart
![docimage](/assets/BuddyBotMainStartLogin(2).png)

## Home Screen
Home screen initalizes a `_HomeScreenState` which supposedly keeps all the state information that is required for the home Screen. In the homescreen state, it defines a `GlobalKey` field with type `<SliderDrawerState>` and sets that to the `GlobalKey` of the `SliderDrawerState` key:value context. Essentially requiring and integrating the SliderDrawerState with the HomeScreen 


```dart
State<HomeScreen> createState() => _HomeScreenState()

class _HomeScreenState extends State<HomeScreen> {
	final GlobalKey <SliderDrawerState> scaffold = GlobalKey<SliderDrawerState>();

}

```