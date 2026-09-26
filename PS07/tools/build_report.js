// Build PS07/docs/PS07_Report.docx from PS07/docs/PS07.tex.
//
// Copied from PS06/tools/build_report.js. The report is written once, in LaTeX. This script
// reads that same file and renders the Word version from it, so the two deliverables cannot
// drift apart. It understands only the constructs PS07.tex actually uses: section/subsection,
// paragraphs with \code \textbf \textit \mbox, itemize/enumerate, table+tabular,
// figure+includegraphics, lstlisting and \lstinputlisting (the source appendix). The title
// page is skipped and rebuilt here, since LaTeX and Word lay a cover page out very differently.
//
// Usage: node PS07/tools/build_report.js
const fs = require('fs');
const path = require('path');

// docx lives in the Mini-Project 1 tools folder on this machine; prefer a local install.
function loadDocx() {
  try {
    return require('docx');
  } catch (e) {
    return require(path.resolve(__dirname, '..', '..', 'Miniproj1', 'tools', 'node_modules', 'docx'));
  }
}
const {
  Document, Packer, Paragraph, TextRun, ImageRun, Table, TableRow, TableCell,
  AlignmentType, HeadingLevel, WidthType, BorderStyle, ShadingType,
  TableOfContents, Footer, PageNumber, LevelFormat, VerticalAlign, TableLayoutType,
} = loadDocx();

const ROOT = path.resolve(__dirname, '..');
const TEX = path.join(ROOT, 'docs', 'PS07.tex');
const OUT = process.env.REPORT_OUT || path.join(ROOT, 'docs', 'PS07_Report.docx');
const LOGO = path.join(ROOT, 'docs', 'KMUTT_CI_Primary_Logo-Full-1200x1200.png');

const FONT = 'TH Sarabun New';
const MONO = 'Consolas';
const CONTENT_DXA = 9026;    // A4 width 11906 minus two 1-inch margins
const MAX_IMG_PX = 600;      // about the content width at 96 dpi

const MEMBERS = [
  ['นายภูมิพัฒน์ อภิวาทธนะพงศ์', '67070501035'],
  ['นายวิรชัช ทองอุทัยศรี', '67070501041'],
  ['นายเจษฎา เกียรติกมลวงศ์', '67070501080'],
];

// ---------------------------------------------------------------- inline text
// Word here has no Thai dictionary for line breaking, so a zero-width space between Thai
// words gives it a legal break point without changing what is printed.
const thaiSegmenter = new Intl.Segmenter('th', { granularity: 'word' });
function thaiBreaks(s) {
  let out = '';
  let prevThai = false;
  for (const { segment } of thaiSegmenter.segment(s)) {
    const isThai = /[฀-๿]/.test(segment);
    if (isThai && prevThai) out += '​';
    out += segment;
    prevThai = isThai;
  }
  return out;
}

// Content of the {...} that starts at `open`, plus the index just past its closing brace.
function braced(s, open) {
  let depth = 0;
  for (let i = open; i < s.length; i++) {
    if (s[i] === '{' && s[i - 1] !== '\\') depth++;
    else if (s[i] === '}' && s[i - 1] !== '\\') {
      depth--;
      if (depth === 0) return { body: s.slice(open + 1, i), end: i + 1 };
    }
  }
  throw new Error('unbalanced braces near: ' + s.slice(open, open + 60));
}

// Escapes that mean the same thing inside and outside \code{}.
function unescape(s) {
  return s
    .replace(/\\textbackslash\s?/g, '\\')
    .replace(/\\([%&_#$])/g, '$1')
    .replace(/\{,\}/g, ',')
    .replace(/\\,/g, ' ')
    .replace(/\\ /g, ' ');
}

// LaTeX fragment -> TextRun[]. Handles nesting such as \textbf{... \code{x} ...}.
function runs(tex, base = {}) {
  const out = [];
  let plain = '';
  const flush = () => {
    if (!plain) return;
    const text = unescape(plain).replace(/--/g, '–').replace(/~/g, ' ').replace(/\s+/g, ' ');
    if (text) out.push(new TextRun({ ...base, text: thaiBreaks(text) }));
    plain = '';
  };
  let i = 0;
  while (i < tex.length) {
    const rest = tex.slice(i);
    let m;
    if ((m = rest.match(/^\\(code|texttt)\{/))) {
      flush();
      const { body, end } = braced(tex, i + m[0].length - 1);
      out.push(new TextRun({ ...base, text: unescape(body), font: MONO, size: 20 }));
      i += end - i;
    } else if (rest.startsWith('\\mbox{')) {
      // \mbox only stops LaTeX from breaking a line at the minus sign of a number
      flush();
      const { body, end } = braced(tex, i + '\\mbox'.length);
      out.push(...runs(body, base));
      i += end - i;
    } else if ((m = rest.match(/^\\(textbf|textit|emph)\{/))) {
      flush();
      const { body, end } = braced(tex, i + m[0].length - 1);
      const mark = m[1] === 'textbf' ? { bold: true } : { italics: true };
      out.push(...runs(body, { ...base, ...mark }));
      i += end - i;
    } else if (rest.startsWith('\\%') || rest.startsWith('\\&') || rest.startsWith('\\_') ||
               rest.startsWith('\\#') || rest.startsWith('\\$')) {
      plain += rest.slice(0, 2);
      i += 2;
    } else if (rest.startsWith('\\textbackslash')) {
      plain += '\\textbackslash';
      i += '\\textbackslash'.length;
    } else {
      plain += tex[i];
      i++;
    }
  }
  flush();
  return out;
}

// ---------------------------------------------------------------- block helpers
const para = (tex, opts = {}) => new Paragraph({
  alignment: AlignmentType.BOTH,
  spacing: { after: 120 },
  ...opts,
  children: runs(tex),
});
// Headings keep one uniform look, so \code{x} in a heading becomes plain text rather than
// a small monospace run that would also leak into the table of contents.
function plainText(tex) {
  let s = tex;
  let prev;
  do {
    prev = s;
    s = s.replace(/\\(code|texttt|textbf|textit|emph)\{([^{}]*)\}/g, '$2');
  } while (s !== prev);
  return unescape(s).replace(/--/g, '–');
}
const heading = (text, level, pageBreak) => new Paragraph({
  heading: level,
  pageBreakBefore: pageBreak === true,
  children: [new TextRun({ text: thaiBreaks(plainText(text)) })],
});
// Every list gets its own numbering instance, so an enumerate restarts at 1 instead of
// continuing from the previous enumerate in the document.
const listItem = (tex, ref, instance) => new Paragraph({
  numbering: { reference: ref, level: 0, instance },
  spacing: { after: 60 },
  alignment: AlignmentType.BOTH,
  children: runs(tex),
});
const caption = (label, text) => new Paragraph({
  alignment: AlignmentType.CENTER,
  spacing: { after: 240 },
  children: [new TextRun({ text: label + ' ', bold: true, size: 28 }), ...runs(text, { size: 28 })],
});

function codeBlock(lines) {
  const edge = { style: BorderStyle.SINGLE, size: 4, color: 'BFBFBF', space: 4 };
  return lines.map((line, i) => new Paragraph({
    shading: { type: ShadingType.CLEAR, color: 'auto', fill: 'F2F2F2' },
    border: {
      top: i === 0 ? edge : undefined,
      bottom: i === lines.length - 1 ? edge : undefined,
      left: edge,
      right: edge,
    },
    spacing: { before: i === 0 ? 120 : 0, after: i === lines.length - 1 ? 120 : 0, line: 240 },
    indent: { left: 120, right: 120 },
    keepNext: i < lines.length - 1,
    // the paragraph mark takes the code font too, otherwise a blank code line is as tall as a
    // line of 16 pt body text
    run: { font: MONO, size: 18 },
    children: [new TextRun({ text: line || ' ', font: MONO, size: 18 })],
  }));
}

function pngSize(file) {
  const b = fs.readFileSync(file);
  return { w: b.readUInt32BE(16), h: b.readUInt32BE(20) };
}

function figureImage(file, widthFactor) {
  const { w, h } = pngSize(file);
  const width = Math.round(Math.min(MAX_IMG_PX * widthFactor, w));
  return new Paragraph({
    alignment: AlignmentType.CENTER,
    keepNext: true,
    spacing: { before: 120, after: 60 },
    children: [new ImageRun({
      type: 'png',
      data: fs.readFileSync(file),
      transformation: { width, height: Math.round(h * width / w) },
    })],
  });
}

const cellBorder = { style: BorderStyle.SINGLE, size: 4, color: '808080' };
const cellBorders = { top: cellBorder, bottom: cellBorder, left: cellBorder, right: cellBorder };

function buildTable(spec, rows) {
  // spec: the tabular column spec, e.g. @{}p{3.9cm}p{12.2cm}@{}
  const cms = [...spec.matchAll(/p\{([\d.]+)cm\}|([lcr])/g)]
    .map((m) => (m[1] ? parseFloat(m[1]) : 3.0));
  const total = cms.reduce((a, b) => a + b, 0);
  const widths = cms.map((c) => Math.round(CONTENT_DXA * c / total));

  const mkCell = (tex, w, header) => new TableCell({
    width: { size: w, type: WidthType.DXA },
    borders: cellBorders,
    verticalAlign: VerticalAlign.CENTER,
    shading: header ? { type: ShadingType.CLEAR, color: 'auto', fill: 'D9D9D9' } : undefined,
    margins: { top: 40, bottom: 40, left: 100, right: 100 },
    children: [new Paragraph({
      alignment: header ? AlignmentType.CENTER : AlignmentType.LEFT,
      children: runs(tex, header ? { bold: true } : {}),
    })],
  });

  const [head, ...body] = rows;
  return new Table({
    width: { size: widths.reduce((a, b) => a + b, 0), type: WidthType.DXA },
    columnWidths: widths,
    layout: TableLayoutType.FIXED,
    rows: [
      new TableRow({ tableHeader: true, children: head.map((c, i) => mkCell(c, widths[i], true)) }),
      ...body.map((r) => new TableRow({
        cantSplit: true,
        children: r.map((c, i) => mkCell(c, widths[i], false)),
      })),
    ],
  });
}

// ---------------------------------------------------------------- LaTeX reader
const source = fs.readFileSync(TEX, 'utf8').replace(/\r\n/g, '\n');
const docStart = source.indexOf('\\begin{document}');
const afterCover = source.indexOf('\\setcounter{page}{1}', docStart);
const docEnd = source.indexOf('\\end{document}');
const bodyTex = source.slice(afterCover + '\\setcounter{page}{1}'.length, docEnd);

const counters = { section: 0, sub: 0, subsub: 0, figure: 0, table: 0, code: 0 };
const out = [];
let firstSection = true;
let buffer = [];
let listCount = 0;

function flushParagraph() {
  const tex = buffer.join(' ').trim();
  buffer = [];
  if (tex) out.push(para(tex));
}

// Pull a \caption{...} out of a block and return [caption, blockWithoutCaption].
function takeCaption(block) {
  const at = block.indexOf('\\caption{');
  if (at < 0) return ['', block];
  const { body, end } = braced(block, at + '\\caption'.length);
  return [body, block.slice(0, at) + block.slice(end)];
}

const lines = bodyTex.split('\n');
for (let i = 0; i < lines.length; i++) {
  const line = lines[i];
  const trimmed = line.trim();

  if (trimmed.startsWith('%') || trimmed.startsWith('\\addcontentsline')) continue;

  if (trimmed === '') { flushParagraph(); continue; }

  let m;
  if ((m = trimmed.match(/^\\(sub)?(sub)?section\*?\{/))) {
    flushParagraph();
    const { body } = braced(trimmed, trimmed.indexOf('{'));
    const starred = trimmed.includes('section*');
    const depth = (trimmed.match(/sub/g) || []).length;
    let text = body;
    if (!starred) {
      if (depth === 0) { counters.section++; counters.sub = 0; counters.subsub = 0; text = `${counters.section}. ${body}`; }
      else if (depth === 1) { counters.sub++; counters.subsub = 0; text = `${counters.section}.${counters.sub} ${body}`; }
      else { counters.subsub++; text = `${counters.section}.${counters.sub}.${counters.subsub} ${body}`; }
    }
    const level = depth === 0 ? HeadingLevel.HEADING_1 : depth === 1 ? HeadingLevel.HEADING_2 : HeadingLevel.HEADING_3;
    out.push(heading(text, level, depth === 0 && !firstSection));
    if (depth === 0) firstSection = false;
    continue;
  }

  if (trimmed.startsWith('\\begin{itemize}') || trimmed.startsWith('\\begin{enumerate}')) {
    flushParagraph();
    const ref = trimmed.includes('itemize') ? 'bullets' : 'steps';
    const close = trimmed.includes('itemize') ? '\\end{itemize}' : '\\end{enumerate}';
    const instance = ++listCount;
    let item = null;
    for (i++; i < lines.length && !lines[i].trim().startsWith(close); i++) {
      const t = lines[i].trim();
      if (t.startsWith('\\begin{lstlisting}')) {          // a code block inside a list item
        if (item !== null) { out.push(listItem(item, ref, instance)); item = null; }
        const code = [];
        for (i++; i < lines.length && !lines[i].trim().startsWith('\\end{lstlisting}'); i++) code.push(lines[i].trim());
        out.push(...codeBlock(code));
        continue;
      }
      if (t.startsWith('\\item')) {
        if (item !== null) out.push(listItem(item, ref, instance));
        item = t.slice('\\item'.length).trim();
      } else if (item !== null) {
        item += ' ' + t;
      }
    }
    if (item !== null) out.push(listItem(item, ref, instance));
    continue;
  }

  if (trimmed.startsWith('\\begin{table}')) {
    flushParagraph();
    let block = '';
    for (i++; i < lines.length && !lines[i].trim().startsWith('\\end{table}'); i++) block += lines[i] + '\n';
    const [cap, rest] = takeCaption(block);
    const specMatch = rest.match(/\\begin\{tabular\}\{([^\n]*)\}\s*\n/);
    const inner = rest.slice(rest.indexOf('\n', rest.indexOf('\\begin{tabular}')) + 1, rest.indexOf('\\end{tabular}'));
    const rows = inner
      .split('\\\\')
      .map((r) => r.replace(/\\(top|mid|bottom)rule/g, '').trim())
      .filter((r) => r.length)
      .map((r) => r.split('&').map((c) => c.trim()));
    counters.table++;
    out.push(caption(`Table ${counters.table}:`, cap));
    out.push(buildTable(specMatch ? specMatch[1] : '', rows));
    out.push(new Paragraph({ spacing: { after: 160 }, children: [] }));
    continue;
  }

  if (trimmed.startsWith('\\begin{figure}')) {
    flushParagraph();
    let block = '';
    for (i++; i < lines.length && !lines[i].trim().startsWith('\\end{figure}'); i++) block += lines[i] + '\n';
    const [cap, rest] = takeCaption(block);
    const img = rest.match(/\\includegraphics\[width=([\d.]*)\\textwidth\]\{([^}]+)\}/);
    const factor = img && img[1] ? parseFloat(img[1]) : 1;
    const file = path.resolve(path.join(ROOT, 'docs'), img[2]);
    counters.figure++;
    out.push(figureImage(file, factor));
    out.push(caption(`Figure ${counters.figure}:`, cap));
    continue;
  }

  if (trimmed.startsWith('\\begin{lstlisting}')) {
    flushParagraph();
    const opt = trimmed.slice(trimmed.indexOf('[') + 1);
    let cap = '';
    if (opt.includes('caption=')) {
      const at = trimmed.indexOf('caption=');
      cap = braced(trimmed, trimmed.indexOf('{', at)).body;
    }
    const code = [];
    for (i++; i < lines.length && !lines[i].trim().startsWith('\\end{lstlisting}'); i++) code.push(lines[i]);
    out.push(...codeBlock(code));
    if (cap) {
      counters.code++;
      out.push(caption(`Code ${counters.code}:`, cap));
    }
    continue;
  }

  // \lstinputlisting[caption={...}]{../src/ps7.c} : the path is relative to docs/, like LaTeX
  if (trimmed.startsWith('\\lstinputlisting')) {
    flushParagraph();
    let cap = '';
    const at = trimmed.indexOf('caption=');
    if (at >= 0) cap = braced(trimmed, trimmed.indexOf('{', at)).body;
    const close = trimmed.lastIndexOf('}');
    const file = trimmed.slice(trimmed.lastIndexOf('{', close) + 1, close);
    const code = fs.readFileSync(path.resolve(ROOT, 'docs', file), 'utf8')
      .replace(/\r\n/g, '\n').replace(/\n$/, '').split('\n')
      .map((l) => l.replace(/\s+$/, ''));
    out.push(...codeBlock(code));
    if (cap) {
      counters.code++;
      out.push(caption(`Code ${counters.code}:`, cap));
    }
    continue;
  }

  buffer.push(trimmed);
}
flushParagraph();

// ---------------------------------------------------------------- cover page
function cover() {
  const center = (text, size, bold = false, after = 80) => new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after },
    children: [new TextRun({ text: thaiBreaks(text), size, bold })],
  });
  const memberRows = MEMBERS.map(([name, id]) => new TableRow({
    children: [
      new TableCell({
        width: { size: 5200, type: WidthType.DXA }, borders: {}, margins: { bottom: 80 },
        children: [new Paragraph({ children: [new TextRun({ text: thaiBreaks(name), size: 32 })] })],
      }),
      new TableCell({
        width: { size: 2600, type: WidthType.DXA }, borders: {},
        children: [new Paragraph({ alignment: AlignmentType.RIGHT, children: [new TextRun({ text: id, size: 32 })] })],
      }),
    ],
  }));
  return [
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 480, after: 320 },
      children: [new ImageRun({ type: 'png', data: fs.readFileSync(LOGO), transformation: { width: 120, height: 120 } })],
    }),
    center('รายงานปฏิบัติการ', 36, true, 120),
    center('PS07: Concurrency and Thread', 36, true, 640),
    center('เสนอ', 32, true, 120),
    center('อาจารย์ ราชวิชช์ สโรชวิกสิต', 32, false, 480),
    center('จัดทำโดย', 32, true, 160),
    new Table({
      width: { size: 7800, type: WidthType.DXA },
      columnWidths: [5200, 2600],
      alignment: AlignmentType.CENTER,
      layout: TableLayoutType.FIXED,
      rows: memberRows,
    }),
    new Paragraph({ spacing: { after: 560 }, children: [] }),
    center('รายงานนี้เป็นส่วนหนึ่งของวิชา CPE 333 Operating Systems', 32, false, 60),
    center('ภาควิชาวิศวกรรมคอมพิวเตอร์ คณะวิศวกรรมศาสตร์', 32, false, 60),
    center('ภาคการศึกษาที่ 1 ปีการศึกษา 2569', 32, false, 60),
    center('มหาวิทยาลัยเทคโนโลยีพระจอมเกล้าธนบุรี', 32, false, 60),
  ];
}

// ---------------------------------------------------------------- document
const doc = new Document({
  creator: 'CPE 333 Problem Session 7 group',
  title: 'CPE 333 Problem Session 7: Concurrency and Thread',
  styles: {
    default: { document: { run: { font: FONT, size: 32, language: { value: 'en-US', bidirectional: 'th-TH' } } } },
    paragraphStyles: [
      { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: FONT, size: 40, bold: true, color: '000000' },
        paragraph: { spacing: { before: 240, after: 160 }, outlineLevel: 0, keepNext: true } },
      { id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: FONT, size: 36, bold: true, color: '000000' },
        paragraph: { spacing: { before: 240, after: 120 }, outlineLevel: 1, keepNext: true } },
      { id: 'Heading3', name: 'Heading 3', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: FONT, size: 33, bold: true, color: '000000' },
        paragraph: { spacing: { before: 200, after: 100 }, outlineLevel: 2, keepNext: true } },
    ],
  },
  numbering: {
    config: [
      { reference: 'bullets', levels: [{ level: 0, format: LevelFormat.BULLET, text: '•', alignment: AlignmentType.LEFT,
        style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: 'steps', levels: [{ level: 0, format: LevelFormat.DECIMAL, text: '%1.', alignment: AlignmentType.LEFT,
        style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
    ],
  },
  features: { updateFields: true },
  sections: [
    {
      properties: { page: { size: { width: 11906, height: 16838 }, margin: { top: 1440, bottom: 1440, left: 1440, right: 1440 } } },
      children: cover(),
    },
    {
      properties: { page: { size: { width: 11906, height: 16838 }, margin: { top: 1440, bottom: 1440, left: 1440, right: 1440 },
        pageNumbers: { start: 1 } } },
      footers: { default: new Footer({ children: [new Paragraph({ alignment: AlignmentType.CENTER,
        children: [new TextRun({ children: [PageNumber.CURRENT] })] })] }) },
      children: [
        new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 240 },
          children: [new TextRun({ text: 'สารบัญ', bold: true, size: 40 })] }),
        new TableOfContents('สารบัญ', { hyperlink: true, headingStyleRange: '1-3' }),
        new Paragraph({ pageBreakBefore: true, children: [] }),
        ...out,
      ],
    },
  ],
});

Packer.toBuffer(doc).then((buf) => {
  fs.writeFileSync(OUT, buf);
  console.log(`wrote ${OUT}`);
  console.log(`sections: ${counters.section}, figures: ${counters.figure}, tables: ${counters.table}, code blocks: ${counters.code}`);
});
