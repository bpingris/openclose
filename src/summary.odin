package main

import "core:fmt"
import "core:os"
import "core:path/filepath"

// Summary command handler
summary_cmd :: proc() {
	if !os.exists(".openclose") {
		fmt.println("No .openclose directory found. Run 'openclose init' first.")
		return
	}
	
	fmt.println("=== OpenClose Summary ===\n")
	
	all_specs := make([dynamic]Spec_Info)
	all_epics := make([dynamic]Epic_Info)
	
	// Collect standalone specs
	specs_dir := get_specs_dir()
	if os.exists(specs_dir) {
		collect_specs_recursive(specs_dir, &all_specs)
	}
	
	// Collect epics and their specs
	epics_dir := get_epics_dir()
	if os.exists(epics_dir) {
		fd, err := os.open(epics_dir, os.O_RDONLY)
		if err == nil {
			defer os.close(fd)
			files, _ := os.read_dir(fd, 0)
			for f in files {
				if is_directory(f.mode) {
					epic_path := filepath.join({epics_dir, f.name})
					epic_info := collect_epic_info(epic_path, f.name)
					append(&all_epics, epic_info)
				}
			}
		}
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
	
	for epic in all_epics {
		total_specs += len(epic.specs)
		for spec in epic.specs {
			if spec.done {
				done_specs += 1
			}
		}
		total_criteria += epic.total_criteria
		completed_criteria += epic.completed_criteria
	}
	
	// Print overall stats
	fmt.println("Overall Progress:")
	fmt.printfln("  Total Specs: %d", total_specs)
	fmt.printfln("  Completed Specs: %d", done_specs)
	
	if total_criteria > 0 {
		progress := f32(completed_criteria) / f32(total_criteria) * 100
		fmt.printfln("  Total Criteria: %d/%d (%.1f%%)", completed_criteria, total_criteria, progress)
	} else {
		fmt.println("  Total Criteria: 0/0")
	}
	
	// Print standalone specs
	if len(all_specs) > 0 {
		fmt.println("\nStandalone Specs:")
		for spec in all_specs {
			status := spec.done ? "DONE" : "WIP"
			if spec.total_criteria > 0 {
				progress := f32(spec.completed_criteria) / f32(spec.total_criteria) * 100
				fmt.printfln("  [%s] %s - %d/%d tasks (%.0f%%)", status, spec.name, spec.completed_criteria, spec.total_criteria, progress)
				
				// Show phases breakdown
				for phase in spec.phases {
					if phase.total_tasks > 0 {
						phase_progress := f32(phase.completed_tasks) / f32(phase.total_tasks) * 100
						fmt.printfln("    %s: %d/%d (%.0f%%)", phase.name, phase.completed_tasks, phase.total_tasks, phase_progress)
					}
				}
			} else {
				fmt.printfln("  [%s] %s - no tasks", status, spec.name)
			}
		}
	}
	
	// Print epics
	if len(all_epics) > 0 {
		fmt.println("\nEpics:")
		for epic in all_epics {
			epic_done := 0
			for spec in epic.specs {
				if spec.done {
					epic_done += 1
				}
			}
			
			if epic.total_criteria > 0 {
				epic_progress := f32(epic.completed_criteria) / f32(epic.total_criteria) * 100
				fmt.printfln("\n  %s - %d/%d specs done, %d/%d tasks (%.1f%%)", 
					epic.name, epic_done, len(epic.specs), epic.completed_criteria, epic.total_criteria, epic_progress)
			} else {
				fmt.printfln("\n  %s - %d/%d specs done, no tasks", 
					epic.name, epic_done, len(epic.specs))
			}
			
			for spec in epic.specs {
				status := spec.done ? "DONE" : "WIP"
				if spec.total_criteria > 0 {
					progress := f32(spec.completed_criteria) / f32(spec.total_criteria) * 100
					fmt.printfln("    [%s] %s - %d/%d (%.0f%%)", status, spec.name, spec.completed_criteria, spec.total_criteria, progress)
					
					// Show phases breakdown
					for phase in spec.phases {
						if phase.total_tasks > 0 {
							phase_progress := f32(phase.completed_tasks) / f32(phase.total_tasks) * 100
							fmt.printfln("      %s: %d/%d (%.0f%%)", phase.name, phase.completed_tasks, phase.total_tasks, phase_progress)
						}
					}
				} else {
					fmt.printfln("    [%s] %s - no tasks", status, spec.name)
				}
			}
		}
	}
	
	fmt.println("")
}
