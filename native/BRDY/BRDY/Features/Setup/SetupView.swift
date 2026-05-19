import SwiftUI

struct SetupView: View {
    let onRoundStarted: (PersistentIdentifier) -> Void

    @Environment(AppDependencies.self) private var deps
    @State private var vm: SetupViewModel?

    var body: some View {
        ZStack {
            BRDYColors.background.ignoresSafeArea()

            if let vm {
                SetupContent(vm: vm, onRoundStarted: onRoundStarted)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if vm == nil {
                vm = SetupViewModel(api: deps.api, rounds: deps.rounds)
            }
        }
    }
}

private struct SetupContent: View {
    @Bindable var vm: SetupViewModel
    let onRoundStarted: (PersistentIdentifier) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BRDYSpacing.md) {
            // Wordmark
            Text("BRDY.")
                .font(.custom("Courier New", size: 48))
                .fontWeight(.bold)
                .foregroundStyle(BRDYColors.onSurface)
                .padding(.top, BRDYSpacing.xl)

            // Handicap
            inputSection(title: "HANDICAP") {
                TextField("0.0", text: $vm.handicapText)
                    .keyboardType(.decimalPad)
                    .font(.custom("Courier New", size: 24))
                    .fontWeight(.bold)
                    .foregroundStyle(BRDYColors.onSurface)
                    .padding(BRDYSpacing.sm)
                    .background(BRDYColors.surface)
                    .cornerRadius(4)
            }

            // Course search
            inputSection(title: "COURSE") {
                HStack {
                    TextField("Search courses…", text: $vm.searchText)
                        .font(.custom("Courier New", size: 16))
                        .foregroundStyle(BRDYColors.onSurface)
                        .onSubmit { Task { await vm.search() } }
                    if vm.isSearching {
                        ProgressView().tint(BRDYColors.onSurfaceMuted)
                    } else {
                        Button(action: { Task { await vm.search() } }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(BRDYColors.onSurface)
                        }
                    }
                }
                .padding(BRDYSpacing.sm)
                .background(BRDYColors.surface)
                .cornerRadius(4)
            }

            // Selected course pill
            if let course = vm.selectedCourse {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(course.clubName.uppercased())
                            .font(.custom("Courier New", size: 13))
                            .fontWeight(.bold)
                            .foregroundStyle(BRDYColors.onSurface)
                        Text("PAR \(course.par) · \(course.holes.count) HOLES")
                            .font(.custom("Courier New", size: 11))
                            .foregroundStyle(BRDYColors.onSurfaceMuted)
                    }
                    Spacer()
                    Button(action: { vm.clearCourse() }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(BRDYColors.onSurfaceMuted)
                    }
                }
                .padding(BRDYSpacing.sm)
                .background(BRDYColors.birdie.opacity(0.15))
                .cornerRadius(4)
            }

            // Search results
            if !vm.searchResults.isEmpty && vm.selectedCourse == nil {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(vm.searchResults) { result in
                            Button(action: { Task { await vm.selectCourse(result) } }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(result.clubName.uppercased())
                                            .font(.custom("Courier New", size: 13))
                                            .fontWeight(.bold)
                                            .foregroundStyle(BRDYColors.onSurface)
                                        if let loc = result.location {
                                            Text(loc.uppercased())
                                                .font(.custom("Courier New", size: 11))
                                                .foregroundStyle(BRDYColors.onSurfaceMuted)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(BRDYColors.onSurfaceMuted)
                                }
                                .padding(BRDYSpacing.sm)
                                .background(BRDYColors.surface)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
                .cornerRadius(4)
            }

            if let error = vm.error {
                Text(error)
                    .font(.custom("Courier New", size: 12))
                    .foregroundStyle(BRDYColors.bogey)
            }

            Spacer()

            // Start button
            Button(action: {
                if let id = vm.startRound() { onRoundStarted(id) }
            }) {
                HStack {
                    Spacer()
                    if vm.isStarting {
                        ProgressView().tint(.black)
                    } else {
                        Text("LOAD")
                            .font(.custom("Courier New", size: 13))
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                    }
                    Spacer()
                }
                .frame(height: 80)
                .background(vm.canStart ? BRDYColors.bogey : BRDYColors.onSurfaceMuted)
                .cornerRadius(4)
            }
            .disabled(!vm.canStart)
            .padding(.bottom, BRDYSpacing.xl)
        }
        .padding(.horizontal, BRDYSpacing.md)
    }

    @ViewBuilder
    private func inputSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: BRDYSpacing.xs) {
            Text(title)
                .font(.custom("Courier New", size: 11))
                .fontWeight(.bold)
                .foregroundStyle(BRDYColors.onSurfaceMuted)
            content()
        }
    }
}
