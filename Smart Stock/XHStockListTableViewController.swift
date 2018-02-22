//
//  XHStockListTableViewController.swift
//  Smart Stock
//
//  Created by Xiaohong Wang on 7/16/17.
//  Copyright © 2017 project.stock.com.xiaohong. All rights reserved.
//

import UIKit

let tableViewCellReuseIdentifier = "stockCell"

//todo: rename to view controller and put table view in separate file
class XHStockListTableViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    var searchResults: [Double] = []
    var stockPrices: [stockPriceInfo] = []
    var stockSymbols = ["AAPL", "BABA", "FB", "AMAT"]
    
    let searchController = UISearchController(searchResultsController: nil)
    var tableView: UITableView = UITableView()
    
    //MARK: Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up searchbar
        searchController.searchBar.placeholder = " Search..."
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = self
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        definesPresentationContext = true
        
        //set up table view
        tableView.frame = self.view.frame
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(XHStockListTableViewCell.self, forCellReuseIdentifier: tableViewCellReuseIdentifier)
        
        self.view.addSubview(tableView)
        
        if(stockSymbols.count > stockPrices.count){
            XHStockInfoDownloader.fetchStocksCurrentPrices(stockSymbols: stockSymbols, completion: { (fetchedPrices) in
                DispatchQueue.main.async{
                self.stockPrices = fetchedPrices
                self.tableView.reloadData()
                }
            })
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return stockPrices.count
    }
    
    func searchStockFianceWithSymbol(symbol: String) {
        //TODO
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All")  {
        let length = searchText.count
        
        if length > 0 {
            searchStockFianceWithSymbol(symbol: searchText)
        } else {
            searchResults.removeAll()
            tableView.reloadData()
        }
        
    }

    //SearchBar stuff
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellReuseIdentifier, for: indexPath) as! XHStockListTableViewCell
        cell.stockInfo = stockPrices[indexPath.row]
        return cell
    }
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
