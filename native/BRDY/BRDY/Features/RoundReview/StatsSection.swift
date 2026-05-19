import SwiftUI

struct StatsSection: View {
    let vm: RoundReviewViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: BRDYSpacing.xl) {

            // WHS differential
            statGroup(title: "DIFFERENTIAL") {
                let sign = vm.scoreToPar >= 0 ? "+" : ""
                statGrid([
                    ("WHS DIFF", vm.whsDifferential),
                    ("SCORE",    "\(sign)\(vm.scoreToPar)"),
                    ("SHOTS",    "\(vm.totalShots)"),
                ])
            }

            // Scoring
            statGroup(title: "SCORING") {
                statGrid([
                    ("EAGLES",  "\(vm.eagles)"),
                    ("BIRDIES", "\(vm.birdies)"),
                    ("PARS",    "\(vm.pars)"),
                    ("BOGEYS",  "\(vm.bogeys)"),
                    ("DOUBLES", "\(vm.doubles)"),
                    ("PICKUPS", "\(vm.pickups)"),
                ])
            }

            // Approach & putting
            statGroup(title: "APPROACH & PUTTING") {
                statGrid([
                    ("FAIRWAYS",   vm.fairwaysAttempted > 0 ? "\(vm.fairwaysHit)/\(vm.fairwaysAttempted)" : "—"),
                    ("GIR",        vm.girsAttempted > 0 ? "\(vm.girsHit)/\(vm.girsAttempted)" : "—"),
                    ("PUTTS",      "\(vm.totalPutts)"),
                    ("AVG PUTTS",  String(format: "%.1f", vm.avgPutts)),
                ])
            }
        }
    }

    @ViewBuilder
    private func statGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: BRDYSpacing.sm + 10) {
            Text(title)
                .font(.custom("Courier New", size: 11))
                .fontWeight(.bold)
                .foregroundStyle(BRDYColors.onSurfaceMuted)
                .padding(.horizontal, BRDYSpacing.md)
            content()
        }
    }

    @ViewBuilder
    private func statGrid(_ items: [(String, String)]) -> some View {
        let pairs = stride(from: 0, to: items.count, by: 2).map {
            Array(items[$0..<min($0 + 2, items.count)])
        }
        VStack(spacing: BRDYSpacing.sm) {
            ForEach(Array(pairs.enumerated()), id: \.offset) { _, pair in
                HStack(spacing: BRDYSpacing.md) {
                    ForEach(pair, id: \.0) { item in
                        StatCard(label: item.0, value: item.1)
                    }
                    if pair.count == 1 { Spacer().frame(maxWidth: .infinity) }
                }
                .padding(.horizontal, BRDYSpacing.md)
            }
        }
    }
}
