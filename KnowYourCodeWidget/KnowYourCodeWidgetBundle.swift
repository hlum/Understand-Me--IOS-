//
//  KnowYourCodeWidgetBundle.swift
//  KnowYourCodeWidget
//
//  Created by アウン on 2026/01/13.
//

import WidgetKit
import SwiftUI

@main
struct KnowYourCodeWidgetBundle: WidgetBundle {
    var body: some Widget {
        KnowYourCodeWidget()
        KnowYourCodeWidgetControl()
        KnowYourCodeWidgetLiveActivity()
    }
}
