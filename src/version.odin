package main

import "core:fmt"

VERSION :: #config(VERSION, "unknown")

// Version command handler
version_cmd :: proc() {
	fmt.println(VERSION)
}
