//
//  BluetoothServiece.swift
//  Bluetooth
//
//  Created by imac-1681 on 2024/9/18.
//

import Foundation
import CoreBluetooth

class BluetoothServices: NSObject {
    
    static let shared = BluetoothServices()
    weak var delegate: BluetoothServiceDelegate?
    
    var central: CBCentralManager?
    var peripheral: CBPeripheralManager?
    var connectedPeripheral: CBPeripheral?
    var rxtxCHaracteristic: CBCharacteristic?
    
    private var bluePeripherals: [CBPeripheral] = []
    
    // 初始化：副線程
    private override init() {
        super.init()
        
        let queue = DispatchQueue.global()
        central = CBCentralManager(delegate: self, queue: queue)
    }
    
    // 掃描藍芽裝置
    func startScan() {
        central?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    // 停止掃描
    func stopScan() {
        central?.stopScan()
    }
    
    // 連接藍芽週邊設備
    func connectPeripheral(peripheral: CBPeripheral) {
        self.connectedPeripheral = peripheral
        central?.connect(peripheral, options: nil)
    }
    
    // 中斷與藍芽周邊設備連接
    func disconnectPeripheral(peripheral: CBPeripheral) {
        central?.cancelPeripheralConnection(peripheral)
    }
}

extension BluetoothServices: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            print("poweredOn")
        @unknown default:
            print("藍芽裝置未知狀態")
        }
        startScan()
    }
    
    // 發現裝置
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        for newPeripheral in bluePeripherals {
            if peripheral.name == newPeripheral.name {
                return
            }
        }
        if let name = peripheral.name {
            bluePeripherals.append(peripheral)
            print(name)
        }
        delegate?.getBLEPeripherals(peripherals: bluePeripherals)
    }
    // 連結裝置
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
}

extension BluetoothServices: CBPeripheralDelegate {
    // 發現服務
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let service = peripheral.services {
            for service in service {
                print(service)
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    // 更改服務
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
    }
    
    // 發現對應服務的特徵
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print(characteristic)
                if characteristic.uuid.isEqual(CBUUID(string: "FFE1")){
                    peripheral.readValue(for: characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                    rxtxCHaracteristic = characteristic
                }
            }
        }
    }
    
    // 特徵值變更
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic == rxtxCHaracteristic,
              let characteristicValue = characteristic.value,
              let ASCIIstring = String(data: characteristicValue,
                                       encoding: String.Encoding.utf8)
        else {
            return
        }
        print(ASCIIstring)
        delegate?.getBLEPeripheralValue(value: ASCIIstring)
    }
}

extension BluetoothServices: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state{
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            print("poweredOn")
        @unknown default:
            print("藍芽裝置未知狀態")
        }
    }
}


protocol BluetoothServiceDelegate: NSObjectProtocol {
    
    func getBLEPeripherals(peripherals: [CBPeripheral])
    
    func getBLEPeripheralValue(value: String)
}
