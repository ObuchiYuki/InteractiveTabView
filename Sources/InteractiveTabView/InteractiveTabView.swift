//
//  InteractiveTabView.swift
//  TabLayoutSample
//
//  Created by yuki on 2025/01/09.
//

import SwiftUI

public struct InteractiveTabViewInteraction {
    public let currentIndex: Int
    public let nextIndex: Int
    public let fraction: CGFloat // -0.5 ... 0.5
    
    public init() {
        self.currentIndex = 0
        self.nextIndex = 0
        self.fraction = 0
    }
    
    public init(
        currentIndex: Int,
        nextIndex: Int,
        fraction: CGFloat
    ) {
        self.currentIndex = currentIndex
        self.nextIndex = nextIndex
        self.fraction = fraction
    }
}

fileprivate struct PageGeometoryData<ID: Hashable & Sendable>: Equatable, Sendable {
    let tabId: ID
    let offset: CGFloat
    let width: CGFloat
}

fileprivate struct PageGeometoryDataPreferenceKey<ID: Hashable & Sendable>: PreferenceKey {
    static var defaultValue: [PageGeometoryData<ID>] { [] }
    
    static func reduce(value: inout [PageGeometoryData<ID>], nextValue: () -> [PageGeometoryData<ID>]) {
        value.append(contentsOf: nextValue())
    }
}

private let interactiveTabScrollAreaName = "__interactiveTabScrollArea"

public struct InteractiveTabView<TabItem: Identifiable, Content: View>: View where TabItem.ID: Sendable {
    @Binding var selection: TabItem.ID?
    
    var handleInteraction: ((InteractiveTabViewInteraction?) -> Void)?
    
    let tabs: [TabItem]
    
    let content: (TabItem) -> Content
    
    public init(
        selection: Binding<TabItem.ID?>,
        tabs: [TabItem],
        @ViewBuilder content: @escaping (TabItem) -> Content
    ) {
        self._selection = selection
        self.tabs = tabs
        self.content = content
    }
    
    public func onInteractionChange(_ action: @escaping (InteractiveTabViewInteraction?) -> Void) -> Self {
        var copy = self
        copy.handleInteraction = action
        return copy
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(self.tabs) { tabItem in
                    self.content(tabItem)
                        .containerRelativeFrame(.horizontal)
                        .overlay(
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(key: PageGeometoryDataPreferenceKey<TabItem.ID>.self, value: [
                                        PageGeometoryData<TabItem.ID>(
                                            tabId: tabItem.id,
                                            offset: proxy.frame(in: .named(interactiveTabScrollAreaName)).minX,
                                            width: proxy.size.width
                                        )
                                    ])
                            }
                        )
                }
                .containerRelativeFrame(.horizontal)
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: self.$selection)
        .coordinateSpace(name: interactiveTabScrollAreaName)
        .onPreferenceChange(PageGeometoryDataPreferenceKey<TabItem.ID>.self) { geometoryData in
            MainActor.assumeIsolated {
                let interaction = self.computeInteraction(geometoryData: geometoryData)
                self.handleInteraction?(interaction)
            }
        }
    }
    
    private func computeInteraction(
        geometoryData: [PageGeometoryData<TabItem.ID>]
    ) -> InteractiveTabViewInteraction? {
        let tabIdToIndex: [TabItem.ID: Int] = Dictionary(
            uniqueKeysWithValues: self.tabs.enumerated().map { ($1.id, $0) }
        )
        
        guard let tabWidth = geometoryData.first?.width else {
            return nil
        }
        
        guard let currentIndex = self.selection.flatMap ({ tabIdToIndex[$0] }) else {
            return nil
        }
        
        guard let currentOffset = geometoryData.first(where: { tabIdToIndex[$0.tabId] == currentIndex })?.offset else {
            return nil
        }
        
        if currentOffset < 0 {
            let fraction = currentOffset / tabWidth
            return InteractiveTabViewInteraction(
                currentIndex: currentIndex,
                nextIndex: currentIndex + 1,
                fraction: -fraction
            )
        } else {
            let fraction = currentOffset / tabWidth
            return InteractiveTabViewInteraction(
                currentIndex: currentIndex,
                nextIndex: currentIndex - 1,
                fraction: fraction
            )
        }
    }
}

fileprivate struct Tab: Identifiable {
    let id: Int
    let title: String
    let color: Color
}

#Preview {
    @Previewable @State var selectedID: Int? = 0
    @Previewable @State var interaction: InteractiveTabViewInteraction?
    
    let tabs = [
        Tab(id: 0, title: "Tab 1", color: .red),
        Tab(id: 1, title: "Tab 2", color: .green),
        Tab(id: 2, title: "Tab 3", color: .blue),
        Tab(id: 3, title: "Tab 4", color: .yellow),
        Tab(id: 4, title: "Tab 5", color: .orange),
        Tab(id: 5, title: "Tab 6", color: .purple),
    ]
    
    VStack {
        if let interaction = interaction {
            Text("currentIndex: \(interaction.currentIndex)")
            Text("nextIndex: \(interaction.nextIndex)")
            Text("fraction: \(interaction.fraction)")
        }
        
        InteractiveTabView(
            selection: $selectedID,
            tabs: tabs
        ) { item in
                ZStack {
                    item.color
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack {
                            ForEach(0..<40, id: \.self) { i in
                                Text("Item \(i)")
                                    .padding()
                            }
                        }
                    }
                }
            }
            .onInteractionChange{
                interaction = $0
            }
    }
}
