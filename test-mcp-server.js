#!/usr/bin/env node
const readline = require('readline');
const fs = require('fs');
const path = require('path');

// Helper to send JSON-RPC responses
function respond(id, result) {
    const response = { jsonrpc: '2.0', id, result };
    console.log(JSON.stringify(response));
}

function respondError(id, code, message) {
    const response = { jsonrpc: '2.0', id, error: { code, message } };
    console.log(JSON.stringify(response));
}

// The actual capture function
function captureKnowledge(args) {
    const { category, topic, details, files } = args;
    
    // Ensure knowledge directory exists
    const knowledgeDir = path.join(process.cwd(), '.knowledge');
    if (!fs.existsSync(knowledgeDir)) {
        fs.mkdirSync(knowledgeDir, { recursive: true });
    }
    
    const sessionFile = path.join(knowledgeDir, 'session.md');
    
    // Create session file header if it doesn't exist
    if (!fs.existsSync(sessionFile)) {
        const date = new Date().toISOString().split('T')[0];
        fs.writeFileSync(sessionFile, `# Knowledge Capture Session - ${date}\n\n`);
    }
    
    // Format the entry
    const time = new Date().toTimeString().slice(0, 5);
    let entry = `### [${time}] [${category}] ${topic}\n`;
    entry += `**Details**: ${details}\n`;
    if (files) {
        entry += `**Files**: ${files}\n`;
    }
    entry += `---\n\n`;
    
    // Atomic append
    fs.appendFileSync(sessionFile, entry);
    
    return `✓ Captured to .knowledge/session.md: [${category}] ${topic}`;
}

// Set up stdin reader for JSON-RPC
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
});

// Handle incoming JSON-RPC requests
rl.on('line', (line) => {
    try {
        const request = JSON.parse(line);
        
        if (request.method === 'initialize') {
            respond(request.id, {
                protocolVersion: '1.0',
                serverInfo: { name: 'knowledge-capture', version: '1.0.0' },
                capabilities: {
                    tools: { listChanged: false }
                }
            });
        } else if (request.method === 'tools/list') {
            respond(request.id, {
                tools: [{
                    name: 'capture_knowledge',
                    description: 'PROACTIVELY capture any learned information about the project - architecture, patterns, dependencies, workflows, configurations, or surprising behaviors. This builds automatic documentation.',
                    inputSchema: {
                        type: 'object',
                        properties: {
                            category: {
                                type: 'string',
                                enum: ['architecture', 'pattern', 'dependency', 'workflow', 'config', 'gotcha', 'convention'],
                                description: 'Type of knowledge being captured'
                            },
                            topic: {
                                type: 'string',
                                description: 'Brief topic/title of what was learned'
                            },
                            details: {
                                type: 'string',
                                description: 'The specific information learned'
                            },
                            files: {
                                type: 'string',
                                description: 'Related files/paths (optional)'
                            }
                        },
                        required: ['category', 'topic', 'details']
                    }
                }]
            });
        } else if (request.method === 'tools/call') {
            if (request.params.name === 'capture_knowledge') {
                try {
                    const result = captureKnowledge(request.params.arguments);
                    respond(request.id, {
                        content: [{ type: 'text', text: result }]
                    });
                } catch (error) {
                    respondError(request.id, -32603, `Capture failed: ${error.message}`);
                }
            } else {
                respondError(request.id, -32601, `Unknown tool: ${request.params.name}`);
            }
        } else if (request.method === 'shutdown') {
            respond(request.id, {});
            process.exit(0);
        } else {
            respondError(request.id, -32601, `Method not found: ${request.method}`);
        }
    } catch (error) {
        // Invalid JSON or other parsing errors
        console.error('Error processing request:', error);
    }
});

// Handle clean shutdown
process.on('SIGTERM', () => process.exit(0));
process.on('SIGINT', () => process.exit(0));