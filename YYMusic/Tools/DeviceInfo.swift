//
//  Device.swift
//  imHome
//
//  Created by Kevin Xu on 2/9/15. Updated on 6/20/15.
//  Copyright (c) 2015 Alpha Labs, Inc. All rights reserved.
//

import Foundation
import UIKit

struct DeviceInfo {
    
    // MARK: - Singletons
    static var TheCurrentDevice: UIDevice {
        struct Singleton {
            static let device = UIDevice.current
        }
        return Singleton.device
    }
    
    static var TheCurrentDeviceVersion: String {
        struct Singleton {
            static let version = UIDevice.current.systemVersion
        }
        return Singleton.version
    }
    
    static var TheCurrentDeviceHeight: CGFloat {
        struct Singleton {
            static let height = UIScreen.main.bounds.size.height
        }
        return Singleton.height
    }
    
    // MARK: - Device Idiom Checks
    
    static var PHONE_OR_PAD: String {
        if isPhone() {
            return "iPhone"
        } else if isPad() {
            return "iPad"
        }
        return "Not iPhone nor iPad"
    }
    
    static var DEBUG_OR_RELEASE: String {
        #if DEBUG
        return "Debug"
        #else
        return "Release"
        #endif
    }
    
    static var SIMULATOR_OR_DEVICE: String {
        #if targetEnvironment(simulator)
        return "Simulator"
        #else
        return "Device"
        #endif
    }
    
    static func isPhone() -> Bool {
        return TheCurrentDevice.userInterfaceIdiom == .phone
    }
    
    static func isPad() -> Bool {
        return TheCurrentDevice.userInterfaceIdiom == .pad
    }
    
    static func isDebug() -> Bool {
        return DEBUG_OR_RELEASE == "Debug"
    }
    
    static func isRelease() -> Bool {
        return DEBUG_OR_RELEASE == "Release"
    }
    
    static func isSimulator() -> Bool {
        return SIMULATOR_OR_DEVICE == "Simulator"
    }
    
    static func isDevice() -> Bool {
        return SIMULATOR_OR_DEVICE == "Device"
    }
    
    // MARK: - Device Version Checks
    
    enum Versions: String {
        case five = "5.0"
        case six = "6.0"
        case seven = "7.0"
        case eight = "8.0"
        case nine = "9.0"
        case ten = "10.0"
        case eleven = "11.0"
        case twelve = "12.0"
        case thirteen = "13.0"
    }
    
    static func isVersion(_ version: Versions) -> Bool {
        return equalVersion(left:TheCurrentDeviceVersion, right: version.rawValue)
    }
    
    static func isVersionOrLater(_ version: Versions) -> Bool {
        let v1 = equalVersion(left:TheCurrentDeviceVersion, right: version.rawValue)
        let v2 = compareVersion(left:TheCurrentDeviceVersion, right: version.rawValue)
        return v1 && !v2
    }
    
    static func isVersionOrEarlier(_ version: Versions) -> Bool {
        let v1 = equalVersion(left:TheCurrentDeviceVersion, right: version.rawValue)
        let v2 = compareVersion(left:TheCurrentDeviceVersion, right: version.rawValue)
        return v1 && v2
    }
    
    static func isVersionLater(_ version: Versions) -> Bool {
        return !compareVersion(left:TheCurrentDeviceVersion, right: version.rawValue)
    }
    
    static func isVersionEarlier(_ version: Versions) -> Bool {
        return compareVersion(left:TheCurrentDeviceVersion, right: version.rawValue)
    }
    
    static var CURRENT_VERSION: String {
        return TheCurrentDeviceVersion
    }
    
    /**系统版本*/
    static func compareVersion(left: String, right: String) -> Bool {
        let lefts = left.split(separator: ".").map({ (substring) -> Int in
            return Int(substring) ?? 0
        })
        
        let rights = right.split(separator: ".").map({ (substring) -> Int in
            return Int(substring) ?? 0
        })
        
        if lefts.lexicographicallyPrecedes(rights) {
            return true
        } else {
            return false
        }
    }
    
    static func equalVersion(left: String, right: String) -> Bool {
        let lefts = left.split(separator: ".").map({ (substring) -> Int in
            return Int(substring) ?? 0
        })
        
        let rights = right.split(separator: ".").map({ (substring) -> Int in
            return Int(substring) ?? 0
        })
        
        if lefts.first == rights.first {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Device Size Checks
    
    enum Heights: CGFloat {
        case inches_3_5 = 480
        case inches_4 = 568
        case inches_4_7 = 667
        case inches_5_5 = 736
        case inches_5_8 = 812
    }
    
    static func isSize(_ height: Heights) -> Bool {
        return TheCurrentDeviceHeight == height.rawValue
    }
    
    static func isSizeOrLarger(_ height: Heights) -> Bool {
        return TheCurrentDeviceHeight >= height.rawValue
    }
    
    static func isSizeOrSmaller(_ height: Heights) -> Bool {
        return TheCurrentDeviceHeight <= height.rawValue
    }
    
    static var CURRENT_SIZE: String {
        if IS_3_5_INCHES() {
            return "3.5 Inches"
        } else if IS_4_INCHES() {
            return "4 Inches"
        } else if IS_4_7_INCHES() {
            return "4.7 Inches"
        } else if IS_5_5_INCHES() {
            return "5.5 Inches"
        } else if IS_5_8_INCHES() {
            return "5.8 Inches"
        }
        return "\(TheCurrentDeviceHeight) Points"
    }
    
    // MARK: 3.5 Inch Checks
    
    static func IS_3_5_INCHES() -> Bool {
        return isPhone() && isSize(.inches_3_5)
    }
    
    static func IS_3_5_INCHES_OR_LARGER() -> Bool {
        return isPhone() && isSizeOrLarger(.inches_3_5)
    }
    
    static func IS_3_5_INCHES_OR_SMALLER() -> Bool {
        return isPhone() && isSizeOrSmaller(.inches_3_5)
    }
    
    // MARK: 4 Inch Checks
    
    static func IS_4_INCHES() -> Bool {
        return isPhone() && isSize(.inches_4)
    }
    
    static func IS_4_INCHES_OR_LARGER() -> Bool {
        return isPhone() && isSizeOrLarger(.inches_4)
    }
    
    static func IS_4_INCHES_OR_SMALLER() -> Bool {
        return isPhone() && isSizeOrSmaller(.inches_4)
    }
    
    // MARK: 4.7 Inch Checks
    
    static func IS_4_7_INCHES() -> Bool {
        return isPhone() && isSize(.inches_4_7)
    }
    
    static func IS_4_7_INCHES_OR_LARGER() -> Bool {
        return isPhone() && isSizeOrLarger(.inches_4_7)
    }
    
    static func IS_4_7_INCHES_OR_SMALLER() -> Bool {
        return isPhone() && isSizeOrLarger(.inches_4_7)
    }
    
    // MARK: 5.5 Inch Checks
    
    static func IS_5_5_INCHES() -> Bool {
        return isPhone() && isSize(.inches_5_5)
    }
    
    static func IS_5_5_INCHES_OR_LARGER() -> Bool {
        return isPhone() && isSizeOrLarger(.inches_5_5)
    }
    
    static func IS_5_5_INCHES_OR_SMALLER() -> Bool {
        return isPhone() && isSizeOrLarger(.inches_5_5)
    }
    
    // MARK: 5.8 Inch Checks
    static func IS_5_8_INCHES() -> Bool {
        return isPhone() && isSize(.inches_5_8)
    }
    
    static func IS_5_8_INCHES_OR_LARGER() -> Bool {
        return isPhone() && isSizeOrLarger(.inches_5_8)
    }
    
    static func IS_5_8_INCHES_OR_SMALLER() -> Bool {
        return isPhone() && isSizeOrLarger(.inches_5_8)
    }
    
    //MARK:-iPhoneX
    static func isiPhoneX() -> Bool {
        return IS_5_8_INCHES()
    }
    
    //MARK:-iPhoneX    iPhoneXs    iPhoneX Max
    static func isiPhoneXOrLater() -> Bool {
        return IS_5_8_INCHES_OR_LARGER()
    }
    
}


