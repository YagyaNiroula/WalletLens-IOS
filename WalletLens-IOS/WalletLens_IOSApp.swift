//
//  WalletLens_IOSApp.swift
//  WalletLens-IOS
//
//  Created by Yagya Niroula on 2025-07-23.
//

import SwiftUI
import UserNotifications

@main
struct WalletLens_IOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionIdentifier = response.actionIdentifier
        let notificationManager = NotificationManager.shared
        
        // Handle different notification actions
        if response.notification.request.content.categoryIdentifier == "BILL_REMINDER" {
            // Extract reminder data from notification if available
            // For now, we'll just handle the action
            notificationManager.handleNotificationAction(actionIdentifier)
        } else if response.notification.request.content.categoryIdentifier == "BUDGET_WARNING" {
            notificationManager.handleNotificationAction(actionIdentifier)
        }
        
        completionHandler()
    }
}
