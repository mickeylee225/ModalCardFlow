//
//  ModalCard.swift
//  ModalCardFlow
//
//  Created by Mickey Lee on 02/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import UIKit

open class ModalCard<C: Context>: UIViewController {

    open var flow: ModalCardFlow<C>?
    open var context: C?

    open func applyContext() { }
}
