import Foundation

enum FinderScriptRunner {
    static func sortDesktop(criterion: SortCriterion, descending: Bool, grouping: DesktopGrouping) -> Result<Int, SortError> {
        guard let url = Bundle.main.url(forResource: "SortDesktop", withExtension: "applescript") else {
            return .failure(.missingScript)
        }

        do {
            let template = try String(contentsOf: url, encoding: .utf8)
            let source = template
                .replacingOccurrences(of: "__DESCENDING__", with: descending ? "true" : "false")
                .replacingOccurrences(of: "__CRITERION__", with: criterion.rawValue)
                .replacingOccurrences(of: "__GROUPING__", with: grouping.rawValue)
            guard let script = NSAppleScript(source: source) else {
                return .failure(.invalidScript)
            }

            var error: NSDictionary?
            let result = script.executeAndReturnError(&error)
            if let error {
                let message = error[NSAppleScript.errorMessage] as? String ?? "Finder no pudo completar la ordenación."
                let number = error[NSAppleScript.errorNumber] as? Int
                print("Desktop Date Sorter — AppleScript error \(number.map(String.init) ?? "unknown"): \(message)")
                return .failure(.appleScript(message))
            }
            return .success(Int(result.int32Value))
        } catch {
            print("Desktop Date Sorter — unable to load script: \(error.localizedDescription)")
            return .failure(.unreadableScript)
        }
    }
}

enum SortError: LocalizedError {
    case missingScript
    case unreadableScript
    case invalidScript
    case appleScript(String)

    var errorDescription: String? {
        switch self {
        case .missingScript, .unreadableScript, .invalidScript:
            return "No se pudo cargar el componente de Finder de la app."
        case .appleScript(let message):
            return "Finder no autorizó o no pudo completar la ordenación: \(message)"
        }
    }
}
