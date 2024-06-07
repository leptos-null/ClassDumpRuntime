// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ClassDumpRuntime",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .watchOS(.v4),
        .tvOS(.v12),
        .macCatalyst(.v13),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "ClassDumpRuntime",
            targets: ["ClassDumpRuntime"]
        ),
        .library(
            name: "ClassDumpRuntimeSwift",
            targets: ["ClassDumpRuntimeSwift"]
        ),
    ],
    targets: [
        .target(
            name: "ClassDumpRuntime"
        ),
        .target(
            name: "ClassDumpRuntimeSwift",
            dependencies: [
              "ClassDumpRuntime",
            ],
            path: "ClassDumpRuntimeSwift"
        ),
        .testTarget(
            name: "ClassDumpRuntimeTests",
            dependencies: ["ClassDumpRuntime"],
            path: "ClassDumpRuntimeTests"
        ),
    ]
)
