//
//  ViewController.swift
//  MusicSearch
//
//  Created by Павел on 9/3/20.
//  Copyright © 2020 Павел. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate , UICollectionViewDelegateFlowLayout{
    
    static let shared = ViewController()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    var albums: [StoreItem] = []
    
    
    func fetchImages(url: URL, completion: @escaping(UIImage?)-> Void){
           let task = URLSession.shared.dataTask(with: url){(data,response,erro) in
               if let data = data,
                   let image = UIImage(data: data){
                   completion(image)
               }else {
                   completion(nil)
               }
           }
           task.resume()
       }
    
    
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.albums.removeAll()
        guard let searchText = searchBar.text?.lowercased() else {return print("error")}
        searchBar.resignFirstResponder()
        self.performSearch(searchTerm: searchText) { (error) in
            if let error = error{
                print("error fetching data: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    if  self.albums.isEmpty{
                        self.infoLabel.isHidden = false
                        self.infoLabel?.text = "Nothing found"
                    } else {
                         self.infoLabel.isHidden = true
                    }
            }
        }
    }
    }
    
    
    let baseURL = URL(string: "https://itunes.apple.com/search?entity=album")!
    
    func performSearch(searchTerm: String, completion: @escaping (Error?)-> Void){
        print(searchTerm)
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        let queryItem = URLQueryItem(name: "term", value: searchTerm)
        urlComponents?.queryItems = [queryItem]
        
        guard let requestUrl = urlComponents?.url else {
            completion(NSError())
            return
        }
        
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) {(data, _, error) in
            
            if let error = error{
                print("cant fetch data \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("no returned data")
                completion(NSError())
                return
            }
            
            print(data)
            
            let jsonDecoder = JSONDecoder()
            
            do{
                
                let searchResults = try jsonDecoder.decode(StoreItems?.self, from: data)
                self.albums.append(contentsOf: searchResults!.results!)
                //self.albums.sort(by: <)
                completion(nil)
            } catch {
                print("cant to decode: \(error)")
                completion(error)
                return
            }
            print(self.albums)
        }.resume()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoLabel.isHidden = true
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show"{
            print("show")
            let detailViewController = segue.destination as? DetailViewController
            let index = collectionView.indexPathsForSelectedItems!.first!.row
            detailViewController?.album = albums[index]
            
           
        }
    }
    
   
}

extension ViewController{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SingleCellView = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SingleCellView
        
        let searchResult = albums[indexPath.row]
        
        cell.artistLabel?.text = searchResult.artistName
        
        cell.artistLabel.adjustsFontSizeToFitWidth = true
        cell.artistLabel.sizeToFit()
        cell.collectionLabel.adjustsFontSizeToFitWidth = true
        cell.collectionLabel.sizeToFit()
        
        cell.collectionLabel?.text = searchResult.collectionName
        fetchImages(url: searchResult.artworkUrl60){image in
            guard let image = image else {return}
            DispatchQueue.main.async {
                if let currentIndexPath = self.collectionView.indexPath(for: cell),
                currentIndexPath != indexPath{
                    return
                }
                cell.imageLabel?.image = image
                cell.setNeedsLayout()
            }
        }
        albums.sort(by: <)
        if albums.isEmpty{
            infoLabel.isHidden = false
            infoLabel?.text = "Nothing found"
        }
        
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
             
        performSegue(withIdentifier: "show", sender: self)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let noOfCellsInRow = 2

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return CGSize(width: size, height: size)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let searchView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchBar", for: indexPath)
        return searchView
    }
}

extension Array {
    public mutating func append(_ newElement: Element?) {
        if let element = newElement {
            self.append(element)
        }
    }
}
