import SwiftUI

struct OutcomeButtonGrid: View {
    let hole: Hole?
    let onOutcome: (HoleOutcome) -> Void
    let onIncrementPutts: () -> Void
    let onDecrementPutts: () -> Void
    let onUndo: () -> Void
    let onNext: () -> Void

    private var currentOutcome: HoleOutcome? { hole?.outcome }
    private var currentPutts: Int { hole?.putts ?? 0 }
    private var maxPutts: Int? { hole?.shots }
    private var canAddPutt: Bool { maxPutts.map { currentPutts < $0 } ?? false }

    var body: some View {
        VStack(spacing: 0) {
            // Row 1: EAGLE, BIRDIE, PAR
            HStack(spacing: 0) {
                outcomeButton(.eagle)
                outcomeButton(.birdie)
                outcomeButton(.par)
            }

            Color.clear.frame(height: 20)

            // Row 2: DOUBLE, BOGEY, PUTTS, PICKUP, NEXT
            HStack(spacing: 0) {
                outcomeButton(.doubleBogey)
                outcomeButton(.bogey)
                puttsButton()
                outcomeButton(.pickup)
                nextButton()
            }
        }
        .padding(.horizontal, BRDYSpacing.sm)
    }

    // MARK: - Outcome button

    @ViewBuilder
    private func outcomeButton(_ outcome: HoleOutcome) -> some View {
        let isActive = currentOutcome == outcome
        Button(action: { onOutcome(outcome) }) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(outcome.color)
                        .frame(width: 6, height: 6)
                    Text(outcome.abbreviation)
                        .font(.custom("Courier New", size: 10))
                        .fontWeight(.bold)
                        .foregroundStyle(BRDYColors.onSurfaceMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.top, 8)
                Spacer()
                Text(outcome.label)
                    .font(.custom("Courier New", size: 13))
                    .fontWeight(.bold)
                    .foregroundStyle(isActive ? .black : BRDYColors.onSurface)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isActive ? outcome.color : outcome.color.opacity(0.25))
            .cornerRadius(4)
            .padding(2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Putts button

    @ViewBuilder
    private func puttsButton() -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Circle()
                    .fill(BRDYColors.onSurfaceMuted)
                    .frame(width: 6, height: 6)
                Text("PTT")
                    .font(.custom("Courier New", size: 10))
                    .fontWeight(.bold)
                    .foregroundStyle(BRDYColors.onSurfaceMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.top, 8)

            Text("\(currentPutts)")
                .font(.custom("Courier New", size: 32))
                .fontWeight(.bold)
                .foregroundStyle(BRDYColors.onSurface)

            HStack(spacing: 0) {
                Button(action: onDecrementPutts) {
                    Text("−")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(currentPutts > 0 ? BRDYColors.onSurface : BRDYColors.onSurfaceMuted)
                        .frame(maxWidth: .infinity).frame(height: 28)
                        .background(BRDYColors.surface)
                }
                .disabled(currentPutts == 0)

                Button(action: onIncrementPutts) {
                    Text("+")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(canAddPutt ? BRDYColors.onSurface : BRDYColors.onSurfaceMuted)
                        .frame(maxWidth: .infinity).frame(height: 28)
                        .background(BRDYColors.surface)
                }
                .disabled(!canAddPutt)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(BRDYColors.surface)
        .cornerRadius(4)
        .padding(2)
    }

    // MARK: - Next / Undo button

    @ViewBuilder
    private func nextButton() -> some View {
        Button(action: { currentOutcome != nil ? onNext() : onUndo() }) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(BRDYColors.bogey)
                        .frame(width: 6, height: 6)
                    Text("NXT")
                        .font(.custom("Courier New", size: 10))
                        .fontWeight(.bold)
                        .foregroundStyle(BRDYColors.onSurfaceMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.top, 8)
                Spacer()
                Text(currentOutcome != nil ? "NEXT" : "UNDO")
                    .font(.custom("Courier New", size: 13))
                    .fontWeight(.bold)
                    .foregroundStyle(BRDYColors.onSurface)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(BRDYColors.bogey.opacity(0.25))
            .cornerRadius(4)
            .padding(2)
        }
        .buttonStyle(.plain)
    }
}
