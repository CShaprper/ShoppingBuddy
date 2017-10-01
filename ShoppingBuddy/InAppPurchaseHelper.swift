//
//  InAppPurchaseHelper.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 23.09.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import StoreKit

class IAPHelper:NSObject, IAlertMessageDelegate, IActivityAnimationService {
    var alertMessageDelegate: IAlertMessageDelegate?
    var activityAnimationServiceDelegate: IActivityAnimationService?
    var sbUserService:ShoppingBuddyUserWebservice!
    fileprivate var products:[SKProduct]?
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var productIdentifiers = Set([eIAPIndentifier.SBFullVersion.rawValue])
    
    override init() {
        super.init()
        sbUserService = ShoppingBuddyUserWebservice()
        sbUserService.alertMessageDelegate = alertMessageDelegate
        sbUserService.activityAnimationServiceDelegate = activityAnimationServiceDelegate
    }

    func ShowAlertMessage(title: String, message: String) {
        if alertMessageDelegate != nil {
            alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
        }
    }
    
    func ShowActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            activityAnimationServiceDelegate!.ShowActivityIndicator!()
        }
    }
    
    public func requestProducts() {
        
        if SKPaymentQueue.canMakePayments() {
            
            productsRequest = SKProductsRequest(productIdentifiers: self.productIdentifiers as Set<String>)
            productsRequest?.delegate = self
            productsRequest?.start()
            
        } else {
            
            let title = String.PurchaseDeniedAlertTitle
            let message = String.PurchaseDeniedAlertMessage
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
            
            if transaction.payment.productIdentifier == eIAPIndentifier.SBFullVersion.rawValue
            {
                UserDefaults.standard.set(true, forKey: eUserDefaultKey.isFullVersionUser.rawValue)
            }
        }
        
        let title = String.PurchaseRestoreAlertTitle
         let message = String.localizedStringWithFormat(String.PurchaseRestoreAlertMessage, currentUser!.nickname!)
        
       self.ShowAlertMessage(title: title, message: message)
        
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
                UserDefaults.standard.set(true, forKey: eUserDefaultKey.isFullVersionUser.rawValue)
                sbUserService.ChangeFullVersionUserStatus(status: true)
                break
            case .failed:
                fail(transaction: transaction)
                UserDefaults.standard.set(false, forKey: eUserDefaultKey.isFullVersionUser.rawValue)
                sbUserService.ChangeFullVersionUserStatus(status: false)
                break
            case .restored:
                restore(transaction: transaction)
                UserDefaults.standard.set(true, forKey: eUserDefaultKey.isFullVersionUser.rawValue)
                sbUserService.ChangeFullVersionUserStatus(status: true)
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
        SKPaymentQueue.default().finishTransaction(transaction)
        
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restore... \(productIdentifier)")
        SKPaymentQueue.default().finishTransaction(transaction)
        
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        
        print("fail...")
        if let transactionError = transaction.error as NSError? {
            
            if transactionError.code != SKError.paymentCancelled.rawValue {
                
                let title = "App Store Error"
                let message = transaction.error!.localizedDescription
                 ShowAlertMessage(title: title, message: message)
                
            }
            
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
