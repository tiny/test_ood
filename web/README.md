# Web preview for the WASM build

This folder contains a lightweight browser page for previewing the game after it is built as a WebAssembly module.

## Suggested build output locations

The loader in `app.js` checks for generated files in these locations:

- `../build/test_ood.js`
- `../build/wasm/test_ood.js`

## Serve locally

Because browsers block some WASM file loading when opened directly from disk, serve the project over a local web server:

```bash
cd /mnt/drive_e/wrk/test_ood
python3 -m http.server 8000
```

Then open:

```text
http://localhost:8000/web/
```

## Notes

- The existing Linux build in `build/` can remain intact.
- For a WebAssembly build, prefer a dedicated build directory such as `build-wasm/` or `build/wasm/` to avoid overwriting the native Linux CMake configuration.
- If the game does not appear, build the project with Emscripten and place the generated JS/WASM output where the loader expects it.
