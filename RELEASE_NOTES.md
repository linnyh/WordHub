# Release Notes - v1.1.0

## 🚀 New Features (新功能)

*   **Favorites Search (收藏页搜索)**:
    *   Added a real-time search bar to the Favorites page.
    *   Supports case-insensitive prefix matching (Trie-like behavior) to quickly find saved word pairs.
    *   Dynamic updates for part-of-speech statistics based on search results.
*   **Persistent API Key Settings (API Key 持久化配置)**:
    *   Replaced the default hardcoded API Key with a secure local configuration file (`config.json`).
    *   Added a manual **"Save"** button in the Settings page for better control over API Key updates.
    *   API Key is now persisted locally and survives app restarts.

## 🎨 UI/UX Improvements (界面与体验优化)

*   **Responsive Layout (响应式布局)**:
    *   **BigCard**: Updated to occupy **80% of the screen width**, ensuring better readability for longer word definitions on various screen sizes.
    *   **Home Page**: Removed the fixed width constraint (800px), allowing the content to fully utilize the available window width.
    *   **Loading Indicator**: Improved the loading bar style to stretch across the full width of its container.
*   **Documentation**:
    *   Revamped `README.md` with a professional layout.
    *   Added high-quality screenshots for Home, Favorites, Details, and Settings pages.
    *   Included Tech Stack badges (Flutter, Dart, Provider, Moonshot AI, Trae IDE).

## 🛠 Technical Details (技术细节)

*   **Local Storage**: Implemented `config.json` handling in `MyAppState` for storing user settings separately from favorites.
*   **Build**: Successfully configured and built macOS Release version (`.dmg` installer included).
*   **Development**: Full project development and refactoring powered by **Trae IDE** and **Vibe Coding**.

## 📦 Installation (安装)

Download the `.dmg` file from the assets, open it, and drag **WordHub** to your Applications folder.
