# Knowledge Capture Session - 2025-08-21

### [15:25] [architecture] Test Architecture
**Details**: This is a test of the MCP server
**Files**: test.js
---

### [16:03] [architecture] MCP Server Architecture
**Details**: The chronicler uses a Node.js-based MCP server that communicates via JSON-RPC over stdio. It captures knowledge in .knowledge/session.md
**Files**: .claude/servers/chronicler.js
---

### [16:03] [pattern] JSON-RPC Communication Pattern
**Details**: All MCP servers use JSON-RPC 2.0 protocol with request/response pattern over stdin/stdout
**Files**: test-chronicler.js
---

### [16:03] [gotcha] Line buffering required
**Details**: MCP servers must handle line-buffered input - each JSON-RPC message must end with newline
---

### [16:04] [architecture] MCP Server Architecture
**Details**: The chronicler uses a Node.js-based MCP server that communicates via JSON-RPC over stdio. It captures knowledge in .knowledge/session.md
**Files**: .claude/servers/chronicler.js
---

### [16:08] [api-endpoints] Express Routes
**Details**: The app has two main endpoints: GET / for API info and GET /health for system status
**Files**: test-project/app.js
---

### [16:08] [database] MongoDB Configuration
**Details**: Uses Mongoose ODM to connect to MongoDB, connection string from MONGODB_URI env var
**Files**: test-project/app.js
---

