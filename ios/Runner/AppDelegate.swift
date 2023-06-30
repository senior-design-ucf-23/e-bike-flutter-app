import UIKit
import Flutter
import CoreBluetooth

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,CBCentralManagerDelegate,FlutterStreamHandler {
    private var centralManager: CBCentralManager!
    private var eventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    guard let controller = window?.rootViewController as? FlutterViewController else {
        fatalError("rootViewController is not type FlutterViewController")
      }

   let bluetoothStateMethodChannel = FlutterMethodChannel(name: "method.flutter.io/bluetooth",
                                                 binaryMessenger: controller.binaryMessenger)

   bluetoothStateMethodChannel.setMethodCallHandler({
         [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
         guard call.method == "getBluetoothState" else {
           result(FlutterMethodNotImplemented)
           return
         }
         self?.getBluetoothState(result: result)
       })

   let bluetoothStateEventChannel = FlutterEventChannel(name: "samples.flutter.io/bluetooth",
                                                 binaryMessenger: controller.binaryMessenger)

   bluetoothStateEventChannel.setStreamHandler(self)
   centralManager = CBCentralManager(delegate: self, queue: nil,options: [CBCentralManagerOptionShowPowerAlertKey: false])

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getBluetoothState(result: FlutterResult) {
     if(self.centralManager.state == .poweredOn) {
           result("Yes");
         } else {
           result("No");
         }
    }

   func onListen(withArguments arguments: Any?,eventSink: @escaping FlutterEventSink) -> FlutterError? {
                   self.eventSink = eventSink
                   return nil
               }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
           eventSink = nil
           return nil
       }

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
   guard let eventSink = eventSink else {
        return
      }
             switch central.state {
                 case .poweredOn:
                   eventSink("on")


                 case .poweredOff:
                 eventSink("off")

                     // Alert user to turn on Bluetooth
                 case .resetting:
                 eventSink("resetting")

                     // Wait for next state update and consider logging interruption of Bluetooth service
                 case .unauthorized:
                 eventSink("unauthorized")

                     // Alert user to enable Bluetooth permission in app Settings
                 case .unsupported:
                  eventSink("unsupported")

                     // Alert user their device does not support Bluetooth and app will not work as expected
                 case .unknown:
                  eventSink("unknown")

                  default:
                  eventSink("not available")

                    // Wait for next state update
             }
         }
}
