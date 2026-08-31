import AppKit
import Foundation

enum SortCriterion: String, CaseIterable, Identifiable { case creationDate, modificationDate, name, kind, size; var id: String { rawValue }; var title: String { switch self { case .creationDate: "Fecha de creación"; case .modificationDate: "Fecha de modificación"; case .name: "Nombre"; case .kind: "Tipo"; case .size: "Tamaño" } } }
enum DesktopGrouping: String, CaseIterable, Identifiable { case none, foldersFirst, filesFirst, imagesFirst; var id: String { rawValue }; var title: String { switch self { case .none: "Sin prioridad de grupo"; case .foldersFirst: "Carpetas primero"; case .filesFirst: "Archivos primero"; case .imagesFirst: "Imágenes primero" } } }
enum DesktopProfile { case recent, work, archive; var value: (SortCriterion, Bool, Bool) { switch self { case .recent: (.creationDate, true, false); case .work: (.modificationDate, true, true); case .archive: (.creationDate, false, true) } } }

@MainActor final class DesktopSorter: ObservableObject {
    @Published private(set) var isWorking = false
    @Published var statusMessage: String?
    @Published var criterion: SortCriterion { didSet { UserDefaults.standard.set(criterion.rawValue, forKey: "criterion") } }
    @Published var grouping: DesktopGrouping { didSet { UserDefaults.standard.set(grouping.rawValue, forKey: "grouping") } }
    init() { criterion = SortCriterion(rawValue: UserDefaults.standard.string(forKey: "criterion") ?? "") ?? .creationDate; grouping = DesktopGrouping(rawValue: UserDefaults.standard.string(forKey: "grouping") ?? "") ?? .none }
    var directionSymbol: String { UserDefaults.standard.bool(forKey: "descending") ? "arrow.down" : "arrow.up" }
    var directionGlyph: String { UserDefaults.standard.bool(forKey: "descending") ? "↓" : "↑" }
    func setCriterion(_ value: SortCriterion) { criterion = value }
    func applyCriterion(_ value: SortCriterion) { criterion = value; sort(descending: UserDefaults.standard.bool(forKey: "descending")) }
    func applyGrouping(_ value: DesktopGrouping) { grouping = value; sort(descending: UserDefaults.standard.bool(forKey: "descending")) }
    func applyProfile(_ profile: DesktopProfile) { let value = profile.value; criterion = value.0; grouping = value.2 ? .foldersFirst : .none; sort(descending: value.1) }
    func toggleOrder() { sort(descending: !UserDefaults.standard.bool(forKey: "descending")) }
    func sort(descending: Bool) {
        guard !isWorking else { return }; isWorking = true; statusMessage = nil
        let selected = criterion; let grouping = grouping
        DispatchQueue.global(qos: .userInitiated).async {
            let result = FinderScriptRunner.sortDesktop(criterion: selected, descending: descending, grouping: grouping)
            DispatchQueue.main.async { self.isWorking = false; switch result { case .success(let count): UserDefaults.standard.set(descending, forKey: "descending"); self.statusMessage = "\(count) iconos ordenados por \(selected.title.lowercased())."; case .failure(let error): self.fail(error) } }
        }
    }
    private func fail(_ error: SortError) { statusMessage = error.localizedDescription; let alert = NSAlert(); alert.alertStyle = .warning; alert.messageText = "No se pudo ordenar el Escritorio"; alert.informativeText = error.localizedDescription ?? ""; alert.addButton(withTitle: "Aceptar"); alert.runModal() }
}
