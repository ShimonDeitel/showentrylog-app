import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @EnvironmentObject var store: ShowEntryStore
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                ShowEntryTheme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 48))
                        .foregroundColor(ShowEntryTheme.accent)
                    Text("Unlock Car Show Entry Log Pro")
                        .font(ShowEntryTheme.titleFont)
                        .foregroundColor(ShowEntryTheme.textPrimary)
                    Text("Multi-show history with award photos and placement tracking")
                        .font(ShowEntryTheme.bodyFont)
                        .foregroundColor(ShowEntryTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button {
                        Task { await purchase() }
                    } label: {
                        Text(isPurchasing ? "Processing..." : "Subscribe $1.99/month")
                            .font(ShowEntryTheme.bodyFont.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ShowEntryTheme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .disabled(isPurchasing)
                    .accessibilityIdentifier("subscribeButton")
                    .padding(.horizontal)
                    if let errorMessage {
                        Text(errorMessage).foregroundColor(.red).font(.caption)
                    }
                    Button("Not now") { dismiss() }
                        .foregroundColor(ShowEntryTheme.textSecondary)
                        .accessibilityIdentifier("dismissPaywallButton")
                }
                .padding()
            }
        }
    }

    private func purchase() async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await purchases.purchasePro()
            if purchases.isPro {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(PurchaseManager())
        .environmentObject(ShowEntryStore())
}
