//
//  Introduction.swift
//  Locus
//
//  Created by Mehul Solanki on 08/08/17.
//  Copyright © 2017 Mehul Solanki. All rights reserved.
//

import UIKit

class Introduction: SuperViewController {

    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.title = "Introduction"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Hide Navigation Bar
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
