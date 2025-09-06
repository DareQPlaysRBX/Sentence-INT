// cloudflare-worker.js - Deploy this as a Cloudflare Worker
// This proxies WebSocket connections to your LSP server

export default {
  async fetch(request, env) {
    const upgradeHeader = request.headers.get('Upgrade');
    
    if (upgradeHeader !== 'websocket') {
      return new Response('Expected websocket', { status: 400 });
    }

    const [client, server] = Object.values(new WebSocketPair());
    
    // Connect to your actual LSP server
    // You'd need to host the LSP server elsewhere (e.g., on a VPS, Heroku, etc.)
    const lspServerUrl = env.LSP_SERVER_URL || 'wss://your-lsp-server.com';
    
    server.accept();
    
    // Handle the WebSocket connection
    const lspSocket = new WebSocket(lspServerUrl);
    
    // Relay messages between client and LSP server
    server.addEventListener('message', event => {
      if (lspSocket.readyState === WebSocket.OPEN) {
        lspSocket.send(event.data);
      }
    });
    
    lspSocket.addEventListener('message', event => {
      server.send(event.data);
    });
    
    lspSocket.addEventListener('close', () => {
      server.close();
    });
    
    server.addEventListener('close', () => {
      lspSocket.close();
    });

    return new Response(null, {
      status: 101,
      webSocket: client,
    });
  }
};

// wrangler.toml configuration
/*
name = "roblox-lsp-proxy"
main = "src/worker.js"
compatibility_date = "2023-05-18"

[env.production]
vars = { LSP_SERVER_URL = "wss://your-lsp-server.com" }
*/