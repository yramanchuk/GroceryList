//
//  SuggestedListManager.swift
//  GroceryListSwift
//
//  Created by Yury Ramanchuk on 5/11/16.
//  Copyright © 2016 Yury Ramanchuk. All rights reserved.
//

import Foundation

class SuggestedListManager: NSObject
{
    var suggestedItems = [ShoppingItem]()
    
    class var sharedInstance:SuggestedListManager
    {
        struct Static
        {
            static var instance : SuggestedListManager? = nil
            static var onceToken : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken)
        {
            Static.instance = SuggestedListManager()
            Static.instance!.createShoppingListItems()
        }
        return Static.instance!
    }
    
    func createShoppingListItems()
    {
        self.suggestedItems.append(ShoppingItem(name: "Cookies", imageName: "Cookie", unitPrice: "$2.95", quantity: 1, units: "13.3 oz", description: "Chocolate"))
        self.suggestedItems.append(ShoppingItem(name: "Black Berries", imageName: "BlackBerries", unitPrice: "$2.93", quantity: 1, units: "", description: "Organic"))
        self.suggestedItems.append(ShoppingItem(name: "Apples", imageName: "Apple", unitPrice: "$1.01", quantity: 1, units: "lb", description: "Organic"))
        self.suggestedItems.append(ShoppingItem(name: "Blue Berries", imageName: "BlueBerries", unitPrice: "$4.95", quantity: 1, units: "", description: "Organic"))
        self.suggestedItems.append(ShoppingItem(name: "Steak", imageName: "Steak", unitPrice: "$11.99", quantity: 1, units: "1 lb", description: "T-Bone"))
        self.suggestedItems.append(ShoppingItem(name: "Bread", imageName: "Bread", unitPrice: "$3.99", quantity: 1, units: "", description: "Organic"))
        self.suggestedItems.append(ShoppingItem(name: "Orange Juice", imageName: "Orange Juice", unitPrice: "$5.00", quantity: 1, units: "12 oz", description: "Organic"))
        self.suggestedItems.append(ShoppingItem(name: "Bananas", imageName: "Banana", unitPrice: "$0.99", quantity: 1, units: "1 lb", description: "Organic"))
        self.suggestedItems.append(ShoppingItem(name: "Cantaloupe", imageName: "Canteloupe", unitPrice: "$0.63", quantity: 1, units: "1 lb", description: "Organic"))
        self.suggestedItems.append(ShoppingItem(name: "Cheerios", imageName: "Cheerios", unitPrice: "$3.13", quantity: 1, units: "12 oz", description: "Gluten Free"))
        self.suggestedItems.append(ShoppingItem(name: "Turkey", imageName: "Turkey", unitPrice: "$23.04", quantity: 1, units: "16 lb", description: "Fresh"))
        self.suggestedItems.append(ShoppingItem(name: "Dates", imageName: "Dates", unitPrice: "$3.49", quantity: 1, units: "1 lb", description: "Organic"))
        self.suggestedItems.append(ShoppingItem(name: "Dragon Fruit", imageName: "Dragon Fruit", unitPrice: "$7.34", quantity: 1, units: "3 oz", description: "Organic"))
        self.suggestedItems.append(ShoppingItem(name: "Figs", imageName: "Fig", unitPrice: "$4.09", quantity: 1, units: "5 oz", description: "Organic"))
        self.suggestedItems.append(ShoppingItem(name: "Ground Beef", imageName: "GroundBeef", unitPrice: "$7.49", quantity: 1, units: "1 lb", description: "Fresh"))
        self.suggestedItems.append(ShoppingItem(name: "Hot Dog Buns", imageName: "HotDogBun", unitPrice: "$3.29", quantity: 1, units: "8 ct", description: "Enriched Buns"))
        self.suggestedItems.append(ShoppingItem(name: "Eggs", imageName: "Eggs", unitPrice: "$7.49", quantity: 1, units: "1 dozen", description: "Organic"))
        self.suggestedItems.append(ShoppingItem(name: "Peaches", imageName: "Peach", unitPrice: "$7.49", quantity: 1, units: "3 lb", description: "Organic"))
        self.suggestedItems.append(ShoppingItem(name: "Oranges", imageName: "Orange", unitPrice: "$5.49", quantity: 1, units: "12 ct", description: "Organic"))
        self.suggestedItems.append(ShoppingItem(name: "Mineral Water", imageName: "MineralWater", unitPrice: "$5.00", quantity: 1, units: "12 ct", description: "Sparkling Mineral Water"))
        self.suggestedItems.append(ShoppingItem(name: "Rice Krispies", imageName: "RiceKrispies", unitPrice: "$3.38", quantity: 1, units: "18 oz", description: "Kelloggs"))
    }
    
}