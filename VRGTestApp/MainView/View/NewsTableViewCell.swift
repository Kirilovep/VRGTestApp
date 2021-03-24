//
//  NewsTableViewCell.swift
//  VRGTestApp
//
//  Created by shizo663 on 23.03.2021.
//

import UIKit
import Kingfisher
class NewsTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets -
    @IBOutlet weak var countrySourceLabel: UILabel!
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    
    //MARK: - LifeCycle -
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - Functions -
    func configure(_ result: News) {
        self.titleLabel.text = result.title
        self.publishedLabel.text = result.published
        self.countrySourceLabel.text = result.source
        
        if result.media.isEmpty == true {
            posterImage.image = UIImage(named: "noImage")
        } else {
            if let url = URL(string: result.media[0].media[0].url ?? "") {
                posterImage.kf.indicatorType = .activity
                posterImage.kf.setImage(with: url)
            }
        }
    }
    
    func configureFromCoreData(_ result: CoreDataNews) {
        titleLabel.text = result.title
        publishedLabel.text = result.published
        countrySourceLabel.text = result.source
        if let imageData = result.image {
            posterImage.image = UIImage(data: imageData)
        } else {
            posterImage.image = UIImage(named: "noImage")
        }
    }
}
