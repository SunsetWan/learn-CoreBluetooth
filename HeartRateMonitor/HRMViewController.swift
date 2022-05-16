/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreBluetooth

class HRMViewController: UIViewController {
  
  var centralManager: CBCentralManager!
  var ipadProPeripheral: CBPeripheral!
  var manufacturerNameCharacteristic: CBCharacteristic!
  var modelNumberCharacteristic: CBCharacteristic!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }
}

// MARK: CBCentralManagerDelegate
extension HRMViewController: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
    case .unknown:
      print("central.state is unknown")
    case .resetting:
      print("central.state is resetting")
    case .unsupported:
      print("central.state is unsupported")
    case .unauthorized:
      print("central.state is unauthorized")
    case .poweredOff:
      print("central.state is poweredOff")
    case .poweredOn:
      print("central.state is poweredOn")
      
      /// Before calling the CBCentralManager methods,
      /// set the state of the central manager object to powered on
      centralManager.scanForPeripherals(withServices: nil)
    }
  }
  
  func centralManager(_ central: CBCentralManager,
                      didDiscover peripheral: CBPeripheral,
                      advertisementData: [String : Any],
                      rssi RSSI: NSNumber)
  {
    if peripheral.name == "sunset iPad Pro" {
      ipadProPeripheral = peripheral
      ipadProPeripheral.delegate = self
      print(ipadProPeripheral)
      centralManager.stopScan()
      centralManager.connect(ipadProPeripheral)
    }
  }
  
  func centralManager(_ central: CBCentralManager,
                      didConnect peripheral: CBPeripheral)
  {
    print("sunset iPad Pro connected!")
    ipadProPeripheral.discoverServices(nil)
  }
}

extension HRMViewController: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }

    print("=== available services START ===")
    for service in services {
      print(service)
    }
    print("=== available services END ===")
    
    let deviceInfoService = services.last!
    peripheral.discoverCharacteristics(nil, for: deviceInfoService)
  }
  
  func peripheral(_ peripheral: CBPeripheral,
                  didDiscoverCharacteristicsFor service: CBService,
                  error: Error?)
  {
    guard let characteristics = service.characteristics else { return }
    
    for characteristic in characteristics {
      print(characteristic)
    }
    
    manufacturerNameCharacteristic = characteristics.first!
    modelNumberCharacteristic = characteristics.last!
    
//    print(ManufacturerNameCharacteristic.properties)
    
    /// Not all characteristics are readable.
    /// You can determine whether a characteristic is readable by checking if its properties attribute.
    if manufacturerNameCharacteristic.properties.contains(.read) {
      print("\(manufacturerNameCharacteristic.uuid): properties contains .read")
      
      /// NOTE: readValue method is async
      peripheral.readValue(for: manufacturerNameCharacteristic)
    }
    
    if modelNumberCharacteristic.properties.contains(.read) {
      print("\(modelNumberCharacteristic.uuid): properties contains .read")
      
      /// NOTE: readValue method is async
      peripheral.readValue(for: modelNumberCharacteristic)
    }
    
    if manufacturerNameCharacteristic.properties.contains(.notify) {
      print("\(manufacturerNameCharacteristic.uuid): properties contains .notify")
    }
    
    if modelNumberCharacteristic.properties.contains(.notify) {
      print("\(modelNumberCharacteristic.uuid): properties contains .notify")
    }

    
//    let heartRateMeasurementCharacteristicCBUUID = ManufacturerNameCharacteristic.uuid
  }
  
  func peripheral(_ peripheral: CBPeripheral,
                  didUpdateValueFor characteristic: CBCharacteristic,
                  error: Error?)
  {
    switch characteristic.uuid {
    case manufacturerNameCharacteristic.uuid:
      guard let manufacturerNameData = characteristic.value else {
        return
      }
      print("manufacturerName: " + (String(data: manufacturerNameData, encoding: .utf8) ?? "manufacturerName missing"))
    case modelNumberCharacteristic.uuid:
      guard let modelNumberStringData = characteristic.value else {
        return
      }
      // iPad7,3 : iPad Pro 10.5-inch 2nd Gen
      print("modelNumberString: " + (String(data: modelNumberStringData, encoding: .utf8) ?? "modelNumberString missing"))
    default:
      print("Unhandled Characteristic UUID: \(characteristic.uuid)")
    }
  }
}
