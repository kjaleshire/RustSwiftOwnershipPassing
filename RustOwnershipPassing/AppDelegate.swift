//
//  AppDelegate.swift
//  RustOwnershipPassing
//
//  Created by Kyle J Aleshire on 2/15/16.
//  Copyright © 2016 Kyle J Aleshire. All rights reserved.
//

import UIKit

extension RustByteSlice {
    func asUnsafeBufferPointer() -> UnsafeBufferPointer<UInt8> {
        return UnsafeBufferPointer(start: bytes, count: len)
    }
    
    func asString(_ encoding: String.Encoding = String.Encoding.utf8) -> String? {
        return String(bytes: asUnsafeBufferPointer(), encoding: encoding)
    }
}

class RustNamedData {
    fileprivate let raw: OpaquePointer
    
    init() {
        raw = named_data_new()
    }
    
    deinit {
        named_data_destroy(raw)
    }
    
    var name: String {
        let byteSlice = named_data_get_name(raw)
        return byteSlice.asString()!
    }
    
    var count: Int {
        return named_data_count(raw)
    }
}

class SwiftObject {
    deinit {
        print("SwiftObject is being deallocated")
    }
    
    fileprivate func callbackWithArg(_ arg: Int) {
        print("SwiftObject: received callback with arg \(arg)")
    }
    
    func sendToRust() {
        let ownedPointer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
        let wrapper = swift_object(
            user: ownedPointer,
            destroy: destroy,
            callback_with_int_arg: callback_with_int_arg
        )
        give_object_to_rust(wrapper)
    }
}

private func callback_with_int_arg(_ user: UnsafeMutableRawPointer?, arg: Int32) {
    if let ptr = user {
        let obj: SwiftObject = Unmanaged.fromOpaque(ptr).takeUnretainedValue()
        obj.callbackWithArg(Int(arg))
    }
}

private func destroy(_ user: UnsafeMutableRawPointer?) {
    if let ptr = user {
        let _ = Unmanaged<SwiftObject>.fromOpaque(ptr).takeRetainedValue()
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        
        let namedData = RustNamedData()
        
        print("namedData.name = \(namedData.name)")
        print("namedData.count = \(namedData.count)")
        
        let obj = SwiftObject()
        obj.sendToRust()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

