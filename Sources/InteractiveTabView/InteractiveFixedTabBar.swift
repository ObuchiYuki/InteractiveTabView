//
//  TabButtonFrameKey.swift
//  InteractiveTabView
//
//  Created by yuki on 2025/01/09.
//


import SwiftUI

fileprivate struct TabButtonFrameKey<ID: Hashable>: PreferenceKey {
    static var defaultValue: [ID: Anchor<CGRect>] { [:] }

    static func reduce(value: inout [ID: Anchor<CGRect>], nextValue: () -> [ID: Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}

public struct InteractiveFixedTabBar<TabItem: Identifiable, Content: View>: View {
    @Binding var selection: TabItem.ID?
    
    let spacing: CGFloat

    let tabs: [TabItem]

    let content: (TabItem) -> Content

    let interaction: InteractiveTabViewInteraction?

    public init(
        selection: Binding<TabItem.ID?>,
        interaction: InteractiveTabViewInteraction?,
        spacing: CGFloat = 8,
        tabs: [TabItem],
        @ViewBuilder content: @escaping (TabItem) -> Content
    ) {
        self._selection = selection
        self.spacing = spacing
        self.interaction = interaction
        self.tabs = tabs
        self.content = content
    }

    public var body: some View {
        HStack(spacing: self.spacing) {
            ForEach(self.tabs) { tab in
                Button(action: { self.selection = tab.id }) {
                    self.content(tab)
                        .padding(.horizontal, 8)
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.anchorPreference(key: TabButtonFrameKey<TabItem.ID>.self, value: .bounds) {
                            [tab.id: $0]
                        }
                    }
                )
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity)
            }
        }
        .overlayPreferenceValue(TabButtonFrameKey.self) { value in
            GeometryReader { proxy in
                if let (indicatorX, indicatorWidth) = self.indicatorPositionAndWidth(in: proxy, anchors: value) {
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: indicatorWidth, height: 3)
                        .position(x: indicatorX, y: proxy.size.height - 1.5)
                }
            }
        }
    }

    private func indicatorPositionAndWidth(
        in proxy: GeometryProxy,
        anchors: [TabItem.ID : Anchor<CGRect>]
    ) -> (CGFloat, CGFloat)? {
        
        guard let interaction = self.interaction else {
            return nil
        }
        
        let safeCurrent = max(0, min(self.tabs.count - 1, interaction.currentIndex))
        let safeNext   = max(0, min(self.tabs.count - 1, interaction.nextIndex))

        guard let currentTabRect = anchors[self.tabs[safeCurrent].id].map({ proxy[$0] }),
              let nextTabRect = anchors[self.tabs[safeNext].id].map({ proxy[$0] })
        else { return nil }

        let interpolatedMidX = self.lerp(a: currentTabRect.midX, b: nextTabRect.midX, t: interaction.fraction)
        let interpolatedWidth = self.lerp(a: currentTabRect.width, b: nextTabRect.width, t: interaction.fraction)

        return (interpolatedMidX, interpolatedWidth)
    }

    private func lerp(a: CGFloat, b: CGFloat, t: CGFloat) -> CGFloat {
        a + (b - a) * t
    }
}


fileprivate struct Tab: Identifiable {
    let id: Int
    let title: String
}

#Preview {
    @Previewable @State var selectedID: Int? = 0
    
    let tabs = [
        Tab(id: 0, title: "Tab 1"),
        Tab(id: 1, title: "Tab 2"),
        Tab(id: 2, title: "Tab 3"),
    ]
    
    
    InteractiveFixedTabBar(
        selection: $selectedID,
        interaction: .init(
            currentIndex: 0,
            nextIndex: 1,
            fraction: 0
        ),
        tabs: tabs,
        content: { item in
            Text(item.title)
                .font(.headline)
                .padding(.vertical)
        }
    )
}
