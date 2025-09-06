// src/diagnostics.js
export function applyDiagnosticsToMonaco(monaco, model, diagnostics) {
  const markers = diagnostics.map(d => ({
    severity: toMonacoSeverity(d.severity),
    message: d.message,
    startLineNumber: d.range.start.line + 1,
    startColumn: d.range.start.character + 1,
    endLineNumber: d.range.end.line + 1,
    endColumn: d.range.end.character + 1,
    code: d.code ?? undefined,
    source: d.source ?? 'lsp'
  }));
  monaco.editor.setModelMarkers(model, 'lsp', markers);
}

function toMonacoSeverity(s) {
  // LSP DiagnosticSeverity: 1 Error, 2 Warning, 3 Information, 4 Hint
  switch (s) {
    case 1: return monaco.MarkerSeverity.Error;
    case 2: return monaco.MarkerSeverity.Warning;
    case 3: return monaco.MarkerSeverity.Info;
    case 4: return monaco.MarkerSeverity.Hint;
    default: return monaco.MarkerSeverity.Info;
  }
}
