const fs = require('fs');
const path = require('path');

const inputDir = path.resolve('schema');                // Input folder
const baseSlug = 'thelaststand/app';                    // Slug base
const outputDir = path.resolve('docs-generated');       // Output folder

function walk(dir, fileList = []) {
  const files = fs.readdirSync(dir);
  files.forEach(file => {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      walk(fullPath, fileList);
    } else {
      fileList.push(fullPath);
    }
  });
  return fileList;
}

function sanitizeName(name) {
  return name.replace(/\.txt$/i, '').toLowerCase();
}

function generateMarkdown(filePath) {
  const relativePath = path.relative(inputDir, filePath);           // e.g. users/UserSchema.txt
  const relativeDir = path.dirname(relativePath);                   // e.g. users
  const rawFileName = path.basename(filePath);                      // e.g. UserSchema.txt
  const cleanName = sanitizeName(path.basename(filePath));          // e.g. userschema

  const slug = `${baseSlug}/${path.join(relativeDir, cleanName)}`.replace(/\\/g, '/');
  const fileContent = fs.readFileSync(filePath, 'utf8');

  return `---
title: ${rawFileName.substring(0, rawFileName.lastIndexOf("."))}
slug: ${slug}
description: ${rawFileName.substring(0, rawFileName.lastIndexOf("."))}
---

${rawFileName.substring(0, rawFileName.lastIndexOf("."))} class

## Object structure

\`\`\`scala
${fileContent}
\`\`\`
`;
}

function ensureDirectoryExistence(filePath) {
  const dir = path.dirname(filePath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

function run() {
  if (!fs.existsSync(inputDir)) {
    console.error(`❌ Input directory "${inputDir}" does not exist.`);
    process.exit(1);
  }

  console.log(`📂 Reading from: ${inputDir}`);
  console.log(`📁 Writing to:   ${outputDir}`);
  console.log(`🔗 Base slug:    ${baseSlug}`);

  const files = walk(inputDir);
  files.forEach(file => {
    const relativePath = path.relative(inputDir, file);                     // e.g. users/UserSchema.txt
    const relativeDir = path.dirname(relativePath);                         // e.g. users
    const fileNameWithoutExt = sanitizeName(path.basename(file));           // e.g. userschema
    const outPath = path.join(outputDir, relativeDir, fileNameWithoutExt + '.md');

    ensureDirectoryExistence(outPath);
    const markdown = generateMarkdown(file);
    fs.writeFileSync(outPath, markdown, 'utf8');

    console.log(`✅ Generated: ${outPath}`);
  });
}

run();
