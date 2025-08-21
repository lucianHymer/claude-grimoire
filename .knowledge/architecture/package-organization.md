# Package-based Organization Structure

## Overview
The project uses a modular `packages/` directory structure where each system/tool is self-contained.

## Structure
Each package in `packages/` contains:
- **agents/** - Agent markdown files for specialized tasks
- **servers/** - MCP server implementations  
- **append-to-* files** - Configuration fragments to append during installation
- **README.md** - Package-specific documentation
- **install.sh** - Installation script (future)

## Benefits
- Self-contained systems
- Portable and reusable
- Independently versioned
- Clear separation of concerns

## Example
The `packages/chronicler/` directory demonstrates this pattern with its complete documentation system implementation.