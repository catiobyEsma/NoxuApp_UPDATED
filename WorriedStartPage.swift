import SwiftUI

struct WorriedStartPage: View {
    @Environment(\.dismiss) var dismiss
    @State private var startAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0D081A").ignoresSafeArea()
                StaticBackgroundStarsView()
                
                VStack(spacing: 25) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title2.bold())
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Release Your Mind")
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        
                        Text("When worries cloud your thoughts...")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .opacity(startAnimation ? 1 : 0)
                    .offset(y: startAnimation ? 0 : 20)
                    Image("pufi_worried")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .padding(.vertical, 20)
                        .scaleEffect(startAnimation ? 1 : 0.8)
                        .opacity(startAnimation ? 1 : 0)
                    VStack(spacing: 16) {
                        NavigationLink(destination: GainPerspectiveView()) {
                            InfoRow(icon: "eye", title: "Gain Perspective", subtitle: "See your worries from a distance")
                        }
                    }
                    .padding(.horizontal)
                    .opacity(startAnimation ? 1 : 0)
                    .offset(y: startAnimation ? 0 : 30)
                    
                    Spacer()
                    NavigationLink(destination: WorriedPage()) {
                        HStack {
                            Text("Write Your Thoughts as Stars")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#4232a8"), Color(hex: "#8793f5")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color(hex: "#4232a8").opacity(0.5), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                    .opacity(startAnimation ? 1 : 0)
                    .offset(y: startAnimation ? 0 : 40)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    startAnimation = true
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("GoToRoot"))) { _ in
            dismiss()
        }
    }
  
    
}

struct InfoRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 45, height: 45)
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "#8793f5"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.04)))
    }
}
struct WorriedStartPage_Previews: PreviewProvider {
    static var previews: some View {
        WorriedStartPage()
            .ignoresSafeArea()
    }
}
