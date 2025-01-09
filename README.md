# InteractiveTabView

<img src="https://github.com/user-attachments/assets/9cc62277-5387-4ea5-be81-b7ae430c8fbc" width="300px">


**InteractiveTabView** is a SwiftUI component for iOS 17 and above that synchronizes a tab-bar indicator with each tab’s scrolling content.
It provides two components, `InteractiveTabView` and `InteractiveTabBar`, allowing you to implement interactive tab navigation with simple SwiftUI APIs.

### Features

- **Scroll-Synced Indicator**: The tab-bar indicator animates in response to each tab’s scroll position.  
- **Flexible Customization**: Easily modify indicator style, tab appearance, and more.  
- **Easy to Use**: Built as a SwiftUI `View`, making integration straightforward.

### Installation

Install via [Swift Package Manager](https://github.com/apple/swift-package-manager). 
In Xcode, choose **File > Add Packages**, then enter:  

```
https://github.com/ObuchiYuki/InteractiveTabView
```

### Usage

Below is an example showing how to provide an array of tab items and display corresponding content. The `InteractiveTabBar` animates the indicator in sync with scroll events.

```swift
struct TabItem: Identifiable {
    let id: Int
    let title: String
}

let tabItems = [
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

---

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.
