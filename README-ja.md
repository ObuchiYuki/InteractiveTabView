# InteractiveTabView

### 概要
**InteractiveTabView** は、iOS 17 以上で動作する SwiftUI コンポーネントです。スクロール操作に合わせて、タブバーのインジケータがインタラクティブに移動します。
`InteractiveTabView` と `InteractiveTabBar` の 2 つを提供しており、シンプルな API でタブとコンテンツの連動を実現できます。

### 特徴
- **スクロール連動**: 各タブのスクロール位置に応じて、タブバーのインジケータがアニメーションします。  
- **カスタマイズ自在**: インジケータやタブの見た目などを柔軟に変更できます。  
- **シンプルな使用方法**: SwiftUI の `View` に準拠した API で、直感的に扱えます。

### インストール
[Swift Package Manager](https://github.com/apple/swift-package-manager) を利用してインストールできます。
Xcode の **File > Add Packages** から、以下のリポジトリを指定してください。  
```
https://github.com/ObuchiYuki/InteractiveTabView
```

### 使い方

以下の例では、タブアイテムの配列を渡して、それぞれに対応するコンテンツを表示しています。タブバーは `InteractiveTabBar` で構築し、スクロールに合わせてインジケータが動きます。

```swift
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
        InteractiveTabView(
            selection: self.$selectedID,
            tabs: tabItems
        ) { item in
            ScrollView {
                ForEach(0..<40, id: \.self) { i in
                    Text("Item \(i)")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .onInteractionChange {
            self.interaction = $0
        }
        .safeAreaInset(edge: .top) {
            VStack(spacing: 0) {
                InteractiveTabBar(
                    selection: self.$selectedID,
                    interaction: self.interaction,
                    tabs: tabItems
                ) { item in
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(
                            item.id == self.selectedID ? Color.primary : Color.primary.opacity(0.25)
                        )
                        .padding(.vertical)
                }
                .background(.ultraThinMaterial)
                
                Divider()
            }
        }
    }
}

#Preview {
    TopBarScreen()
}
```

