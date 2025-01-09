//
//  TopBarScreen.swift
//  InteractiveTabView
//
//  Created by yuki on 2025/01/09.
//

import SwiftUI

fileprivate struct TabItem: Identifiable {
    let id: Int
    let title: String
}

fileprivate let tabItems = [
    TabItem(id: 0, title: "Recommend"),
    TabItem(id: 1, title: "Following"),
    TabItem(id: 2, title: "Popular"),
    TabItem(id: 3, title: "New"),
    TabItem(id: 4, title: "Trend"),
]

struct TopBarScreen: View {
    @State var selectedID: Int? = 0
    @State var interaction: InteractiveTabViewInteraction? = nil
    
    var body: some View {
        VStack {
            InteractiveTabBar(
                selection: self.$selectedID,
                interaction: self.interaction,
                tabs: tabItems,
                content: { item in
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(
                            item.id == self.selectedID ? Color.primary : Color.primary.opacity(0.25)
                        )
                        .padding(.vertical)
                }
            )
            
            InteractiveTabView(
                selection: self.$selectedID,
                tabs: tabItems,
                content: { item in
                    ScrollView {
                        VStack {
                            ForEach(0..<40, id: \.self) { i in
                                Text("Item \(i)")
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            )
            .onInteractionChange {
                self.interaction = $0
            }
        }
        .animation(.easeInOut, value: self.selectedID)
    }
}

#Preview {
    TopBarScreen()
}
