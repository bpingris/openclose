package main

import "core:fmt"
import "core:os"

// Summary command handler
summary_cmd :: proc() {
	if !os.exists(".openclose") {
		fmt.println("No .openclose directory found. Run 'openclose init' first.")
		return
	}

	fmt.println("=== OpenClose Summary ===\n")

	all_specs := make([dynamic]Spec_Info)

	// Collect specs
	specs_dir := get_specs_dir()
	if os.exists(specs_dir) {
		collect_specs_recursive(specs_dir, &all_specs)
	}

	// Calculate totals
	total_specs := len(all_specs)
	done_specs := 0
	total_criteria := 0
	completed_criteria := 0

	for spec in all_specs {
		if spec.done {
			done_specs += 1
		}
		total_criteria += spec.total_criteria
		completed_criteria += spec.completed_criteria
	}

	// Print overall stats
	fmt.println("Overall Progress:")
	fmt.printfln("  Total Specs: %d", total_specs)
	fmt.printfln("  Completed Specs: %d", done_specs)

	if total_criteria > 0 {
		progress := f32(completed_criteria) / f32(total_criteria) * 100
		fmt.printfln(
			"  Total Criteria: %d/%d (%.1f%%)",
			completed_criteria,
			total_criteria,
			progress,
		)
	} else {
		fmt.println("  Total Criteria: 0/0")
	}

	// Print specs
	if len(all_specs) > 0 {
		fmt.println("\nSpecs:")
		for spec in all_specs {
			status := spec.done ? "DONE" : "WIP"
			if spec.total_criteria > 0 {
				progress := f32(spec.completed_criteria) / f32(spec.total_criteria) * 100
				fmt.printfln(
					"  [%s] %s - %d/%d tasks (%.0f%%)",
					status,
					spec.name,
					spec.completed_criteria,
					spec.total_criteria,
					progress,
				)

				// Show phases breakdown
				for phase in spec.phases {
					if phase.total_tasks > 0 {
						phase_progress := f32(phase.completed_tasks) / f32(phase.total_tasks) * 100
						fmt.printfln(
							"    %s: %d/%d (%.0f%%)",
							phase.name,
							phase.completed_tasks,
							phase.total_tasks,
							phase_progress,
						)
					}
				}
			} else {
				fmt.printfln("  [%s] %s - no tasks", status, spec.name)
			}
		}
	}

	fmt.println("")
}
