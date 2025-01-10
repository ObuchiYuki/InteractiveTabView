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
    TabItem(id: 0, title: "History"),
    TabItem(id: 1, title: "Favorite"),
]

struct NestedTabScreen: View {
    @State var selectedID: Int? = 0
    @State var interaction: InteractiveTabViewInteraction? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Color.primary
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    Color.primary.opacity(0.05)
                        .frame(height: 38)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
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
            }
        }
    }
}

#Preview {
    NestedTabScreen()
}

