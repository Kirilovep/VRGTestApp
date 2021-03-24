//
//  DetailViewController.swift
//  VRGTestApp
//
//  Created by shizo663 on 24.03.2021.
//

import UIKit
import WebKit
import CoreData
import Kingfisher
class DetailViewController: UIViewController, WKNavigationDelegate {
    
    //MARK: - Properties-
    var detailData: News?
    var savedData: CoreDataNews?
    var fromCoreData = false
    private var webView: WKWebView!
    private let saveBarButton = UIBarButtonItem()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - IBOutlets -
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var openWebButton: UIButton!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var abstractLabel: UILabel!
    
    //MARK: - LifeCycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButton()
        configureUI(fromCoreData)
        checkSavedData()
    }

    //MARK: - Functions -
    private func configureUI(_ coreData: Bool) {
        navigationItem.largeTitleDisplayMode = .never
        if coreData {
            sourceLabel.text = savedData?.source
            publishedLabel.text = savedData?.published
            typeLabel.text = savedData?.type
            detailTitleLabel.text = savedData?.title
            abstractLabel.text = savedData?.abstract
            if let imageData = savedData?.image {
                posterImage.image = UIImage(data: imageData)
            } else {
                posterImage.image = UIImage(named: "noImage")
            }
        } else {
            sourceLabel.text = detailData?.source
            publishedLabel.text = detailData?.published
            typeLabel.text = detailData?.type
            detailTitleLabel.text = detailData?.title
            abstractLabel.text = detailData?.abstract
            
            if detailData?.media.isEmpty == true {
                posterImage.image = UIImage(named: "noImage")
            } else {
                if let url = URL(string: detailData?.media[0].media[2].url ?? "") {
                    posterImage.kf.indicatorType = .activity
                    posterImage.kf.setImage(with: url)
                }
            }
        }
        openWebButton.layer.cornerRadius = 10
    }
    
    private func checkSavedData() {
        let fetchNews: NSFetchRequest<CoreDataNews> = CoreDataNews.fetchRequest()
    
        if fromCoreData {
            if let id = savedData?.id {
                fetchNews.predicate = NSPredicate(format: "id = %lld", id)
            }
            let results = try? context.fetch(fetchNews)
            if results?.count == 0 {
            } else {
                saveBarButton.isEnabled = false
            }
        } else {
            if let id = detailData?.id {
                let id = Int64(id)
                fetchNews.predicate = NSPredicate(format: "id = %lld", id)
                let results = try? context.fetch(fetchNews)
                if results?.count == 0 {     
                } else {
                    saveBarButton.isEnabled = false
                }
            }
        }
    }
    
    private func setUpButton() {
        saveBarButton.title = "Save"
        saveBarButton.target = self
        saveBarButton.style = .plain
        saveBarButton.action = #selector(saveButtonTapped)
        navigationItem.rightBarButtonItem = saveBarButton
    }
    
    @objc func saveButtonTapped() {
        let newsEntity = CoreDataNews(context: context)
        newsEntity.abstract = detailData?.abstract
        newsEntity.published = detailData?.published
        newsEntity.title = detailData?.title
        newsEntity.type = detailData?.type
        newsEntity.url = detailData?.url
        newsEntity.source = detailData?.source
        if let id = detailData?.id {
            newsEntity.id = Int64(id)
        }
        if let imageData = posterImage.image?.pngData() {
            newsEntity.image = imageData
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        saveBarButton.isEnabled = false
    }
    
    @IBAction func openButtonPressed(_ sender: UIButton) {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        if let stringUrl = detailData?.url {
            if let url = URL(string: stringUrl) {
                webView.load(URLRequest(url: url))
                webView.allowsBackForwardNavigationGestures = true
                navigationItem.rightBarButtonItem = nil
            }
        } else {
            if let stringUrl = savedData?.url {
                if let url = URL(string: stringUrl) {
                    webView.load(URLRequest(url: url))
                    webView.allowsBackForwardNavigationGestures = true
                    navigationItem.rightBarButtonItem = nil
                }
            }
        }
    }
}







