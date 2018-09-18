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
class XHStockListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating {
    var searchResults: [Double] = []
    var stockCurrentQuotes: [stockCurrentQuoteInfo] = []
    var stockSymbols = ["AAPL", "BABA", "FB", "AMAT","SNAP"]
    
    let searchController = UISearchController(searchResultsController: nil)
    let networkManager = XHStockInfoDownloader.sharedInstance
    
    var collectionView: UICollectionView
    
    init() {
        //view layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = XHStockListCollectionViewCell.cellSize();
        layout.minimumLineSpacing = 2
        
        //create collection view
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        
        self.view.addSubview(collectionView)
        
        //set up searchbar
        searchController.searchBar.placeholder = " Search..."
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = self
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            // Fallback on earlier versions
            self.navigationItem.titleView = searchController.searchBar
        }
        definesPresentationContext = true
        
        //set up collection view
        collectionView.snp.makeConstraints { (make)->Void in
            make.top.equalTo(self.view).offset(44)
            make.left.right.bottom.equalTo(self.view)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(XHStockListCollectionViewCell.self, forCellWithReuseIdentifier: tableViewCellReuseIdentifier)
        
        self.setupNetworkRequest()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - collectionView data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stockCurrentQuotes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tableViewCellReuseIdentifier, for: indexPath) as! XHStockListCollectionViewCell
        cell.stockInfo = stockCurrentQuotes[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = StockDetailViewController.init(stockQuote:stockCurrentQuotes[indexPath.row])
        self.navigationController?.present(detailVC, animated: true, completion: nil)
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
    
    func searchStockFianceWithSymbol(symbol: String) {
        //TODO
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All")  {
        let length = searchText.count
        
        if length > 0 {
            searchStockFianceWithSymbol(symbol: searchText)
        } else {
            searchResults.removeAll()
            collectionView.reloadData()
        }
        
    }
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        /*
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                collectionView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
 */
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        /*
        if let _ = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
        }
 */
    }

    // MARK: - Private
    private func setupNetworkRequest()
    {
        networkManager.fetchStocksCurrentPrices(stockSymbols: stockSymbols, completion: { (fetchedPrices) in
            DispatchQueue.main.async{
                self.stockCurrentQuotes = fetchedPrices
                self.collectionView.reloadData()
            }
        })
        
        // Fetch financial info of all stocks in background
        for s in stockSymbols {
            let financial = CoreDataStack.sharedInstance.fetchFinancialHistoryOfStock(symbol: s)
            if let lastUpdateTime = financial?.lastUpdateTime {
                if(lastUpdateTime.timeIntervalSinceNow < 60 * 60 * 24){
                    continue
                }
            }
            networkManager.fetchStocksFinancialData(stockSymbol: s) { (financialData) in
                CoreDataStack.sharedInstance.saveStockFinancialHistoryEntityFrom(symbol: s, dictionary: financialData)
            }
        }
    }
}
