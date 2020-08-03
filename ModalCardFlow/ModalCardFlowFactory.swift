//
//  ModalCardFlowFactory.swift
//  ModalCardFlow
//
//  Created by Mickey Lee on 03/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import Foundation

/// class DefaultContext: For the usage of nil context in the flow
public class DefaultContext: Context { }

public struct ModalCardFlowFactory {

    public static func makeFlow(with config: ModalCardConfig) -> ModalCardFlow<DefaultContext> {
        return ModalCardFlow(context: DefaultContext(), with: config)
    }

    public static func makeFlow<C: Context>(context: C, with config: ModalCardConfig) -> ModalCardFlow<C> {
        return ModalCardFlow(context: context, with: config)
    }
}
