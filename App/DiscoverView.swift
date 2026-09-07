import DishSwipeCore
import SwiftUI

struct DiscoverView: View {
    @StateObject private var model = AppModel()
    @State private var dragOffset: CGSize = .zero
    @State private var showingSaved = false
    @State private var isAnimatingDecision = false

    private let swipeThreshold = 110.0

    var body: some View {
        ZStack {
            Color.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                progress
                    .padding(.top, 14)
                    .padding(.bottom, 18)

                Group {
                    if let dish = model.currentDish {
                        dishCard(dish)
                            .id(dish.id)
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    } else {
                        completionView
                    }
                }
                .frame(maxHeight: .infinity)

                if model.currentDish != nil {
                    actionBar
                        .padding(.top, 18)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .sheet(isPresented: $showingSaved) {
            SavedDishesView(dishes: model.savedDishes)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("DISH SWIPE")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(2.1)
                    .foregroundStyle(Color.mango)
                Text("What sounds good?")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button {
                showingSaved = true
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "heart.fill")
                    Text("\(model.savedDishes.count)")
                        .monospacedDigit()
                }
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(.white.opacity(0.1), in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.08)))
            }
            .accessibilityLabel("Saved cravings, \(model.savedDishes.count) dishes")
        }
        .padding(.top, 8)
    }

    private var progress: some View {
        HStack(spacing: 12) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.11))
                    Capsule()
                        .fill(Color.mango)
                        .frame(width: geometry.size.width * model.progress)
                }
            }
            .frame(height: 5)

            Text("\(min(model.reviewedCount + 1, model.totalCount))/\(model.totalCount)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))
                .monospacedDigit()
        }
    }

    private func dishCard(_ dish: Dish) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                LoopingVideoPlayer(url: dish.videoURL)

                LinearGradient(
                    colors: [.clear, .black.opacity(0.08), .black.opacity(0.92)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                swipeStamp(text: "YES, PLEASE", symbol: "heart.fill", color: .craveGreen)
                    .opacity(likeOpacity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(24)

                swipeStamp(text: "NOT NOW", symbol: "xmark", color: .coral)
                    .opacity(passOpacity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(24)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Label(dish.cuisine, systemImage: "fork.knife")
                        Text("•")
                        Label("\(dish.durationMinutes) min", systemImage: "clock")
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.78))

                    Text(dish.name)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .tracking(-0.8)
                        .foregroundStyle(.white)

                    Text("Swipe right if you’d eat it. Left if tonight’s not the night.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                        .lineSpacing(3)
                }
                .padding(24)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.45), radius: 24, y: 16)
            .offset(x: dragOffset.width, y: dragOffset.height * 0.15)
            .rotationEffect(.degrees(dragOffset.width / 22))
            .scaleEffect(isAnimatingDecision ? 0.97 : 1)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { value in
                        guard !isAnimatingDecision else { return }
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        guard let decision = SwipeDecision(
                            horizontalTranslation: value.translation.width,
                            threshold: swipeThreshold
                        ) else {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                                dragOffset = .zero
                            }
                            return
                        }
                        commit(decision)
                    }
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(dish.name), \(dish.cuisine), \(dish.durationMinutes) minutes")
            .accessibilityHint("Swipe left to pass or right to save")
        }
    }

    private func swipeStamp(text: String, symbol: String, color: Color) -> some View {
        Label(text, systemImage: symbol)
            .font(.system(size: 15, weight: .black, design: .rounded))
            .tracking(1)
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .frame(height: 42)
            .background(.black.opacity(0.42), in: Capsule())
            .overlay(Capsule().stroke(color, lineWidth: 2))
    }

    private var likeOpacity: Double {
        min(max(dragOffset.width / swipeThreshold, 0), 1)
    }

    private var passOpacity: Double {
        min(max(-dragOffset.width / swipeThreshold, 0), 1)
    }

    private var actionBar: some View {
        HStack(spacing: 22) {
            actionButton(
                title: "Pass",
                symbol: "xmark",
                foreground: .coral,
                background: .white.opacity(0.09)
            ) { commit(.pass) }

            Text("SWIPE")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.35))

            actionButton(
                title: "Crave",
                symbol: "heart.fill",
                foreground: .craveGreen,
                background: .white.opacity(0.09)
            ) { commit(.like) }
        }
    }

    private func actionButton(
        title: String,
        symbol: String,
        foreground: Color,
        background: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .bold))
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
            }
            .foregroundStyle(foreground)
            .frame(width: 76, height: 62)
            .background(background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.08)))
        }
        .disabled(isAnimatingDecision)
    }

    private var completionView: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle().fill(Color.mango.opacity(0.13)).frame(width: 112, height: 112)
                Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                    .font(.system(size: 45))
                    .foregroundStyle(Color.mango)
            }
            Text("Dinner decided.")
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text("You saved \(model.savedDishes.count) delicious option\(model.savedDishes.count == 1 ? "" : "s").")
                .foregroundStyle(.white.opacity(0.62))
            Button("Swipe again") {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) { model.reset() }
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.black)
            .padding(.horizontal, 22)
            .frame(height: 50)
            .background(Color.mango, in: Capsule())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
    }

    private func commit(_ decision: SwipeDecision) {
        guard !isAnimatingDecision else { return }
        isAnimatingDecision = true
        let destination = decision == .like ? 700.0 : -700.0
        withAnimation(.easeIn(duration: 0.22)) {
            dragOffset = CGSize(width: destination, height: 20)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            model.decide(decision)
            dragOffset = .zero
            isAnimatingDecision = false
        }
    }
}

private struct SavedDishesView: View {
    let dishes: [Dish]

    var body: some View {
        NavigationStack {
            Group {
                if dishes.isEmpty {
                    ContentUnavailableView(
                        "No cravings yet",
                        systemImage: "heart",
                        description: Text("Swipe right on something delicious and it will show up here.")
                    )
                } else {
                    List(dishes) { dish in
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14).fill(Color.mango.opacity(0.14))
                                Image(systemName: "fork.knife")
                                    .foregroundStyle(Color.mango)
                            }
                            .frame(width: 52, height: 52)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(dish.name).font(.headline)
                                Text("\(dish.cuisine) · \(dish.durationMinutes) min")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Your cravings")
        }
    }
}

private extension Color {
    static let canvas = Color(red: 0.035, green: 0.037, blue: 0.043)
    static let mango = Color(red: 1.0, green: 0.72, blue: 0.22)
    static let coral = Color(red: 1.0, green: 0.36, blue: 0.32)
    static let craveGreen = Color(red: 0.27, green: 0.92, blue: 0.66)
}
