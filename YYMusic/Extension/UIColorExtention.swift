//
//  UIColorExtention.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/29.
//  Copyright © 2020 haoge. All rights reserved.

//
//  MuColor.swift
//  MuMu

import UIKit

extension UIColor {
  
  /**
  通过RGB得到颜色
  
  - parameter stringToConvert: 六位到八位的RGB字符串
  
  - returns: 颜色
  */
  class func hexStringToColor(stringToConvert: String, alpha: CGFloat = 1) -> UIColor{
    var cString : String = stringToConvert.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    // String should be 6 or 8 characters
    
    if cString.count < 6 {
      return UIColor.black
    }
    
    if cString.hasPrefix("0X"){
      cString = NSString(string: cString).substring(from: 2)
    }
    if cString.hasPrefix("#"){
      cString = NSString(string: cString).substring(from: 1)
    }
    if cString.count != 6{
      return UIColor.black
    }
    // Separate into r, g, b substrings
    var range  = NSRange(location: 0,length: 2)
    let rString = NSString(string: cString).substring(with: range)
    range.location = 2
    let gString = NSString(string: cString).substring(with: range)
    range.location = 4
    let bString = NSString(string: cString).substring(with: range)
    
    // Scan values
    var r, g, b : UInt32?
    r = 0
    g = 0
    b = 0
    Scanner(string: rString).scanHexInt32(&r!)
    Scanner(string: gString).scanHexInt32(&g!)
    Scanner(string: bString).scanHexInt32(&b!)
    
    return UIColor(red: (CGFloat(r!))/255.0, green: (CGFloat(g!))/255.0, blue: (CGFloat(b!))/255.0, alpha: alpha)
  }
  
    func getRGB() -> (CGFloat,CGFloat,CGFloat) {
        let colors = self.cgColor.components
        if (colors?.count ?? 0) < 3 { return (0,0,0) /*黑色*/ }
        return (CGFloat(colors![0])*255,CGFloat(colors![1])*255, CGFloat(colors![2])*255)
    }
    
    func changeBackgroundColorToAlpha(alpha: CGFloat = 0.15) -> UIColor {
        if self == UIColor.white{
            return UIColor(red: 1, green: 1, blue: 1, alpha: alpha)
        } else if self == UIColor.black{
            return UIColor(red: 0, green: 0, blue: 0, alpha: alpha)
        }
        //获得RGB值描述
        let RGBValue = NSString(format: "%@", self)
        //将RGB值描述分隔成字符串
        let RGBArr = RGBValue.components(separatedBy: " ")
        //获取红色值
        let r = Double(RGBArr[1])
        //获取绿色值
        let g = Double(RGBArr[2])
        //获取蓝色值
        let b = Double(RGBArr[3])
        return UIColor(red: CGFloat(r ?? 0.0), green: CGFloat(g ?? 0.0), blue: CGFloat(b ?? 0.0), alpha: alpha)
    }
  
}
