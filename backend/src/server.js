'use strict';

const { createReadPackApp } = require('./app');

const PORT = Number(process.env.PORT || 4000);

async function startServer() {
  const { createServer, store } = await createReadPackApp();
  const server = createServer();

  server.listen(PORT, () => {
    console.log(
      `[ReadPack Express Backend] Listening on http://localhost:${PORT} (Storage Mode: ${store.mode})`
    );
  });
}

if (require.main === module) {
  startServer().catch((err) => {
    console.error('[ReadPack Express Backend] Fatal startup error:', err);
    process.exit(1);
  });
}

module.exports = { startServer };
