// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// This package will assume C / Objective-C interoperability as it's more common.
// C++ could be enabled with:
// swiftSettings: [.interoperabilityMode(.Cxx)]

// Swift target
private let name: String = "SPFKUtils"

// C/C++ target
private let nameC: String = "\(name)C"

private let platforms: [PackageDescription.SupportedPlatform]? = [
    .macOS(.v12)
]

private let products: [PackageDescription.Product] = [
    .library(
        name: name,
        targets: [name, nameC]
    )
]

private let dependencies: [PackageDescription.Package.Dependency] = [
    .package(name: "SPFKTesting", path: "../SPFKTesting"),
    // .package(url: "https://github.com/ryanfrancesconi/SPFKTesting", branch: "main"),
    
    .package(url: "https://github.com/orchetect/OTCore", branch: "main"),
    .package(url: "https://github.com/orchetect/OTAtomics", branch: "main"),
    .package(url: "https://github.com/tadija/AEXML", from: "4.6.0"),
    
]

private let targets: [PackageDescription.Target] = [
    // Swift
    .target(
        name: name,
        dependencies: [
            .target(name: nameC),
            .byNameItem(name: "SPFKTesting", condition: nil),

            .byNameItem(name: "OTCore", condition: nil),
            .byNameItem(name: "OTAtomics", condition: nil),
            .byNameItem(name: "AEXML", condition: nil)
        ]
    ),
    
    // C
    .target(
        name: nameC,
        dependencies: [],
        publicHeadersPath: "include",
        cSettings: [
            .headerSearchPath("include_private")
        ],
        cxxSettings: [
            .headerSearchPath("include_private")
        ]
    ),

    .testTarget(
        name: "\(name)Tests",
        dependencies: [
            .byNameItem(name: name, condition: nil),
            .byNameItem(name: nameC, condition: nil),
        ],
        resources: [
            .process("Resources")
        ]
    )
]

let package = Package(
    name: name,
    defaultLocalization: "en",
    platforms: platforms,
    products: products,
    dependencies: dependencies,
    targets: targets,
    cxxLanguageStandard: .cxx20
)
