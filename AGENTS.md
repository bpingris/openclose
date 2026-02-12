# Project overview

A CLI tool to create specifications files under .openclose directory that should be used by model agent like opencode.

## Language

The tool is written in Odin exclusively.

There are templates for PRD, tasks and scenarios written as markdown files that are embeded into the CLI.

## Run the project

      odin run ./src -- <command> <args>

## Test the project

      task test

to test a specific function:

      task test -- -define:ODIN_TEST_NAMES=package.function
