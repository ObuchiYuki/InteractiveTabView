//
//  NestedTabScreen.swift
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
    TabItem(id: 0, title: "Calories"),
    TabItem(id: 1, title: "PFC"),
    TabItem(id: 2, title: "Weight"),
]

struct NestedTabScreen: View {
    @State var selectedID: Int? = 0
    @State var interaction: InteractiveTabViewInteraction? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    ForEach(0..<5, id: \.self) { i in
                        Text("Item \(i)")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Section(content: {
                        InteractiveTabView(
                            selection: self.$selectedID,
                            tabs: tabItems,
                            content: { item in
                                LazyVStack {
                                    ForEach(0..<40, id: \.self) { i in
                                        Text("Item \(i)")
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        )
                        .onInteractionChange {
                            self.interaction = $0
                        }
                    }, header: {
                        VStack(spacing: 0) {
                            InteractiveFixedTabBar(
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
                            Divider()
                        }
                        .background(Color(.systemBackground))
                        
                    })
                }
                .animation(.easeInOut, value: self.selectedID)
                .navigationBarTitle("Nested Tab View")
                .toolbarBackground(Color(.systemBackground), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
            }
        }
    }
}

#Preview {
    NestedTabScreen()
}

