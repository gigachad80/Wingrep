package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"os"
	"regexp"
	"strings"
)

func main() {
	// Command line flags
	var (
		ignoreCase = flag.Bool("i", false, "ignore case")
		lineNumber = flag.Bool("n", false, "show line numbers")
		invert     = flag.Bool("v", false, "invert match (show non-matching lines)")
		regex      = flag.Bool("E", false, "use extended regex")
		merge      = flag.String("m", "", "merge mode: append unique matching lines to specified file (anew-like)")
		quiet      = flag.Bool("q", false, "quiet mode: don't print to stdout when using merge mode")
		dryRun     = flag.Bool("d", false, "dry run: show what would be added without actually writing to file")
		help       = flag.Bool("h", false, "show help")
	)
	flag.Parse()

	if *help {
		showHelp()
		return
	}

	args := flag.Args()
	if len(args) == 0 {
		fmt.Fprintf(os.Stderr, "Usage: wingrep [options] pattern [file...]\n")
		fmt.Fprintf(os.Stderr, "Use -h for help\n")
		os.Exit(1)
	}

	pattern := args[0]
	files := args[1:]

	// Compile regex pattern
	var re *regexp.Regexp
	var err error

	if *regex {
		if *ignoreCase {
			re, err = regexp.Compile("(?i)" + pattern)
		} else {
			re, err = regexp.Compile(pattern)
		}
	} else {
		// Simple string matching
		if *ignoreCase {
			pattern = strings.ToLower(pattern)
		}
	}

	if err != nil {
		fmt.Fprintf(os.Stderr, "Error compiling pattern: %v\n", err)
		os.Exit(1)
	}

	// Load existing lines from merge file if merge mode is enabled
	var existingLines map[string]bool
	var mergeFile *os.File
	if *merge != "" {
		existingLines = loadExistingLines(*merge)
		if !*dryRun {
			mergeFile, err = os.OpenFile(*merge, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
			if err != nil {
				fmt.Fprintf(os.Stderr, "Error opening merge file %s: %v\n", *merge, err)
				os.Exit(1)
			}
			defer mergeFile.Close()
		}
	}

	// If no files specified, read from stdin
	if len(files) == 0 {
		grepReader(os.Stdin, "", pattern, re, *ignoreCase, *lineNumber, *invert, *regex, existingLines, mergeFile, *quiet, *dryRun)
		return
	}

	// Process each file
	for _, filename := range files {
		file, err := os.Open(filename)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error opening %s: %v\n", filename, err)
			continue
		}

		showFilename := len(files) > 1
		grepReader(file, filename, pattern, re, *ignoreCase, *lineNumber, *invert, *regex, existingLines, mergeFile, *quiet, *dryRun, showFilename)
		file.Close()
	}
}

func loadExistingLines(filename string) map[string]bool {
	existingLines := make(map[string]bool)

	file, err := os.Open(filename)
	if err != nil {
		return existingLines
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line != "" {
			existingLines[line] = true
		}
	}

	return existingLines
}

func grepReader(reader io.Reader, filename, pattern string, re *regexp.Regexp, ignoreCase, showLineNum, invert, useRegex bool, existingLines map[string]bool, mergeFile *os.File, quiet, dryRun bool, showFilename ...bool) {
	scanner := bufio.NewScanner(reader)
	lineNum := 0
	showFile := len(showFilename) > 0 && showFilename[0]
	mergeMode := existingLines != nil

	for scanner.Scan() {
		lineNum++
		line := scanner.Text()

		var matches bool
		if useRegex {
			matches = re.MatchString(line)
		} else {
			searchLine := line
			searchPattern := pattern
			if ignoreCase {
				searchLine = strings.ToLower(line)
				searchPattern = strings.ToLower(pattern)
			}
			matches = strings.Contains(searchLine, searchPattern)
		}

		// Invert logic if needed
		if invert {
			matches = !matches
		}

		if matches {
			output := ""
			actualLine := line

			// Build output string for display
			if showFile {
				output += filename + ":"
			}

			if showLineNum {
				output += fmt.Sprintf("%d:", lineNum)
			}

			output += line

			if mergeMode {
				// In merge mode, check if line is unique
				trimmedLine := strings.TrimSpace(line)
				if trimmedLine != "" && !existingLines[trimmedLine] {
					// This is a new unique line
					existingLines[trimmedLine] = true

					if !dryRun {
						// Write to merge file
						if _, err := fmt.Fprintln(mergeFile, trimmedLine); err != nil {
							fmt.Fprintf(os.Stderr, "Error writing to merge file: %v\n", err)
						}
					}

					if !quiet {
						// Print to stdout (either the original line or formatted output based on flags)
						if showFile || showLineNum {
							fmt.Println(output)
						} else {
							fmt.Println(actualLine)
						}
					}

					if dryRun {
						fmt.Fprintf(os.Stderr, "[DRY RUN] Would add: %s\n", trimmedLine)
					}
				}
				// If line already exists, don't print anything (anew behavior)
			} else {
				// Normal grep mode
				fmt.Println(output)
			}
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "Error reading: %v\n", err)
	}
}

func showHelp() {
	fmt.Println("wingrep - Simple grep utility for Windows with anew-like merge functionality")
	fmt.Println()
	fmt.Println("USAGE:")
	fmt.Println("  wingrep [options] pattern [file...]")
	fmt.Println("  cat file.txt | wingrep pattern")
	fmt.Println("  cat file.txt | wingrep -m output.txt pattern")
	fmt.Println()
	fmt.Println("OPTIONS:")
	fmt.Println("  -i         ignore case")
	fmt.Println("  -n         show line numbers")
	fmt.Println("  -v         invert match (show lines that don't match)")
	fmt.Println("  -E         use extended regex")
	fmt.Println("  -m <file>  merge mode: append unique matching lines to file (anew-like)")
	fmt.Println("  -q         quiet mode: don't print to stdout when using merge mode")
	fmt.Println("  -d         dry run: show what would be added without writing to file")
	fmt.Println("  -h         show this help")
	fmt.Println()
	fmt.Println("EXAMPLES:")
	fmt.Println("  wingrep \"hello\" file.txt")
	fmt.Println("  wingrep -i \"HELLO\" file.txt")
	fmt.Println("  wingrep -n \"error\" *.log")
	fmt.Println("  type file.txt | wingrep \"pattern\"")
	fmt.Println("  cat file.txt | wingrep \"pattern\"")
	fmt.Println("  wingrep -E \"^[0-9]+\" data.txt")
	fmt.Println()
	fmt.Println("MERGE MODE (anew-like functionality):")
	fmt.Println("  cat input.txt | wingrep -m output.txt \"pattern\"")
	fmt.Println("  wingrep -m unique.txt -q \"error\" logs/*.txt")
	fmt.Println("  wingrep -m results.txt -d \"TODO\" *.go  # dry run")
}
