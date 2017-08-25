//
//  Dashboard.swift
//  Locus
//
//  Created by Mehul Solanki on 25/08/17.
//  Copyright © 2017 Mehul Solanki. All rights reserved.
//

import UIKit
import MWPhotoBrowser

class Dashboard: SuperViewController, MWPhotoBrowserDelegate {

    @IBOutlet weak var collectionViewPeople: UICollectionView!
    var refreshControl: UIRefreshControl!
    
    let arrayPeople = ["Model1.png", "Model2.png", "Model3.png", "Model4.png", "Model5.png",
                       "Model1.png", "Model2.png", "Model3.png", "Model4.png", "Model5.png"]
    let arrayName = ["Kim Kardashian", "Reese Witherspoon", "Nicolas Cage", "Gwyneth Paltrow", "Steven Spielberg", "Blake Lively", "Jennifer Aniston", "Ashton Kutcher", "Ashlee Simpson", "David Beckham"]
    let arrayWork = ["American television personality",
                     "American actress",
                     "Actor at Con Air",
                     "Singer for events",
                     "Director for Jaws",
                     "Actress at Black Shallow",
                     "Lead at Friends",
                     "Two and a half man",
                     "American singer-songwriter",
                     "English footballer"]
    
    let arrayMWPhoto = [MWPhoto(image: UIImage(named: "Model1.png")),
                        MWPhoto(image: UIImage(named: "Model2.png")),
                        MWPhoto(image: UIImage(named: "Model3.png")),
                        MWPhoto(image: UIImage(named: "Model4.png")),
                        MWPhoto(image: UIImage(named: "Model5.png"))]
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Navigation Title
        self.title = "Locus"
        
        //Add Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(refreshListing), for: .valueChanged)
        collectionViewPeople.addSubview(refreshControl)
        collectionViewPeople.alwaysBounceVertical = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Hide Navigation Bar
        self.navigationController?.isNavigationBarHidden = false
        
        //No Need of Default Back Button
        self.navigationItem.hidesBackButton = true
            }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Status Bar Visibility
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    //MARK: - Refresh Listing
    func refreshListing() -> Void {
        refreshControl.endRefreshing()
    }
    
    
    //MARK: - Like Clicked
    func btnLikeClicked(_ sender: UIButton) -> Void {
        print("Tag : \(sender.tag)")
        
        sender.isSelected = !sender.isSelected
    }
    
    
    //MARK: - MWPhotoBrowser Delegates
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(arrayMWPhoto.count)
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        if (index < UInt(arrayMWPhoto.count)) {
            let photo = arrayMWPhoto[Int(index)]
            return photo
        }
        return nil
    }
}


//MARK: - UICollectionView Methods
extension Dashboard: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 175.0)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayPeople.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "CellPeople"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CellPeople
        
        //Set Data
        cell.imageViewPeople.image = UIImage(named: arrayPeople[indexPath.row])
        cell.lblName.text = arrayName[indexPath.row]
        cell.lblWork.text = arrayWork[indexPath.row]
        
        //Set Target
        cell.btnLike.tag = indexPath.row
        cell.btnLike.addTarget(self, action: #selector(self.btnLikeClicked(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoViewer = MWPhotoBrowser(delegate: self)
        
        photoViewer?.displayActionButton = false
        photoViewer?.displayNavArrows = false
        photoViewer?.setCurrentPhotoIndex(UInt(0))
        
        self.navigationController?.pushViewController(photoViewer!, animated: true)
        
        photoViewer?.showNextPhoto(animated: true)
        photoViewer?.showPreviousPhoto(animated: true)
    }
}
