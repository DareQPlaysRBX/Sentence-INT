// src/monacoGlue.js
import { applyDiagnosticsToMonaco } from './diagnostics.js';
import { fromMonacoPosition, fromMonacoRange } from './util.js';

/**
 * Attach Monaco providers to an LSP client instance.
 * Returns a function to detach providers.
 * @param {{monaco:any, editor:any, lsp:any, languageId:string, getDocument:()=>{uri:string,languageId:string,version:number,text:string}, log:(m:string,l?:string)=>void}} ctx 
 */
export function attachMonaco(ctx) {
  const { monaco, editor, lsp, languageId, getDocument, log } = ctx;

  // Diagnostics
  const diagDispose = lsp.onPublishDiagnostics((p) => {
    const model = editor.getModel();
    if (!model || model.uri.toString(true) !== p.uri) return;
    applyDiagnosticsToMonaco(monaco, model, p.diagnostics || []);
  });

  // Completion
  const completionProv = monaco.languages.registerCompletionItemProvider('lua', {
    triggerCharacters: ['.', ':', '"', "'", '['],
    provideCompletionItems: async (model, position, context, token) => {
      const params = {
        textDocument: { uri: model.uri.toString(true) },
        position: fromMonacoPosition(position),
        context: { triggerKind: 1 }
      };
      try {
        const res = await lsp.completion(params, { signal: token });
        const items = Array.isArray(res?.items) ? res.items : Array.isArray(res) ? res : [];
        return {
          suggestions: items.map(toMonacoCompletion)
        };
      } catch (e) {
        if (e.name === 'AbortError') return { suggestions: [] };
        log('completion error: ' + e.message, 'error');
        return { suggestions: [] };
      }
    }
  });

  // Hover
  const hoverProv = monaco.languages.registerHoverProvider('lua', {
    provideHover: async (model, position, token) => {
      try {
        const res = await lsp.hover({ textDocument: { uri: model.uri.toString(true) }, position: fromMonacoPosition(position) }, { signal: token });
        if (!res || !res.contents) return null;
        const md = Array.isArray(res.contents) ? res.contents.map(c => typeof c === 'string' ? c : c.value).join('\n\n') :
                  (typeof res.contents === 'string' ? res.contents : res.contents.value || '');
        return { contents: [{ value: md }] };
      } catch (e) {
        if (e.name === 'AbortError') return null;
        log('hover error: ' + e.message, 'error');
        return null;
      }
    }
  });

  // Signature Help
  const sigProv = monaco.languages.registerSignatureHelpProvider('lua', {
    signatureHelpTriggerCharacters: ['(', ','],
    provideSignatureHelp: async (model, position, token) => {
      try {
        const res = await lsp.signatureHelp({ textDocument: { uri: model.uri.toString(true) }, position: fromMonacoPosition(position) }, { signal: token });
        if (!res) return null;
        return { value: res, dispose: () => {} };
      } catch (e) {
        if (e.name === 'AbortError') return null;
        log('signatureHelp error: ' + e.message, 'error');
        return null;
      }
    }
  });

  // Definition (Go to)
  const defProv = monaco.languages.registerDefinitionProvider('lua', {
    provideDefinition: async (model, position, token) => {
      try {
        const res = await lsp.definition({ textDocument: { uri: model.uri.toString(true) }, position: fromMonacoPosition(position) }, { signal: token });
        return toMonacoLocations(monaco, res);
      } catch (e) {
        if (e.name === 'AbortError') return [];
        log('definition error: ' + e.message, 'error');
        return [];
      }
    }
  });

  // References
  const refProv = monaco.languages.registerReferenceProvider('lua', {
    provideReferences: async (model, position, context, token) => {
      try {
        const res = await lsp.references({ textDocument: { uri: model.uri.toString(true) }, position: fromMonacoPosition(position), context: { includeDeclaration: true } }, { signal: token });
        return toMonacoLocations(monaco, res);
      } catch (e) {
        if (e.name === 'AbortError') return [];
        log('references error: ' + e.message, 'error');
        return [];
      }
    }
  });

  // Rename
  const renameProv = monaco.languages.registerRenameProvider('lua', {
    provideRenameEdits: async (model, position, newName, token) => {
      try {
        const res = await lsp.rename({ textDocument: { uri: model.uri.toString(true) }, position: fromMonacoPosition(position), newName }, { signal: token });
        return toWorkspaceEdit(monaco, res);
      } catch (e) {
        if (e.name === 'AbortError') return { edits: [] };
        log('rename error: ' + e.message, 'error');
        return { edits: [] };
      }
    }
  });

  // Symbols
  const symProv = monaco.languages.registerDocumentSymbolProvider('lua', {
    provideDocumentSymbols: async (model, token) => {
      try {
        const res = await lsp.documentSymbol({ textDocument: { uri: model.uri.toString(true) } }, { signal: token });
        if (!res) return [];
        // Could be SymbolInformation[] or DocumentSymbol[]
        if (Array.isArray(res) && res.length && res[0].location) {
          // SymbolInformation[]
          return res.map(si => ({
            name: si.name,
            detail: si.containerName || '',
            kind: toMonacoSymbolKind(si.kind),
            range: new monaco.Range(si.location.range.start.line + 1, si.location.range.start.character + 1, si.location.range.end.line + 1, si.location.range.end.character + 1),
            selectionRange: new monaco.Range(si.location.range.start.line + 1, si.location.range.start.character + 1, si.location.range.end.line + 1, si.location.range.end.character + 1),
            tags: []
          }));
        }
        // DocumentSymbol[]
        const toDoc = (ds) => ({
          name: ds.name,
          detail: ds.detail || '',
          kind: toMonacoSymbolKind(ds.kind),
          range: new monaco.Range(ds.range.start.line + 1, ds.range.start.character + 1, ds.range.end.line + 1, ds.range.end.character + 1),
          selectionRange: new monaco.Range(ds.selectionRange.start.line + 1, ds.selectionRange.start.character + 1, ds.selectionRange.end.line + 1, ds.selectionRange.end.character + 1),
          children: (ds.children || []).map(toDoc),
          tags: []
        });
        return res.map(toDoc);
      } catch (e) {
        if (e.name === 'AbortError') return [];
        log('documentSymbol error: ' + e.message, 'error');
        return [];
      }
    }
  });

  // Formatting
  const fmtProv = monaco.languages.registerDocumentFormattingEditProvider('lua', {
    provideDocumentFormattingEdits: async (model, options, token) => {
      try {
        const edits = await lsp.formatting({ textDocument: { uri: model.uri.toString(true) }, options: { tabSize: options.tabSize || 2, insertSpaces: options.insertSpaces !== false } }, { signal: token });
        if (!Array.isArray(edits)) return [];
        return edits.map(e => ({ range: new monaco.Range(e.range.start.line + 1, e.range.start.character + 1, e.range.end.line + 1, e.range.end.character + 1), text: e.newText }));
      } catch (e) {
        if (e.name === 'AbortError') return [];
        log('formatting error: ' + e.message, 'error');
        return [];
      }
    }
  });

  // Return disposer
  return () => {
    diagDispose?.();
    completionProv?.dispose();
    hoverProv?.dispose();
    sigProv?.dispose();
    defProv?.dispose();
    refProv?.dispose();
    renameProv?.dispose();
    symProv?.dispose();
    fmtProv?.dispose();
  };
}

// Helpers

function toMonacoCompletion(ci) {
  // Basic mapping; could be expanded with documentation, details, etc.
  const kind = toMonacoCompletionKind(ci.kind);
  return {
    label: ci.label,
    kind,
    detail: ci.detail,
    documentation: (typeof ci.documentation === 'string') ? ci.documentation : ci.documentation?.value,
    insertText: ci.insertText || ci.label,
    range: undefined, // let Monaco decide, LSP has textEdit for precise ranges
    sortText: ci.sortText,
    filterText: ci.filterText,
    commitCharacters: ci.commitCharacters
  };
}

function toMonacoCompletionKind(k) {
  // LSP CompletionItemKind -> Monaco CompletionItemKind
  const map = {
    1: monaco.languages.CompletionItemKind.Text,
    2: monaco.languages.CompletionItemKind.Method,
    3: monaco.languages.CompletionItemKind.Function,
    4: monaco.languages.CompletionItemKind.Constructor,
    5: monaco.languages.CompletionItemKind.Field,
    6: monaco.languages.CompletionItemKind.Variable,
    7: monaco.languages.CompletionItemKind.Class,
    8: monaco.languages.CompletionItemKind.Interface,
    9: monaco.languages.CompletionItemKind.Module,
    10: monaco.languages.CompletionItemKind.Property,
    11: monaco.languages.CompletionItemKind.Unit,
    12: monaco.languages.CompletionItemKind.Value,
    13: monaco.languages.CompletionItemKind.Enum,
    14: monaco.languages.CompletionItemKind.Keyword,
    15: monaco.languages.CompletionItemKind.Snippet,
    16: monaco.languages.CompletionItemKind.Color,
    17: monaco.languages.CompletionItemKind.File,
    18: monaco.languages.CompletionItemKind.Reference,
    19: monaco.languages.CompletionItemKind.Folder,
    20: monaco.languages.CompletionItemKind.EnumMember,
    21: monaco.languages.CompletionItemKind.Constant,
    22: monaco.languages.CompletionItemKind.Struct,
    23: monaco.languages.CompletionItemKind.Event,
    24: monaco.languages.CompletionItemKind.Operator,
    25: monaco.languages.CompletionItemKind.TypeParameter
  };
  return map[k] || monaco.languages.CompletionItemKind.Text;
}

function toMonacoSymbolKind(k) {
  const map = {
    1: monaco.languages.SymbolKind.File,
    2: monaco.languages.SymbolKind.Module,
    3: monaco.languages.SymbolKind.Namespace,
    4: monaco.languages.SymbolKind.Package,
    5: monaco.languages.SymbolKind.Class,
    6: monaco.languages.SymbolKind.Method,
    7: monaco.languages.SymbolKind.Property,
    8: monaco.languages.SymbolKind.Field,
    9: monaco.languages.SymbolKind.Constructor,
    10: monaco.languages.SymbolKind.Enum,
    11: monaco.languages.SymbolKind.Interface,
    12: monaco.languages.SymbolKind.Function,
    13: monaco.languages.SymbolKind.Variable,
    14: monaco.languages.SymbolKind.Constant,
    15: monaco.languages.SymbolKind.String,
    16: monaco.languages.SymbolKind.Number,
    17: monaco.languages.SymbolKind.Boolean,
    18: monaco.languages.SymbolKind.Array,
    19: monaco.languages.SymbolKind.Object,
    20: monaco.languages.SymbolKind.Key,
    21: monaco.languages.SymbolKind.Null,
    22: monaco.languages.SymbolKind.EnumMember,
    23: monaco.languages.SymbolKind.Struct,
    24: monaco.languages.SymbolKind.Event,
    25: monaco.languages.SymbolKind.Operator,
    26: monaco.languages.SymbolKind.TypeParameter
  };
  return map[k] || monaco.languages.SymbolKind.Function;
}

function toMonacoLocations(monaco, res) {
  const arr = Array.isArray(res) ? res : (res ? [res] : []);
  return arr.map(loc => {
    const uri = monaco.Uri.parse(loc.uri);
    const range = new monaco.Range(loc.range.start.line + 1, loc.range.start.character + 1, loc.range.end.line + 1, loc.range.end.character + 1);
    return { uri, range };
  });
}

function toWorkspaceEdit(monaco, we) {
  if (!we || !we.changes) return { edits: [] };
  const edits = [];
  for (const [uriStr, textEdits] of Object.entries(we.changes)) {
    const uri = monaco.Uri.parse(uriStr);
    const model = monaco.editor.getModel(uri);
    if (!model) continue;
    for (const e of textEdits) {
      edits.push({
        resource: uri,
        edit: {
          range: new monaco.Range(e.range.start.line + 1, e.range.start.character + 1, e.range.end.line + 1, e.range.end.character + 1),
          text: e.newText
        }
      });
    }
  }
  return { edits };
}
