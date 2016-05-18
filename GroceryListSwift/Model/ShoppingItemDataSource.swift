//
//  ShoppingItemDataSource.swift
//  GroceryListSwift
//
//  Created by Yury Ramanchuk on 5/18/16.
//  Copyright © 2016 Yury Ramanchuk. All rights reserved.
//

import UIKit

struct ShoppingItemsCategorized {
    var categories = [String]()
    var itemObjects = [[ShoppingItem]]()
    
    func getShoppingListForCategory(categoryIdx: Int) -> [ShoppingItem]? {
        return itemObjects[categoryIdx]
    }
    
    func getShoppingListForCategory(categoryName: String) -> [ShoppingItem]? {
        if let idx = categories.indexOf(categoryName) {
            return getShoppingListForCategory(idx)
        }
        
        return nil
    }

    func getShoppingItem(categoryIdx: Int, itemIdx: Int) -> ShoppingItem? {
        if let categoryList = getShoppingListForCategory(categoryIdx) {
            return categoryList[itemIdx]
        }
        
        return nil
    }
    
    mutating func moveShoppingItem(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        if (fromIndexPath.section != toIndexPath.section) {
            let movedItem = itemObjects[fromIndexPath.section].removeAtIndex(fromIndexPath.row)
            itemObjects[toIndexPath.section].insert(movedItem, atIndex: toIndexPath.row)
        } else if (fromIndexPath.section != toIndexPath.section && fromIndexPath.row != toIndexPath.section) {
            swap(&itemObjects[fromIndexPath.section][fromIndexPath.row], &itemObjects[toIndexPath.section][toIndexPath.row])
        }
        
    }
    
    mutating func appendItems(shoppingItems: [ShoppingItem]) {
        for item in shoppingItems {
            if let idx = categories.indexOf(item.itemDescription) {
                itemObjects[idx].append(item)
            } else {
                itemObjects.append([item])
                categories.append(item.itemDescription)
            }
        }
        
    }
    
}

class ShoppingItemDataSource {
    // MARK: - constants
    private let kLblUncategorize = "Uncategorize"
    private let kLblCategorize = "Categorize"
    
    private let kItemsSyncKey = "kItemsSyncKey"
    private let kItemsCategorizedSyncKey = "kItemsCategorizedSyncKey"
    private let kItemsCategorizedKeysSyncKey = "kItemsCategorizedKeysSyncKey"

    private var isCategorized = false
    var isFiltered = false

    private var items = [ShoppingItem]()
    private var itemsCategorized = ShoppingItemsCategorized()

    private var filteredItems = [ShoppingItem]()
    private var filteredItemsCategorized = ShoppingItemsCategorized()
    
    init() {
        retrieveShoppingItems()
        retrieveShoppingItemsCategorized()
    }
    
    func moveShoppingItem(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        if (isCategorized) {
            itemsCategorized.moveShoppingItem(fromIndexPath, toIndexPath: toIndexPath)
            saveShoppingItemsCategorized()
        } else if (fromIndexPath.row != toIndexPath.row) {
            swap(&items[fromIndexPath.row], &items[toIndexPath.row])
            saveShoppingItems()
        }
    }
    
    func categorizeShoppingList() {
        isCategorized = !isCategorized
    }
    
    
    func getCategorizeLbl() -> String {
        return isCategorized ? kLblUncategorize: kLblCategorize
    }
    
    
}

//MARK: - table view helper
extension ShoppingItemDataSource {
    func numberOfSections() -> Int {
        return isCategorized ? itemsCategorized.categories.count : 1
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        
        if isFiltered {
            return isCategorized ? filteredItemsCategorized.getShoppingListForCategory(section)!.count : filteredItems.count
        } else {
            return isCategorized ? itemsCategorized.getShoppingListForCategory(section)!.count : items.count
        }
        
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        if isFiltered {
            return isCategorized ? filteredItemsCategorized.categories[section] : nil
        } else {
            return isCategorized ? itemsCategorized.categories[section] : nil
        }
    }
    
    func shoppingItemForCell(indexPath: NSIndexPath) -> ShoppingItem {
        if isFiltered {
            return isCategorized ? (filteredItemsCategorized.getShoppingItem(indexPath.section, itemIdx: indexPath.row))! : filteredItems[indexPath.row]
        } else {
            return isCategorized ? (itemsCategorized.getShoppingItem(indexPath.section, itemIdx: indexPath.row))! : items[indexPath.row]
        }
        
    }
}

//MARK: - sorting & filtering
extension ShoppingItemDataSource {
    func sortShoppingList() {
        if (!isCategorized) {
            items.sortInPlace() { $0.name < $1.name }
            
            saveShoppingItems()
        } else {
            for (index, items) in itemsCategorized.itemObjects.enumerate() {
                itemsCategorized.itemObjects[index] = items.sort() { $0.name < $1.name }
            }
            saveShoppingItemsCategorized()
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String) {
        if (!isFiltered) {
            return
        }
        
        if (!isCategorized) {
            filteredItems = items.filter({( shoppingItem : ShoppingItem) -> Bool in
                //            let categoryMatch = (scope == "All") || (shoppingItem.category == scope)
                //            return categoryMatch && shoppingItem.name.lowercaseString.containsString(searchText.lowercaseString)
                return shoppingItem.name.lowercaseString.containsString(searchText.lowercaseString)
            })
        } else {
            for (index, items) in itemsCategorized.itemObjects.enumerate() {

                filteredItemsCategorized.itemObjects[index] = items.filter({( shoppingItem : ShoppingItem) -> Bool in
                    return shoppingItem.name.lowercaseString.containsString(searchText.lowercaseString)
                })
            }
        }
    }
    
    
}

//MARK: saving helpers
extension ShoppingItemDataSource {
    private func retrieveShoppingItems() {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(kItemsSyncKey) as? NSData,
            let unarchivedValue =  NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [ShoppingItem] {
            items =  unarchivedValue
        } else {
            items = SuggestedListManager.sharedInstance.suggestedItems
        }
    }
    
    private func retrieveShoppingItemsCategorized() {
        if
            let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(kItemsCategorizedSyncKey) as? NSData,
            let unarchivedValue =  NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [[ShoppingItem]],
            
            let unarchivedObjectCategories = NSUserDefaults.standardUserDefaults().objectForKey(kItemsCategorizedKeysSyncKey) as? NSData,
            let unarchivedValueCategories =  NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObjectCategories) as? [String] {
            
            itemsCategorized.itemObjects = unarchivedValue
            itemsCategorized.categories = unarchivedValueCategories
            
            filteredItemsCategorized.itemObjects = unarchivedValue
            filteredItemsCategorized.categories = unarchivedValueCategories
            
        } else {
            itemsCategorized.appendItems(items)
            filteredItemsCategorized.appendItems(items)
            
        }

    }
    
    private func saveShoppingItems() {
        
        let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(items as NSArray)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(archivedObject, forKey: kItemsSyncKey)
        defaults.synchronize()
        
    }
    
    private func saveShoppingItemsCategorized() {
        
        let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(itemsCategorized.itemObjects as NSArray)
        let archivedObjectKeys = NSKeyedArchiver.archivedDataWithRootObject(itemsCategorized.categories as NSArray)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(archivedObject, forKey: kItemsCategorizedSyncKey)
        defaults.setObject(archivedObjectKeys, forKey: kItemsCategorizedKeysSyncKey)
        defaults.synchronize()
        
    }

}


//func saveShoppingItems(shoppingItems:[ShoppingItem]) -> Void {
//    
//    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(shoppingItems as NSArray)
//    let defaults = NSUserDefaults.standardUserDefaults()
//    defaults.setObject(archivedObject, forKey: kItemsSyncKey)
//    defaults.synchronize()
//    
//}
//
//func saveShoppingItemsCategorized(shoppingItems:[String:[ShoppingItem]]) -> Void {
//    
//    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(shoppingItems as NSDictionary)
//    let defaults = NSUserDefaults.standardUserDefaults()
//    defaults.setObject(archivedObject, forKey: kItemsCategorizedSyncKey)
//    defaults.synchronize()
//    
//}
//
//func retrieveShoppingItems() -> [ShoppingItem]? {
//    if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(kItemsSyncKey) as? NSData {
//        return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [ShoppingItem]
//    }
//    return nil
//}
//
//func retrieveShoppingItemsCategorized() -> [String:[ShoppingItem]]? {
//    if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(kItemsCategorizedSyncKey) as? NSData {
//        return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [String:[ShoppingItem]]
//    }
//    return nil
//}