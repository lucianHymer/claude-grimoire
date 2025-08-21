#!/usr/bin/env node
const { spawn } = require('child_process');

// Spawn the MCP server
const server = spawn('node', ['test-mcp-server.js']);

let responses = [];

// Capture server output
server.stdout.on('data', (data) => {
    const lines = data.toString().trim().split('\n');
    lines.forEach(line => {
        if (line) {
            try {
                const response = JSON.parse(line);
                console.log('Response:', JSON.stringify(response, null, 2));
                responses.push(response);
            } catch (e) {
                console.log('Non-JSON output:', line);
            }
        }
    });
});

server.stderr.on('data', (data) => {
    console.error('Server error:', data.toString());
});

// Test sequence
const tests = [
    // Test 1: Initialize
    {
        jsonrpc: '2.0',
        id: 1,
        method: 'initialize',
        params: {}
    },
    // Test 2: List tools
    {
        jsonrpc: '2.0',
        id: 2,
        method: 'tools/list',
        params: {}
    },
    // Test 3: Call the tool
    {
        jsonrpc: '2.0',
        id: 3,
        method: 'tools/call',
        params: {
            name: 'capture_knowledge',
            arguments: {
                category: 'architecture',
                topic: 'Test Architecture',
                details: 'This is a test of the MCP server',
                files: 'test.js'
            }
        }
    },
    // Test 4: Call with invalid tool name
    {
        jsonrpc: '2.0',
        id: 4,
        method: 'tools/call',
        params: {
            name: 'invalid_tool',
            arguments: {}
        }
    },
    // Test 5: Invalid method
    {
        jsonrpc: '2.0',
        id: 5,
        method: 'invalid/method',
        params: {}
    },
    // Test 6: Shutdown
    {
        jsonrpc: '2.0',
        id: 6,
        method: 'shutdown',
        params: {}
    }
];

// Send tests with delay
let index = 0;
const sendTest = () => {
    if (index < tests.length) {
        const test = tests[index];
        console.log(`\n--- Test ${index + 1}: ${test.method} ---`);
        console.log('Request:', JSON.stringify(test, null, 2));
        server.stdin.write(JSON.stringify(test) + '\n');
        index++;
        setTimeout(sendTest, 100);
    } else {
        setTimeout(() => {
            console.log('\n--- Test Summary ---');
            console.log(`Sent ${tests.length} requests, received ${responses.length} responses`);
            
            // Check if session file was created
            const fs = require('fs');
            if (fs.existsSync('.knowledge/session.md')) {
                console.log('\n--- Session file contents ---');
                console.log(fs.readFileSync('.knowledge/session.md', 'utf8'));
            }
            
            process.exit(0);
        }, 500);
    }
};

// Start tests after server initializes
setTimeout(sendTest, 100);

server.on('close', (code) => {
    console.log(`Server exited with code ${code}`);
});