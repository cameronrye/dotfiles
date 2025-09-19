# JetBrains IDEs Configuration

This directory contains configuration files and settings for JetBrains IDEs including IntelliJ IDEA, WebStorm, PyCharm, and Rider.

## Configuration Files

### Settings Repository
JetBrains IDEs support settings synchronization through a settings repository. You can sync your settings across different machines and IDEs.

### Manual Configuration
For manual configuration, copy the relevant files to your IDE's configuration directory:

#### macOS
- **IntelliJ IDEA**: `~/Library/Application Support/JetBrains/IntelliJIdea{version}/`
- **WebStorm**: `~/Library/Application Support/JetBrains/WebStorm{version}/`
- **PyCharm**: `~/Library/Application Support/JetBrains/PyCharm{version}/`
- **Rider**: `~/Library/Application Support/JetBrains/Rider{version}/`

#### Windows
- **IntelliJ IDEA**: `%APPDATA%\JetBrains\IntelliJIdea{version}\`
- **WebStorm**: `%APPDATA%\JetBrains\WebStorm{version}\`
- **PyCharm**: `%APPDATA%\JetBrains\PyCharm{version}\`
- **Rider**: `%APPDATA%\JetBrains\Rider{version}\`

#### Linux
- **IntelliJ IDEA**: `~/.config/JetBrains/IntelliJIdea{version}/`
- **WebStorm**: `~/.config/JetBrains/WebStorm{version}/`
- **PyCharm**: `~/.config/JetBrains/PyCharm{version}/`
- **Rider**: `~/.config/JetBrains/Rider{version}/`

## Recommended Settings

### General Settings
- **Theme**: Darcula or IntelliJ Light
- **Font**: JetBrains Mono, size 14
- **Line height**: 1.2
- **Tab size**: 2 spaces for web technologies, 4 for others
- **Auto-save**: Enable auto-save on focus loss
- **Code completion**: Case sensitive completion = First letter only

### Code Style
- **JavaScript/TypeScript**: 2 spaces, semicolons, single quotes
- **Python**: 4 spaces, PEP 8 compliant
- **C#**: 4 spaces, Microsoft conventions
- **HTML/CSS**: 2 spaces
- **JSON/YAML**: 2 spaces

### Plugins to Install

#### Essential Plugins
- **GitToolBox**: Enhanced Git integration
- **Rainbow Brackets**: Colorful bracket pairs
- **String Manipulation**: Text manipulation tools
- **Key Promoter X**: Learn keyboard shortcuts
- **IdeaVim**: Vim emulation (optional)
- **.ignore**: Support for .gitignore files
- **Prettier**: Code formatting
- **ESLint**: JavaScript linting

#### Language-Specific Plugins
- **Node.js**: Node.js integration
- **Python**: Python support (PyCharm has built-in)
- **Docker**: Docker integration
- **Database Tools**: Database support
- **Markdown**: Markdown support

#### Productivity Plugins
- **CodeGlance**: Minimap
- **Presentation Assistant**: Show keyboard shortcuts
- **Translation**: Translation plugin
- **Grep Console**: Console output filtering
- **Material Theme UI**: Material design theme

### Keymap Customizations
- **Duplicate Line**: Cmd+D (macOS) / Ctrl+D (Windows/Linux)
- **Delete Line**: Cmd+Shift+K (macOS) / Ctrl+Shift+K (Windows/Linux)
- **Move Line Up/Down**: Alt+Up/Down
- **Multiple Cursors**: Alt+Click
- **Select All Occurrences**: Cmd+Ctrl+G (macOS) / Ctrl+Alt+Shift+J (Windows/Linux)

### Live Templates
Create custom live templates for frequently used code patterns:
- `cl` → `console.log($END$);`
- `fn` → `function $NAME$($PARAMS$) { $END$ }`
- `af` → `const $NAME$ = ($PARAMS$) => { $END$ };`
- `tc` → `try { $SELECTION$ } catch (error) { $END$ }`

### File and Code Templates
Customize file templates for new files:
- JavaScript/TypeScript files with standard headers
- Python files with proper encoding and imports
- C# files with namespace and class structure

### Version Control Integration
- **Git**: Enable VCS integration
- **GitHub**: Configure GitHub integration
- **Commit**: Enable code analysis before commit
- **Changelists**: Use changelists for organizing changes

### Debugging Configuration
- **Breakpoints**: Configure exception breakpoints
- **Watches**: Set up useful watch expressions
- **Variables**: Configure variable display options

### External Tools
Configure external tools for:
- **Prettier**: Code formatting
- **ESLint**: Linting
- **Black**: Python formatting
- **dotnet format**: C# formatting

## Synchronization

### Settings Repository
1. Go to File → Manage IDE Settings → Settings Repository
2. Enter your repository URL (e.g., GitHub repository)
3. Choose "Overwrite Local" for first sync or "Merge" for subsequent syncs

### Export/Import Settings
1. Go to File → Manage IDE Settings → Export Settings
2. Select the settings you want to export
3. Save to a .zip file
4. Import on other machines using File → Manage IDE Settings → Import Settings

## Tips and Tricks

### Productivity Tips
- Use **Double Shift** for Search Everywhere
- **Cmd+Shift+A** (macOS) / **Ctrl+Shift+A** (Windows/Linux) for Find Action
- **Cmd+E** (macOS) / **Ctrl+E** (Windows/Linux) for Recent Files
- **Cmd+Shift+E** (macOS) / **Ctrl+Shift+E** (Windows/Linux) for Recent Locations
- Use **Bookmarks** (F11) to mark important locations
- **Cmd+B** (macOS) / **Ctrl+B** (Windows/Linux) to go to declaration
- **Cmd+Alt+B** (macOS) / **Ctrl+Alt+B** (Windows/Linux) to go to implementation

### Code Navigation
- **Cmd+F12** (macOS) / **Ctrl+F12** (Windows/Linux) for File Structure
- **Cmd+Shift+O** (macOS) / **Ctrl+Shift+N** (Windows/Linux) for Go to File
- **Cmd+Alt+O** (macOS) / **Ctrl+Alt+Shift+N** (Windows/Linux) for Go to Symbol
- **Cmd+U** (macOS) / **Ctrl+U** (Windows/Linux) for Go to Super Method

### Refactoring
- **F6** for Move
- **Shift+F6** for Rename
- **Cmd+Alt+M** (macOS) / **Ctrl+Alt+M** (Windows/Linux) for Extract Method
- **Cmd+Alt+V** (macOS) / **Ctrl+Alt+V** (Windows/Linux) for Extract Variable
- **Cmd+Alt+C** (macOS) / **Ctrl+Alt+C** (Windows/Linux) for Extract Constant

### Debugging
- **F8** for Step Over
- **F7** for Step Into
- **Shift+F8** for Step Out
- **F9** for Resume Program
- **Cmd+F8** (macOS) / **Ctrl+F8** (Windows/Linux) for Toggle Breakpoint

## Maintenance

### Regular Tasks
- Update plugins regularly
- Clean up unused live templates and file templates
- Review and update code style settings
- Backup settings before major IDE updates
- Clean IDE caches if experiencing issues (File → Invalidate Caches)

### Performance Optimization
- Increase IDE memory if working with large projects
- Exclude unnecessary directories from indexing
- Disable unused plugins
- Use Power Save Mode for better battery life on laptops
