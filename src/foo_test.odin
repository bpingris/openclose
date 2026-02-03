package main
import "core:fmt"
import "core:testing"

@(test)
test_foo :: proc(t: ^testing.T) {
	result := foo()

	fmt.eprintln(result.specs_path)

	testing.expect_value(t, result.specs_path, "HELLO")
}
