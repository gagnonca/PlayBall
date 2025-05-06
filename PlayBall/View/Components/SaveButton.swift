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
            Image(systemName: "checkmark.circle.fill")
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
            SaveButton(isEnabled: true) {
                print("Saved!")
            }
            
            SaveButton(isEnabled: false) {
                print("Shouldn't be tappable")
            }
        }
    }
}


#Preview("Gradient Blur") {
    ZStack {
        ColorGradient()
            .opacity(0.3)
        VStack(spacing: 32) {
            SaveButton(isEnabled: true) {
                print("Saved!")
            }
            
            SaveButton(isEnabled: false) {
                print("Shouldn't be tappable")
            }
        }
    }
}
