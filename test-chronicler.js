#!/usr/bin/env node

// Test script to verify the chronicler MCP server works
const { spawn } = require('child_process');

// Start the MCP server
const server = spawn('node', ['.claude/servers/chronicler.js']);

let requestId = 1;

// Helper to send JSON-RPC request
function sendRequest(method, params = {}) {
    const request = {
        jsonrpc: '2.0',
        id: requestId++,
        method,
        params
    };
    console.log('→ Sending:', JSON.stringify(request, null, 2));
    server.stdin.write(JSON.stringify(request) + '\n');
}

// Handle server output
server.stdout.on('data', (data) => {
    const lines = data.toString().split('\n').filter(line => line);
    lines.forEach(line => {
        try {
            const response = JSON.parse(line);
            console.log('← Response:', JSON.stringify(response, null, 2));
        } catch (e) {
            console.log('← Raw output:', line);
        }
    });
});

server.stderr.on('data', (data) => {
    console.error('Server error:', data.toString());
});

// Test sequence
async function runTests() {
    console.log('=== Testing Chronicler MCP Server ===\n');
    
    // Initialize
    sendRequest('initialize');
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // List tools
    sendRequest('tools/list');
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Test gather_knowledge calls
    console.log('\n=== Testing knowledge gathering ===\n');
    
    // Test 1: Architecture discovery
    sendRequest('tools/call', {
        name: 'gather_knowledge',
        arguments: {
            category: 'architecture',
            topic: 'MCP Server Architecture',
            details: 'The chronicler uses a Node.js-based MCP server that communicates via JSON-RPC over stdio. It captures knowledge in .knowledge/session.md',
            files: '.claude/servers/chronicler.js'
        }
    });
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Test 2: Pattern discovery
    sendRequest('tools/call', {
        name: 'gather_knowledge',
        arguments: {
            category: 'pattern',
            topic: 'JSON-RPC Communication Pattern',
            details: 'All MCP servers use JSON-RPC 2.0 protocol with request/response pattern over stdin/stdout',
            files: 'test-chronicler.js'
        }
    });
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Test 3: Gotcha
    sendRequest('tools/call', {
        name: 'gather_knowledge',
        arguments: {
            category: 'gotcha',
            topic: 'Line buffering required',
            details: 'MCP servers must handle line-buffered input - each JSON-RPC message must end with newline'
        }
    });
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Shutdown
    console.log('\n=== Shutting down ===\n');
    sendRequest('shutdown');
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Check the output file
    const fs = require('fs');
    if (fs.existsSync('.knowledge/session.md')) {
        console.log('\n=== Contents of .knowledge/session.md ===\n');
        console.log(fs.readFileSync('.knowledge/session.md', 'utf8'));
    }
    
    process.exit(0);
}

// Run tests after a brief startup delay
setTimeout(runTests, 1000);