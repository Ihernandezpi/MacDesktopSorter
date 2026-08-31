import AppKit
import ServiceManagement
import SwiftUI

@main
struct DesktopDateSorterApp: App {
    @StateObject private var sorter = DesktopSorter()
    @State private var launchAtLoginEnabled = SMAppService.mainApp.status == .enabled

    var body: some Scene {
        MenuBarExtra {
            ForEach(SortCriterion.allCases) { criterion in
                Button {
                    if sorter.criterion == criterion {
                        sorter.toggleOrder()
                    } else {
                        sorter.applyCriterion(criterion)
                    }
                } label: {
                    HStack {
                        if sorter.criterion == criterion {
                            Image(systemName: "checkmark")
                        }
                        Text(sorter.criterion == criterion ? "\(criterion.title)  \(sorter.directionGlyph)" : criterion.title)
                        Spacer()
                    }
                }
                .disabled(sorter.isWorking)
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
        } label: {
            if sorter.isWorking {
                Image(systemName: "arrow.triangle.2.circlepath")
            } else {
                Image("MenuBarIcon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
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
