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
        .opacity(isEnabled ? 1 : 0.2)
    }
}

#Preview {
    VStack(spacing: 32) {
        SaveButton(isEnabled: true) {
            print("Saved!")
        }

        SaveButton(isEnabled: false) {
            print("Shouldn't be tappable")
        }
    }
    .padding()
}
