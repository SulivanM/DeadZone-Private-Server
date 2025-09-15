const fs = require('fs');
const path = require('path');

const inputDir = path.resolve('schema');
const baseSlug = 'thelaststand/app';
const outputFile = path.resolve('sidebar.js');

function walk(dir, files = []) {
  fs.readdirSync(dir).forEach(file => {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      walk(fullPath, files);
    } else if (file.endsWith('.txt')) {
      files.push(fullPath);
    }
  });
  return files;
}

function generateSidebar(filePaths, inputDir, baseSlug) {
  const tree = [];

  function sanitize(filePath) {
    const relative = path.relative(inputDir, filePath);
    const extless = relative.replace(/\.txt$/i, '').replace(/\.[^/.]+$/, '');
    const parts = extless.split(path.sep);
    const slug = `${baseSlug}/${parts.join('/')}`.toLowerCase();
    const label = parts.at(-1);
    return { parts: parts.map(p => p.toLowerCase()), label, slug };
  }

  function insert(tree, parts, label, slug) {
    if (parts.length === 1) {
      tree.push({ label, slug });
      return;
    }

    const [head, ...rest] = parts;
    let branch = tree.find(node => node.label === head);

    if (!branch) {
      branch = { label: head, collapsed: true, items: [] };
      tree.push(branch);
    }

    insert(branch.items, rest, label, slug);
  }

  for (const filePath of filePaths) {
    const { parts, label, slug } = sanitize(filePath);
    insert(tree, parts, label, slug);
  }

  return [
    {
      label: 'thelaststand.app',
      collapsed: true,
      items: tree,
    },
  ];
}

// Main script
function run() {
  if (!fs.existsSync(inputDir)) {
    console.error(`❌ Input directory "${inputDir}" not found.`);
    process.exit(1);
  }

  const txtFiles = walk(inputDir);
  const sidebar = generateSidebar(txtFiles, inputDir, baseSlug);
  const content = `export const sidebar = ${JSON.stringify(sidebar, null, 2)};`;

  fs.writeFileSync(outputFile, content, 'utf8');
  console.log(`✅ Sidebar written to ${outputFile}`);
}

run();
