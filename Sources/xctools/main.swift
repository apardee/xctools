// swiftlint:disable line_length
import Foundation
import Commander
import PathKit
import BuildSettings
import Frameworks
import Core

enum XcodeError: Error {
    case xcodeEnvironmentNotFound
}

Group {
    $0.group("frameworks", "set of tools to work with frameworks in your project") { (frameworks) in
        let embedCommand = command(Flag("allconfigs", flag: "a", description: "Embed the frameworks for all the configurations", default: true),
                                   Option("configs", "", flag: "c", description: "Comma separated list of configs that need the framework to be embed (e.g. Debug,Release)")) { (buildAllConfigs: Bool, configs: String) in
                                    guard let environment = XcodeEnvironment() else{
                                        throw XcodeError.xcodeEnvironmentNotFound
                                    }
                                    try EmbedCommand(buildAllConfigs: buildAllConfigs,
                                                     configsToBuild: configs.components(separatedBy: ","),
                                                     configuration: environment.configuration,
                                                     inputsAndOutputs: environment.inputsAndOutputs,
                                                     validArchs: environment.validArchs,
                                                     action: environment.action,
                                                     builtProductsDir: environment.builtProductsDir).execute()
        }
        let stripCommand = command(Argument("path", description: "Framework path"),
                                   Option("archs", "", flag: "a", description: "Comma separated list of architectures to strip (e.g. armv7,arm64)")) { (path: String, archs: String) in
            try StripCommand(packagePath: Path(path), architecturesToStrip: Set(archs.components(separatedBy: ","))).execute()
        }
        frameworks.addCommand("embed", "embeds frameworks into the product /Frameworks folder", embedCommand)
        frameworks.addCommand("strip", "strip architectures from a given framework", stripCommand)
    }
    
    $0.group("buildsettings", "set of tools to view and manipulate project build settings") { (frameworks) in
        let cleanCommand = command(Argument("sourcePath", description: "The project source path"), Option("targetPath", "", flag: "t", description: "A target path for the cleaned project file")) { (sourcePath: String, targetPath: String) in
            try BuildSettingsCleanCommand(projectPath: Path(sourcePath), target: targetPath).execute()
        }
        frameworks.addCommand("clean", "cleans the project build settings", cleanCommand)
    }
    
    }.run()
// swiftlint:enable line_length
