package main

import "core:strings"

Foo :: struct {
	specs_path: string,
}

foo :: proc() -> Foo {
	f := Foo {
		specs_path = "",
	}

	a := strings.to_upper("hello")

	f.specs_path = a

	return f
}
