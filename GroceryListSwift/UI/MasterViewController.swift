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
    var detailViewController: DetailViewController? = nil
    let shoppingDataSource = ShoppingItemDataSource()
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let editButton = UIBarButtonItem()
        editButton.target = self.editButtonItem().target
        editButton.action = self.editButtonItem().action
        editButton.title = "Edit"
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

    
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        tableView.tableHeaderView = searchController.searchBar
        
        let sortButton = UIBarButtonItem()
        sortButton.target = self
        sortButton.action = #selector(MasterViewController.categorizeShoppingList(_:))
        sortButton.title = shoppingDataSource.getCategorizeLbl()
        self.navigationItem.rightBarButtonItem = sortButton

        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(UIImage(named: "sort"), forSearchBarIcon: UISearchBarIcon.Bookmark, state: UIControlState.Normal)
        
//        if let splitViewController = splitViewController {
//            let controllers = splitViewController.viewControllers
//            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        //used for master-detail
//        clearsSelectionOnViewWillAppear = splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return shoppingDataSource.numberOfSections()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingDataSource.numberOfRowsInSection(section)
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return shoppingDataSource.titleForHeaderInSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let shoppingItem = shoppingDataSource.shoppingItemForCell(indexPath)

        (cell.viewWithTag(1) as! UILabel).text = shoppingItem.name
        (cell.viewWithTag(2) as! UILabel).text = shoppingItem.unitPrice
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
        shoppingDataSource.moveShoppingItem(fromIndexPath, toIndexPath: toIndexPath)
    }
    
    //MARK: - filtering
    func filterContentForSearchText(searchText: String, scope: String /*= "All"*/) {
        shoppingDataSource.isFiltered = searchController.active && searchController.searchBar.text != ""

        shoppingDataSource.filterContentForSearchText(searchText, scope: scope)
        tableView.reloadData()
    }
    
    //MARK: - sorting
    func categorizeShoppingList(sender: UIBarButtonItem?) {
        shoppingDataSource.categorizeShoppingList()
        sender?.title = shoppingDataSource.getCategorizeLbl()
        
        tableView.reloadData()
    }

    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let shoppingItem = shoppingDataSource.shoppingItemForCell(indexPath)
                
                //used for master-detail
//                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
//                controller.detailShoppingItem = shoppingItem
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
//                controller.navigationItem.leftItemsSupplementBackButton = true

                let controller = segue.destinationViewController as! DetailViewController
                controller.detailShoppingItem = shoppingItem
                self.navigationController?.navigationBarHidden = false
            }
        }
    }
    
 
}


extension MasterViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        shoppingDataSource.sortShoppingList()
        tableView.reloadData();
    }
}

extension MasterViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        let searchBar = searchController.searchBar
//        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: "")
    }
}
