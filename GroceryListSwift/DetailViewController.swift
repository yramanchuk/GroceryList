//
//  DetailViewController.swift
//  GroceryListSwift
//
//  Created by Yury Ramanchuk on 5/11/16.
//  Copyright © 2016 Yury Ramanchuk. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var priceCell: UITableViewCell!
    @IBOutlet weak var unitsCell: UITableViewCell!
    @IBOutlet weak var quantatyCell: UITableViewCell!
    @IBOutlet weak var descriptionCell: UITableViewCell!


    var detailShoppingItem: ShoppingItem? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailShoppingItem {
            if let priceCellView = self.priceCell {
                priceCellView.textLabel?.text = detail.unitPrice
            }
            if let unitsCellView = self.unitsCell {
                unitsCellView.textLabel?.text = detail.units
            }
            if let quantatyCellView = self.quantatyCell {
                quantatyCellView.textLabel?.text = String(format: "%d", detail.quantity)
            }
            if let descriptionCellView = self.descriptionCell {
                descriptionCellView.textLabel?.text = detail.itemDescription
            }
            if let imageView = self.image {
                imageView.image = UIImage(named: detail.imageName)
            }

            self.title = detail.name
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

