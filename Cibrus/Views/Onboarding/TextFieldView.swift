import SwiftUI

@available(iOS 18.0, *)
struct TextFieldContent: View {

    let headerTitle: String
    let headerSubtitle: String
    let placeholder: String

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    init(
        headerTitle: String = "What are your goals\nright now?",
        headerSubtitle: String =
            "The more you share, the more\npersonalized your affirmations will be",
        placeholder: String = "I want to..."
    ) {
        self.headerTitle = headerTitle
        self.headerSubtitle = headerSubtitle
        self.placeholder = placeholder
    }

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isFocused = false
                }

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(headerTitle)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    if !headerSubtitle.isEmpty {
                        Text(headerSubtitle)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 24)

                // Text Editor
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $text)
                        .focused($isFocused)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .regular))
                        .padding(12)
                }
                .frame(height: 140)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isFocused ? Color.blue : Color.white.opacity(0.15),
                            lineWidth: isFocused ? 1.5 : 1
                        )
                )
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isFocused = true
        }
    }
}

// MARK: - Preview

#Preview {
    TextFieldContent()
        .background(Color.black)
}
