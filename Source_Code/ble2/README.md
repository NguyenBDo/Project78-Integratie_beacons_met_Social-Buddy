# BLE2

This is an application with which you can connect to a BLE device
using Flutter/Dart. This is meant to be implemented in the
`Social Buddy bot application`, which is installed on tablets that 
are in the hands of the elderly. This is not to be confused with the
`Companion application`, which is used by the caregiver.

This application has an interface in which 
a list of BLE devices will be shown. It can be filtered by:
- Connectability of the device. `[Yes/No]`

It can be refreshed manually with the `refresh button` in the upper
right corner.

## General information
For user(elerly/patient) guide, you can take a look at 
[`User_guide_user`](../../Documentation/Guides/) 
and the guide for caretakers is in the same folder/directory 
[`User_guide_caregiver`](../../Documentation/Guides/).

There is also a [`flowchart`](../../Documentation/Diagrams/) for the code.

## Important files

File/Folder   	                                                    | Description 	
:------------------------------------------------------------------ | :------------	
[`lib/`](./lib/)                                                    | Main dart code folder, starts at [main.dart](./lib/main.dart)
[`lib/src/ble/`](lib/src/ble/)                                      | Contains code for Flutter's app
[`lib/src/service/`](lib/src/service/)                              | Contains service to for other main codes for Flutter's app
[`pubspec.yaml`](./pubspec.yaml)                                    | Flutter project's packets manager 
[`build.gradle`](./android/app/build.gradle)                        | Android's plugins manager 
[`proguard-rules.pro`](./android/app/proguard-rules.pro)            | Android's build rules
[`analysis_options.yaml`](./android/app/analysis_options.yaml)      | Flutter's analysis strictness/rules
[`AndroidManifest.xml`](./android/app/src/main/AndroidManifest.xml) | Metadata for this Android app
