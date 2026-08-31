import AppKit
import ServiceManagement
import SwiftUI

@main
struct DesktopDateSorterApp: App {
    @StateObject private var sorter = DesktopSorter()
    @State private var launchAtLoginEnabled = SMAppService.mainApp.status == .enabled

    var body: some Scene {
        MenuBarExtra("Ordenar Escritorio", systemImage: "arrow.up.arrow.down") {
            Button {
                sorter.toggleOrder()
            } label: {
                Label(sorter.criterion.title, systemImage: sorter.directionSymbol)
            }
            .disabled(sorter.isWorking)

            ForEach(SortCriterion.allCases) { criterion in
                Button {
                    sorter.applyCriterion(criterion)
                } label: {
                    if sorter.criterion == criterion {
                        Label(criterion.title, systemImage: "checkmark")
                    } else {
                        Text(criterion.title)
                    }
                }
                .disabled(sorter.isWorking || sorter.criterion == criterion)
            }

            Divider()
            ForEach(DesktopGrouping.allCases) { grouping in
                Button {
                    sorter.applyGrouping(grouping)
                } label: {
                    if sorter.grouping == grouping {
                        Label(grouping.title, systemImage: "checkmark")
                    } else {
                        Text(grouping.title)
                    }
                }
                .disabled(sorter.isWorking || sorter.grouping == grouping)
            }

            Divider()

            Menu("Perfiles") {
                Button("Recientes") { sorter.applyProfile(.recent) }
                Button("Trabajo") { sorter.applyProfile(.work) }
                Button("Archivo") { sorter.applyProfile(.archive) }
            }
            Divider()

            Toggle("Abrir al iniciar sesión", isOn: $launchAtLoginEnabled)
                .onChange(of: launchAtLoginEnabled) { enabled in
                    updateLaunchAtLogin(enabled)
                }

            if sorter.isWorking {
                Divider()
                Text("Ordenando…")
            } else if let message = sorter.statusMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Divider()

            Button("Salir") {
                NSApplication.shared.terminate(nil)
            }
        }
        .menuBarExtraStyle(.menu)
    }

    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            launchAtLoginEnabled = SMAppService.mainApp.status == .enabled
            sorter.statusMessage = "No se pudo actualizar el inicio: \(error.localizedDescription)"
        }
    }
}
