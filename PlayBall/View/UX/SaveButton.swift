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
            Image(systemName: "checkmark")
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
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
    .background(Color.black.ignoresSafeArea())
}
