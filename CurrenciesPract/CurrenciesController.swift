//
//  CurrenciesController.swift
//  Currencies
//
//  Created by Vagan Albertyan on 02.04.2022.
//


import UIKit

class CurrenciesController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var upperDropList: UIPickerView!
    @IBOutlet weak var downDropList: UIPickerView!
    @IBOutlet weak var rateLabel: UILabel!// вывод курса
    @IBOutlet weak var valueField: UITextField!// ввод числа
    
    enum CurrencyPicker: Int {
        case base     = 0
        case required = 1
    }
    
    var baseCurrencies: [Currency] = []
    var requiredCurrencies: [Currency] = []
    
    var rates: RateList = [:]
    var baseCurrency: Currency = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        JsonWorker.shared.getCurrencies(success: { (currencies) in
            
            self.baseCurrencies = currencies
            
            DispatchQueue.main.async {
                self.upperDropList.reloadAllComponents()
                self.baseCurrency = currencies[self.upperDropList.selectedRow(inComponent: 0)]
                self.updateRecuiredCurrencies(base: self.baseCurrency)
            }
            
        }) { (error) in
            print("Ошибка загрузки курса")
        }
    }
    
    // MARK: UIPickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    
        var count = 0
        
        switch pickerView.tag {
        case CurrencyPicker.base.rawValue:
            count = baseCurrencies.count
//            print(baseCurrency)
            break
        case CurrencyPicker.required.rawValue:
            count = rates.count
//            print(baseCurrency, rates)
            break
        default:
            break
        }
        
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    
        var attributedString = NSMutableAttributedString()
        let attributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        switch pickerView.tag {
        case CurrencyPicker.base.rawValue:
            let currency = baseCurrencies[row]
            attributedString = NSMutableAttributedString(string: currency, attributes: attributes)
            break
        case CurrencyPicker.required.rawValue:
            let currency = requiredCurrencies[row]
            attributedString = NSMutableAttributedString(string: currency, attributes: attributes)
            break
        default:
            break
        }
//        print(attributedString)
        return attributedString
       
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case CurrencyPicker.base.rawValue:
            let row = pickerView.selectedRow(inComponent: 0)
            baseCurrency = self.baseCurrencies[row]
            updateRecuiredCurrencies(base: baseCurrency)
            return
        case CurrencyPicker.required.rawValue:
            let row = pickerView.selectedRow(inComponent: 0)
            updateRateLabel(currency: requiredCurrencies[row])//обновили курс
            return
        default:
            return
        }
    }
    
    // MARK: UITextField
    
    @IBAction func valueChanged(_ sender: UITextField) {
        updateRateLabel(currency: requiredCurrencies[downDropList.selectedRow(inComponent: 0)])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        updateRateLabel(currency: requiredCurrencies[downDropList.selectedRow(inComponent: 0)])
        textField.resignFirstResponder()
        
        return true
    }

    
    // MARK: Helpers
    
    func updateRecuiredCurrencies(base: Currency) {
        
        JsonWorker.shared.getRates(base: base, success: { (rates) in
            

            self.rates = rates
            self.requiredCurrencies = Array(rates.keys)
            //сортировку сюда
            
            DispatchQueue.main.async {
                self.downDropList.reloadAllComponents()
                self.updateRateLabel(currency: self.requiredCurrencies[self.downDropList.selectedRow(inComponent: 0)])
            }
            
        }) { (error) in
            print("Ошибка загрузки курса")
        }
    }
    
    func updateRateLabel(currency: Currency) {
        
        var value: Rate?
        if let string = valueField.text {
            
            value = Double(string)
            
            if value == nil {
                value = 0
                valueField.text = "" //Введите число
            }
            
        } else {
            value = 1
            valueField.text = "1"
        }
        
        let rateValue = rates[currency] ?? 0
        let incomeValue = value ?? 1.0
        rateLabel.text = "\(rateValue * incomeValue)"
//        rateLabel.text = String(format: "%.2f", rateLabel)

        print(incomeValue) // входящее значение
        print(rateValue) // значение коэфициента
    }
}

