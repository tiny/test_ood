const statusEl = document.getElementById('status');
const canvas = document.getElementById('gameCanvas');

function setStatus(message, isError = false) {
  statusEl.textContent = message;
  statusEl.style.color = isError ? '#fca5a5' : '#eaf2ff';
}

function loadScript(src) {
  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = src;
    script.onload = () => resolve(src);
    script.onerror = () => reject(new Error(`Unable to load ${src}`));
    document.body.appendChild(script);
  });
}

async function bootWasm() {
  const scriptSrc = '../build-wasm/test_ood.js';

  try {
    setStatus(`Loading ${scriptSrc}...`);
    window.Module = {
      ...window.Module,
      canvas,
      onRuntimeInitialized: () => setStatus('WebAssembly runtime ready.'),
    };
    await loadScript(scriptSrc);
  } catch (error) {
    console.error(error);
    setStatus('The WASM bundle could not be loaded. Build the project for web and refresh this page.', true);
  }
}

bootWasm();
// echo "Executable:   ./$BUILD_DIR/test_ood"
// echo "To run:       ./$BUILD_DIR/test_ood"
