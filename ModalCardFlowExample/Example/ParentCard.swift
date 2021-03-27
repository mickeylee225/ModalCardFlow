//
//  ParentCard.swift
//  ModalCardFlowExample
//
//  Created by Mickey Lee on 03/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import UIKit
import ModalCardFlow

final class ParentCard: ModalCard<ExampleContext> {

    @IBOutlet weak var quantityLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func applyContext() {
        quantityLabel.text = context?.quantity == nil ? "Please choose quantity" : "\(context!.quantity!)"
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        let child = ChildCard()
        flow?.push(card: child)
    }
}
