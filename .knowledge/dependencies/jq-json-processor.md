# jq - JSON Processor Dependency

## Overview
The chronicler-quicken script requires jq (JSON processor) to parse the stream-json output from Claude CLI.

## Usage
Used to extract:
- Text messages from `.message.content[0].text`
- Tool names from `.message.content[0].name`

## Installation
Most systems have jq pre-installed. If not available:
- Ubuntu/Debian: `apt-get install jq`
- macOS: `brew install jq`
- RHEL/CentOS: `yum install jq`

## Files Requiring jq
- `chronicler-quicken` - For parsing Claude's stream-json output