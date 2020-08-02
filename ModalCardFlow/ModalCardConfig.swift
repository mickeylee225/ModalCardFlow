//
//  ModalCardFlowConfig.swift
//  ModalCardFlow
//
//  Created by Mickey Lee on 02/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import UIKit

public struct ModalCardConfig {

    let dimViewColour: UIColor?
    let dimViewAlpha: CGFloat
    let containerRadius: CGFloat
    let containerColour: UIColor?
    let title: String?
    let titleFont: UIFont?
    let dragToDismissEnabled: Bool

    public init(
        dimViewColour: UIColor? = .darkGray,
        dimViewAlpha: CGFloat = 0.5,
        containerRadius: CGFloat = 1,
        containerColour: UIColor? = .white,
        title: String? = nil,
        titleFont: UIFont? = .boldSystemFont(ofSize: 17),
        dragToDismissEnabled: Bool = true
    ) {
        self.dimViewColour = dimViewColour
        self.dimViewAlpha = dimViewAlpha
        self.containerRadius = containerRadius
        self.containerColour = containerColour
        self.title = title
        self.titleFont = titleFont
        self.dragToDismissEnabled = dragToDismissEnabled
    }
}
