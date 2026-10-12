import SwiftUI

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    var pages: [String]
    var colorHex: String
    var isBold: Bool
    var isItalic: Bool
    var fontName: String
}

struct MidnightJournalView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("journal_entries") var entriesData: Data = Data()
    
    @State private var entries: [JournalEntry] = []
    @State private var journalPages: [String] = [""]
    @State private var currentPageIndex: Int = 0
    @State private var showInstructions = true
    
    @State private var selectedColor: Color = .white
    @State private var isBold: Bool = false
    @State private var isItalic: Bool = false
    @State private var selectedFont: String = "Georgia"
    
    let fontOptions = ["Georgia", "Palatino", "Charter", "Times New Roman", "Avenir"]
    
    var body: some View {
        ZStack {
            Color(hex: "#061836").ignoresSafeArea()
            StaticBackgroundStarsView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                
                Spacer()
                VStack(spacing: 0) {
                    toolbarView
                    
                    ZStack(alignment: .bottom) {
                        pageContentView
                        pageNavigationControls
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(0.8, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.black.opacity(0.4))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(LinearGradient(colors: [.white.opacity(0.2), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
                .padding(.horizontal, 25)
                
                Spacer()
                pastEntriesView
                    .padding(.bottom, 30)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .overlay {
            if showInstructions {
                journalInstructionsOverlay
            }
        }
        .onAppear(perform: loadEntries)
        .navigationBarHidden(true)
    }

    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.6))
                    .padding(10)
            }
            Spacer()
            Text("Midnight Journal")
                .font(.system(.headline, design: .serif))
                .foregroundColor(.white)
            Spacer()
            Button(action: saveEntry) {
                Text("Save")
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#A855F7"))
                    .padding(10)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var toolbarView: some View {
        HStack(spacing: 12) {
            Menu {
                ForEach(fontOptions, id: \.self) { font in
                    Button(font) { selectedFont = font }
                }
            } label: {
                HStack {
                    Text(selectedFont).font(.caption)
                    Image(systemName: "chevron.down").font(.system(size: 8))
                }
                .foregroundColor(.white.opacity(0.7))
                .padding(8)
                .background(Color.white.opacity(0.1)).cornerRadius(8)
            }
            
            Divider().frame(height: 20).background(Color.white.opacity(0.2))
            
            Button(action: { isBold.toggle() }) {
                Image(systemName: "bold").foregroundColor(isBold ? Color(hex: "#A855F7") : .white)
            }
            Button(action: { isItalic.toggle() }) {
                Image(systemName: "italic").foregroundColor(isItalic ? Color(hex: "#A855F7") : .white)
            }
            ColorPicker("", selection: $selectedColor).labelsHidden().scaleEffect(0.7)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    journalPages = [""]
                    currentPageIndex = 0
                }
            }) {
                Image(systemName: "square.and.pencil").foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
    }
    
    private var pageContentView: some View {
        ZStack(alignment: .topLeading) {
            // Çizgiler
            VStack(spacing: 30) {
                ForEach(0..<9, id: \.self) { _ in
                    Divider().background(Color.white.opacity(0.06))
                }
            }
            .padding(.top, 65)
            
            TextEditor(text: $journalPages[currentPageIndex])
                .scrollContentBackground(.hidden)
                .foregroundColor(selectedColor)
                .font(.custom(selectedFont, size: 20))
                .fontWeight(isBold ? .bold : .regular)
                .italic(isItalic)
                .lineSpacing(10)
                .padding(.horizontal, 20)
                .padding(.top, 30)
                .padding(.bottom, 60)
        }
    }
    
    private var pageNavigationControls: some View {
        HStack {
            Button(action: { if currentPageIndex > 0 { currentPageIndex -= 1 } }) {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundColor(.white.opacity(0.6))
                    .opacity(currentPageIndex == 0 ? 0.2 : 1)
            }
            .disabled(currentPageIndex == 0)
            
            Spacer()
            
            Text("\(currentPageIndex + 1) / \(journalPages.count)")
                .font(.caption2).monospacedDigit()
                .foregroundColor(.white.opacity(0.4))
            
            Spacer()
            
            Button(action: {
                if currentPageIndex == journalPages.count - 1 {
                    addNewPage()
                } else {
                    currentPageIndex += 1
                }
            }) {
                Image(systemName: currentPageIndex == journalPages.count - 1 ? "plus.circle" : "chevron.right")
                    .font(.title3.bold())
            }
        }
        .foregroundColor(Color(hex: "#A855F7"))
        .padding(.horizontal, 25)
        .padding(.bottom, 20)
    }
    
    private var pastEntriesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !entries.isEmpty {
                Text("Past Thoughts")
                    .font(.caption).foregroundColor(.white.opacity(0.4)).padding(.leading, 30)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(entries) { entry in
                            JournalEntryCard(entry: entry, onDelete: {
                                deleteEntry(entry)
                            }, onSelect: {
                                loadSpecificEntry(entry)
                            })
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .frame(height: 100)
            }
        }
    }

    func loadSpecificEntry(_ entry: JournalEntry) {
        withAnimation(.easeInOut) {
            self.journalPages = entry.pages
            self.currentPageIndex = 0
            self.selectedFont = entry.fontName
            self.selectedColor = Color(hex: entry.colorHex)
            self.isBold = entry.isBold
            self.isItalic = entry.isItalic
        }
    }

    func addNewPage() {
        withAnimation {
            journalPages.append("")
            currentPageIndex = journalPages.count - 1
        }
    }
    
    func saveEntry() {
        let nonEmptyPages = journalPages.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !nonEmptyPages.isEmpty else { return }
        
        let newEntry = JournalEntry(
            id: UUID(),
            date: Date(),
            pages: nonEmptyPages,
            colorHex: selectedColor.toHex() ?? "#FFFFFF",
            isBold: isBold,
            isItalic: isItalic,
            fontName: selectedFont
        )
        
        withAnimation(.spring()) {
            entries.insert(newEntry, at: 0)
            saveToDisk()
            hideKeyboard()
        }
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        withAnimation {
            entries.removeAll { $0.id == entry.id }
            saveToDisk()
        }
    }
    
    func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(entries) {
            entriesData = encoded
        }
    }
    
    func loadEntries() {
        if let decoded = try? JSONDecoder().decode([JournalEntry].self, from: entriesData) {
            entries = decoded
        }
    }
    
    var journalInstructionsOverlay: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("📓").font(.system(size: 60))
                Text("Midnight Journal").font(.title2.bold()).foregroundColor(.white)
                Text("Write freely. Tap on 'Past Thoughts' to re-read or edit your old notes.")
                    .font(.subheadline).multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.7)).padding(.horizontal, 50)
                
                Button("Start Writing") {
                    withAnimation { showInstructions = false }
                }
                .padding().frame(width: 180)
                .background(Color(hex: "#A855F7")).foregroundColor(.white).cornerRadius(15)
            }
        }
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    let onDelete: () -> Void
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(entry.date.formatted(.dateTime.day().month()))
                        .font(.caption2.bold()).foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Button(action: onDelete) {
                        Image(systemName: "trash.fill").font(.system(size: 9)).foregroundColor(.red.opacity(0.5))
                    }
                }
                Text(entry.pages.first ?? "")
                    .font(.custom(entry.fontName, size: 11))
                    .fontWeight(entry.isBold ? .bold : .regular)
                    .italic(entry.isItalic)
                    .foregroundColor(Color(hex: entry.colorHex))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(12)
            .frame(width: 140, height: 90)
            .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.08)))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
    func toHex() -> String? {
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components, components.count >= 3 else { return nil }
        let r = Float(components[0]), g = Float(components[1]), b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
