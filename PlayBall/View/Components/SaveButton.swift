import SwiftUI

struct SaveButton: View {
    var isEnabled: Bool
    var action: () -> Void

    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            Image(.save)
                .foregroundStyle(Color.primary)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 0.9 : 0.2)
    }
}

#Preview("Gradient") {
    ZStack {
        ColorGradient()
        VStack(spacing: 32) {
            SaveButton(isEnabled: true) {}
            SaveButton(isEnabled: false) {}
        }
    }
}


#Preview("Gradient Blur") {
    ZStack {
        ColorGradient()
            .opacity(0.3)
        VStack(spacing: 32) {
            SaveButton(isEnabled: true) {}
            SaveButton(isEnabled: false) {}
        }
    }
}
