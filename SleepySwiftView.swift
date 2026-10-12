import SwiftUI

struct SleepySwiftView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userCredits") private var userCredits = 100 // Bakiye tutarlılığı için eklendi
    @State private var startAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0D081A").ignoresSafeArea()
                StaticBackgroundStarsView()
                
                VStack(spacing: 0) {
                    headerArea
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 25) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Feeling Tired & Sleepy?")
                                    .font(.system(size: 32, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                                   
                                
                                Text("We all do actually...")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineSpacing(4)
                                 
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .opacity(startAnimation ? 1 : 0)
                            .offset(y: startAnimation ? 0 : 20)
                        
                            Image("pufi_bed")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 180)
                                .padding(.vertical, 20)
                                .scaleEffect(startAnimation ? 1 : 0.8)
                                .opacity(startAnimation ? 1 : 0)
                            VStack(spacing: 16) {
                                NavigationLink(destination: SleepAssistantView()) {
                                    InfoRow(icon: "moon", title: "Sleep Assistant", subtitle: "Your assistant is  here to help you sleep")
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                NavigationLink(destination: NatureSoundsView()) {
                                    InfoRow(icon: "speaker.wave.2", title: "Nature Sounds", subtitle: "Sounds to help you sleep")
                                }
                                .buttonStyle(PlainButtonStyle())

                                NavigationLink(destination: CompletedListView()) {
                                    InfoRow(icon: "checkmark.circle", title: "Your Completed List", subtitle: "See your completed list & call it a day!")
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal)
                            .opacity(startAnimation ? 1 : 0)
                            .offset(y: startAnimation ? 0 : 30)
                        }
                        .padding(.bottom, 30)
                    }
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
    var headerArea: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.6))
            
            }
            
            Spacer()
            HStack(spacing: 5) {
                Text("\(userCredits)").fontWeight(.bold)
                Image("100").resizable().scaledToFit().frame(width: 20, height: 20)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.1)))
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

struct SleepySwiftView_Previews: PreviewProvider {
    static var previews: some View {
        SleepySwiftView()
    }
}
