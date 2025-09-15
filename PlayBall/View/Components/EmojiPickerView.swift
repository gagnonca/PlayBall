//
//  EmojiPickerView.swift
//  PlayBall
//
//  Created by Corey Gagnon on 9/14/25.
//


// EmojiPickerView.swift

import SwiftUI

struct EmojiPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: String?

    // Persist simple "recents" list as a single string (🔹-delimited)
    @AppStorage("emojiPickerRecents") private var recentStorage: String = ""
    private var recents: [String] {
        recentStorage.split(separator: "🔹").map(String.init)
    }
    private func setRecents(_ new: [String]) {
        recentStorage = new.prefix(18).joined(separator: "🔹")
    }
    
    @State private var selectedCategory: Category = .smileys

    private let columns = [GridItem(.adaptive(minimum: 44), spacing: 8)]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Live preview like iMessage
                previewHeader

                // Recents
                if !recents.isEmpty {
                    recentRow
                        .padding(.vertical, 8)
                        .background(.thinMaterial)
                }

                // Categories control
                Picker("", selection: $selectedCategory) {
                    ForEach(Category.allCases) { cat in
                        Text(cat.icon)
                            .tag(cat)
                            .accessibilityLabel(cat.title)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 10)

                // Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(selectedCategory.emojis, id: \.self) { emoji in
                            Button {
                                selection = emoji
                                pushToRecents(emoji)
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 28))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(.ultraThinMaterial)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Choose Emoji")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .disabled(selection == nil)
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button {
                            // Let users type/paste any emoji via keyboard
                            showKeyboardEntry()
                        } label: {
                            Label("Use Keyboard", systemImage: "keyboard")
                        }

                        Spacer()

                        Button {
                            // Fun: random from current category
                            if let random = selectedCategory.emojis.randomElement() {
                                selection = random
                                pushToRecents(random)
                            }
                        } label: {
                            Label("Random", systemImage: "die.face.5")
                        }
                    }
                }
            }
        }
    }

    private var previewHeader: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(
                    colors: [.blue.opacity(0.25), .purple.opacity(0.25)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(height: 120)
                .overlay(Rectangle().strokeBorder(.white.opacity(0.15)))

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.regularMaterial)
                        .frame(width: 72, height: 72)
                        .overlay(Circle().strokeBorder(.white.opacity(0.15)))
                    Text(selection ?? "🙂")
                        .font(.system(size: 36))
                }
                VStack(alignment: .leading) {
                    Text("Mascot")
                        .font(.headline)
                    Text(selection ?? "Pick an emoji")
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
        }
    }

    private var recentRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Text("Recents")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 6)

                ForEach(recents, id: \.self) { emoji in
                    Button {
                        selection = emoji
                        pushToRecents(emoji)
                    } label: {
                        Text(emoji)
                            .font(.system(size: 24))
                            .frame(width: 36, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial)
                            )
                    }
                    .buttonStyle(.plain)
                }

                if !recents.isEmpty {
                    Button(role: .destructive) {
                        clearRecents()
                    } label: {
                        Label("Clear", systemImage: "xmark.circle")
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func pushToRecents(_ emoji: String) {
        var list = recents.filter { $0 != emoji }
        list.insert(emoji, at: 0)
        setRecents(list)
    }

    private func clearRecents() {
        setRecents([])
    }

    private func showKeyboardEntry() {
        // Present a minimal input alert/sheet where user can paste/type an emoji.
        // For simplicity here, we simulate with a small sheet:
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }.first
        keyWindow?.endEditing(true) // dismiss any current
        // Tip to user: they can paste from the emoji keyboard directly into the picker by long-press.
        // (If you want, replace this with a custom sheet hosting a TextField bound to selection.)
    }
}

// MARK: - Categories & Data

private enum Category: String, CaseIterable, Identifiable {
    case smileys, people, animals, food, activities, travel, objects, symbols, flags
    var id: String { rawValue }

    var title: String {
        switch self {
        case .smileys: "Smileys"; case .people: "People"; case .animals: "Animals"
        case .food: "Food"; case .activities: "Activities"; case .travel: "Travel"
        case .objects: "Objects"; case .symbols: "Symbols"; case .flags: "Flags"
        }
    }

    var icon: String {
        switch self {
        case .smileys: "🙂"; case .people: "👥"; case .animals: "🐾"; case .food: "🍔"
        case .activities: "🎮"; case .travel: "✈️"; case .objects: "📦"; case .symbols: "🔣"
        case .flags: "🏳️"
        }
    }

    var emojis: [String] {
        switch self {
        case .smileys: return "😀😃😄😁😆😅😂🤣😊😇🙂🙃😉😍🥰😘😗😙😚😋😛😜🤪🤨🫠🤗🤭🤫🤔🤐🤥😶😮‍💨😮😯😲🥳🥺😎🤩😭😤😡🤬🤯😱😴🥱🤤🤒🤕🤧🤢🤮🤠😈👻💀🤖".map(String.init)
        case .people:  return "👶🧒👦👧🧑👨👩👱‍♀️👱‍♂️🧔👨‍🦰👩‍🦰👨‍🦱👩‍🦱👨‍🦳👩‍🦳👮‍♀️👮‍♂️🧑‍🚒🧑‍🏫🧑‍⚕️🧑‍🍳🧑‍🔬🧑‍💻🧑‍🎨🧑‍🚀🤵‍♂️👰‍♀️🧑‍🎓🧑‍🦽🧑‍🦯".map(String.init)
        case .animals:  return "🐶🐱🐭🐹🐰🦊🐻🐼🐨🐯🦁🐮🐷🐵🐸🐔🐧🐦🦆🦅🦉🦇🐺🦄🐝🪲🦋🐢🐍🐬🐳🐙".map(String.init)
        case .food:     return "🍏🍎🍐🍊🍋🍌🍉🍇🍓🫐🍒🍑🥭🍍🥥🥝🍅🥑🥕🌽🥔🍞🥐🍔🍟🍕🌭🥪🌮🌯🍣🍪🍩🎂🍦".map(String.init)
        case .activities:return "⚽️🏀🏈⚾️🎾🏐🏉🥏🏓🥅⛳️🎣🥊🥋🎽🛼⛸️🥇🥈🥉🏆🎮🎲♟️🎯🎻🎸🥁🎤🎧".map(String.init)
        case .travel:   return "🚗🚕🚙🚌🚎🏎️🚓🚑🚒🚜🛵🏍️🚲✈️🛩️🛫🛬🚀🛸⛵️🚤🚢🗽🗼🗻🏰🏟️🏝️🌋🗿".map(String.init)
        case .objects:  return "⌚️📱💻⌨️🖥️🖨️🕹️📷📸🎥📺📻🔊🎙️💡🔦🔋🔌🧯🧭⏰🧸🎁🧩✏️🖊️📚🧪⚗️🔬🧰🔧🪛".map(String.init)
        case .symbols:  return "❤️🧡💛💚💙💜🖤🤍🤎💖💘💝💤💢💥💫✨⭐️🌟🔥🌈❄️☀️☔️⚡️🌀🎵🎶♻️✅❌❗️❓🔔".map(String.init)
        case .flags:    return "🏳️🏴🏁🚩🏳️‍🌈🏳️‍⚧️🇺🇸🇨🇦🇬🇧🇫🇷🇩🇪🇮🇹🇪🇸🇧🇷🇯🇵🇨🇳🇮🇳🇲🇽🇦🇺🇳🇿🇰🇷🇸🇦🇿🇦".map(String.init)
        }
    }
}
