import OpenSCAD from '/wasm/openscad.js';
import { addFonts } from '/wasm/openscad.fonts.js';

self.onmessage = async ({ data }) => {
  const logs = [];
  try {
    const runtime = await OpenSCAD({
      noInitialRun: true,
      print: line => logs.push(String(line)),
      printErr: line => logs.push(String(line)),
    });
    const instance = runtime.getInstance?.() || runtime;
    addFonts(instance);
    const files = await (await fetch('/inputs.json')).json();
    for (const [virtualPath, url] of files) {
      instance.FS.mkdirTree(virtualPath.slice(0, virtualPath.lastIndexOf('/')));
      const response = await fetch(url);
      if (!response.ok) throw new Error(`Cannot load ${virtualPath}`);
      instance.FS.writeFile(virtualPath, new Uint8Array(await response.arrayBuffer()));
    }
    instance.FS.chdir(data.input.slice(0, data.input.lastIndexOf('/')));
    let input = data.input;
    if (data.module) {
      input = '/thumbnail-entry.scad';
      instance.FS.writeFile(input, `use <${data.input}>\n${data.module}();\n`);
    }
    const status = instance.callMain([
      '-o', '/preview.stl', '--backend=Manifold', '--export-format=binstl',
      ...data.args, input,
    ]);
    if (status && status !== 0) throw new Error(`OpenSCAD exited ${status}`);
    if (logs.some(line => /ERROR:|Can't open|Cannot open|Could not (?:open|read)/i.test(line))) {
      throw new Error('OpenSCAD reported missing geometry or an error');
    }
    const output = instance.FS.readFile('/preview.stl');
    if (output.length < 84) throw new Error('Empty geometry');
    self.postMessage({ output, logs });
  } catch (error) {
    self.postMessage({ error: String(error.message || error), logs });
  }
};