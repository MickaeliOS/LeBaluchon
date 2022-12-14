//
//  ExchangeVC.swift
//  LeBaluchon
//
//  Created by Mickaël Horn on 20/10/2022.
//

import UIKit

class ExchangeVC: UIViewController {
    
    // MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        getLatestChangeRates()
    }
    
    // MARK: - Outlets
    @IBOutlet weak var moneyFromText: UITextField!
    @IBOutlet weak var moneyToText: UITextField!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var eurToUsdLabel: UILabel!
    @IBOutlet weak var usdToEurLabel: UILabel!
    @IBOutlet weak var refreshRateButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Actions
    @IBAction func calculateButton(_ sender: Any) {
        guard let result = formControl() else {
            return
        }
        
        calculateExchangeRate(amount: result)
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        moneyFromText.resignFirstResponder()
    }
    
    @IBAction func refreshRateButton(_ sender: Any) {
        getLatestChangeRates()
        resetTextViews()
    }
    
    // MARK: - Private functions
    private func formControl() -> Double? {
        guard let amount = moneyFromText.text, !amount.isEmpty else {
            presentAlert(with: "Please fill a currency you want to convert.")
            return nil
        }
        
        guard let result = Double(amount) else {
            presentAlert(with: "Please provide correct amount.")
            return nil
        }
        
        return result
    }
    
    private func calculateExchangeRate(amount: Double) {
        guard let rate = ExchangeService.shared.rate else {
            presentAlert(with: "Unknown exchange rate, please refresh it.")
            return
        }
        
        let result = rate * amount
        self.moneyToText.text = "\(result)"
    }
    
    private func getLatestChangeRates() {
        // I'm hidding the refresh button to prevent the user for multiple input
        toggleActivityIndicator(shown: true)

        // EUR to USD
        ExchangeService.shared.getLatestChangeRate(from: "EUR", to: "USD") { success, result, error in
            if error != nil {
                self.presentAlert(with: error!.localizedDescription)
                
                // If the first call fails, it means it will never execute the second one and I need to
                // hide the ActivityIndicator and put the button back
                self.toggleActivityIndicator(shown: false)
                return
            }
            
            guard let result = result, success == true else {
                self.presentAlert(with: "Can't fetch the EUR to USD rate. Please press the refresh button.")
                
                // If the first call fails, it means it will never execute the second one and I need to
                // hide the ActivityIndicator and put the button back
                self.toggleActivityIndicator(shown: false)
                return
            }
            
            ExchangeService.shared.rate = result
            self.eurToUsdLabel.text = "1 EUR = \(result) USD"
            
            // USD to EUR
            ExchangeService.shared.getLatestChangeRate(from: "USD", to: "EUR") { success, result, error in
                // Here, both of the API calls finished, so I have to make the button reappear and
                // hide the ActivityIndicator
                self.toggleActivityIndicator(shown: false)

                if error != nil {
                    self.presentAlert(with: error!.localizedDescription)
                    return
                }
                
                guard let result = result, success == true else {
                    self.presentAlert(with: "Can't fetch the USD to EUR rate. You can either press the refresh button or convert your value.")
                    return
                }
                
                self.usdToEurLabel.text = "1 USD = \(result) EUR"
            }
        }
    }
    
    private func setupInterface() {
        calculateButton.layer.cornerRadius = 20
        refreshRateButton.layer.cornerRadius = 15
    }
    
    private func toggleActivityIndicator(shown: Bool) {
        // If shown is true, then the refresh button is hidden and we display the Activity Indicator
        // If not, we hide the Activity Indicator and show the refresh button
        refreshRateButton.isHidden = shown
        activityIndicator.isHidden = !shown
    }
    
    private func resetTextViews() {
        moneyFromText.text = ""
        moneyToText.text = ""
    }
}

// MARK: - Extentions
extension ExchangeVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        moneyFromText.resignFirstResponder()
        return true
    }
}
