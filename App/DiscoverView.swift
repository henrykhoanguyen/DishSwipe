import DishSwipeCore
import Foundation
import SwiftUI

struct DiscoverView: View {
    private enum PresentedScreen: String, Identifiable {
        case cravings
        case cart

        var id: String { rawValue }
    }

    @StateObject private var model = AppModel()
    @State private var dragOffset: CGSize = .zero
    @State private var presentedScreen: PresentedScreen?
    @State private var isAnimatingDecision = false

    private let swipeThreshold = 110.0

    var body: some View {
        ZStack {
            if let dish = model.currentDish {
                dishExperience(dish)
                    .ignoresSafeArea()
                    .id(dish.id)
                    .transition(.opacity)
            } else {
                completionView
            }
        }
        .background(Color.warmWhite)
        .preferredColorScheme(.light)
        .sheet(item: $presentedScreen) { screen in
            switch screen {
            case .cravings:
                SavedDishesView(model: model)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            case .cart:
                CartView(model: model)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private func dishExperience(_ dish: Dish) -> some View {
        GeometryReader { geometry in
            ZStack {
                LoopingVideoPlayer(url: dish.videoURL)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.52), location: 0),
                        .init(color: .clear, location: 0.27),
                        .init(color: .clear, location: 0.48),
                        .init(color: .black.opacity(0.88), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                swipeStamp(text: "CRAVE", symbol: "heart.fill")
                    .opacity(likeOpacity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.top, 150)
                    .padding(.leading, 24)

                swipeStamp(text: "PASS", symbol: "xmark")
                    .opacity(passOpacity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 150)
                    .padding(.trailing, 24)

                VStack(spacing: 0) {
                    header
                    progress
                        .padding(.top, 12)

                    Spacer()

                    dishDetails(dish)
                    actionBar
                        .padding(.top, 22)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .ignoresSafeArea()
            .offset(x: dragOffset.width, y: dragOffset.height * 0.08)
            .rotationEffect(.degrees(dragOffset.width / 28))
            .scaleEffect(isAnimatingDecision ? 0.985 : 1)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 10)
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
            .accessibilityElement(children: .contain)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("DISH\nSWIPE")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)
                .lineSpacing(-3)
                .foregroundStyle(.white)
                .frame(width: 68, height: 48)
                .background(Color.brandRed, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white, lineWidth: 3))
                .shadow(color: .black.opacity(0.18), radius: 7, y: 3)

            Spacer()

            headerButton(
                label: "Cravings",
                symbol: "heart.fill",
                count: model.savedDishes.count
            ) { presentedScreen = .cravings }

            headerButton(
                label: "Cart",
                symbol: "cart.fill",
                count: model.cartItems.count
            ) { presentedScreen = .cart }
        }
    }

    private func headerButton(
        label: String,
        symbol: String,
        count: Int,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.brandRed)
                    .frame(width: 48, height: 48)
                    .background(.white, in: Circle())
                    .shadow(color: .black.opacity(0.18), radius: 7, y: 3)

                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(minWidth: 20, minHeight: 20)
                        .background(Color.brandBlue, in: Circle())
                        .offset(x: 4, y: -3)
                }
            }
        }
        .accessibilityLabel("\(label), \(count) items")
    }

    private var progress: some View {
        HStack(spacing: 10) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.45))
                    Capsule()
                        .fill(Color.brandRed)
                        .frame(width: geometry.size.width * model.progress)
                }
            }
            .frame(height: 6)

            Text("\(min(model.reviewedCount + 1, model.totalCount))/\(model.totalCount)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
                .shadow(color: .black.opacity(0.35), radius: 3)
        }
    }

    private func dishDetails(_ dish: Dish) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Label(dish.cuisine, systemImage: "fork.knife")
                Text("•")
                Label("\(dish.durationMinutes) min", systemImage: "clock.fill")
            }
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(.white.opacity(0.9))

            Text(dish.name)
                .font(.system(size: 40, weight: .black, design: .rounded))
                .tracking(-1.1)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.8)
                .lineLimit(2)

            Text("Swipe right to crave it · left to pass")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.82))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(color: .black.opacity(0.4), radius: 5, y: 2)
    }

    private func swipeStamp(text: String, symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.system(size: 16, weight: .black, design: .rounded))
            .tracking(1)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .frame(height: 46)
            .background(Color.brandRed, in: Capsule())
            .overlay(Capsule().stroke(.white, lineWidth: 3))
            .rotationEffect(.degrees(text == "CRAVE" ? -10 : 10))
    }

    private var likeOpacity: Double {
        min(max(dragOffset.width / swipeThreshold, 0), 1)
    }

    private var passOpacity: Double {
        min(max(-dragOffset.width / swipeThreshold, 0), 1)
    }

    private var actionBar: some View {
        HStack(spacing: 28) {
            actionButton(title: "Pass", symbol: "xmark", filled: false) { commit(.pass) }
            actionButton(title: "Crave", symbol: "heart.fill", filled: true) { commit(.like) }
        }
        .frame(maxWidth: .infinity)
    }

    private func actionButton(
        title: String,
        symbol: String,
        filled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(filled ? .white : Color.brandRed)
                .frame(width: 138, height: 58)
                .background(filled ? Color.brandRed : .white, in: Capsule())
                .overlay(Capsule().stroke(.white, lineWidth: filled ? 3 : 0))
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
        }
        .disabled(isAnimatingDecision)
    }

    private var completionView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.brandRed)

            Text("Dinner decided!")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(Color.ink)

            Text("You saved \(model.savedDishes.count) delicious option\(model.savedDishes.count == 1 ? "" : "s").")
                .foregroundStyle(Color.ink.opacity(0.65))

            Button("View your cravings") { presentedScreen = .cravings }
                .brandPrimaryButton()

            Button("Swipe again") {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) { model.reset() }
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(Color.brandRed)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }

    private func commit(_ decision: SwipeDecision) {
        guard !isAnimatingDecision else { return }
        isAnimatingDecision = true
        let destination = decision == .like ? 700.0 : -700.0
        withAnimation(.easeIn(duration: 0.22)) {
            dragOffset = CGSize(width: destination, height: 10)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            model.decide(decision)
            dragOffset = .zero
            isAnimatingDecision = false
        }
    }
}

private struct SavedDishesView: View {
    @ObservedObject var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if model.savedDishes.isEmpty {
                    ContentUnavailableView(
                        "No cravings yet",
                        systemImage: "heart",
                        description: Text("Swipe right on a dish and it will show up here.")
                    )
                } else {
                    List {
                        ForEach(model.savedDishes) { dish in
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 12) {
                                    Image(systemName: "fork.knife.circle.fill")
                                        .font(.system(size: 38))
                                        .foregroundStyle(Color.brandRed)

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(dish.name)
                                            .font(.headline)
                                            .foregroundStyle(Color.ink)
                                        Text("\(dish.cuisine) · \(dish.durationMinutes) min · \(dish.ingredients.count) ingredients")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                HStack(spacing: 10) {
                                    Button {
                                        model.addIngredientsToCart(for: dish)
                                    } label: {
                                        Label(
                                            model.cartContainsIngredients(for: dish) ? "Added to cart" : "Add ingredients",
                                            systemImage: model.cartContainsIngredients(for: dish) ? "checkmark" : "cart.badge.plus"
                                        )
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Color.brandBlue)
                                    .disabled(model.cartContainsIngredients(for: dish))

                                    Button(role: .destructive) {
                                        model.removeFromCravings(dish)
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 16, weight: .bold))
                                            .frame(width: 44, height: 44)
                                    }
                                    .buttonStyle(.bordered)
                                    .accessibilityLabel("Remove \(dish.name) from cravings")
                                }
                            }
                            .padding(.vertical, 8)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Your cravings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        CartView(model: model)
                    } label: {
                        Label("Cart (\(model.cartItems.count))", systemImage: "cart.fill")
                            .foregroundStyle(Color.brandRed)
                    }
                    .accessibilityLabel("View cart")
                }
            }
        }
        .tint(Color.brandRed)
        .preferredColorScheme(.light)
    }
}

private struct CartView: View {
    @ObservedObject var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingConfirmation = false

    var body: some View {
        NavigationStack {
            Group {
                if model.cartItems.isEmpty {
                    ContentUnavailableView(
                        "Your cart is empty",
                        systemImage: "cart",
                        description: Text("Add ingredients from one of your cravings.")
                    )
                } else {
                    List {
                        Section {
                            ForEach(model.cartItems) { ingredient in
                                HStack(alignment: .firstTextBaseline, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(ingredient.name)
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(Color.ink)
                                        Text(ingredient.amount)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(currency(ingredient.priceInCents))
                                        .font(.body.weight(.bold))
                                        .foregroundStyle(Color.ink)
                                }
                                .padding(.vertical, 5)
                            }
                        } header: {
                            Text("Ingredients")
                        } footer: {
                            Text("Prices are estimates for this prototype.")
                        }

                        Section {
                            HStack {
                                Text("Estimated total")
                                    .font(.headline)
                                Spacer()
                                Text(currency(model.cartTotalInCents))
                                    .font(.title3.weight(.black))
                                    .foregroundStyle(Color.brandRed)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Your cart")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    showingConfirmation = true
                } label: {
                    HStack {
                        Text("Check out")
                        Spacer()
                        Text(currency(model.cartTotalInCents))
                    }
                }
                .brandPrimaryButton()
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .disabled(model.cartItems.isEmpty)
            }
        }
        .tint(Color.brandRed)
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingConfirmation) {
            PurchaseConfirmationView()
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
    }

    private func currency(_ cents: Int) -> String {
        String(format: "$%.2f", Double(cents) / 100)
    }
}

private struct PurchaseConfirmationView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.brandRed)
            Text("Thank you for your purchase!")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.ink)
            Text("This is a demo checkout. No order was placed.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Done") { dismiss() }
                .brandPrimaryButton()
        }
        .padding(24)
        .preferredColorScheme(.light)
    }
}

private extension View {
    func brandPrimaryButton() -> some View {
        self
            .font(.system(size: 17, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .padding(.horizontal, 2)
            .background(Color.brandRed, in: Capsule())
    }
}

private extension Color {
    static let brandRed = Color(red: 0.79, green: 0.02, blue: 0.08)
    static let brandBlue = Color(red: 0.02, green: 0.38, blue: 0.66)
    static let warmWhite = Color(red: 0.98, green: 0.97, blue: 0.95)
    static let ink = Color(red: 0.12, green: 0.12, blue: 0.12)
}
