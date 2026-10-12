import SwiftUI
import UserNotifications

struct PufiSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("pufiName") var pufiName: String = ""
    @AppStorage("selectedTrait") var selectedTrait: String = ""
    @AppStorage("selectedAsset") var selectedAsset: String = ""
    @AppStorage("pufiMantra") var pufiMantra: String = ""
    @AppStorage("hasCustomPufi") var hasCustomPufi: Bool = false
    @AppStorage("pufiName2") var pufiName2: String = ""
    @AppStorage("selectedTrait2") var selectedTrait2: String = ""
    @AppStorage("selectedAsset2") var selectedAsset2: String = ""
    @AppStorage("pufiMantra2") var pufiMantra2: String = ""
    @AppStorage("hasCustomPufi2") var hasCustomPufi2: Bool = false
    @AppStorage("userName") var userName: String = ""
    
    @State private var showInfo = false
    let traits = ["Calm", "Energic", "Sleepy", "Curious"]
    
    var body: some View {
        ZStack {
            Color(hex: "#061836").ignoresSafeArea()
            StarFieldView1(starCount: 100)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    
                    Text("Pufi Settings 💫")
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .padding(.top, 60)
                    if hasCustomPufi {
                        VStack(spacing: 20) {
                            pufiHeader(name: pufiName, asset: selectedAsset)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                settingSection(title: "1st PUFI NAME") {
                                    TextField("Name your pufi", text: $pufiName)
                                        .textFieldStyle(PufiTextFieldStyle())
                                }
                                
                                traitPicker(selection: $selectedTrait)
                                
                                settingSection(title: "1st PUFI MANTRA") {
                                    TextField("Mantra...", text: $pufiMantra)
                                        .textFieldStyle(PufiTextFieldStyle())
                                }
                                
                                appIconButtonStyle(for: selectedAsset, name: pufiName)
                            }
                        }
                        .padding().background(Color.white.opacity(0.03)).cornerRadius(25)
                    }
                    if hasCustomPufi2 {
                        VStack(spacing: 20) {
                            pufiHeader(name: pufiName2, asset: selectedAsset2)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                settingSection(title: "2nd PUFI NAME") {
                                    TextField("Name your second pufi", text: $pufiName2)
                                        .textFieldStyle(PufiTextFieldStyle())
                                }
                                
                                traitPicker(selection: $selectedTrait2)
                                
                                settingSection(title: "2nd PUFI MANTRA") {
                                    TextField("Mantra...", text: $pufiMantra2)
                                        .textFieldStyle(PufiTextFieldStyle())
                                }
                                
                                appIconButtonStyle(for: selectedAsset2, name: pufiName2)
                            }
                        }
                        .padding().background(Color.white.opacity(0.03)).cornerRadius(25)
                    }
                    settingSection(title: "HOW SHOULD THEY CALL YOU?") {
                        TextField("Your name...", text: $userName)
                            .textFieldStyle(PufiTextFieldStyle())
                    }
                    .padding(.horizontal)
                    saveButton
                }
                .padding(.horizontal, 20)
            }
            
            topBar
            
            if showInfo { infoPopupView }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func pufiHeader(name: String, asset: String) -> some View {
        HStack(spacing: 15) {
            Image(asset).resizable().scaledToFit().frame(width: 60, height: 60)
            Text(name).font(.title3.bold()).foregroundColor(.white)
            Spacer()
        }
    }

    private func traitPicker(selection: Binding<String>) -> some View {
        settingSection(title: "PERSONALITY") {
            HStack(spacing: 8) {
                ForEach(traits, id: \.self) { trait in
                    Button(action: { selection.wrappedValue = trait }) {
                        Text(trait)
                            .font(.system(size: 12, weight: .bold))
                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(selection.wrappedValue == trait ? Color(hex: "#4232a8") : Color.white.opacity(0.1))
                            .foregroundColor(.white).cornerRadius(10)
                    }
                }
            }
        }
    }

    private func appIconButtonStyle(for asset: String, name: String) -> some View {
        // İkon ismini belirleyelim
        let iconToSet: String
        if asset == "green_custom" {
            iconToSet = "gren"
        } else {
            iconToSet = "\(asset)_i"
        }
        return Button(action: {
            self.changeAppIcon(to: iconToSet)
        }) {
            HStack {
                Image(systemName: "app.badge.fill")
                Text("Set \(name) as Icon")
            }
            .font(.footnote.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            NotificationManager.instance.rescheduleAllNotifications()
            UISelectionFeedbackGenerator().selectionChanged()
            
            dismiss()
        }) {
            Text("Save All Changes")
                .font(.headline)
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
                .cornerRadius(18)
                .shadow(color: Color(hex: "#4232a8").opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal)
        .padding(.bottom, 40)
    }
    private var topBar: some View {
        VStack {
            HStack {
                Button(action: { withAnimation { showInfo.toggle() } }) {
                    Circle().fill(Color.white.opacity(0.1)).frame(width: 40, height: 40)
                        .overlay(Image(systemName: "questionmark").foregroundColor(.white))
                }
                Spacer()
                Button(action: { dismiss() }) {
                    Circle().fill(Color.white.opacity(0.1)).frame(width: 40, height: 40)
                        .overlay(Image(systemName: "xmark").foregroundColor(.white))
                }
            }.padding(.horizontal).padding(.top, 15)
            Spacer()
        }
    }

    private func changeAppIcon(to iconName: String?) {
        print("🔍 Xcode şu ikonu arıyor: \(iconName ?? "nil")")
        if let path = Bundle.main.path(forResource: "green_custom_icon", ofType: "png") {
            print("✅ Dosya pakette var: \(path)")
        } else {
            print("❌ HATA: Dosya uygulama paketine dahil edilmemiş!")
        }
        guard UIApplication.shared.supportsAlternateIcons else { return }
        if UIApplication.shared.alternateIconName == iconName { return }
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error { print("❌ Error: \(error.localizedDescription)") }
        }
    }

    private var infoPopupView: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea().onTapGesture { withAnimation { showInfo = false } }
            VStack(spacing: 20) {
                Text("Management").font(.title3.bold()).foregroundColor(.white)
                Text("You can customize both of your Pufis here. Each has its own name and personality traits!").font(.body).multilineTextAlignment(.center).foregroundColor(.white.opacity(0.8))
                Button("Got it!") { withAnimation { showInfo = false } }.padding().background(Color.white.opacity(0.1)).cornerRadius(10).foregroundColor(.white)
            }
            .padding(30).background(Color(hex: "#061836")).cornerRadius(30).padding(40)
        }
    }

    private func settingSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(size: 10, weight: .black)).foregroundColor(.white.opacity(0.4))
            content()
        }
    }
}
struct PufiTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(15)
            .background(Color.white.opacity(0.05))
            .cornerRadius(15)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}
