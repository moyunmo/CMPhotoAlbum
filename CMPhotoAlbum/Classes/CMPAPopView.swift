//
//  CMPAPopView.swift
//  CMPhotoAlbum
//
//  Created by Moyun on 2017/7/4.
//

import UIKit

class CMPAPopView: UIView {
    @IBOutlet var popupViewHeight: NSLayoutConstraint!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet var arrowImgView: UIImageView!
    @IBOutlet var backgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.popUpView.layer.cornerRadius = 5.0
        self.arrowImgView.image = CMBundle.bundleImage(named: "arrow")
        self.tableView.register(UINib(nibName: "CMPAListViewCell", bundle: Bundle(for: CMPAListViewCell.self)), forCellReuseIdentifier: "CMPAListViewCell")
    }
    
}
