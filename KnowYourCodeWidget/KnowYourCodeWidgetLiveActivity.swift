//
//  KnowYourCodeWidgetLiveActivity.swift
//  KnowYourCodeWidget
//
//  Created by アウン on 2026/01/13.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct KnowYourCodeWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct KnowYourCodeWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: KnowYourCodeWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension KnowYourCodeWidgetAttributes {
    fileprivate static var preview: KnowYourCodeWidgetAttributes {
        KnowYourCodeWidgetAttributes(name: "World")
    }
}

extension KnowYourCodeWidgetAttributes.ContentState {
    fileprivate static var smiley: KnowYourCodeWidgetAttributes.ContentState {
        KnowYourCodeWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: KnowYourCodeWidgetAttributes.ContentState {
         KnowYourCodeWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: KnowYourCodeWidgetAttributes.preview) {
   KnowYourCodeWidgetLiveActivity()
} contentStates: {
    KnowYourCodeWidgetAttributes.ContentState.smiley
    KnowYourCodeWidgetAttributes.ContentState.starEyes
}
