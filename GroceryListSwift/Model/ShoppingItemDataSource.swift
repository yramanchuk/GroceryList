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
    var items = [[ShoppingItem]]()
    
    func getShoppingListForCategory(categoryIdx: Int) -> [ShoppingItem]? {
        return items[categoryIdx]
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
            let movedItem = items[fromIndexPath.section].removeAtIndex(fromIndexPath.row)
            items[toIndexPath.section].insert(movedItem, atIndex: toIndexPath.row)
        } else {
            swap(&items[fromIndexPath.section][fromIndexPath.row], &items[toIndexPath.section][toIndexPath.row])
        }
        
    }
    
    mutating func appendItems(shoppingItems: [ShoppingItem]) {
        for item in shoppingItems {
            if let idx = categories.indexOf(item.itemDescription) {
                items[idx].append(item)
            } else {
                items.append([item])
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

    private var categorized = false
    var filtered = false

    private var shoppingItems = [ShoppingItem]()
    private var shoppingItemsCategorized = ShoppingItemsCategorized()

    private var filteredShoppingItems = [ShoppingItem]()
    private var filteredShoppingItemsItemsCategorized = ShoppingItemsCategorized()
    
    init() {
        retrieveShoppingItems()
        retrieveShoppingItemsCategorized()
    }
    
    func moveShoppingItem(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        if (categorized) {
            shoppingItemsCategorized.moveShoppingItem(fromIndexPath, toIndexPath: toIndexPath)
            saveShoppingItemsCategorized()
        } else {
            swap(&shoppingItems[fromIndexPath.row], &shoppingItems[toIndexPath.row])
            saveShoppingItems()
        }
    }
    
    func categorizeShoppingList() {
        categorized = !categorized
    }
    
    
    func getCategorizeLbl() -> String {
        return categorized ? kLblUncategorize: kLblCategorize
    }
    
    
}

//MARK: - table view helper
extension ShoppingItemDataSource {
    func numberOfSections() -> Int {
        return categorized ? shoppingItemsCategorized.categories.count : 1
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        
        if filtered {
            return categorized ? filteredShoppingItemsItemsCategorized.getShoppingListForCategory(section)!.count : filteredShoppingItems.count
        } else {
            return categorized ? shoppingItemsCategorized.getShoppingListForCategory(section)!.count : shoppingItems.count
        }
        
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        if filtered {
            return categorized ? filteredShoppingItemsItemsCategorized.categories[section] : nil
        } else {
            return categorized ? shoppingItemsCategorized.categories[section] : nil
        }
    }
    
    func shoppingItemForCell(indexPath: NSIndexPath) -> ShoppingItem {
        if filtered {
            return categorized ? (filteredShoppingItemsItemsCategorized.getShoppingItem(indexPath.section, itemIdx: indexPath.row))! : filteredShoppingItems[indexPath.row]
        } else {
            return categorized ? (shoppingItemsCategorized.getShoppingItem(indexPath.section, itemIdx: indexPath.row))! : shoppingItems[indexPath.row]
        }
        
    }
}

//MARK: - sorting & filtering
extension ShoppingItemDataSource {
    func sortShoppingList() {
        if (!categorized) {
            shoppingItems.sortInPlace() { $0.name < $1.name }
            
            saveShoppingItems()
        } else {
            for var items in shoppingItemsCategorized.items {
                items.sortInPlace() { $0.name < $1.name }
            }
            shoppingItemsCategorized.categories.sortInPlace(<)
            saveShoppingItemsCategorized()
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String) {
        if (!filtered) {
            return
        }
        
        if (!categorized) {
            filteredShoppingItems = shoppingItems.filter({( shoppingItem : ShoppingItem) -> Bool in
                //            let categoryMatch = (scope == "All") || (shoppingItem.category == scope)
                //            return categoryMatch && shoppingItem.name.lowercaseString.containsString(searchText.lowercaseString)
                return shoppingItem.name.lowercaseString.containsString(searchText.lowercaseString)
            })
        } else {
            for (index, items) in shoppingItemsCategorized.items.enumerate() {

                filteredShoppingItemsItemsCategorized.items[index] = items.filter({( shoppingItem : ShoppingItem) -> Bool in
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
            shoppingItems =  unarchivedValue
        } else {
            shoppingItems = SuggestedListManager.sharedInstance.suggestedItems
        }
    }
    
    private func retrieveShoppingItemsCategorized() {
        if
            let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(kItemsCategorizedSyncKey) as? NSData,
            let unarchivedValue =  NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [[ShoppingItem]],
            
            let unarchivedObjectCategories = NSUserDefaults.standardUserDefaults().objectForKey(kItemsCategorizedKeysSyncKey) as? NSData,
            let unarchivedValueCategories =  NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObjectCategories) as? [String] {
            
            shoppingItemsCategorized.items = unarchivedValue
            shoppingItemsCategorized.categories = unarchivedValueCategories
            
            filteredShoppingItemsItemsCategorized.items = unarchivedValue
            filteredShoppingItemsItemsCategorized.categories = unarchivedValueCategories
            
        } else {
            shoppingItemsCategorized.appendItems(shoppingItems)
            filteredShoppingItemsItemsCategorized.appendItems(shoppingItems)
            
        }

    }
    
    private func saveShoppingItems() {
        
        let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(shoppingItems as NSArray)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(archivedObject, forKey: kItemsSyncKey)
        defaults.synchronize()
        
    }
    
    private func saveShoppingItemsCategorized() {
        
        let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(shoppingItemsCategorized.items as NSArray)
        let archivedObjectKeys = NSKeyedArchiver.archivedDataWithRootObject(shoppingItemsCategorized.categories as NSArray)
        
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