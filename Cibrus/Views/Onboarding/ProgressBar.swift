import SwiftUI

@available(iOS 18.0, *)
struct ProgressBar: View {
    let progress: Double
    @State private var animatedProgress: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)

                Capsule()
                    .fill(Color.blue)
                    .frame(
                        width: geometry.size.width * animatedProgress,
                        height: 4
                    )
            }
        }
        .frame(height: 4)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.4)) {
                animatedProgress = newValue
            }
        }
    }
}

#Preview {
    ZStack {
        Color.white.ignoresSafeArea()

        ProgressBar(progress: 0.5)
            .padding(.horizontal, 24)
    }
}
