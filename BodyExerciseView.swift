import SwiftUI

struct BodyExerciseView: View {
    @Environment(\.dismiss) var dismiss
    @State private var startAnimation = false
    
    var body: some View {
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

                VStack(alignment: .leading, spacing: 10) {
                    Text("Regular Breathe Exercise")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Choose a small breathe exercise to help you for relaxing")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .opacity(startAnimation ? 1 : 0)
                .offset(y: startAnimation ? 0 : 20)
                
                Spacer().frame(height: 20)

                VStack(spacing: 16) {

                    NavigationLink(destination: BreatheDetailView()) {
                        InfoRow(
                            icon: "wind",
                            title: "Breathe Exercise",
                            subtitle: "Too feel calm"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    NavigationLink(destination: PhysicalPainStartView()) {
                        InfoRow(
                            icon: "bolt.heart",
                            title: "Release Your Physical Pain",
                            subtitle: "Focus on tension and let it go"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                }
                .padding(.horizontal)
                .opacity(startAnimation ? 1 : 0)
                .offset(y: startAnimation ? 0 : 30)
                
                Spacer()
                Image("flower1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .opacity(0.3)
                    .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                startAnimation = true
            }
        }
    }
}

