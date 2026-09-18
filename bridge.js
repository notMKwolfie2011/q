const http = require('http');
const httpProxy = require('http-proxy');
const net = require('net');

// Use the platform's dynamic PORT, or default to 8080
const PORT = process.env.PORT || 8080;

// Set up a standard HTTP proxy to serve noVNC files
const proxy = httpProxy.createProxyServer({
    target: { host: '127.0.0.1', port: 6080 },
    ws: true
});

const server = http.createServer((req, res) => {
    proxy.web(req, res, {}, (err) => {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end('Bridge error connecting to VNC');
    });
});

// Capture WebSocket traffic and route it straight to VNC (Port 5900)
server.on('upgrade', (req, socket, head) => {
    const targetSocket = net.connect(5900, '127.0.0.1', () => {
        targetSocket.write(head);
        socket.pipe(targetSocket).pipe(socket);
    });

    targetSocket.on('error', () => socket.destroy());
    socket.on('error', () => targetSocket.destroy());
});

server.listen(PORT, () => {
    console.log(`🚀 New web bridge running smoothly on port ${PORT}`);
});
