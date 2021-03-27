//
//  ChildCard.swift
//  ModalCardFlowExample
//
//  Created by Mickey Lee on 03/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import UIKit
import ModalCardFlow

final class ChildCard: ModalCard<ExampleContext> {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var textField: UITextField!
    var quantity: Int = 0

    override func applyContext() {
        slider.value = Float(context?.quantity ?? 0)
        textField.text = "\(context?.quantity ?? 0)"
    }

    @IBAction func quantitySliderChanged(_ sender: UISlider) {
        quantity = Int(sender.value)
        textField.text = "\(quantity)"
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        flow?.update(context: context?.update(quantity: quantity))
        flow?.pop()
    }
}

extension ChildCard: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange, with: string)
           quantity = Int(updatedText) ?? 0
           slider.value = Float(quantity)
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
