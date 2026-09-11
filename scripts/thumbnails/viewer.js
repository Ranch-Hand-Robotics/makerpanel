import * as THREE from 'three';
import { STLLoader } from '/three/examples/jsm/loaders/STLLoader.js';

const canvas = document.querySelector('canvas');
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, preserveDrawingBuffer: true });
renderer.setPixelRatio(1);
const scene = new THREE.Scene();
scene.add(new THREE.HemisphereLight(0xffffff, 0x46513c, 2.4));
const light = new THREE.DirectionalLight(0xffffff, 3);
light.position.set(-2, -3, 6);
scene.add(light);
let mesh;
let camera;

window.compile = data => new Promise((resolve, reject) => {
  const worker = new Worker('/worker.js', { type: 'module' });
  const timer = setTimeout(() => {
    worker.terminate();
    reject(new Error(`OpenSCAD exceeded ${data.timeoutMs}ms`));
  }, data.timeoutMs);
  const finish = () => { clearTimeout(timer); worker.terminate(); };
  worker.onerror = event => { finish(); reject(new Error(event.message)); };
  worker.onmessage = ({ data: result }) => {
    finish();
    if (result.error) return reject(new Error(`${result.error}\n${result.logs.join('\n')}`));
    try {
      const bytes = result.output;
      const geometry = new STLLoader().parse(bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength));
      geometry.computeBoundingBox();
      if (geometry.boundingBox.isEmpty()) throw new Error('Empty mesh');
      geometry.center();
      geometry.computeVertexNormals();
      mesh = new THREE.Mesh(geometry, new THREE.MeshStandardMaterial({
        color: '#b8e63e', roughness: 0.65, metalness: 0.1, side: THREE.DoubleSide,
      }));
      scene.add(mesh);
      const size = geometry.boundingBox.getSize(new THREE.Vector3());
      const radius = size.length() / 2;
      if (!Number.isFinite(radius) || radius <= 0) throw new Error('Invalid mesh bounds');
      const direction = new THREE.Vector3(...(data.camera || [0.35, -0.65, 1])).normalize();
      camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.01, radius * 12);
      camera.up.set(0, 0, 1);
      camera.position.copy(direction.multiplyScalar(radius * 5));
      camera.lookAt(0, 0, 0);
      camera.updateMatrixWorld();
      const projected = [];
      for (const x of [-size.x / 2, size.x / 2])
        for (const y of [-size.y / 2, size.y / 2])
          for (const z of [-size.z / 2, size.z / 2])
            projected.push(new THREE.Vector3(x, y, z).applyMatrix4(camera.matrixWorldInverse));
      const halfWidth = Math.max(...projected.map(p => Math.abs(p.x)));
      const halfHeight = Math.max(...projected.map(p => Math.abs(p.y)));
      const aspect = data.width / data.height;
      const fit = Math.max(halfHeight, halfWidth / aspect) * 1.2;
      camera.left = -fit * aspect; camera.right = fit * aspect;
      camera.top = fit; camera.bottom = -fit;
      camera.updateProjectionMatrix();
      renderer.setSize(data.width, data.height);
      resolve({ triangles: geometry.attributes.position.count / 3, logs: result.logs });
    } catch (error) { reject(error); }
  };
  worker.postMessage(data);
});
window.renderTheme = theme => {
  scene.background = new THREE.Color(theme.background);
  mesh.material.color.set(theme.material);
  renderer.render(scene, camera);
};