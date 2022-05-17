/// Copyright (c) 2022 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreBluetooth

class CentralViewController: UIViewController {
  
  var centralManager: CBCentralManager!
  var ipadProPeripheral: CBPeripheral!
  var ipadCustomService: CBService!
  var ipadCustomCharacteristic: CBCharacteristic!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    centralManager.stopScan()
  }
}

// MARK: CBCentralManagerDelegate
extension CentralViewController: CBCentralManagerDelegate {
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
    ipadProPeripheral.discoverServices([CustomCBUUID.customServiceCBUUID])
  }
}

extension CentralViewController: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }

    print("=== available services START ===")
    for service in services {
      print(service)
    }
    print("=== available services END ===")
    
    
    peripheral.discoverCharacteristics(nil, for: services.first!)
  }
  
  func peripheral(_ peripheral: CBPeripheral,
                  didDiscoverCharacteristicsFor service: CBService,
                  error: Error?)
  {
    guard let characteristics = service.characteristics else { return }
    
    for characteristic in characteristics {
      print(characteristic)
    }
    
    ipadCustomCharacteristic = characteristics.first!
    if ipadCustomCharacteristic.properties.contains(.read) {
      /// 1. `didReceiveRead` don't called
      peripheral.readValue(for: ipadCustomCharacteristic)
//      let helloData = "a".data(using: .utf8)!
      
      /// 2. If type is .withoutResponse, `didReceiveWrite` don't called
//      peripheral.writeValue(helloData, for: ipadCustomCharacteristic, type: .withResponse)
      view.backgroundColor = [.red, .black, .blue, .brown, .cyan, .green].randomElement()
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral,
                  didUpdateValueFor characteristic: CBCharacteristic,
                  error: Error?)
  {
    guard error == nil else {
      print(error)
      fatalError()
    }
    
    let data = characteristic.value ?? Data()
    print("read data: " + (String(data: data, encoding: .utf8) ?? ""))
  }
}
