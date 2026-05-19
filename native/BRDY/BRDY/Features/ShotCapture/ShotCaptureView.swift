import SwiftUI
import SwiftData

struct ShotCaptureView: View {
    let roundId: PersistentIdentifier
    let onRoundComplete: (PersistentIdentifier) -> Void

    @Environment(AppDependencies.self) private var deps
    @Environment(\.modelContext) private var modelContext
    @State private var vm: ShotCaptureViewModel?

    var body: some View {
        ZStack {
            BRDYColors.background.ignoresSafeArea()
            if let vm {
                ShotCaptureContent(vm: vm, onRoundComplete: onRoundComplete)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if vm == nil, let round = deps.rounds.fetch(id: roundId) {
                vm = ShotCaptureViewModel(
                    round: round,
                    holes: deps.holes,
                    rounds: deps.rounds
                )
            }
        }
    }
}

private struct ShotCaptureContent: View {
    @Bindable var vm: ShotCaptureViewModel
    let onRoundComplete: (PersistentIdentifier) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HoleHeaderView(
                hole: vm.currentHole,
                holeIndex: vm.activeHoleIndex,
                totalShots: vm.totalShots,
                highestScoredIndex: vm.highestScoredIndex,
                onPrevHole: vm.goToPrevHole,
                onNextHole: vm.goToNextHole
            )
            .frame(height: UIScreen.main.bounds.height * 0.32)

            VStack(spacing: 0) {
                // Wordmark
                HStack {
                    Text("BRDY.\(String(format: "%02d", vm.activeHoleIndex + 1))")
                        .font(.custom("Courier New", size: 13))
                        .fontWeight(.bold)
                        .foregroundStyle(BRDYColors.onSurfaceMuted)
                    Spacer()
                }
                .padding(.horizontal, BRDYSpacing.md)
                .padding(.top, BRDYSpacing.sm + 15)
                .padding(.bottom, BRDYSpacing.sm)

                OutcomeButtonGrid(
                    hole: vm.currentHole,
                    onOutcome: vm.recordOutcome,
                    onIncrementPutts: vm.incrementPutts,
                    onDecrementPutts: vm.decrementPutts,
                    onUndo: vm.undoOutcome,
                    onNext: {
                        let done = vm.advanceHole()
                        if done, let id = vm.currentHole?.round?.persistentModelID {
                            onRoundComplete(id)
                        }
                    }
                )

                Spacer()

                FairwayGirTogglesView(
                    hole: vm.currentHole,
                    voiceService: vm.voiceService,
                    onFairway: vm.setFairway,
                    onGir: vm.setGir
                )
                .padding(.bottom, BRDYSpacing.md)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }
        .onChange(of: vm.voiceService.lastCommand) { _, command in
            if let command { vm.handleVoiceCommand(command) }
        }
    }
}
