import SwiftUI

struct BuyMeACoffeeButton: View {
    var action: () -> Void = {}
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.brown, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.bounce, value: isHovering)
                
                Text("Buy Me a Coffee")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(VisualEffectView(material: .headerView, blendingMode: .withinWindow))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(isHovering ? 0.1 : 0.05), radius: 4, x: 0, y: 2)
            .scaleEffect(isHovering ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
        .help("Support the developer")
    }
}

// Standalone coffee icon for toolbar/menu use
struct CoffeeIcon: View {
    @State private var isHovering = false
    
    var body: some View {
        Image(systemName: "cup.and.saucer.fill")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(
                LinearGradient(
                    colors: [.brown, .orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .padding(8)
            .background(VisualEffectView(material: .headerView, blendingMode: .withinWindow))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .scaleEffect(isHovering ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}

struct BuyMeACoffeeButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Background to show glass effect
            LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom)
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                BuyMeACoffeeButton()
                
                CoffeeIcon()
            }
            .padding()
        }
        .frame(width: 300, height: 200)
    }
}