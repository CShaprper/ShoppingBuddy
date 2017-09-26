//
//  InAppPurchaseHelper.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 23.09.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import StoreKit

class IAPHelper:NSObject, IAlertMessageDelegate {
    var alertMessageDelegate: IAlertMessageDelegate?
    fileprivate var products:[SKProduct]?
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var productIdentifiers = Set([eIAPIndentifier.HalfYearSubscription.rawValue, eIAPIndentifier.QuaterlySubscription.rawValue, eIAPIndentifier.AnnualSbsrciption.rawValue])

    func ShowAlertMessage(title: String, message: String) {
        if alertMessageDelegate != nil {
            alertMessageDelegate?.ShowAlertMessage(title: title, message: message)
        }
    }
    
    public func requestProducts() {
        
        if SKPaymentQueue.canMakePayments() {
            
            productsRequest = SKProductsRequest(productIdentifiers: self.productIdentifiers as Set<String>)
            productsRequest?.delegate = self
            productsRequest?.start()
            
        } else {
            
            let title = ""
            let message = ""
            self.ShowAlertMessage(title: title, message: message)
            
        }
        
    }
    
    public func buyProduct(productIdentifier: String) {
        
        if let index = products!.index(where: { $0.productIdentifier == productIdentifier }){
            
             let p = products![index]
            print("Buying \(p.productIdentifier)...")
            
            let payment = SKPayment(product: p)
            SKPaymentQueue.default().add(payment)
            
        }
        
        
    }
    
    func restorePurchases(sender: UIButton) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        print("Transactions Restored")
      
        for transaction:SKPaymentTransaction in queue.transactions as [SKPaymentTransaction] {
            
            if transaction.payment.productIdentifier == eIAPIndentifier.HalfYearSubscription.rawValue
            {
                print("Consumable Product Purchased")
                // Unlock Feature
            }
            else if transaction.payment.productIdentifier == eIAPIndentifier.QuaterlySubscription.rawValue
            {
                print("Non-Consumable Product Purchased")
                // Unlock Feature
            }
        }
        
       self.ShowAlertMessage(title: "Thank You", message: "Your purchase(s) were restored.")
        
    }
}
extension IAPHelper: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        print("Loaded list of products...")
        products = response.products
        productsRequest = nil
        
        for p in products! {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
        
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequest = nil
        
    }
    
}


extension IAPHelper: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        //TODO: Remove ads
        //deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restore... \(productIdentifier)")
        //TODO: Remove ads
        //deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError? {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                print("Transaction Error: \(String(describing: transaction.error?.localizedDescription))")
            }
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
