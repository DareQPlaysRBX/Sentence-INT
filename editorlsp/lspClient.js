// src/lspClient.js
import { WebSocketTransport } from './transport.js';
import { JsonRpc } from './jsonRpc.js';

/**
 * LSP client providing high-level wrappers.
 * Focused on browser WebSocket transport.
 */

export function createLspClient({ url, languageId = 'luau', log = ()=>{}, onStatus = ()=>{} }) {
  const transport = new WebSocketTransport(url, { log, onStatus });
  const rpc = new JsonRpc(transport, { log });
  /** @type {0|1|2} */
  let serverSyncKind = 1; // Full(1) default per protocol, but many servers use Incremental(2)
  /** @type {any} */
  let serverCapabilities = {};
  let connected = false;

  function clientCapabilities() {
    return {
      textDocument: {
        synchronization: { dynamicRegistration: false, willSave: true, didSave: true, willSaveWaitUntil: false },
        completion: {
          dynamicRegistration: false,
          completionItem: { snippetSupport: true, commitCharactersSupport: true, documentationFormat: ['markdown', 'plaintext'] }
        },
        hover: { contentFormat: ['markdown', 'plaintext'] },
        signatureHelp: { signatureInformation: { documentationFormat: ['markdown', 'plaintext'] } },
        definition: { dynamicRegistration: false },
        references: { dynamicRegistration: false },
        documentHighlight: { dynamicRegistration: false },
        documentSymbol: { dynamicRegistration: false },
        codeAction: { dynamicRegistration: false, codeActionLiteralSupport: { codeActionKind: { valueSet: ['quickfix', 'refactor', 'source'] } } },
        formatting: { dynamicRegistration: false },
        rangeFormatting: { dynamicRegistration: false },
        rename: { dynamicRegistration: false, prepareSupport: true },
        publishDiagnostics: { relatedInformation: true },
        semanticTokens: {
          dynamicRegistration: false,
          requests: { range: true, full: true },
          tokenTypes: [],
          tokenModifiers: []
        }
      },
      window: { workDoneProgress: true }
    };
  }

  // Server -> client notifications
  rpc.on('window/showMessage', (p) => log(`[srv] ${p?.message}`, p?.type === 1 ? 'error' : 'info'));
  rpc.on('textDocument/publishDiagnostics', (p) => {
    // monaco glue will subscribe via exposed hook
    _listeners.publishDiagnostics.forEach(h => h(p));
  });
  rpc.on('client/registerCapability', (p) => {
    // Optional: handle dynamic registration (skipped for simplicity)
    log('Dynamic registration requested (ignored)', 'warn');
  });

  const _listeners = { publishDiagnostics: new Set() };

  return {
    connect() {
      transport.connect();
      connected = true;
    },
    disconnect() { connected = false; transport.disconnect(); },
    onPublishDiagnostics(cb) { _listeners.publishDiagnostics.add(cb); return () => _listeners.publishDiagnostics.delete(cb); },
    clientCapabilities,
    get serverCapabilities() { return serverCapabilities; },
    get serverSyncKind() { return serverSyncKind; },

    async initialize(params) {
      const res = await rpc.request('initialize', params);
      serverCapabilities = res.capabilities || {};
      // Determine text sync kind
      const sync = serverCapabilities.textDocumentSync;
      if (typeof sync === 'number') serverSyncKind = sync;
      else if (typeof sync === 'object' && sync.change != null) serverSyncKind = sync.change;
      return res;
    },
    async initialized() { return rpc.notify('initialized', {}); },
    async shutdown() { try { return await rpc.request('shutdown'); } finally { rpc.notify('exit'); } },

    // Text document lifecycle
    async didOpen(textDocument/*TextDocumentItem*/) {
      return rpc.notify('textDocument/didOpen', { textDocument });
    },
    async didChange(params) { return rpc.notify('textDocument/didChange', params); },
    async didSave(params) { return rpc.notify('textDocument/didSave', params); },

    // Features
    async completion(params, options={}) { return rpc.request('textDocument/completion', params, options); },
    async hover(params, options={}) { return rpc.request('textDocument/hover', params, options); },
    async signatureHelp(params, options={}) { return rpc.request('textDocument/signatureHelp', params, options); },
    async definition(params, options={}) { return rpc.request('textDocument/definition', params, options); },
    async references(params, options={}) { return rpc.request('textDocument/references', params, options); },
    async rename(params, options={}) { return rpc.request('textDocument/rename', params, options); },
    async documentSymbol(params, options={}) { return rpc.request('textDocument/documentSymbol', params, options); },
    async formatting(params, options={}) { return rpc.request('textDocument/formatting', params, options); },
    async rangeFormatting(params, options={}) { return rpc.request('textDocument/rangeFormatting', params, options); },
    async semanticTokensFull(params, options={}) { return rpc.request('textDocument/semanticTokens/full', params, options); },
    async semanticTokensRange(params, options={}) { return rpc.request('textDocument/semanticTokens/range', params, options); },
  };
}
