//
//  Package.swift
//  TaskFlow
//
//

import PackageDescription

let package = Package(
	name: "TaskFlow",
	targets: [
		Target(name: "TaskFlow", dependencies: ["AtomicValue"]),
		Target(name: "AtomicValue", dependencies: []),
	]
)

