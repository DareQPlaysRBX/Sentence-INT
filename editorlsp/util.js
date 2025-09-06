// src/util.js
export function asRange(monaco, r) {
  return new monaco.Range(r.start.line + 1, r.start.character + 1, r.end.line + 1, r.end.character + 1);
}
export function fromMonacoPosition(p) {
  return { line: p.lineNumber - 1, character: p.column - 1 };
}
export function fromMonacoRange(r) {
  return {
    start: { line: r.startLineNumber - 1, character: r.startColumn - 1 },
    end: { line: r.endLineNumber - 1, character: r.endColumn - 1 }
  };
}
