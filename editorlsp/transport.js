// src/transport.js
// WebSocket transport with reconnect/backoff and keepalive

export class WebSocketTransport {
  /**
   * @param {string} url 
   * @param {{log?:(msg:string, level?:'info'|'warn'|'error')=>void, onStatus?:(s:string)=>void, backoff?:{min:number,max:number,factor:number}, keepaliveSec?:number}} opts 
   */
  constructor(url, opts = {}) {
    this.url = url;
    this.log = opts.log || (()=>{});
    this.onStatus = opts.onStatus || (()=>{});
    this.backoff = Object.assign({ min: 500, max: 8000, factor: 2 }, opts.backoff);
    this.keepaliveSec = opts.keepaliveSec ?? 30;
    this._messageHandlers = new Set();
    this._openHandlers = new Set();
    this._closeHandlers = new Set();
    this._errorHandlers = new Set();
    this._ws = null;
    this._connected = false;
    this._retry = 0;
    this._kaTimer = null;
  }

  connect() {
    if (this._ws && (this._ws.readyState === WebSocket.OPEN || this._ws.readyState === WebSocket.CONNECTING)) {
      return;
    }
    this.onStatus?.('🔌 Łączenie…');
    this._ws = new WebSocket(this.url);
    this._ws.addEventListener('open', () => {
      this._connected = true;
      this._retry = 0;
      this.onStatus?.('✅ Połączony');
      this._openHandlers.forEach(h => h());
      if (this.keepaliveSec > 0) {
        clearInterval(this._kaTimer);
        this._kaTimer = setInterval(() => {
          try {
            // Send a benign notification to keep path hot (LSP ignores unknown methods)
            this._ws?.readyState === WebSocket.OPEN && this._ws.send(JSON.stringify({ jsonrpc:'2.0', method:'$/keepalive' }));
          } catch {}
        }, this.keepaliveSec * 1000);
      }
    });
    this._ws.addEventListener('message', (ev) => {
      this._messageHandlers.forEach(h => h(ev.data));
    });
    this._ws.addEventListener('close', (ev) => {
      this._connected = false;
      this.onStatus?.('⏳ Rozłączony');
      clearInterval(this._kaTimer);
      this._closeHandlers.forEach(h => h(ev));
      // auto-reconnect disabled by default, leave reconnect policy to client if desired
    });
    this._ws.addEventListener('error', (err) => {
      this._errorHandlers.forEach(h => h(err));
    });
  }

  disconnect() {
    clearInterval(this._kaTimer);
    if (this._ws) {
      try { this._ws.close(); } catch {}
    }
    this._ws = null;
    this._connected = false;
  }

  send(data) {
    if (!this._ws || this._ws.readyState !== WebSocket.OPEN) {
      throw new Error('WebSocket not open');
    }
    this._ws.send(data);
  }

  onMessage(cb) { this._messageHandlers.add(cb); return () => this._messageHandlers.delete(cb); }
  onOpen(cb) { this._openHandlers.add(cb); return () => this._openHandlers.delete(cb); }
  onClose(cb) { this._closeHandlers.add(cb); return () => this._closeHandlers.delete(cb); }
  onError(cb) { this._errorHandlers.add(cb); return () => this._errorHandlers.delete(cb); }
}
