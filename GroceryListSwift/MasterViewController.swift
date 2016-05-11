//
//  MasterViewController.swift
//  GroceryListSwift
//
//  Created by Yury Ramanchuk on 5/11/16.
//  Copyright © 2016 Yury Ramanchuk. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    // MARK: - Properties
    var categorized = false
    var detailViewController: DetailViewController? = nil
    var shoppingItems = [ShoppingItem]()
    var shoppingItemsCategorized = [String : [ShoppingItem]]()
    var filteredshoppingItems = [ShoppingItem]()
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if let items = self.retrieveItems() {
            shoppingItems = items
        } else {
            shoppingItems = SuggestedListManager.sharedInstance.suggestedItems;
        }

        for item in shoppingItems {
            if (shoppingItemsCategorized[item.itemDescription] == nil) {
                shoppingItemsCategorized[item.itemDescription] = [ShoppingItem]()
            }
            shoppingItemsCategorized[item.itemDescription]?.append(item)
        }
        
        let editButton = UIBarButtonItem()
        editButton.target = self.editButtonItem().target
        editButton.action = self.editButtonItem().action
        editButton.title = "Edit"
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

    
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
//        searchController.searchBar.scopeButtonTitles = ["All", "Fruits", "Dry Fruits", "Other"]
        tableView.tableHeaderView = searchController.searchBar
        
        let sortButton = UIBarButtonItem()
        sortButton.target = self
        sortButton.action = #selector(MasterViewController.categorizeShoppingList(_:))
        sortButton.title = categorized ? "Uncategorize": "Categorize"
        self.navigationItem.rightBarButtonItem = sortButton

        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(UIImage(named: "sort"), forSearchBarIcon: UISearchBarIcon.Bookmark, state: UIControlState.Normal)
        
        if let splitViewController = splitViewController {
            let controllers = splitViewController.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return categorized ? shoppingItemsCategorized.count : 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredshoppingItems.count
        }
        return categorized ? shoppingItemsCategorized[((shoppingItemsCategorized as NSDictionary).allKeys as! [String])[section]]!.count : shoppingItems.count
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categorized ? ((shoppingItemsCategorized as NSDictionary).allKeys as! [String])[section] : nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let shoppingItem: ShoppingItem
        if searchController.active && searchController.searchBar.text != "" {
            shoppingItem = filteredshoppingItems[indexPath.row]
        } else {
            if categorized {
                let sectionItems = shoppingItemsCategorized[((shoppingItemsCategorized as NSDictionary).allKeys as! [String])[indexPath.section]]
                shoppingItem = sectionItems![indexPath.row]
            } else {
                shoppingItem = shoppingItems[indexPath.row]
            }
        }
        cell.textLabel!.text = shoppingItem.name
        cell.detailTextLabel!.text = shoppingItem.unitPrice
        cell.imageView?.image = UIImage(named:shoppingItem.imageName);
        return cell
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let itemToMove = shoppingItems[fromIndexPath.row]
        shoppingItems.removeAtIndex(fromIndexPath.row)
        shoppingItems.insert(itemToMove, atIndex: toIndexPath.row)
        
        self.saveLists()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredshoppingItems = shoppingItems.filter({( shoppingItem : ShoppingItem) -> Bool in
//            let categoryMatch = (scope == "All") || (shoppingItem.category == scope)
//            return categoryMatch && shoppingItem.name.lowercaseString.containsString(searchText.lowercaseString)
            return shoppingItem.name.lowercaseString.containsString(searchText.lowercaseString)
        })
        tableView.reloadData()
    }
    
    //MARK: - sorting
    
    func sortShoppingList(sender: AnyObject?) {
        shoppingItems.sortInPlace() { $0.name < $1.name }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.synchronize()

        tableView.reloadData();
    }

    func categorizeShoppingList(sender: UIBarButtonItem?) {
        categorized = !categorized
        sender?.title = categorized ? "Uncategorize": "Categorize"
        
        tableView.reloadData()
    }

    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let shoppingItem: ShoppingItem
                if searchController.active && searchController.searchBar.text != "" {
                    shoppingItem = filteredshoppingItems[indexPath.row]
                } else {
                    shoppingItem = shoppingItems[indexPath.row]
                }
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailShoppingItem = shoppingItem
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
 
    func saveLists() -> Void {
        
        let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(shoppingItems as NSArray)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(archivedObject, forKey: "shoppingItems")
        defaults.synchronize()
        
    }
    
    func retrieveItems() -> [ShoppingItem]? {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("shoppingItems") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [ShoppingItem]
        }
        return nil
    }
}

extension MasterViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        self.sortShoppingList(searchBar)
    }
}

extension MasterViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        let searchBar = searchController.searchBar
//        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: "")
    }
}
