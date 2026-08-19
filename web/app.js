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
  const candidates = [
    './test_ood.js'
    , './test_ood.wasm'
  ];

  const scriptSrc = candidates.find((candidate) => candidate.endsWith('.js'));
  if (!scriptSrc) {
    setStatus('No generated WASM module found yet. Build it with Emscripten and place the output under build/ or build/wasm/.', true);
    return;
  }

  try {
    setStatus(`Loading ${scriptSrc}...`);
    await loadScript(scriptSrc);

    if (window.Module) {
      window.Module.canvas = canvas;
      window.Module.onRuntimeInitialized = () => {
        setStatus('WebAssembly runtime ready.');
      };
    }

    if (window.test_ood && typeof window.test_ood === 'function') {
      setStatus('App module initialized.');
    }
  } catch (error) {
    console.error(error);
    setStatus('The WASM bundle could not be loaded. Build the project for web and refresh this page.', true);
  }
}

bootWasm();
// echo "Executable:   ./$BUILD_DIR/test_ood"
// echo "To run:       ./$BUILD_DIR/test_ood"
