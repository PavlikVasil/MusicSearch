//
//  DetailViewController.swift
//  MusicSearch
//
//  Created by Павел on 9/7/20.
//  Copyright © 2020 Павел. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        updateUI()
    }
    
    var album: StoreItem?
    
    var tracks: [Tracks] = []
    
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var detailCollection: UILabel!
    @IBOutlet weak var detailArtist: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
   
    @IBOutlet weak var tableView: UITableView!
    
    func updateUI(){
        guard let album = album else {return}
        
        detailCollection.text = album.collectionName
        detailArtist.text = album.artistName
        genreLabel.text = album.primaryGenreName
        priceLabel.text = String(format:"Price: $%.2f", album.collectionPrice)
        
        ViewController.shared.fetchImages(url: album.artworkUrl100){image in
            guard let image = image else {return}
            DispatchQueue.main.async {
                self.detailImage?.image = image
            }
        }
        
        self.performSearch(searchTerm: album.collectionId){ (error) in
        if let error = error{
            print("error fetching data: \(error)")
        } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
        }
            }
        }
        
    
    }
    
    let baseURL = URL(string:"https://itunes.apple.com/lookup?country=US&entity=song")!
    
    func performSearch(searchTerm: Int, completion: @escaping (Error?)-> Void){
       var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        let queryItem = URLQueryItem(name: "id", value: String(searchTerm))
        let entityItem = URLQueryItem(name: "entity", value: "song")
       urlComponents?.queryItems = [queryItem, entityItem]
       
       guard let requestUrl = urlComponents?.url else {
           completion(NSError())
           return
       }
 
        var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) {(data, _, error) in
                print(request)
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
                    var searchResults = try jsonDecoder.decode(Album?.self, from: data)
                    print(searchResults as Any)
                    searchResults?.results?.remove(at: 0)
                    self.tracks.append(contentsOf: searchResults!.results!)
                    
                    
                    completion(nil)
                } catch {
                    print("cant to decode: \(error)")
                    completion(error)
                    return
                }
                print(self.tracks)
            }.resume()
        }

}

extension DetailViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let searchResult = tracks[indexPath.row]
        
        cell.trackNumber?.text = String(describing: searchResult.trackNumber!)
        cell.trackName?.text = searchResult.trackName!
        
        return cell
    }
    
    
}
