//
//  ViewController.swift
//  iBeacon
//
//  Created by ESD26 on 2024/4/16.
//

import UIKit
import CoreLocation
import CoreML
import Vision


class ViewController: UIViewController, CLLocationManagerDelegate, UIDocumentPickerDelegate {

    var locationManager: CLLocationManager = CLLocationManager()
    
    let uuid = "A3E1C063-9235-4B25-AA84-D249950AADC4"
    let identifier = "esd region"
    
    @IBOutlet weak var monitorResultTextView: UITextView!
    @IBOutlet weak var rangingResultTextView: UITextView!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var predictAreaField: UITextView!
    @IBOutlet weak var predictCoordinateField: UITextView!
    
    var dataString:String!
    var dataNow_1 = [[String:Any]]()
    var dataNow_2 = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            if locationManager.authorizationStatus != CLAuthorizationStatus.authorizedAlways {
                locationManager.requestAlwaysAuthorization()
            }
        }
        
        let region = CLBeaconRegion(uuid: UUID.init(uuidString: uuid)!, identifier: identifier)
        
        locationManager.delegate = self
        region.notifyEntryStateOnDisplay = true
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        locationManager.startMonitoring(for: region)
        writeStringToFile(writeString: "", fileName: "data_c.txt")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        monitorResultTextView.text = "did start monitoring \(region.identifier)\n" + monitorResultTextView.text
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        monitorResultTextView.text = "did enter\n" + monitorResultTextView.text
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        monitorResultTextView.text = "did exit\n" + monitorResultTextView.text
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            monitorResultTextView.text = "state inside\n" + monitorResultTextView.text
            manager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: UUID.init(uuidString: uuid)!))
        case .outside:
            monitorResultTextView.text = "state outside\n" + monitorResultTextView.text
            manager.stopMonitoring(for: region)
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        rangingResultTextView.text = ""
        dataNow_1 = [[String:Any]]()
        dataNow_2 = [[String:Any]]()
        
        var lists_1 = [Any]()
        var lists_2 = [Any]()
        
        let orderedBeaconArray = beacons.sorted(by: { (b1, b2) -> Bool in return [b1.minor .intValue] < [b2.minor .intValue]})
        for beacon in orderedBeaconArray {
            var proximityString = ""
            switch beacon.proximity {
            case .far:
                proximityString = "far"
            case .near:
                proximityString = "near"
            case .immediate:
                proximityString = "immediate"
            default:
                proximityString = "unknow"
            }
            rangingResultTextView.text = rangingResultTextView.text + " Major: \(beacon.major)" + " Minor: \(beacon.minor)" + " RSSI: \(beacon.rssi)" + " Proximity: \(proximityString)" + " Accuracy: \(beacon.accuracy)" + "\n\n"
            
            if(beacon.major.intValue == 1){
                lists_1.append(beacon.rssi)
                lists_1.append(proximityString)
                lists_1.append(beacon.accuracy)
            }
            else if(beacon.major.intValue == 2){
                lists_2.append(beacon.rssi)
                lists_2.append(proximityString)
                lists_2.append(beacon.accuracy)
            }
        }

        if lists_1.count > 10{
            dataNow_1.append(["Tag": tagField.text ?? "", "RSSI_1":lists_1[0], "Proximity_1":lists_1[1], "Accuracy_1":lists_1[2], "RSSI_2":lists_1[3], "Proximity_2":lists_1[4], "Accuracy_2":lists_1[5], "RSSI_3":lists_1[6], "Proximity_3":lists_1[7], "Accuracy_3":lists_1[8], "RSSI_4":lists_1[9], "Proximity_4":lists_1[10], "Accuracy_4":lists_1[11]])
        }
        if lists_2.count > 22{
            dataNow_2.append(["Tag": tagField.text ?? "", "RSSI_1":lists_2[0], "Proximity_1":lists_2[1], "Accuracy_1":lists_2[2], "RSSI_2":lists_2[3], "Proximity_2":lists_2[4], "Accuracy_2":lists_2[5], "RSSI_3":lists_2[6], "Proximity_3":lists_2[7], "Accuracy_3":lists_2[8], "RSSI_4":lists_2[9], "Proximity_4":lists_2[10], "Accuracy_4":lists_2[11], "RSSI_5":lists_2[12], "Proximity_5":lists_2[13], "Accuracy_5":lists_2[14], "RSSI_6":lists_2[15], "Proximity_6":lists_2[16], "Accuracy_6":lists_2[17], "RSSI_7":lists_2[18], "Proximity_7":lists_2[19], "Accuracy_7":lists_2[20], "RSSI_8":lists_2[21], "Proximity_8":lists_2[22], "Accuracy_8":lists_2[23]])
        }
    }
    
    func getAreaInputTensor() throws -> MLMultiArray {
        let shape: [NSNumber] = [1, 16]
        let inputTensor = try MLMultiArray(shape: shape, dataType: .float32)
        
        var tempArr = [Float32]()
        
        tempArr.append(Float32(dataNow_1[0]["RSSI_1"] as? Int ?? 0))
        tempArr.append(Float32(dataNow_1[0]["Accuracy_1"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_1[0]["RSSI_2"] as? Int ?? 0))
        tempArr.append(Float32(dataNow_1[0]["Accuracy_2"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_1[0]["RSSI_3"] as? Int ?? 0))
        tempArr.append(Float32(dataNow_1[0]["Accuracy_3"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_1[0]["RSSI_4"] as? Int ?? 0))
        tempArr.append(Float32(dataNow_1[0]["Accuracy_4"] as? Double ?? 0.0))
        tempArr.append(Float32(((dataNow_1[0]["Proximity_1"] as? String ?? "far") == "far") ? 1 : 0))
        tempArr.append(Float32(((dataNow_1[0]["Proximity_1"] as? String ?? "far") == "near") ? 1 : 0))
        tempArr.append(Float32(((dataNow_1[0]["Proximity_2"] as? String ?? "far") == "far") ? 1 : 0))
        tempArr.append(Float32(((dataNow_1[0]["Proximity_2"] as? String ?? "far") == "near") ? 1 : 0))
        tempArr.append(Float32(((dataNow_1[0]["Proximity_3"] as? String ?? "far") == "far") ? 1 : 0))
        tempArr.append(Float32(((dataNow_1[0]["Proximity_3"] as? String ?? "far") == "near") ? 1 : 0))
        tempArr.append(Float32(((dataNow_1[0]["Proximity_4"] as? String ?? "far") == "far") ? 1 : 0))
        tempArr.append(Float32(((dataNow_1[0]["Proximity_4"] as? String ?? "far") == "near") ? 1 : 0))
        
        tempArr[0] = (tempArr[0] + 6.52087379e+01) / sqrt(9.96894382e+01)
        tempArr[1] = (tempArr[1] - 1.17634529e+01) / sqrt(5.07900083e+01)
        tempArr[2] = (tempArr[2] + 6.38786408e+01) / sqrt(3.28153690e+01)
        tempArr[3] = (tempArr[3] - 8.40177676e+00) / sqrt(1.71800580e+01)
        tempArr[4] = (tempArr[4] + 6.43106796e+01) / sqrt(3.74374588e+01)
        tempArr[5] = (tempArr[5] - 8.96885582e+00) / sqrt(2.09475039e+01)
        tempArr[6] = (tempArr[6] + 6.75485437e+01) / sqrt(5.73156047e+01)
        tempArr[7] = (tempArr[7] - 1.38230567e+01) / sqrt(4.69009149e+01)
        tempArr[8] = (tempArr[8] - 9.22330097e-01) / sqrt(7.16372891e-02)
        tempArr[9] = (tempArr[9] - 6.31067961e-02) / sqrt(5.91243284e-02)
        tempArr[10] = (tempArr[10] - 9.66019417e-01) / sqrt(3.28259025e-02)
        tempArr[11] = (tempArr[11] - 3.39805825e-02) / sqrt(3.28259025e-02)
        tempArr[12] = (tempArr[12] - 9.41747573e-01) / sqrt(5.48590819e-02)
        tempArr[13] = (tempArr[13] - 5.82524272e-02) / sqrt(5.48590819e-02)
        tempArr[14] = (tempArr[14] - 9.75728155e-01) / sqrt(2.36827222e-02)
        tempArr[15] = (tempArr[15] - 1.94174757e-02) / sqrt(1.90404374e-02)
        
        for i in 0..<tempArr.count {
            inputTensor[i] = NSNumber(value: tempArr[i])
        }

        return inputTensor
    }
    
    func getCoordinateInputTensor() throws -> MLMultiArray {
        let shape: [NSNumber] = [1, 32]
        let inputTensor = try MLMultiArray(shape: shape, dataType: .float32)
        
        var tempArr = [Float32]()
        
        tempArr.append(Float32(dataNow_2[0]["RSSI_1"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["Accuracy_1"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["RSSI_2"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["Accuracy_2"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["RSSI_3"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["Accuracy_3"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["RSSI_4"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["Accuracy_4"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["RSSI_5"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["Accuracy_5"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["RSSI_6"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["Accuracy_6"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["RSSI_7"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["Accuracy_7"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["RSSI_8"] as? Double ?? 0.0))
        tempArr.append(Float32(dataNow_2[0]["Accuracy_8"] as? Double ?? 0.0))
        
        tempArr.append(Float32(((dataNow_2[0]["Proximity_1"] as? String ?? "far") == "far") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_1"] as? String ?? "far") == "near") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_2"] as? String ?? "far") == "far") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_2"] as? String ?? "far") == "near") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_3"] as? String ?? "far") == "far") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_3"] as? String ?? "far") == "near") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_4"] as? String ?? "far") == "far") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_4"] as? String ?? "far") == "near") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_5"] as? String ?? "far") == "far") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_5"] as? String ?? "far") == "near") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_6"] as? String ?? "far") == "far") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_6"] as? String ?? "far") == "near") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_7"] as? String ?? "far") == "far") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_7"] as? String ?? "far") == "near") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_8"] as? String ?? "far") == "far") ? 1 : 0))
        tempArr.append(Float32(((dataNow_2[0]["Proximity_8"] as? String ?? "far") == "near") ? 1 : 0))
        
        tempArr[0] = (tempArr[0] + 5.49813307e+01) / sqrt(9.58050606e+02)
        tempArr[1] = (tempArr[1] - 2.02836900e+01) / sqrt(3.94714284e+02)
        tempArr[2] = (tempArr[2] + 5.12295059e+01) / sqrt(1.09360159e+03)
        tempArr[3] = (tempArr[3] - 1.89525708e+01) / sqrt(4.68397784e+02)
        tempArr[4] = (tempArr[4] + 5.28121842e+01) / sqrt(1.03932604e+03)
        tempArr[5] = (tempArr[5] - 1.79461414e+01) / sqrt(3.33007164e+02)
        tempArr[6] = (tempArr[6] + 5.93107805e+01) / sqrt(7.70091512e+02)
        tempArr[7] = (tempArr[7] - 2.23033288e+01) / sqrt(4.37575729e+02)
        tempArr[8] = (tempArr[8] + 6.80050533e+01) / sqrt(1.97865499e+02)
        tempArr[9] = (tempArr[9] - 1.97052242e+01) / sqrt(1.65795434e+02)
        tempArr[10] = (tempArr[10] + 4.37827063e+01) / sqrt(1.29568608e+03)
        tempArr[11] = (tempArr[11] - 1.82833086e+01) / sqrt(5.50567792e+02)
        tempArr[12] = (tempArr[12] + 5.05384615e+01) / sqrt(1.23567525e+03)
        tempArr[13] = (tempArr[13] - 2.40715745e+01) / sqrt(6.00874879e+02)
        tempArr[14] = (tempArr[14] + 4.45701853e+01) / sqrt(1.31166338e+03)
        tempArr[15] = (tempArr[15] - 2.02052263e+01) / sqrt(6.30092940e+02)
        tempArr[16] = (tempArr[16] - 7.56316676e-01) / sqrt(1.84301762e-01)
        tempArr[17] = (tempArr[17] - 9.54519933e-03) / sqrt(9.45408850e-03)
        tempArr[18] = (tempArr[18] - 7.09432903e-01) / sqrt(2.06137859e-01)
        tempArr[19] = (tempArr[19] - 2.52667041e-03) / sqrt(2.52028635e-03)
        tempArr[20] = (tempArr[20] - 7.30769231e-01) / sqrt(1.96745562e-01)
        tempArr[21] = (tempArr[21] - 3.50926446e-03) / sqrt(3.49694952e-03)
        tempArr[22] = (tempArr[22] - 8.06569343e-01) / sqrt(1.56015238e-01)
        tempArr[23] = (tempArr[23] - 2.40033689e-02) / sqrt(2.34272072e-02)
        tempArr[24] = (tempArr[24] - 9.43430657e-01) / sqrt(5.33692525e-02)
        tempArr[25] = (tempArr[25] - 2.52667041e-02) / sqrt(2.46282978e-02)
        tempArr[26] = (tempArr[26] - 5.88994947e-01) / sqrt(2.42079899e-01)
        tempArr[27] = (tempArr[27] - 1.41774284e-02) / sqrt(1.39764289e-02)
        tempArr[28] = (tempArr[28] - 6.73357664e-01) / sqrt(2.19947120e-01)
        tempArr[29] = (tempArr[29] - 5.61482313e-03) / sqrt(5.58329689e-03)
        tempArr[30] = (tempArr[30] - 6.05558675e-01) / sqrt(2.38857366e-01)
        tempArr[31] = (tempArr[31] - 1.96518810e-03) / sqrt(1.96132613e-03)
        
        for i in 0..<tempArr.count {
            inputTensor[i] = NSNumber(value: tempArr[i])
        }

        return inputTensor
    }
    
    @IBAction func predictAreaButtonPressed(_ sender: Any) {
        if (dataNow_1.count != 1) {
            predictAreaField.text = "No iBeacon Found."
            return
        }
        
        guard let inputArray = try? getAreaInputTensor() else {
            predictAreaField.text = "Failed to create input array"
            return
        }
        
        guard inputArray.count == 16 else {
            predictAreaField.text = "Unexpected input size"
            return
        }
        
        let model: model_area
        do {
            model = try model_area(configuration: MLModelConfiguration())
        } catch {
            predictAreaField.text = "Model Initiallized Failed: \(error)"
            return
        }
        
        let input = model_areaInput(input_1: inputArray)
        
        guard let output = try? model.prediction(input: input) else {
            predictAreaField.text = "Model Predictioin Failed"
            return
        }

        let outputMultiArray = output.var_16
        var outputArray: [Float] = []
        for i in 0..<outputMultiArray.count {
            outputArray.append(outputMultiArray[i].floatValue)
        }
        
         var maxIndex = 0
         var maxValue = outputArray[0]
         
         for i in 1..<outputArray.count {
             if outputArray[i] > maxValue {
                 maxValue = outputArray[i]
                 maxIndex = i
             }
         }
         
         let outputClasses = ["A", "B", "C"]
         let predictedClass = outputClasses[maxIndex]
         predictAreaField.text = "Predicted class: \(predictedClass) \n Area A with probability: \(outputArray[0])  \n Area B with probability: \(outputArray[1])  \n Area C with probability: \(outputArray[2])"
    }
    
    @IBAction func predictCoordinateButtonPressed(_ sender: Any) {
        if (dataNow_2.count != 1) {
            predictCoordinateField.text = "No iBeacon Found."
            return
        }
        
        guard let inputArray = try? getCoordinateInputTensor() else {
            predictCoordinateField.text = "Failed to create input array"
            return
        }
        
        guard inputArray.count == 32 else {
            predictCoordinateField.text = "Unexpected input size"
            return
        }
        
        let input_x = model_cor_xInput(input_1: inputArray)
        let input_y = model_cor_yInput(input_1: inputArray)
        
        let model_x: model_cor_x
        do {
            model_x = try model_cor_x(configuration: MLModelConfiguration())
        } catch {
            predictCoordinateField.text = "Model_X Initiallized Failed: \(error)"
            return
        }
        
        let model_y: model_cor_y
        do {
            model_y = try model_cor_y(configuration: MLModelConfiguration())
        } catch {
            predictCoordinateField.text = "Model_Y Initiallized Failed: \(error)"
            return
        }
        
        guard let output_x = try? model_x.prediction(input: input_x) else {
            predictCoordinateField.text = "Model_X Predictioin Failed"
            return
        }
        
        guard let output_y = try? model_y.prediction(input: input_y) else {
            predictCoordinateField.text = "Model_Y Predictioin Failed"
            return
        }
        
        let outputMultiArray_x = output_x.var_11[0]
        let outputMultiArray_y = output_y.var_11[0]
        
        var x = Double(truncating: outputMultiArray_x)
        var y = Double(truncating: outputMultiArray_y)
        
        x = (x * 59) > 0 ? x : 0
        y = (y * 5) > 0 ? y : 0
        
        x = (x * 59) < 60 ? (x * 59) : 60
        y = (y * 5) < 5 ? (y * 5) : 5
        
        x = 0.15 + 0.4*x
        y = 0.33 + 0.67*y
        
        predictCoordinateField.text = "\(x)\n\(y)"
        
    }
    
    @IBAction func saveDataButtonPressed(_ sender: Any) {
        loadDataArray()
        saveDataArray()
    }
    
    
    func writeStringToFile(writeString:String, fileName:String) {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in :.userDomainMask).first else{return}
        let fileURL = dir.appendingPathComponent(fileName)
        do{
            try writeString.write(to: fileURL, atomically: false, encoding: .utf8)
        }catch{
            print("write error")
        }
        print("\(fileURL)")
    }
    
    func readFileToString(fileName:String) -> String {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return ""
        }
        
        let fileURL = dir.appendingPathComponent(fileName)
        var readString = ""
        do {
            try readString = String.init(contentsOf:  fileURL, encoding: .utf8)
        } catch {
            print("read error")
        }
        
        return readString
    }
    
    func saveDataArray() {
        var finalString = ""
        finalString = finalString + dataString
        for data in dataNow_2 {
            let tag = data["Tag"] as? String ?? "No Tag"
            //let major = data["Major"] as? Int ?? 0
            //let minor = data["Minor"] as? Int ?? 0
            let rssi_1 = data["RSSI_1"] as? Int ?? 0
            let proximity_1 = data["Proximity_1"] as? String ?? ""
            let accuracy_1 = data["Accuracy_1"] as? Double ?? 0.0
            let rssi_2 = data["RSSI_2"] as? Int ?? 0
            let proximity_2 = data["Proximity_2"] as? String ?? ""
            let accuracy_2 = data["Accuracy_2"] as? Double ?? 0.0
            let rssi_3 = data["RSSI_3"] as? Int ?? 0
            let proximity_3 = data["Proximity_3"] as? String ?? ""
            let accuracy_3 = data["Accuracy_3"] as? Double ?? 0.0
            let rssi_4 = data["RSSI_4"] as? Int ?? 0
            let proximity_4 = data["Proximity_4"] as? String ?? ""
            let accuracy_4 = data["Accuracy_4"] as? Double ?? 0.0
            let rssi_5 = data["RSSI_5"] as? Int ?? 0
            let proximity_5 = data["Proximity_5"] as? String ?? ""
            let accuracy_5 = data["Accuracy_5"] as? Double ?? 0.0
            let rssi_6 = data["RSSI_6"] as? Int ?? 0
            let proximity_6 = data["Proximity_6"] as? String ?? ""
            let accuracy_6 = data["Accuracy_6"] as? Double ?? 0.0
            let rssi_7 = data["RSSI_7"] as? Int ?? 0
            let proximity_7 = data["Proximity_7"] as? String ?? ""
            let accuracy_7 = data["Accuracy_7"] as? Double ?? 0.0
            let rssi_8 = data["RSSI_8"] as? Int ?? 0
            let proximity_8 = data["Proximity_8"] as? String ?? ""
            let accuracy_8 = data["Accuracy_8"] as? Double ?? 0.0
            
            
            finalString = finalString + tag + "," + "\(rssi_1)" + "," + "\(proximity_1)" + "," + "\(accuracy_1)" + "," + "\(rssi_2)" + "," + "\(proximity_2)" + "," + "\(accuracy_2)" + "," + "\(rssi_3)" + "," + "\(proximity_3)" + "," + "\(accuracy_3)" + "," + "\(rssi_4)" + "," + "\(proximity_4)" + "," + "\(accuracy_4)" + "," + "\(rssi_5)" + "," + "\(proximity_5)" + "," + "\(accuracy_5)" + "," + "\(rssi_6)" + "," + "\(proximity_6)" + "," + "\(accuracy_6)" + "," + "\(rssi_7)" + "," + "\(proximity_7)" + "," + "\(accuracy_7)" + "," + "\(rssi_8)" + "," + "\(proximity_8)" + "," + "\(accuracy_8)"  + "\n"
        }
        finalString = finalString + "\n\n"
        
        
        writeStringToFile(writeString: finalString, fileName: "data_c.txt")
    }
    
    func loadDataArray() {
        dataString = readFileToString(fileName: "data_c.txt")
        print(dataString ?? "No Data")
    }
    
    @IBAction func saveToFile(_ sender: Any) {
        let content = dataString ?? "No Data"
        let fileName = "data_c.txt"
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try content.write(to: tempURL, atomically: true, encoding: .utf8)
        } catch {
            print("File Output Error: \(error)")
            return
        }
        
        let documentPicker = UIDocumentPickerViewController(forExporting: [tempURL])
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            print("File Save To: \(url)")
        }
    }
}

