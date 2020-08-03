//
//  LandingViewController.swift
//  ModalCardFlowExample
//
//  Created by Mickey Lee on 03/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import UIKit
import ModalCardFlow

class LandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func startButtonClicked(_ sender: Any) {
        let context = ExampleContext()
        let config = ModalCardConfig(containerRadius: 10)
        let flow = ModalCardFlowFactory.makeFlow(context: context, with: config)
        let parentCard = ParentCard()
        flow.start(with: parentCard, andPresentOn: navigationController)
    }
}
