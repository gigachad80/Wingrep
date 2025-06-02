# 🚀 Project Name : Wingrep

<p align="center">
  <img src="https://img.shields.io/badge/Maintained%3F-yes-pink.svg" alt="Maintenance">
  <a href="https://github.com/gigachad80/wingrep/issues">
    <img src="https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat" alt="Contributions Welcome">
  </a>
</p>

<p align="center">
  <strong>Windows utility combining Linux grep functionality with anew-like merge capabilities</strong>
</p>

---

## 📌 Overview

**WinGrep** is your essential command-line text search utility designed specifically for Windows environments. While Linux users enjoy powerful tools like `grep` and `anew`, Windows users often struggle with limited native text processing capabilities. WinGrep bridges this gap by combining the familiar grep functionality with anew-like merge capabilities, all optimized for Windows workflows.

Whether you're analyzing logs, processing bug bounty data, or filtering large text files, WinGrep provides pattern matching, regex support, and unique line collection in one lightweight executable. Simply search your patterns, collect unique results, and streamline your text processing tasks without juggling multiple tools or complex PowerShell syntax.

### 🤔 Why This Name?

**Win** (Windows) + **Grep** (Global Regular Expression Print) = **WinGrep**

---

## 📚 Requirements & Dependencies

- **Windows 7.0 or later**
- No additional dependencies required

---

<p align="center">

## ⚡ Installation

</p>

### If you have Git installed :
1. Git clone this repo 
```
git clone https://github.com/gigachad80/wingrep
```
2. Now build Go executable : 

```
go build -o wingrep.exe
```
3. Run Powershell ISE as administrator and Go to the direcctory where you have cloned the repo then run this command :

```
.\install-wingrep.ps1
```

### If you haven't Git installed . 

1. Go to releases section and download the exe file as per your architecture. 

2. Now , Run Powershell ISE as administrator and Go to the direcctory where you have cloned the repo then run this command .

```
.\install-wingrep.ps1
```

## 🔧 Features & Command Options

### Core Features

- ✅ **Linux grep compatibility** - Works with pipes just like Linux grep  
- ✅ **Case-sensitive and case-insensitive search**
- ✅ **Line numbers support**
- ✅ **Multiple file support**
- ✅ **Regex support** (extended regex with `-E`)
- ✅ **Invert matching** (show non-matching lines)
- ✅ **Stdin support** - Reads from stdin when no files specified
- ✅ **Windows native** - Works in Command Prompt and PowerShell
- ✅ **Anew-like merge mode** - Append unique lines to files

### Comparison with Linux grep and anew

| Feature | Linux grep | anew | wingrep |
|---------|------------|------|--------|
| Pattern matching | ✅ | ❌ | ✅ |
| Case insensitive | ✅ | ❌ | ✅ |
| Line numbers | ✅ | ❌ | ✅ |
| Regex support | ✅ | ❌ | ✅ |
| Unique line dedup | ❌ | ✅ | ✅ |
| Append to file | ❌ | ✅ | ✅ |
| Windows native | ❌ | ❌ | ✅ |
| Stdin support | ✅ | ✅ | ✅ |

---
### Command Options

| Option | Description |
|--------|-------------|
| `-i` | Ignore case |
| `-n` | Show line numbers |
| `-v` | Invert match (show non-matching lines) |
| `-E` | Use extended regex |
| `-m <file>` | **Merge mode**: append unique matching lines to file (anew-like) |
| `-q` | **Quiet mode**: don't print to stdout when using merge mode |
| `-d` | **Dry run**: show what would be added without writing to file |
| `-h` | Show help |

---

## 📖 Usage Examples

### Basic Grep Operations

```cmd
# Search for "error" in a file
wingrep "error" logfile.txt

# Search ignoring case
wingrep -i "ERROR" logfile.txt

# Show line numbers
wingrep -n "function" code.js

# Use with pipe (like Linux)
type file.txt | wingrep "pattern"
cat file.txt | wingrep "pattern"

# Multiple files
wingrep "TODO" *.js *.go *.py

# Invert match (show lines that DON'T contain pattern)
wingrep -v "comment" code.js

# Use regex patterns
wingrep -E "^[0-9]+" numbers.txt
```

### Windows Command Equivalents

```cmd
# Instead of Linux: cat file.txt | grep "pattern"
# Use: type file.txt | wingrep "pattern" ( CMD.exe )
# Or: cat file.txt | wingrep "pattern" (if you have cat via Git Bash)

# Find errors in log files
wingrep -i "error" *.log

# Find function definitions in code
wingrep -n "function\|def\|func" *.js *.py *.go

# Find IP addresses (regex)
wingrep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" access.log

# Search in piped output
dir | wingrep ".txt"
netstat -an | wingrep ":80"
```

### New! Anew-like Merge Mode

The `-m` flag enables anew-like functionality, allowing you to append unique matching lines to a file while avoiding duplicates.

```cmd
# Basic merge - append unique matching lines to output.txt
cat input.txt | wingrep -m output.txt "pattern" ( Powershell ) 

# Collect unique error messages from multiple log files
wingrep -i -m unique-errors.txt "error" *.log

# Quiet mode - don't print to stdout, just append to file
wingrep -m domains.txt -q "\.com" urls.txt

# Dry run - see what would be added without writing
wingrep -m results.txt -d "TODO" *.go

# Combine with other flags
wingrep -i -n -m matches.txt "function" *.js
```

### Merge Mode Behavior

- **Deduplication**: Only lines that don't already exist in the target file are appended
- **Stdout output**: New unique lines are printed to stdout (unless `-q` is used)
- **File creation**: Target file is created if it doesn't exist
- **Preserves order**: Lines are appended in the order they're found

---

## 🔥 Real-World Use Cases

### Security Analysis
```cmd
# Collect unique failed login attempts
wingrep -i -m failed-logins.txt "failed.*login" *.log

# Find unique suspicious IPs
wingrep -E "blocked.*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" -m suspicious-ips.txt security.log
```

### Development Workflow
```cmd
# Collect all TODO items across project
wingrep -i -m todos.txt "todo\|fixme\|hack" *.js *.py *.go

# Find unique API endpoints
wingrep -E "GET|POST|PUT|DELETE.*/" -m endpoints.txt *.log

# Gather unique error patterns
wingrep -E "Exception|Error.*:" -m errors.txt *.log
```

### Log Analysis
```cmd
# Collect unique error codes from web server logs
wingrep -E "HTTP [4-5][0-9][0-9]" -m http-errors.txt access.log

# Find unique database errors
wingrep -i -m db-errors.txt "database.*error\|connection.*failed" *.log

# Gather unique user agents
wingrep -E "User-Agent: .*" -m user-agents.txt access.log
```

---

<p align="center">

## 🏆 WinGrep vs PowerShell Comparison

</p>

### 🤡 PowerShell vs 🗿 WinGrep: The Battle of Text Processing

| **Task** | **PowerShell 🤡** | **WinGrep 🗿** | **Winner** |
|----------|-------------------|----------------|------------|
| **Basic Pattern Search** | `Select-String "pattern" file.txt` | `wingrep "pattern" file.txt` | 🗿 **Shorter syntax** |
| **Case Insensitive Search** | `Select-String -Pattern "pattern" -CaseSensitive:$false file.txt` | `wingrep -i "pattern" file.txt` | 🗿 **Much simpler** |
| **Show Line Numbers** | `Select-String "pattern" file.txt \| Select-Object LineNumber,Line` | `wingrep -n "pattern" file.txt` | 🗿 **One flag vs pipeline** |
| **Invert Match** | `Get-Content file.txt \| Where-Object {$_ -notmatch "pattern"}` | `wingrep -v "pattern" file.txt` | 🗿 **Direct flag** |
| **Regex Search** | `Select-String -Pattern "^[0-9]+" file.txt` | `wingrep -E "^[0-9]+" file.txt` | 🗿 **Simpler flag** |
| **Multiple Files** | `Select-String "pattern" *.txt \| Format-Table` | `wingrep "pattern" *.txt` | 🗿 **Native support** |

### 📊 Advanced Operations Comparison

| **Operation** | **PowerShell 🤡** | **WinGrep 🗿** | **Complexity** |
|---------------|-------------------|----------------|----------------|
| **Search + Get Unique Lines** | `Select-String "ERROR" *.log \| Select-Object -Property Line -Unique \| Out-File unique.txt` | `wingrep -m unique.txt "ERROR" *.log` | **PS: 3 cmdlets** vs **WG: 1 flag** |
| **Case Insensitive + Line Numbers + Multiple Files** | `Select-String -Pattern "error" -CaseSensitive:$false *.log \| Select-Object Filename,LineNumber,Line` | `wingrep -i -n "error" *.log` | **PS: Complex pipeline** vs **WG: 2 flags** |
| **Regex + Invert + Unique Collection** | `Get-Content *.txt \| Where-Object {$_ -notmatch "^#"} \| Sort-Object -Unique \| Out-File result.txt` | `wingrep -E -v -m result.txt "^#" *.txt` | **PS: 4 cmdlets** vs **WG: 3 flags** |
| **Dry Run Preview** | `$results = Get-Content file.txt \| Where-Object {...}; Write-Host "Would add $($results.Count) lines"` | `wingrep -d -m output.txt "pattern" file.txt` | **PS: Custom scripting** vs **WG: Built-in flag** |

### 🔥 Real-World Scenarios

#### Scenario 1: Log Analysis
**Task:** Find all ERROR lines from multiple log files, get unique ones, save to file

| **PowerShell 🤡** | **WinGrep 🗿** |
|-------------------|----------------|
| ```$errors = Select-String "ERROR" *.log<br>$unique = $errors \| Select-Object -Property Line -Unique<br>$unique \| Out-File -FilePath errors.txt``` | ```bash<br>wingrep -m errors.txt "ERROR" *.log<br>``` |
| **3 lines, 3 variables** | **1 line, done** |

#### Scenario 2: URL Collection (Bug Bounty)
**Task:** Extract unique URLs containing "api" from multiple files, case insensitive

| **PowerShell 🤡** | **WinGrep 🗿** |
|-------------------|----------------|
| ```$urls = Select-String -Pattern "api" -CaseSensitive:$false *.txt<br>$unique_urls = $urls \| Select-Object -Property Line -Unique<br>$unique_urls \| Out-File -FilePath api_urls.txt -Append<br>``` | ```bash<br>wingrep -i -m api_urls.txt "api" *.txt<br>``` |
| **3 commands, pipeline hell** | **1 command, clean** |

#### Scenario 3: Configuration File Processing
**Task:** Find lines NOT starting with #, show line numbers, case insensitive

| **PowerShell 🤡** | **WinGrep 🗿** |
|-------------------|----------------|
| ```Get-Content config.txt \| <br>  ForEach-Object -Begin {$i=0} -Process {<br>    $i++; if($_ -notmatch "^#") {<br>      Write-Output "$i`:$_"<br>    }<br>  }<br>``` | ```bash<br>wingrep -v -n "^#" config.txt<br>``` |
| **Complex loop + logic** | **2 flags, simple** |

### 🚀 Performance & Memory Comparison

| **Aspect** | **PowerShell 🤡** | **WinGrep 🗿** |
|------------|-------------------|----------------|
| **Startup Time** | ~2-3 seconds (PowerShell initialization) | ~50ms (native binary) |
| **Memory Usage** | ~50-100MB (PowerShell runtime) | ~5-10MB (Go binary) |
| **Large Files** | Can crash with Out-of-Memory | Streams data efficiently |
| **Pipeline Overhead** | Each `\|` creates new process | Single process handles all |

### 💀 PowerShell Pain Points vs WinGrep Solutions

| **PowerShell Problems 🤡** | **WinGrep Solutions 🗿** |
|----------------------------|-------------------------|
| Verbose syntax: `Select-String -Pattern "x" -CaseSensitive:$false` | Concise: `wingrep -i "x"` |
| Pipeline complexity: `cmd1 \| cmd2 \| cmd3` | Single command with flags |
| No built-in unique merge | Native `-m` flag (anew-like) |
| Memory hungry for large files | Efficient streaming |
| Slow startup due to .NET initialization | Instant startup (native binary) |
| Complex object manipulation required | Direct text processing |
| No dry-run capabilities | Built-in `-d` flag |
| Escaping hell with special characters | Simple pattern matching |

### 🏆 Why WinGrep Wins

#### ✅ **Simplicity**
- **PowerShell:** `Select-String -Pattern "ERROR" -CaseSensitive:$false *.log | Select-Object -Property Line -Unique | Out-File errors.txt`
- **WinGrep:** `wingrep -i -m errors.txt "ERROR" *.log`

#### ✅ **Performance**
- Native Go binary vs PowerShell's .NET overhead
- Single process vs multiple pipeline processes
- Memory efficient streaming vs object-heavy processing

#### ✅ **Features**
- Built-in unique line collection (like `anew`)
- Dry-run capabilities
- Simple flag-based interface
- Cross-architecture support (amd64, arm64, 386)

#### ✅ **User Experience**
- Familiar grep syntax for Unix users
- No PowerShell knowledge required
- Portable single executable
- Consistent behavior across Windows versions

### 🎯 Bottom Line

**PowerShell 🤡:** "Let me write🤓☝️ a complex pipeline with multiple cmdlets, object manipulation, and pray it doesn't run out of memory..."

**WinGrep 🗿:** "One command, few flags, job done. Next!"

**WinGrep makes you feel like a text processing ninja 🥷, while PowerShell makes you feel like you're debugging someone else's spaghetti code 🍝**

---

<p align="center">

## 📊 Feature Comparison Table

</p>


## 🛠️ Advanced Usage

### Flag Combinations Summary

| Command | Description |
|---------|-------------|
| `wingrep "pattern"` | Basic search |
| `wingrep -i "pattern"` | Case-insensitive |
| `wingrep -n "pattern"` | Show line numbers |
| `wingrep -v "pattern"` | Invert match |
| `wingrep -E "pattern"` | Use regex |
| `wingrep -m file "pattern"` | Merge unique matches to file |
| `wingrep -i -n "pattern"` | Case-insensitive + line numbers |
| `wingrep -v -n "pattern"` | Invert + line numbers |
| `wingrep -E -i "pattern"` | Regex + case-insensitive |
| `wingrep -m file -q "pattern"` | Merge quietly (no stdout) |
| `wingrep -m file -d "pattern"` | Dry run merge |

### Combining with Other Windows Commands

```cmd
# Find files containing pattern
dir /b *.txt | wingrep "sample"

# Find running processes
tasklist | wingrep -i "chrome"

# Find network connections
netstat -an | wingrep ":80"

# Merge unique results from multiple commands
tasklist | wingrep -m processes.txt "chrome"
netstat -an | wingrep -m connections.txt ":80"
```

### Practical Merge Examples

```cmd
# Collect unique URLs from multiple files
wingrep -E "https?://[^\s]+" -m all-urls.txt *.html *.txt

# Gather unique error codes
wingrep -E "HTTP [4-5][0-9][0-9]" -m error-codes.txt access.log

# Collect unique IP addresses
wingrep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" -m ips.txt *.log

# Find unique function names across codebase
wingrep -E "function\s+\w+" -m functions.txt *.js
```

---

## 🧪 Sample Data & Examples

### Sample Files Setup

**sample.txt**
```
Error: Database connection failed
INFO: Application started successfully
Warning: Low disk space detected
ERROR: Authentication failed for user john
Debug: Processing request #12345
Info: User login successful
error: File not found
```

**code.js**
```javascript
function calculateTotal() {
    console.log("Starting calculation");
    return total;
}

// TODO: Add error handling
var result = calculateTotal();
function processData() {
    // Handle data processing
}
```

### Example Commands and Outputs

```cmd
# Case-insensitive search with line numbers
C:\> type sample.txt | wingrep -i -n "error" ( CMD.exe )
1:Error: Database connection failed
4:ERROR: Authentication failed for user john
7:error: File not found

# Find functions in code files
C:\> wingrep -n "function" code.js
1:function calculateTotal() {
7:function processData() {

# Invert match - show non-error lines
C:\> type sample.txt | wingrep -v -i "error" ( CMD.exe )
INFO: Application started successfully
Warning: Low disk space detected
Debug: Processing request #12345
Info: User login successful

# Regex: find lines starting with numbers
C:\> type log.txt | wingrep -E "^[0-9]" ( CMD.exe )
2024-01-15 10:30:25 [INFO] Server started
2024-01-15 10:31:12 [ERROR] Database timeout

# Merge mode: collect unique errors
C:\> wingrep -i -m errors.txt "error" *.log
ERROR: Database timeout
ERROR: Failed to save data
(these lines are also appended to errors.txt)
```

---

## 📋 Tips and Best Practices

1. **Use merge mode for collecting unique data** across multiple files
2. **Combine flags** for powerful filtering: `-i -n -m results.txt`
3. **Use dry run mode** (`-d`) to preview what would be added
4. **Quiet mode** (`-q`) is perfect for silent data collection
5. **Regex mode** (`-E`) enables powerful pattern matching
6. **Remember**: wingrep uses `type` instead of `cat` on Windows

---

## 🙃 Why I Created This

I created WinGrep to have a single, convenient tool for text processing without PowerShell's verbose cmdlets or complex terminal setups. Instead of remembering `Select-String -Pattern "error" -CaseSensitive:$false *.log | Select-Object -Property Line -Unique | Out-File results.txt` for simple pattern matching, I wanted familiar grep-style commands like `wingrep -i -m results.txt "error" *.log` that just work.

I don't want to write bloated PS commands, and as an avid Linux user, I prefer simple grep-like syntax. I know WSL exists, and terminal emulators like Tabby (which I personally use) work great, but why change shells when you can simply open PS or CMD and run the command?

---

## ⌚ Development Stats

**Total Time taken to develop & test:** 4 hour 5 min

---

## 💓 Credits

- [@tomnomnom](https://github.com/tomnomnom) for creating anew for inspiration

---

## 📞 Contact

📧 Email: pookielinuxuser@tutamail.com

---

## 📄 License

Licensed under **GNU Affero General Public License 3.0**

---

<p align="center">
  <strong>Need help?</strong> Run <code>wingrep -h</code> for quick reference or check the examples above!
</p>

<p align="center">
  🕒 Last Updated: June 2, 2025
</p>
