// import 'package:buddy_bot/config/config_exporter.dart';
// import 'package:buddy_bot/utils/common_method.dart';
import 'package:flutter/material.dart';
import 'package:flic_button/flic_button.dart';
import 'package:provider/provider.dart';
import 'flic_state.dart';


class FlicConnect extends StatelessWidget {
  const FlicConnect({super.key});

  @override
  Widget build(BuildContext context)  {

    final buttonState = Provider.of<ButtonState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flic Button'),
      ),
      body: FutureBuilder(
        future: buttonState.flicButtonManager != null
            ? buttonState.flicButtonManager?.invokation
            : null,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            // Not initialized yet, display initialization button
            return Center(
              child: ElevatedButton(
                onPressed: () => buttonState.startStopFlic2(),
                child: const Text('Start and initialize Flic2'),
              ),
            );
          } else {
            // Flic2 initialized, show buttons and scanning controls
            return Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Flic2 is initialized',
                  style: TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                  onPressed: () => buttonState.startStopFlic2(),
                  child: const Text('Stop Flic2'),
                ),
                if (buttonState.flicButtonManager != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        //show all known flic buttons 
                        onPressed: () => buttonState.getButtons(),
                        child: const Text('Get Buttons'),
                      ),
                      ElevatedButton(
                        //scan fot available flic buttons
                        onPressed: () => buttonState.startStopScanningForFlic2(),
                        child: Text(
                          buttonState.isScanning ? 'Stop Scanning' : 'Scan for buttons',
                        ),
                      ),
                    ],
                  ),
                Text(
                  buttonState.no.toString(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to the first page
                  },
                  child: Text('Go Back to First Page'),
                ),
                //if the app is currenctly looking for a button show this
                if (buttonState.isScanning)
                  const Text(
                      'Hold down your flic2 button so we can find it now we are scanning...'),
                Expanded(
                  child: ListView(
                    children: buttonState.buttonsFound.values
                        .map(
                          (e) => ListTile(
                        key: ValueKey(e.uuid),
                        leading: const Icon(Icons.radio_button_on, size: 48),
                        title: Text('FLIC2 @${e.buttonAddr}'),
                        subtitle: Column(
                          children: [
                            Text('${e.uuid}\n'
                                //show the values of the flic button
                                'name: ${e.name}\n'
                                'batt: ${e.battVoltage}V (${e.battPercentage}%)\n'
                                'serial: ${e.serialNo}\n'
                                'pressed: ${e.pressCount}\n'),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => buttonState.connectDisconnectButton(e),
                                  //if the flic button is not connected show 'connect' else show 'disconnect'
                                  child: Text(e.connectionState == Flic2ButtonConnectionState.disconnected
                                      ? 'connect'
                                      : 'disconnect'),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  //forget the flic button
                                  onPressed: () => buttonState.forgetButton(e),
                                  child: const Text('forget'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}