import SwiftUI

struct RoundReviewView: View {
    let roundId: PersistentIdentifier
    let onDone: () -> Void

    @Environment(AppDependencies.self) private var deps
    @State private var vm: RoundReviewViewModel?
    @State private var showShare = false

    var body: some View {
        ZStack {
            BRDYColors.background.ignoresSafeArea()
            if let vm {
                RoundReviewContent(vm: vm, onDone: onDone, showShare: $showShare)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if vm == nil, let round = deps.rounds.fetch(id: roundId) {
                vm = RoundReviewViewModel(round: round, rounds: deps.rounds)
            }
        }
        .sheet(isPresented: $showShare) {
            if let vm {
                ShareSheet(text: vm.shareText)
            }
        }
    }
}

private struct RoundReviewContent: View {
    let vm: RoundReviewViewModel
    let onDone: () -> Void
    @Binding var showShare: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BRDYSpacing.xl) {
                StatsSection(vm: vm)

                ScorecardTable(holes: vm.sortedHoles, coursePar: 72)
                    .padding(.horizontal, BRDYSpacing.md)

                // Action buttons
                HStack(spacing: BRDYSpacing.sm) {
                    Button(action: onDone) {
                        Text("NEW ROUND")
                            .font(.custom("Courier New", size: 13))
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(BRDYColors.onSurface)
                            .cornerRadius(4)
                    }
                    Button(action: { showShare = true }) {
                        Text("SHARE")
                            .font(.custom("Courier New", size: 13))
                            .fontWeight(.bold)
                            .foregroundStyle(BRDYColors.onSurface)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(BRDYColors.surface)
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal, BRDYSpacing.md)
                .padding(.bottom, BRDYSpacing.xl)
            }
            .padding(.top, BRDYSpacing.xl)
        }
    }
}
