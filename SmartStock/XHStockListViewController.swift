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
class XHStockListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    var stockQuotes = [String: StockCurrentQuote]()
    var stockKeyStats = [String: StockKeyStats]()
    var stockSymbols = ["AAPL", "BABA", "FB", "AMAT","SNAP"]
    
    let searchBar = UISearchBar()
    var searchItems = [String]()
    var isSearchMode: Bool = false
    
    let networkManager = XHStockInfoDownloader()
    
    var collectionView: UICollectionView
    
    init() {
        //view layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = XHStockListCollectionViewCell.cellSize();
        layout.minimumLineSpacing = 2
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        //create collection view
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        self.view.backgroundColor = UIColor.white
        
        //set up searchbar
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        searchBar.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        definesPresentationContext = true
        
        //set up collection view
        self.view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(XHStockListCollectionViewCell.self, forCellWithReuseIdentifier: tableViewCellReuseIdentifier)
        
        self.setupNetworkRequest()
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
        return isSearchMode ? searchItems.count : stockSymbols.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tableViewCellReuseIdentifier, for: indexPath) as! XHStockListCollectionViewCell
        let symb = isSearchMode ? searchItems[indexPath.row] : stockSymbols[indexPath.row]
        cell.setStockInfo(quote: stockQuotes[symb], keyStats: stockKeyStats[symb])
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
        let symb = stockSymbols[indexPath.row]
        let detailVC = StockDetailViewController.init(stockQuote: stockQuotes[symb]!, stockStats: stockKeyStats[symb]!)
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
    
    func _filterContentForSearchText(_ searchText: String)  {
        let length = searchText.count
        
        if length > 0 {
            searchItems.removeAll()
            for symb in stockSymbols {
                if symb.hasPrefix(searchText){
                    searchItems.append(symb)
                }
            }
        } else {
            searchItems = stockSymbols
        }
        collectionView.reloadData()
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearchMode = false
        self._filterContentForSearchText(searchBar.text!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchItems.removeAll()
        searchBar.text = nil
        isSearchMode = false
        collectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearchMode = true
        self._filterContentForSearchText(searchText)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                collectionView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
        }
    }

    // MARK: - Private
    private func setupNetworkRequest()
    {
        networkManager.fetchQuoteAndStatsOfStocks(stockSymbols: stockSymbols) { (keyStats, quotes) in
            self.stockQuotes = quotes
            self.stockKeyStats = keyStats
            self.collectionView.reloadData()
        }
        
        // Fetch financial info of all stocks in background
        for s in stockSymbols {
            let financial = CoreDataStack.sharedInstance.fetchFinancialHistoryOfStock(symbol: s)
            if let lastUpdateTime = financial?.lastUpdateTime {
                if(-lastUpdateTime.timeIntervalSinceNow < 60 * 60 * 24){
                    continue
                }
            }
            networkManager.fetchFinancialsOfStock(stockSymbol: s) { (financialData) in
               // CoreDataStack.sharedInstance.saveStockFinancialHistoryEntityFrom(symbol: s, dictionary: financialData)
            }
        }
    }
}
