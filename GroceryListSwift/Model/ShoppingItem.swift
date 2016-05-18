//
//  ShoppingItem.swift
//  GroceryListSwift
//
//  Created by Yury Ramanchuk on 5/11/16.
//  Copyright © 2016 Yury Ramanchuk. All rights reserved.
//

import Foundation
class ShoppingItem: NSObject, NSCoding
{
    var name:String
    var imageName:String
    var unitPrice:String
    var quantity:Int
    var units:String
    var itemDescription:String
    
    init(name:String, imageName:String, unitPrice:String, quantity:Int, units:String, description:String)
    {
        self.name = name
        self.imageName = imageName.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).capitalizedString
        self.unitPrice = unitPrice
        self.quantity = quantity
        self.units = units
        self.itemDescription = description
    }
    
    required init(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.imageName = aDecoder.decodeObjectForKey("imageName") as! String
        self.unitPrice = aDecoder.decodeObjectForKey("unitPrice") as! String
        self.quantity = (aDecoder.decodeObjectForKey("quantity") as! NSNumber).integerValue
        self.units = aDecoder.decodeObjectForKey("units") as! String
        self.itemDescription = aDecoder.decodeObjectForKey("itemDescription") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(imageName, forKey: "imageName")
        aCoder.encodeObject(unitPrice, forKey: "unitPrice")
        aCoder.encodeObject(quantity, forKey: "quantity")
        aCoder.encodeObject(units, forKey: "units")
        aCoder.encodeObject(itemDescription, forKey: "itemDescription")
    }
}