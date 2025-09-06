// src/jsonRpc.js
// Minimal JSON-RPC 2.0 over WebSocket with request tracking and cancellation.

export class JsonRpc {
  /**
   * @param {{send:(data:string)=>void, onMessage:(cb:(msg:any)=>void)=>void, onOpen:(cb:()=>void)=>void, onClose:(cb:(ev:any)=>void)=>void, onError:(cb:(err:any)=>void)=>void}} transport 
   * @param {{log?:(msg:string, level?:'info'|'warn'|'error')=>void, timeoutMs?: number}} opts 
   */
  constructor(transport, opts = {}) {
    this.transport = transport;
    this.log = opts.log || (()=>{});
    this.timeoutMs = opts.timeoutMs ?? 10000;
    this._id = 1;
    this._pending = new Map(); // id -> {resolve,reject, timer, method}
    transport.onMessage(this._handleMessage.bind(this));
  }

  connect() { /* transport handles */ }
  disconnect() { /* transport handles */ }

  request(method, params, {signal} = {}) {
    const id = this._id++;
    const payload = { jsonrpc: '2.0', id, method, params };
    this.transport.send(JSON.stringify(payload));
    this.log?.(`→ ${method}`, 'info');
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this._pending.delete(id);
        reject(new Error(`RPC timeout for ${method}`));
      }, this.timeoutMs);
      const entry = { resolve, reject, timer, method };
      this._pending.set(id, entry);
      if (signal) {
        signal.addEventListener('abort', () => {
          try {
            // LSP-specific cancellation
            this.notify('$/cancelRequest', { id });
          } catch {}
          clearTimeout(timer);
          this._pending.delete(id);
          reject(new DOMException('Operation canceled', 'AbortError'));
        }, { once: true });
      }
    });
  }

  notify(method, params) {
    const payload = { jsonrpc: '2.0', method, params };
    this.transport.send(JSON.stringify(payload));
    this.log?.(`→ (notify) ${method}`, 'info');
  }

  on(method, handler) {
    if (!this._handlers) this._handlers = new Map();
    if (!this._handlers.has(method)) this._handlers.set(method, new Set());
    this._handlers.get(method).add(handler);
    return () => this._handlers.get(method)?.delete(handler);
  }

  _emit(method, params) {
    const hs = this._handlers?.get(method);
    if (!hs || !hs.size) return;
    for (const h of hs) {
      try { h(params); } catch (e) { console.error(e); }
    }
  }

  _handleMessage(raw) {
    let msg;
    try {
      msg = JSON.parse(raw);
    } catch (e) {
      this.log?.('RPC parse error: ' + e.message, 'error');
      return;
    }

    if (Array.isArray(msg)) {
      // Batch (rare on ws in browsers), handle individually
      for (const m of msg) this._handleMessage(JSON.stringify(m));
      return;
    }

    // Response
    if (Object.prototype.hasOwnProperty.call(msg, 'id')) {
      const entry = this._pending.get(msg.id);
      if (!entry) return;
      clearTimeout(entry.timer);
      this._pending.delete(msg.id);
      if (msg.error) {
        const err = new Error(msg.error.message || 'RPC Error');
        err.code = msg.error.code;
        err.data = msg.error.data;
        entry.reject(err);
      } else {
        entry.resolve(msg.result);
      }
      return;
    }

    // Notification / Request
    if (msg.method) {
      // LSP may send server->client request (rare). For now, support only notifications.
      this._emit(msg.method, msg.params);
    }
  }
}
