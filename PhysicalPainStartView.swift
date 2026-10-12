import SwiftUI

struct PhysicalPainStartView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedGender: Gender? = nil
    @State private var showWarning = true
    @State private var isDetailPresented = false
    
    enum Gender {
        case male, female
        var imageName: String {
            switch self {
            case .male: return "figure.male"
            case .female: return "figure.female"
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#0D081A").ignoresSafeArea()
            StaticBackgroundStarsView()
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                if !showWarning {
                    VStack(spacing: 30) {
                        Text("Select Your Gender")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 25) {
                            GenderSelectionButton(gender: .female, selectedGender: $selectedGender)
                            GenderSelectionButton(gender: .male, selectedGender: $selectedGender)
                        }
                        if let _ = selectedGender {
                            Button(action: {
                                isDetailPresented = true
                            }) {
                                HStack {
                                    Text("Continue")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 220, height: 60)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "#4232a8"), Color(hex: "#8793f5")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
                                .shadow(color: Color(hex: "#4232a8").opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                            .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                        }
                    }
                    .padding(.bottom, 60)
                }
                Spacer()
            }
            .blur(radius: showWarning ? 15 : 0)
            .animation(.easeInOut, value: showWarning)
            
            if showWarning {
                warningOverlayView
            }
        }
        .navigationDestination(isPresented: $isDetailPresented) {
            if let gender = selectedGender {
                PhysicalPainDetailView(gender: gender, isRootActive: $isDetailPresented)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    private var warningOverlayView: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 25) {
                Image(systemName: "shield.text.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: "#FF7AF3"))
                
                Text("Important Health Notice")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("This exercise is designed to help you release physical discomfort in a psychological way. It is NOT a remedy or cure for injuries. It only aids in reducing psychological pain perception.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                Text("Please consult a doctor for serious medical concerns.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.yellow.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showWarning = false
                    }
                }) {
                    Text("I Understand & Accept")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color(hex: "#4232a8"))
                        .cornerRadius(15)
                }
            }
            .padding(30)
            .background(RoundedRectangle(cornerRadius: 30).fill(Color(hex: "#1A142D")))
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.1), lineWidth: 1))
            .padding(.horizontal, 30)
        }
        .transition(.opacity.combined(with: .scale(scale: 1.1)))
    }
}
struct GenderSelectionButton: View {
    let gender: PhysicalPainStartView.Gender
    @Binding var selectedGender: PhysicalPainStartView.Gender?
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) { selectedGender = gender }
        }) {
            VStack(spacing: 12) {
                Image(systemName: gender == .female ? "figure.female" : "figure.male")
                    .font(.system(size: 40))
                    .foregroundColor(selectedGender == gender ? .white : .white.opacity(0.3))
                
                Text(gender == .female ? "Female" : "Male")
                    .font(.headline)
                    .foregroundColor(selectedGender == gender ? .white : .white.opacity(0.5))
            }
            .frame(width: 130, height: 130)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(selectedGender == gender ? Color(hex: "#4232a8").opacity(0.6) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(selectedGender == gender ? Color(hex: "#FF7AF3") : Color.clear, lineWidth: 2)
            )
        }
    }
}
struct PhysicalPainStartView_Previews: PreviewProvider {
    static var previews: some View {
        PhysicalPainStartView()
            .ignoresSafeArea()
    }
}
