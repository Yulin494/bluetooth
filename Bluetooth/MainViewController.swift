//
//  MainViewController.swift
//  Bluetooth
//
//  Created by imac-1681 on 2024/9/18.
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet var Tview: UITableView!
    @IBOutlet var NumberLb: UILabel!
    
    // MARK: - Proprtty
    var BluetoothName: [CBPeripheral] = []
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableSet()
        BluetoothServices.shared.delegate = self
        BluetoothServices.shared.startScan()
    }
    // MARK: - UI Setting
    func tableSet() {
        Tview.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: MainTableViewCell.indentifile)
        
        Tview.dataSource = self
        Tview.delegate = self
        }
    // MARK: - IBAction
    
    // MARK: - Function
    
}
// MARK: - Extensions
extension MainViewController: BluetoothServiceDelegate, CBPeripheralDelegate {
    func getBLEPeripherals(peripherals: [CBPeripheral]) {
        self.BluetoothName = peripherals
        // 主線成
        DispatchQueue.main.async {
            self.Tview.reloadData()
        }
    }
    
    func getBLEPeripheralValue(value: String) {
        self.NumberLb.text = value
        print("\(value)")
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    // cellForRowAt內容的設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Tview.dequeueReusableCell(withIdentifier: MainTableViewCell.indentifile, for: indexPath) as! MainTableViewCell
        cell.NameLb?.text = BluetoothName[indexPath.row].name ?? "Unnamed"
        return cell
    }
    // numberOfRowsInSection顯示的行數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BluetoothName.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeripheral = BluetoothName[indexPath.row]
        BluetoothServices.shared.connectPeripheral(peripheral: selectedPeripheral)
        
    }
    
}
