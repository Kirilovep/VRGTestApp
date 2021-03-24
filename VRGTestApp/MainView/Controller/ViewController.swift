//
//  ViewController.swift
//  VRGTestApp
//
//  Created by shizo663 on 23.03.2021.
//

import UIKit

class ViewController: UIViewController {
    //MARK: - Properties -
    private var newsData: NewsModel?
    private let refreshControl = UIRefreshControl()
    private var savedData: [CoreDataNews]?
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let spinner = UIActivityIndicatorView(style: .large)
    
    //MARK: - IBOutlets -
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let nib = UINib(nibName: Cells.tableViewCellNib.rawValue, bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: Cells.tableViewCellIdentifier.rawValue)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    //MARK: - LifeCycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        setUpRefresh()
        checkConnection()
        setIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = parent?.restorationIdentifier
        if isSavedVC() {
            fetchDataFromCoreData()
        }
    }
    //MARK: - Functions -
    
    private func fetchData() {
        switch parent?.restorationIdentifier {
        case VC.mostViewed.rawValue:
            fetchNews(filter: Urls.viewed.rawValue)
        case VC.mostShared.rawValue:
            fetchNews(filter: Urls.shared.rawValue)
        case VC.mostEmailed.rawValue:
            fetchNews(filter: Urls.emailed.rawValue)
        case VC.savedVC.rawValue:
            fetchDataFromCoreData()
        default:
            break
        }
    }
    
    private func fetchNews(filter: String) {
        NetworkManager.fetchData(filter) { [weak self] (data) in
            guard let self = self else { return }
            self.newsData = data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func fetchDataFromCoreData() {
        do {
            savedData = try context.fetch(CoreDataNews.fetchRequest())
            tableView.reloadData()
        } catch {
            print("Fetching Failed!")
        }
    }
    
    private func setUpRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        fetchData()
        refreshControl.endRefreshing()
    }
    
    private func isSavedVC() -> Bool {
        if parent?.restorationIdentifier == VC.savedVC.rawValue {
            return true
        } else {
            return false
        }
    }
    
    private func checkConnection() {
        if Connectivity.isConnectedToInternet() {
            
        } else if parent?.restorationIdentifier == VC.mostEmailed.rawValue{
            self.tabBarController?.selectedIndex = 3
            let alert = UIAlertController(title: "Wrong connection..", message: "Getting saved data", preferredStyle: .alert)
            present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func setIndicator() {
        spinner.startAnimating()
        tableView.backgroundView = spinner
    }
}

//MARK: - TableView delegates -
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSavedVC() {
            spinner.stopAnimating()
            guard let savedCount = savedData?.count else { return 0 }
            return savedCount
        } else {
            guard let newsCount = newsData?.results?.count else { return 0 }
            return newsCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.tableViewCellIdentifier.rawValue, for: indexPath) as! NewsTableViewCell
        
        if let data = newsData?.results?[indexPath.row] {
            cell.configure(data)
        } else {
            if let data = savedData?[indexPath.row] {
                cell.configureFromCoreData(data)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = newsData?.results?[indexPath.row]
        let vc = storyboard?.instantiateViewController(identifier: VC.detailVC.rawValue) as! DetailViewController
        
        if isSavedVC() {
            vc.savedData = savedData?[indexPath.row]
            vc.fromCoreData = true
        } else {
            vc.detailData = data
        }
        
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if isSavedVC()  {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if isSavedVC()  {
            if editingStyle == .delete {
                guard let task = savedData?[indexPath.row] else { return }
                context.delete(task)
                savedData?.remove(at: indexPath.row)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
            tableView.reloadData()
        }
    }
}


