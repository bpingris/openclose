package main

import "core:testing"

@(test)
test_slugify_simple :: proc(t: ^testing.T) {
	result := slugify("Hello World")
	defer delete(result)
	testing.expect_value(t, result, "hello-world")
}

@(test)
test_slugify_with_underscores :: proc(t: ^testing.T) {
	result := slugify("hello_world_test")
	defer delete(result)
	testing.expect_value(t, result, "hello-world-test")
}

@(test)
test_slugify_already_slugified :: proc(t: ^testing.T) {
	result := slugify("hello-world")
	defer delete(result)
	testing.expect_value(t, result, "hello-world")
}

@(test)
test_slugify_mixed_case :: proc(t: ^testing.T) {
	result := slugify("UserAuthentication")
	defer delete(result)
	testing.expect_value(t, result, "userauthentication")
}

@(test)
test_slugify_with_numbers :: proc(t: ^testing.T) {
	result := slugify("Test123Feature")
	defer delete(result)
	testing.expect_value(t, result, "test123feature")
}

@(test)
test_slugify_multiple_spaces :: proc(t: ^testing.T) {
	result := slugify("Multiple   Spaces   Here")
	defer delete(result)
	testing.expect_value(t, result, "multiple---spaces---here")
}

@(test)
test_normalize_spec_name_rejects_empty :: proc(t: ^testing.T) {
	_, ok := normalize_spec_name("   ")
	testing.expect(t, !ok)
}

@(test)
test_normalize_spec_name_rejects_separator_only :: proc(t: ^testing.T) {
	_, ok := normalize_spec_name(".. / __")
	testing.expect(t, !ok)
}

@(test)
test_normalize_spec_name_rejects_path_chars :: proc(t: ^testing.T) {
	_, ok := normalize_spec_name("../../outside-spec")
	testing.expect(t, !ok)
}

@(test)
test_is_safe_specs_subpath_valid :: proc(t: ^testing.T) {
	testing.expect(t, is_safe_specs_subpath("my-spec"))
	testing.expect(t, is_safe_specs_subpath("epic/my-spec"))
}

@(test)
test_is_safe_specs_subpath_rejects_traversal :: proc(t: ^testing.T) {
	testing.expect(t, !is_safe_specs_subpath("../secret"))
	testing.expect(t, !is_safe_specs_subpath("epic/../../secret"))
	testing.expect(t, !is_safe_specs_subpath("/absolute"))
	testing.expect(t, !is_safe_specs_subpath("spec/"))
	testing.expect(t, !is_safe_specs_subpath("spec//child"))
}
