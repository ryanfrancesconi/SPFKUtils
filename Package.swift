// swift-tools-version: 6.2.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let name: String = "SPFKUtils" // Swift target
private let dependencyNames: [String] = ["SPFKBase", "SPFKTesting"]
private let dependencyNamesC: [String] = []
private let dependencyBranch = "main"
private let useLocalDependencies: Bool = false
private let platforms: [PackageDescription.SupportedPlatform]? = [
    .macOS(.v12),
    .iOS(.v15)
]

let remoteDependencies: [RemoteDependency] = [
    .init(package: .package(url: "https://github.com/orchetect/OTAtomics", branch: "main"),
          product: .product(name: "OTAtomics", package: "OTAtomics")),
    .init(package: .package(url: "https://github.com/tadija/AEXML", from: "4.6.0"),
          product: .product(name: "AEXML", package: "AEXML")),
    .init(package: .package(url: "https://github.com/rnine/Checksum", branch: "master"),
          product: .product(name: "Checksum", package: "Checksum")),
    .init(package: .package(url: "https://github.com/jozefizso/swift-xattr", branch: "main"),
          product: .product(name: "XAttr", package: "swift-xattr"))
]

// MARK: - Reusable Code for a dual Swift + C package

struct RemoteDependency {
    let package: PackageDescription.Package.Dependency
    let product: PackageDescription.Target.Dependency
}

private let nameC: String = "\(name)C" // C/C++ target
private let nameTests: String = "\(name)Tests" // Test target
private let githubBase = "https://github.com/ryanfrancesconi"

private let products: [PackageDescription.Product] = [
    .library(name: name, targets: [name, nameC])
]

private var packageDependencies: [PackageDescription.Package.Dependency] {
    let local: [PackageDescription.Package.Dependency] =
        dependencyNames.map {
            .package(name: "\($0)", path: "../\($0)")
        }

    let remote: [PackageDescription.Package.Dependency] =
        dependencyNames.map {
            .package(url: "\(githubBase)/\($0)", branch: dependencyBranch)
        }

    var value = useLocalDependencies ? local : remote
    value.append(contentsOf: remoteDependencies.map { $0.package })
    return value
}

private var swiftTargetDependencies: [PackageDescription.Target.Dependency] {
    let names = dependencyNames.filter { $0 != "SPFKTesting" }

    var value: [PackageDescription.Target.Dependency] = names.map {
        .byNameItem(name: "\($0)", condition: nil)
    }

    value.append(.target(name: nameC))
    value.append(contentsOf: remoteDependencies.map { $0.product })
    return value
}

private let swiftTarget: PackageDescription.Target = .target(
    name: name,
    dependencies: swiftTargetDependencies,
    resources: nil
)

private var testTargetDependencies: [PackageDescription.Target.Dependency] {
    var array: [PackageDescription.Target.Dependency] = [
        .byNameItem(name: name, condition: nil),
        .byNameItem(name: nameC, condition: nil)
    ]

    if dependencyNames.contains("SPFKTesting") {
        array.append(.byNameItem(name: "SPFKTesting", condition: nil))
    }

    return array
}

private let testTarget: PackageDescription.Target = .testTarget(
    name: nameTests,
    dependencies: testTargetDependencies,
    resources: nil
)

private var cTargetDependencies: [PackageDescription.Target.Dependency] {
    dependencyNamesC.map {
        .byNameItem(name: "\($0)", condition: nil)
    }
}

private let cTarget: PackageDescription.Target = .target(
    name: nameC,
    dependencies: cTargetDependencies,
    publicHeadersPath: "include",
    cSettings: [
        .headerSearchPath("include_private")
    ],
    cxxSettings: [
        .headerSearchPath("include_private")
    ]
)

private let targets: [PackageDescription.Target] = [
    swiftTarget, cTarget, testTarget
]

let package = Package(
    name: name,
    defaultLocalization: "en",
    platforms: platforms,
    products: products,
    dependencies: packageDependencies,
    targets: targets,
    cxxLanguageStandard: .cxx20
)
