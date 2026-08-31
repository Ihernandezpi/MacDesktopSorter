import AppKit
import ServiceManagement
import SwiftUI

@main
struct DesktopDateSorterApp: App {
    @StateObject private var sorter = DesktopSorter()
    @State private var launchAtLoginEnabled = SMAppService.mainApp.status == .enabled

    var body: some Scene {
        MenuBarExtra("Ordenar Escritorio", systemImage: "arrow.up.arrow.down") {
            Menu("Ordenar por: \(sorter.criterion.title)") {
                ForEach(SortCriterion.allCases) { criterion in
                    Button(criterion.title) { sorter.setCriterion(criterion) }
                }
            }

            Button("Más recientes primero") { sorter.sort(descending: true) }.disabled(sorter.isWorking)
            Button("Más antiguos primero") { sorter.sort(descending: false) }.disabled(sorter.isWorking)
            Button("Alternar orden") { sorter.toggleOrder() }.disabled(sorter.isWorking)
            Toggle("Carpetas primero", isOn: $sorter.foldersFirst).disabled(sorter.isWorking)

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
