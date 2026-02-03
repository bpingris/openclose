package main

import "core:testing"

@(test)
test_slugify_simple :: proc(t: ^testing.T) {
	result := slugify("Hello World")
	testing.expect_value(t, result, "hello-world")
}

@(test)
test_slugify_with_underscores :: proc(t: ^testing.T) {
	result := slugify("hello_world_test")
	testing.expect_value(t, result, "hello-world-test")
}

@(test)
test_slugify_already_slugified :: proc(t: ^testing.T) {
	result := slugify("hello-world")
	testing.expect_value(t, result, "hello-world")
}

@(test)
test_slugify_mixed_case :: proc(t: ^testing.T) {
	result := slugify("UserAuthentication")
	testing.expect_value(t, result, "userauthentication")
}

@(test)
test_slugify_with_numbers :: proc(t: ^testing.T) {
	result := slugify("Test123Feature")
	testing.expect_value(t, result, "test123feature")
}

@(test)
test_slugify_multiple_spaces :: proc(t: ^testing.T) {
	result := slugify("Multiple   Spaces   Here")
	testing.expect_value(t, result, "multiple---spaces---here")
}
