//
//  SearchView.swift
//  pianoLearningApp
//
//  Created by Vincent_Huang on 2019/3/26.
//  Copyright © 2019年 ENYUHUANG. All rights reserved.
//

import UIKit

class SearchView: UIView {

    @IBOutlet weak var backGround: UIView!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var resultsView: UIView!
    @IBOutlet weak var tableView: UITableView!
//    var searchBar: SHSearchBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        let searchBarConfig = SHSearchBarConfig()
//        searchBar = SHSearchBar(config: searchBarConfig)
//        searchBar.frame = searchBarView.frame
//        searchBarView.addSubview(searchBar)
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeSearchView))
//        self.backGround.addGestureRecognizer(tapGesture)
    }

    @objc func closeSearchView() {
        self.removeFromSuperview()
    }
}
