// browser-lsp.js - Add this to your HTML editor
// This runs entirely in the browser without needing a server

class BrowserRobloxLSP {
    constructor() {
        this.robloxAPI = this.loadRobloxAPI();
        this.diagnosticsEnabled = true;
    }

    // Load Roblox API definitions (subset for demonstration)
    loadRobloxAPI() {
        return {
            services: ['Players', 'Workspace', 'ReplicatedStorage', 'ServerStorage', 'StarterGui', 'TweenService', 'RunService', 'UserInputService', 'DataStoreService'],
            classes: {
                'Part': {
                    properties: ['Position', 'Size', 'CFrame', 'Anchored', 'CanCollide', 'Transparency', 'Color', 'Material'],
                    methods: ['Clone', 'Destroy', 'GetMass', 'BreakJoints'],
                    events: ['Touched', 'TouchEnded']
                },
                'Humanoid': {
                    properties: ['Health', 'MaxHealth', 'WalkSpeed', 'JumpPower', 'DisplayName'],
                    methods: ['TakeDamage', 'MoveTo', 'LoadAnimation'],
                    events: ['Died', 'HealthChanged', 'StateChanged']
                },
                'Player': {
                    properties: ['Name', 'UserId', 'DisplayName', 'Character', 'Team'],
                    methods: ['LoadCharacter', 'Kick'],
                    events: ['CharacterAdded', 'CharacterRemoving']
                }
            },
            globals: {
                'game': 'DataModel',
                'workspace': 'Workspace',
                'script': 'Script',
                'print': 'function',
                'warn': 'function',
                'error': 'function',
                'wait': 'function (deprecated)',
                'task': 'Library'
            },
            types: ['Vector3', 'CFrame', 'Color3', 'UDim2', 'Ray', 'Region3']
        };
    }

    // Provide auto-completion suggestions
    getCompletions(text, position) {
        const line = this.getLineAt(text, position);
        const wordBefore = this.getWordBefore(line, position.column);
        
        const suggestions = [];
        
        // Service completions for game:GetService
        if (line.includes('game:GetService(')) {
            this.robloxAPI.services.forEach(service => {
                suggestions.push({
                    label: service,
                    kind: 'Module',
                    insertText: `"${service}"`,
                    detail: `Roblox Service: ${service}`
                });
            });
        }
        
        // Property/method completions after dot
        const dotMatch = line.match(/(\w+)\.$/);
        if (dotMatch) {
            const variable = dotMatch[1];
            // Check if it's a known class
            Object.entries(this.robloxAPI.classes).forEach(([className, classData]) => {
                if (variable.toLowerCase().includes(className.toLowerCase())) {
                    classData.properties?.forEach(prop => {
                        suggestions.push({
                            label: prop,
                            kind: 'Property',
                            insertText: prop,
                            detail: `${className} property`
                        });
                    });
                    classData.methods?.forEach(method => {
                        suggestions.push({
                            label: method,
                            kind: 'Method',
                            insertText: `${method}()`,
                            detail: `${className} method`
                        });
                    });
                }
            });
        }
        
        // Global completions
        if (!line.includes('.') && !line.includes(':')) {
            Object.keys(this.robloxAPI.globals).forEach(global => {
                suggestions.push({
                    label: global,
                    kind: 'Variable',
                    insertText: global,
                    detail: this.robloxAPI.globals[global]
                });
            });
        }
        
        return suggestions;
    }

    // Perform syntax checking and diagnostics
    getDiagnostics(text) {
        const diagnostics = [];
        const lines = text.split('\n');
        
        lines.forEach((line, lineIndex) => {
            // Check for deprecated wait()
            if (line.match(/\bwait\s*\(/)) {
                diagnostics.push({
                    line: lineIndex,
                    column: line.indexOf('wait'),
                    severity: 'warning',
                    message: 'wait() is deprecated. Use task.wait() instead.'
                });
            }
            
            // Check for common mistakes
            if (line.includes('game.Workspace')) {
                diagnostics.push({
                    line: lineIndex,
                    column: line.indexOf('game.Workspace'),
                    severity: 'info',
                    message: 'Consider using workspace global instead of game.Workspace'
                });
            }
            
            // Check for missing GetService
            if (line.match(/game\.Players\b/) || line.match(/game\.ReplicatedStorage\b/)) {
                diagnostics.push({
                    line: lineIndex,
                    column: line.indexOf('game.'),
                    severity: 'warning',
                    message: 'Use game:GetService() instead of direct property access'
                });
            }
            
            // Basic syntax errors
            const openParens = (line.match(/\(/g) || []).length;
            const closeParens = (line.match(/\)/g) || []).length;
            if (openParens !== closeParens) {
                diagnostics.push({
                    line: lineIndex,
                    column: 0,
                    severity: 'error',
                    message: 'Mismatched parentheses'
                });
            }
        });
        
        return diagnostics;
    }

    // Get hover information
    getHoverInfo(text, position) {
        const line = this.getLineAt(text, position);
        const word = this.getWordAt(line, position.column);
        
        // Check globals
        if (this.robloxAPI.globals[word]) {
            return {
                contents: [`**${word}**`, `Type: ${this.robloxAPI.globals[word]}`]
            };
        }
        
        // Check for Roblox types
        if (this.robloxAPI.types.includes(word)) {
            return {
                contents: [`**${word}**`, `Roblox data type`]
            };
        }
        
        // Check for class names
        if (this.robloxAPI.classes[word]) {
            const classData = this.robloxAPI.classes[word];
            return {
                contents: [
                    `**${word}**`,
                    `Roblox class`,
                    `Properties: ${classData.properties?.length || 0}`,
                    `Methods: ${classData.methods?.length || 0}`
                ]
            };
        }
        
        return null;
    }

    // Helper methods
    getLineAt(text, position) {
        const lines = text.split('\n');
        return lines[position.line] || '';
    }

    getWordBefore(line, column) {
        const beforeCursor = line.substring(0, column);
        const match = beforeCursor.match(/(\w+)$/);
        return match ? match[1] : '';
    }

    getWordAt(line, column) {
        const words = line.split(/\W+/);
        let currentPos = 0;
        for (const word of words) {
            const wordStart = line.indexOf(word, currentPos);
            const wordEnd = wordStart + word.length;
            if (column >= wordStart && column <= wordEnd) {
                return word;
            }
            currentPos = wordEnd;
        }
        return '';
    }
}

// Integration with Monaco Editor
function setupBrowserLSP(monaco, editor) {
    const lsp = new BrowserRobloxLSP();
    
    // Register completion provider
    monaco.languages.registerCompletionItemProvider('lua', {
        provideCompletionItems: (model, position) => {
            const text = model.getValue();
            const suggestions = lsp.getCompletions(text, {
                line: position.lineNumber - 1,
                column: position.column - 1
            });
            
            return {
                suggestions: suggestions.map(s => ({
                    label: s.label,
                    kind: monaco.languages.CompletionItemKind[s.kind],
                    insertText: s.insertText,
                    detail: s.detail,
                    range: {
                        startLineNumber: position.lineNumber,
                        endLineNumber: position.lineNumber,
                        startColumn: position.column,
                        endColumn: position.column
                    }
                }))
            };
        }
    });
    
    // Register hover provider
    monaco.languages.registerHoverProvider('lua', {
        provideHover: (model, position) => {
            const text = model.getValue();
            const hoverInfo = lsp.getHoverInfo(text, {
                line: position.lineNumber - 1,
                column: position.column - 1
            });
            
            if (!hoverInfo) return null;
            
            return {
                contents: hoverInfo.contents.map(c => ({ value: c })),
                range: new monaco.Range(
                    position.lineNumber,
                    position.column,
                    position.lineNumber,
                    position.column
                )
            };
        }
    });
    
    // Real-time diagnostics
    let diagnosticsTimeout;
    editor.onDidChangeModelContent(() => {
        clearTimeout(diagnosticsTimeout);
        diagnosticsTimeout = setTimeout(() => {
            const text = editor.getValue();
            const diagnostics = lsp.getDiagnostics(text);
            
            const markers = diagnostics.map(d => ({
                severity: d.severity === 'error' ? monaco.MarkerSeverity.Error :
                         d.severity === 'warning' ? monaco.MarkerSeverity.Warning :
                         monaco.MarkerSeverity.Info,
                startLineNumber: d.line + 1,
                startColumn: d.column + 1,
                endLineNumber: d.line + 1,
                endColumn: d.column + 20,
                message: d.message
            }));
            
            monaco.editor.setModelMarkers(editor.getModel(), 'browser-lsp', markers);
        }, 500);
    });
    
    return lsp;
}

// Export for use in your HTML
window.BrowserRobloxLSP = BrowserRobloxLSP;
window.setupBrowserLSP = setupBrowserLSP;