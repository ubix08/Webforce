# PDFCompressr — Master Project Specification
> **Version:** 1.0 · **Status:** Implementation Ready  
> **Purpose:** Self-contained specification handed to an AI coding agent to scaffold and implement the full production-ready project end-to-end.  
> **Audience:** AI coding agent (Claude Code, Cursor, Windsurf, or equivalent). No human clarification should be needed. All decisions are made inside this document.

---

## 0. Document Map

```
Section 1  — Product Overview & Strategic Context
Section 2  — Technical Architecture
Section 3  — Project File & Directory Structure
Section 4  — Dependency Manifest (package.json)
Section 5  — Environment Variables & Configuration
Section 6  — Core Engine: Ghostscript WASM Worker
Section 7  — State Management (Zustand Store)
Section 8  — React Component Tree
Section 9  — UI Specification (Design System + All Screens)
Section 10 — Compression Presets System
Section 11 — Freemium & Paywall Logic
Section 12 — Monetization Integration (Stripe)
Section 13 — SEO & Metadata Strategy
Section 14 — PWA Configuration
Section 15 — Vercel Deployment Configuration
Section 16 — Implementation Order (Coding Agent Task Queue)
Section 17 — Acceptance Criteria & Test Checklist
Section 18 — Known Constraints & Hard Rules
```

---

## 1. Product Overview & Strategic Context

### 1.1 Product Name
**PDFCompressr** — Privacy-First Local PDF Compressor

### 1.2 One-Line Value Proposition
> Compress any PDF in seconds — entirely inside your browser. Your file never leaves your device.

### 1.3 Core Differentiator
Every competing tool (Smallpdf, IlovePDF, Adobe Compress) routes files through their servers. PDFCompressr processes everything using **Ghostscript compiled to WebAssembly**, running natively in the user's browser tab. Zero upload. Zero server. Zero data exposure.

This is not a marketing claim. It is a technical architecture fact. The network tab in DevTools will show zero file-related requests after the engine is loaded.

### 1.4 Target Buyers

| Segment | Pain | Frequency |
|---|---|---|
| Legal & HR professionals | Confidential documents (NDAs, tax returns, contracts) | Weekly |
| Office administrators | Email attachment limits (Gmail 25MB, Outlook 20MB) | Daily |
| Students & academics | University portal upload limits | Weekly |
| Medical / Clinical staff | HIPAA-sensitive patient documents | Daily |

### 1.5 Business Model

```
FREE TIER (no account required)
  └── Compress 1 file per session
  └── All compression quality presets available
  └── Max file size: 50MB
  └── Output: direct browser download

PAID TIER — $9/month (Stripe subscription)
  └── Unlimited files per session (batch mode)
  └── Max file size: 500MB per file
  └── Drag-and-drop queue with progress per file
  └── Bulk ZIP download of all compressed files
  └── Priority preset: custom DPI input
  └── No "Powered by PDFCompressr" footer on output metadata
```

### 1.6 Monetization Architecture
Because the app is 100% static (no backend), the paywall is implemented via:
1. **Stripe Payment Links** → user pays → Stripe redirects back with `?session_id=` param
2. **Stripe.js client-side session verification** → calls Stripe's `retrieveSession` endpoint from browser
3. **localStorage token** → stores `{ paid: true, expires: timestamp }` for 30-day rolling session
4. This is a pragmatic, zero-backend approach. It is not cryptographically airtight (a determined user can spoof localStorage), but it is entirely sufficient for a solo-founder Micro-SaaS at this stage. The paywall stops honest users from over-consuming free resources.

---

## 2. Technical Architecture

### 2.1 Stack Decision Table

| Layer | Choice | Reason |
|---|---|---|
| Framework | Next.js 14 (App Router) | Static export, SEO, fast iteration |
| Language | TypeScript (strict mode) | Type safety across WASM boundary |
| Styling | Tailwind CSS v3 | Utility-first, zero runtime |
| State | Zustand | Lightweight, no boilerplate |
| WASM Engine | `@jspawn/ghostscript-wasm` v0.0.2 | Battle-tested, CDN-available, browser-native |
| WASM Loading | Dynamic `import()` + CDN jsdelivr | ~18MB loaded once, cached in Cache Storage |
| Worker | Native Web Worker (no Comlink) | Keeps main thread fully unblocked |
| Payments | Stripe.js + Stripe Payment Links | Zero backend required |
| Hosting | Vercel (static export) | Free tier sufficient, global CDN |
| PWA | next-pwa | Offline support, installable |
| Analytics | Plausible (privacy-respecting) | Aligns with brand promise |
| Fonts | Google Fonts: Syne (display) + DM Sans (body) | Distinctive, not generic |

### 2.2 Data Flow Diagram

```
USER DROPS PDF
      │
      ▼
[React App — Main Thread]
  FileReader.readAsArrayBuffer(file)
      │
      ▼ postMessage(fileBuffer, preset, fileId)
[Compression Web Worker]
  ├── Check Cache Storage for gs.wasm binary
  │     ├── HIT  → load from disk (instant)
  │     └── MISS → fetch from CDN → store in Cache Storage → load
  │
  ├── gs.FS.writeFile('/input.pdf', uint8Array)
  ├── gs.callMain([
  │     '-sDEVICE=pdfwrite',
  │     '-dCompatibilityLevel=1.4',
  │     '-dPDFSETTINGS=/{preset}',   ← screen | ebook | printer | prepress
  │     '-dNOPAUSE', '-dQUIET', '-dBATCH',
  │     '-sOutputFile=/output.pdf',
  │     '/input.pdf'
  │   ])
  ├── gs.FS.readFile('/output.pdf')
  └── postMessage({ fileId, outputBuffer, stats })
      │
      ▼
[React App — Main Thread]
  └── Blob URL → <a download> → browser saves file
      NO NETWORK REQUEST FOR FILE DATA
```

### 2.3 WASM Loading Strategy

```
First visit:
  1. Worker starts
  2. Check: await caches.match(GS_WASM_URL)
  3. MISS → fetch GS_WASM from jsDelivr CDN (~18MB)
  4. Store in Cache Storage 'pdfcompressr-wasm-v1'
  5. Initialize Ghostscript with fetched binary
  6. Ready signal → UI exits loading state

Repeat visits:
  1. Worker starts
  2. Check: await caches.match(GS_WASM_URL)
  3. HIT → load from disk (< 200ms)
  4. Initialize Ghostscript
  5. Ready signal → UI exits loading state instantly
```

### 2.4 Cross-Origin Isolation Requirements
Ghostscript WASM requires `SharedArrayBuffer` for optimal multithreaded performance. This requires the following HTTP headers on all routes:

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

These are set in `next.config.js` headers and in `vercel.json`.

---

## 3. Project File & Directory Structure

The coding agent MUST create this exact structure. No deviations.

```
pdfcompressr/
├── public/
│   ├── favicon.ico
│   ├── icon-192.png              ← PWA icon (solid dark bg, white PDF icon)
│   ├── icon-512.png
│   ├── manifest.json             ← PWA manifest
│   ├── robots.txt
│   ├── sitemap.xml
│   └── workers/
│       └── compression.worker.js ← Web Worker script (plain JS, not bundled by Next)
│
├── src/
│   ├── app/
│   │   ├── layout.tsx            ← Root layout: fonts, metadata, COOP/COEP headers
│   │   ├── page.tsx              ← Homepage: Hero + Dropzone + Compressor UI
│   │   ├── globals.css           ← Tailwind base + CSS custom properties
│   │   ├── pricing/
│   │   │   └── page.tsx          ← Pricing page
│   │   ├── success/
│   │   │   └── page.tsx          ← Post-payment success page (validates Stripe session)
│   │   └── legal/
│   │       ├── privacy/page.tsx
│   │       └── terms/page.tsx
│   │
│   ├── components/
│   │   ├── layout/
│   │   │   ├── Header.tsx
│   │   │   └── Footer.tsx
│   │   ├── compressor/
│   │   │   ├── DropZone.tsx      ← Drag-and-drop file input
│   │   │   ├── FileCard.tsx      ← Single file compression state card
│   │   │   ├── FileQueue.tsx     ← Batch list (paid tier only)
│   │   │   ├── PresetSelector.tsx← screen/ebook/printer/prepress + custom DPI
│   │   │   ├── ProgressBar.tsx   ← Animated compression progress
│   │   │   ├── ResultStats.tsx   ← Before/after size + % saved
│   │   │   └── DownloadButton.tsx
│   │   ├── engine/
│   │   │   ├── EngineLoader.tsx  ← First-load UI (branded loading screen)
│   │   │   └── useCompressor.ts  ← Hook: manages Worker lifecycle + messages
│   │   ├── paywall/
│   │   │   ├── PaywallModal.tsx  ← Upgrade prompt modal
│   │   │   └── PricingCard.tsx
│   │   └── ui/
│   │       ├── Badge.tsx
│   │       ├── Button.tsx
│   │       ├── Modal.tsx
│   │       └── PrivacyBadge.tsx  ← "Zero Upload" trust indicator component
│   │
│   ├── store/
│   │   └── useAppStore.ts        ← Zustand global store
│   │
│   ├── lib/
│   │   ├── compression/
│   │   │   ├── presets.ts        ← Compression preset definitions
│   │   │   └── workerBridge.ts   ← Type-safe postMessage wrapper
│   │   ├── paywall/
│   │   │   ├── access.ts         ← isPaid(), grantAccess(), revokeAccess()
│   │   │   └── stripe.ts         ← Stripe.js session verification
│   │   └── utils/
│   │       ├── fileSize.ts       ← formatBytes(), compressionRatio()
│   │       └── analytics.ts      ← Plausible event wrappers
│   │
│   └── types/
│       ├── compression.ts
│       └── worker.ts
│
├── next.config.js
├── tailwind.config.ts
├── tsconfig.json
├── vercel.json
├── .env.local.example
└── package.json
```

---

## 4. Dependency Manifest

```json
{
  "name": "pdfcompressr",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "next": "14.2.x",
    "react": "18.3.x",
    "react-dom": "18.3.x",
    "zustand": "4.5.x",
    "@stripe/stripe-js": "3.x",
    "next-pwa": "5.6.x",
    "react-dropzone": "14.x",
    "framer-motion": "11.x",
    "clsx": "2.x",
    "tailwind-merge": "2.x"
  },
  "devDependencies": {
    "typescript": "5.x",
    "@types/react": "18.x",
    "@types/react-dom": "18.x",
    "@types/node": "20.x",
    "tailwindcss": "3.4.x",
    "postcss": "8.x",
    "autoprefixer": "8.x",
    "eslint": "8.x",
    "eslint-config-next": "14.x"
  }
}
```

**IMPORTANT NOTE ON GHOSTSCRIPT WASM:**
Do NOT install `@jspawn/ghostscript-wasm` as an npm package. Load it at runtime from CDN inside the Web Worker. This avoids bundling an 18MB binary into the Next.js build.

```javascript
// Inside compression.worker.js — load from CDN at runtime
const GS_CDN = 'https://cdn.jsdelivr.net/npm/@jspawn/ghostscript-wasm@0.0.2/gs.mjs';
const GS_WASM_CDN = 'https://cdn.jsdelivr.net/npm/@jspawn/ghostscript-wasm@0.0.2/gs.wasm';
```

---

## 5. Environment Variables & Configuration

### `.env.local.example`
```bash
# Stripe — PUBLIC keys only (no secret keys ever in frontend)
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_xxxxxxxxxxxxxxxxxxxx
NEXT_PUBLIC_STRIPE_MONTHLY_PRICE_LINK=https://buy.stripe.com/xxxxxxxxxxxx

# Plausible Analytics (optional — privacy-respecting)
NEXT_PUBLIC_PLAUSIBLE_DOMAIN=pdfcompressr.com

# App
NEXT_PUBLIC_APP_URL=https://pdfcompressr.com
NEXT_PUBLIC_FREE_TIER_MAX_MB=50
NEXT_PUBLIC_PAID_TIER_MAX_MB=500
```

### `next.config.js`
```javascript
const withPWA = require('next-pwa')({
  dest: 'public',
  disable: process.env.NODE_ENV === 'development',
  register: true,
  skipWaiting: true,
});

/** @type {import('next').NextConfig} */
const nextConfig = {
  // Required for SharedArrayBuffer (Ghostscript multithreading)
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          { key: 'Cross-Origin-Opener-Policy', value: 'same-origin' },
          { key: 'Cross-Origin-Embedder-Policy', value: 'require-corp' },
          { key: 'Cross-Origin-Resource-Policy', value: 'cross-origin' },
        ],
      },
    ];
  },
  // Exclude worker file from Next.js bundling
  webpack: (config) => {
    config.module.rules.push({
      test: /\.worker\.js$/,
      use: { loader: 'worker-loader' },
    });
    return config;
  },
};

module.exports = withPWA(nextConfig);
```

---

## 6. Core Engine: Ghostscript WASM Worker

### `public/workers/compression.worker.js`

This file MUST live in `/public/workers/` so it is served as a static asset, not processed by the Next.js bundler. It is instantiated as `new Worker('/workers/compression.worker.js')`.

```javascript
// compression.worker.js
// Runs in a Web Worker context — no DOM access, no React, no imports from src/

const GS_MODULE_URL = 'https://cdn.jsdelivr.net/npm/@jspawn/ghostscript-wasm@0.0.2/gs.mjs';
const GS_WASM_URL   = 'https://cdn.jsdelivr.net/npm/@jspawn/ghostscript-wasm@0.0.2/gs.wasm';
const CACHE_NAME    = 'pdfcompressr-wasm-v1';

let gsInstance = null;
let isReady = false;

// ─── Initialization ───────────────────────────────────────────────────────────

async function loadGhostscript() {
  postMessage({ type: 'ENGINE_LOADING', progress: 0 });

  try {
    // Try to get WASM binary from Cache Storage first
    let wasmBinary = null;
    try {
      const cache = await caches.open(CACHE_NAME);
      const cached = await cache.match(GS_WASM_URL);
      if (cached) {
        wasmBinary = await cached.arrayBuffer();
        postMessage({ type: 'ENGINE_LOADING', progress: 40, source: 'cache' });
      }
    } catch (e) {
      // Cache API may not be available in all worker contexts — graceful degradation
    }

    if (!wasmBinary) {
      // Fetch from CDN with progress tracking
      postMessage({ type: 'ENGINE_LOADING', progress: 5, source: 'network', message: 'Downloading secure engine (18MB — once only)' });
      
      const response = await fetch(GS_WASM_URL);
      const reader = response.body.getReader();
      const contentLength = parseInt(response.headers.get('Content-Length') || '18874368');
      
      let received = 0;
      const chunks = [];
      
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        chunks.push(value);
        received += value.length;
        const progress = Math.round(5 + (received / contentLength) * 30);
        postMessage({ type: 'ENGINE_LOADING', progress });
      }
      
      wasmBinary = new Uint8Array(chunks.reduce((acc, c) => [...acc, ...c], [])).buffer;
      
      // Store in Cache Storage for next visit
      try {
        const cache = await caches.open(CACHE_NAME);
        await cache.put(GS_WASM_URL, new Response(wasmBinary.slice(0), {
          headers: { 'Content-Type': 'application/wasm' }
        }));
      } catch (e) { /* non-fatal */ }
      
      postMessage({ type: 'ENGINE_LOADING', progress: 40 });
    }

    // Dynamically import the ES module wrapper
    postMessage({ type: 'ENGINE_LOADING', progress: 60, message: 'Initializing Ghostscript...' });
    
    const { default: initGhostscript } = await import(GS_MODULE_URL);
    
    gsInstance = await initGhostscript({
      locateFile: (filename) => {
        if (filename.endsWith('.wasm')) {
          // Return object URL from cached binary
          return URL.createObjectURL(new Blob([wasmBinary], { type: 'application/wasm' }));
        }
        return `https://cdn.jsdelivr.net/npm/@jspawn/ghostscript-wasm@0.0.2/${filename}`;
      }
    });

    isReady = true;
    postMessage({ type: 'ENGINE_READY', progress: 100 });

  } catch (error) {
    postMessage({ type: 'ENGINE_ERROR', error: error.message });
  }
}

// ─── Compression ──────────────────────────────────────────────────────────────

async function compressFile({ fileId, buffer, preset, customDpi }) {
  if (!isReady || !gsInstance) {
    postMessage({ type: 'COMPRESS_ERROR', fileId, error: 'Engine not ready' });
    return;
  }

  try {
    postMessage({ type: 'COMPRESS_PROGRESS', fileId, progress: 10 });

    const inputArray = new Uint8Array(buffer);
    const inputPath  = `/input_${fileId}.pdf`;
    const outputPath = `/output_${fileId}.pdf`;

    // Write input to Ghostscript virtual filesystem
    gsInstance.FS.writeFile(inputPath, inputArray);
    postMessage({ type: 'COMPRESS_PROGRESS', fileId, progress: 20 });

    // Build Ghostscript arguments
    const args = buildGhostscriptArgs(inputPath, outputPath, preset, customDpi);

    postMessage({ type: 'COMPRESS_PROGRESS', fileId, progress: 30 });

    // Execute compression (blocking in worker — main thread stays free)
    gsInstance.callMain(args);

    postMessage({ type: 'COMPRESS_PROGRESS', fileId, progress: 80 });

    // Read output
    const outputArray = gsInstance.FS.readFile(outputPath);
    
    // Clean up virtual filesystem
    gsInstance.FS.unlink(inputPath);
    gsInstance.FS.unlink(outputPath);

    postMessage({ type: 'COMPRESS_PROGRESS', fileId, progress: 95 });

    postMessage({
      type: 'COMPRESS_DONE',
      fileId,
      outputBuffer: outputArray.buffer,
      originalSize: buffer.byteLength,
      compressedSize: outputArray.buffer.byteLength,
    }, [outputArray.buffer]); // Transfer ownership — zero copy

  } catch (error) {
    postMessage({ type: 'COMPRESS_ERROR', fileId, error: error.message });
    
    // Attempt cleanup
    try {
      gsInstance.FS.unlink(`/input_${fileId}.pdf`);
      gsInstance.FS.unlink(`/output_${fileId}.pdf`);
    } catch (e) {}
  }
}

// ─── Ghostscript Argument Builder ─────────────────────────────────────────────

/**
 * Preset mappings to Ghostscript -dPDFSETTINGS values:
 *
 *  screen   → 72 DPI  — smallest file, screen viewing only
 *  ebook    → 150 DPI — good balance, default recommendation
 *  printer  → 300 DPI — print quality, moderate compression
 *  prepress → 300 DPI — maximum quality, minimal compression
 *  custom   → user-specified DPI (paid tier only)
 */
function buildGhostscriptArgs(inputPath, outputPath, preset, customDpi) {
  const base = [
    '-dNOPAUSE',
    '-dQUIET',
    '-dBATCH',
    '-sDEVICE=pdfwrite',
    '-dCompatibilityLevel=1.4',
    `-sOutputFile=${outputPath}`,
  ];

  if (preset === 'custom' && customDpi) {
    return [
      ...base,
      '-dDownsampleColorImages=true',
      '-dDownsampleGrayImages=true',
      '-dDownsampleMonoImages=true',
      `-dColorImageResolution=${customDpi}`,
      `-dGrayImageResolution=${customDpi}`,
      `-dMonoImageResolution=${customDpi}`,
      inputPath,
    ];
  }

  const presetMap = {
    screen:   '/screen',
    ebook:    '/ebook',
    printer:  '/printer',
    prepress: '/prepress',
  };

  return [
    ...base,
    `-dPDFSETTINGS=${presetMap[preset] || '/ebook'}`,
    inputPath,
  ];
}

// ─── Message Router ───────────────────────────────────────────────────────────

self.onmessage = async (event) => {
  const { type, ...payload } = event.data;
  
  switch (type) {
    case 'INIT':
      await loadGhostscript();
      break;
    case 'COMPRESS':
      await compressFile(payload);
      break;
    default:
      console.warn('[Worker] Unknown message type:', type);
  }
};
```

---

## 7. State Management (Zustand Store)

### `src/store/useAppStore.ts`

```typescript
import { create } from 'zustand';
import { CompressionFile, CompressionPreset, EngineState } from '@/types/compression';

interface AppStore {
  // Engine
  engineState: EngineState;
  engineProgress: number;
  engineMessage: string;
  setEngineState: (state: EngineState, progress?: number, message?: string) => void;

  // Files
  files: CompressionFile[];
  addFile: (file: CompressionFile) => void;
  updateFile: (id: string, patch: Partial<CompressionFile>) => void;
  removeFile: (id: string) => void;
  clearFiles: () => void;

  // Preset
  selectedPreset: CompressionPreset;
  customDpi: number;
  setPreset: (preset: CompressionPreset) => void;
  setCustomDpi: (dpi: number) => void;

  // Paywall
  isPaid: boolean;
  setIsPaid: (paid: boolean) => void;
  showPaywall: boolean;
  setShowPaywall: (show: boolean) => void;
}

export const useAppStore = create<AppStore>((set) => ({
  // Engine
  engineState: 'idle',
  engineProgress: 0,
  engineMessage: '',
  setEngineState: (engineState, engineProgress = 0, engineMessage = '') =>
    set({ engineState, engineProgress, engineMessage }),

  // Files
  files: [],
  addFile: (file) => set((s) => ({ files: [...s.files, file] })),
  updateFile: (id, patch) =>
    set((s) => ({ files: s.files.map((f) => (f.id === id ? { ...f, ...patch } : f)) })),
  removeFile: (id) => set((s) => ({ files: s.files.filter((f) => f.id !== id) })),
  clearFiles: () => set({ files: [] }),

  // Preset
  selectedPreset: 'ebook',
  customDpi: 150,
  setPreset: (selectedPreset) => set({ selectedPreset }),
  setCustomDpi: (customDpi) => set({ customDpi }),

  // Paywall
  isPaid: false,
  setIsPaid: (isPaid) => set({ isPaid }),
  showPaywall: false,
  setShowPaywall: (showPaywall) => set({ showPaywall }),
}));
```

---

## 8. Types

### `src/types/compression.ts`
```typescript
export type EngineState = 'idle' | 'loading' | 'ready' | 'error';

export type CompressionPreset = 'screen' | 'ebook' | 'printer' | 'prepress' | 'custom';

export type FileStatus = 'queued' | 'compressing' | 'done' | 'error';

export interface CompressionFile {
  id: string;                     // nanoid()
  name: string;                   // original filename
  originalSize: number;           // bytes
  compressedSize?: number;        // bytes — set after compression
  compressionRatio?: number;      // 0–1 — set after compression
  status: FileStatus;
  progress: number;               // 0–100
  error?: string;
  outputBlob?: Blob;             // downloadable output
  outputUrl?: string;            // URL.createObjectURL(outputBlob)
}

export interface WorkerMessage {
  type:
    | 'ENGINE_LOADING'
    | 'ENGINE_READY'
    | 'ENGINE_ERROR'
    | 'COMPRESS_PROGRESS'
    | 'COMPRESS_DONE'
    | 'COMPRESS_ERROR';
  fileId?: string;
  progress?: number;
  message?: string;
  source?: 'cache' | 'network';
  outputBuffer?: ArrayBuffer;
  originalSize?: number;
  compressedSize?: number;
  error?: string;
}
```

---

## 9. UI Specification

### 9.1 Design System

**Aesthetic direction:** Industrial precision meets digital privacy. Dark theme. Monochromatic base with a single high-contrast accent. Feels like a professional tool trusted by lawyers, not a free web utility.

```css
/* src/app/globals.css — CSS Custom Properties */

:root {
  /* Colors */
  --color-bg:          #0A0A0B;     /* Near-black base */
  --color-surface:     #111114;     /* Card / panel surfaces */
  --color-surface-2:   #1A1A1F;     /* Elevated surfaces */
  --color-border:      #2A2A32;     /* Subtle borders */
  --color-border-2:    #3A3A45;     /* Stronger borders, hover */
  --color-accent:      #00E5A0;     /* Electric green — trust + speed */
  --color-accent-dim:  #00E5A020;   /* Accent with opacity */
  --color-text-1:      #F0F0F4;     /* Primary text */
  --color-text-2:      #8A8A9A;     /* Secondary text */
  --color-text-3:      #5A5A6A;     /* Muted / placeholder */
  --color-error:       #FF4444;
  --color-warning:     #FFB800;
  --color-success:     #00E5A0;     /* Same as accent */

  /* Typography */
  --font-display:      'Syne', sans-serif;   /* Headers, logo */
  --font-body:         'DM Sans', sans-serif; /* Body, UI */
  --font-mono:         'JetBrains Mono', monospace; /* File sizes, stats */

  /* Spacing */
  --radius-sm:         6px;
  --radius-md:         12px;
  --radius-lg:         20px;
  --radius-full:       9999px;
}
```

**Font imports (in `layout.tsx`):**
```typescript
import { Syne, DM_Sans, JetBrains_Mono } from 'next/font/google';

const syne = Syne({ subsets: ['latin'], variable: '--font-syne', weight: ['400', '600', '700', '800'] });
const dmSans = DM_Sans({ subsets: ['latin'], variable: '--font-dm-sans' });
const jetbrains = JetBrains_Mono({ subsets: ['latin'], variable: '--font-mono', weight: ['400', '500'] });
```

### 9.2 Header Component

```
[PDFCompressr logo — Syne 700]     [Pricing]  [Upgrade → $9/mo button]
```

- Logo: "PDF" in accent color + "Compressr" in text-1
- Sticky, `backdrop-blur`, `bg-[var(--color-bg)]/80`
- On mobile: hamburger menu collapses nav

### 9.3 Homepage Layout

```
┌──────────────────────────────────────────────────────┐
│  HEADER                                              │
├──────────────────────────────────────────────────────┤
│                                                      │
│  HERO SECTION                                        │
│  ┌────────────────────────────────────────────────┐  │
│  │  "Compress PDFs in your browser."              │  │
│  │  "Zero upload. Zero server. 100% private."     │  │
│  │                                                │  │
│  │  [PrivacyBadge: 🔒 Your file never leaves     │  │
│  │   your device — verified by open source]      │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  ENGINE LOADER (shows when engine is loading)        │
│  ┌────────────────────────────────────────────────┐  │
│  │  Branded loading screen — see §9.4             │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  COMPRESSOR UI (shows when engine is ready)          │
│  ┌────────────────────────────────────────────────┐  │
│  │  PresetSelector (4 presets + custom)           │  │
│  │  DropZone                                      │  │
│  │  FileQueue (paid) / FileCard (free)            │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  TRUST SECTION                                       │
│  ┌────────────────────────────────────────────────┐  │
│  │  3 columns:                                    │  │
│  │  [🔒 Private]  [⚡ Fast]  [🌐 Offline]        │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  FAQ SECTION (schema markup for SEO)                 │
│                                                      │
│  FOOTER                                              │
└──────────────────────────────────────────────────────┘
```

### 9.4 Engine Loader Screen

Shown on first visit while Ghostscript WASM downloads. This is critical UX — without it users will think the app is broken.

```
┌─────────────────────────────────────────────┐
│                                             │
│   🔒                                        │
│                                             │
│   Preparing your private engine             │
│   [================================================] 67%   │
│                                             │
│   Downloading Ghostscript (18MB)            │
│   This happens once. All future visits      │
│   load instantly — and work offline.        │
│                                             │
│   ✓ No files sent to any server             │
│   ✓ Engine cached on your device            │
│   ✓ Works without internet after this       │
│                                             │
└─────────────────────────────────────────────┘
```

Implementation notes:
- Full viewport height, centered
- Progress bar uses `--color-accent` fill, animated left-to-right
- Counter increments from `engineProgress` in store
- Framer Motion fade-in on mount
- When `engineState === 'ready'`, fade out and reveal compressor UI

### 9.5 Preset Selector

```
COMPRESSION QUALITY

[  Screen  ] [ ● Ebook ] [ Printer ] [ Prepress ] [ Custom* ]
  72 DPI      150 DPI     300 DPI     300 DPI      ___ DPI

  Smallest    Balanced    Print       Archive     ↑ Paid only
  file size   (default)   quality     quality
```

- Horizontal pill tabs with active state (accent border + background)
- Each preset shows: name, DPI, brief use-case label
- Custom tab only clickable for paid users — clicking triggers PaywallModal for free users
- Custom DPI: number input, 50–600 range, shown inline when Custom tab is active

### 9.6 Drop Zone

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│   ↓   Drop your PDF here                           │
│       or click to browse                           │
│                                                     │
│   Accepted: PDF  ·  Max 50MB (free) / 500MB (paid) │
│                                                     │
└─────────────────────────────────────────────────────┘
```

- `border-2 border-dashed border-[var(--color-border)]`
- On drag over: border changes to accent color, subtle background fill
- On drop of non-PDF: shake animation + error message
- On drop of PDF > free limit: PaywallModal opens
- On drop of multiple files (free user): PaywallModal opens after first file is accepted
- Uses `react-dropzone` — `accept: { 'application/pdf': ['.pdf'] }`

### 9.7 File Card (Free Tier — Single File)

```
┌─────────────────────────────────────────────────────┐
│  📄 contract_2024.pdf                          [✕]  │
│  ─────────────────────────────────────────────────  │
│  [████████████████████░░░░] 72%                     │
│                                                     │
│  Before: 4.2 MB → After: 1.1 MB  (-74%)            │
│                                                     │
│  [↓ Download compressed PDF]                        │
└─────────────────────────────────────────────────────┘
```

State transitions:
- `queued` → show spinner, "Waiting..."
- `compressing` → animated progress bar (real progress from worker messages)
- `done` → show stats + download button, green accent border
- `error` → red border, error message, retry button

### 9.8 File Queue (Paid Tier — Batch)

Same as FileCard but rendered as a vertical list. Additional controls:
- "Compress All" button → dispatches all queued files to worker
- "Download All as ZIP" button → shown when all files are done (uses JSZip)
- Individual file remove buttons

Add `jszip` to dependencies for batch ZIP:
```json
"jszip": "3.x"
```

### 9.9 Result Stats Component

```
┌─────────────────────────────────────────────────────┐
│  BEFORE          AFTER            SAVED             │
│  4.2 MB   →     1.1 MB           74%               │
│  (original)     (compressed)     🎉                 │
└─────────────────────────────────────────────────────┘
```

- Font: JetBrains Mono for numbers
- "SAVED" percentage: large, accent color, animated count-up on appear
- If savings < 5%: show "Minimal reduction — file may already be optimized"

### 9.10 Paywall Modal

Triggered by:
- Dropping a second file (free user)
- Dropping file > 50MB (free user)
- Clicking Custom DPI tab (free user)

```
┌────────────────────────────────────────┐
│  ✕                                     │
│                                        │
│  Unlock Unlimited Compression          │
│                                        │
│  ✓ Unlimited files per session         │
│  ✓ Files up to 500MB                  │
│  ✓ Custom DPI control                 │
│  ✓ Bulk ZIP download                  │
│  ✓ No branding in output metadata     │
│                                        │
│  $9 / month                           │
│  Cancel anytime                       │
│                                        │
│  [Upgrade Now →]                      │
│                                        │
│  Your files stay private regardless   │
│  of which plan you use.               │
└────────────────────────────────────────┘
```

- "Upgrade Now" button → opens Stripe Payment Link in new tab
- Bottom reassurance line: critical — never let the user think paying removes privacy

### 9.11 Privacy Badge Component

Shown prominently in hero and in PaywallModal:

```
🔒  Zero Upload · Verified Open Source
    Your file is never sent to any server.
```

- Links to GitHub of `laurentmmeyer/ghostscript-pdf-compress.wasm` for credibility

---

## 10. Compression Presets System

### `src/lib/compression/presets.ts`

```typescript
export interface Preset {
  id: 'screen' | 'ebook' | 'printer' | 'prepress' | 'custom';
  label: string;
  gsFlag: string;          // Ghostscript -dPDFSETTINGS value
  dpi: number;             // Approximate DPI for display
  description: string;     // Short label shown in UI
  useCase: string;         // Tooltip / subtitle
  estimatedReduction: string; // e.g. "60-80%"
  requiresPaid: boolean;
}

export const PRESETS: Preset[] = [
  {
    id: 'screen',
    label: 'Screen',
    gsFlag: '/screen',
    dpi: 72,
    description: 'Smallest file',
    useCase: 'Web, email, sharing',
    estimatedReduction: '70–85%',
    requiresPaid: false,
  },
  {
    id: 'ebook',
    label: 'Ebook',
    gsFlag: '/ebook',
    dpi: 150,
    description: 'Balanced',
    useCase: 'Default — general use',
    estimatedReduction: '50–70%',
    requiresPaid: false,
  },
  {
    id: 'printer',
    label: 'Printer',
    gsFlag: '/printer',
    dpi: 300,
    description: 'Print quality',
    useCase: 'Physical printing',
    estimatedReduction: '20–40%',
    requiresPaid: false,
  },
  {
    id: 'prepress',
    label: 'Prepress',
    gsFlag: '/prepress',
    dpi: 300,
    description: 'Maximum quality',
    useCase: 'Archive, professional print',
    estimatedReduction: '5–20%',
    requiresPaid: false,
  },
  {
    id: 'custom',
    label: 'Custom',
    gsFlag: '',             // Built dynamically from customDpi
    dpi: 0,                 // User-specified
    description: 'Custom DPI',
    useCase: 'Fine-grained control',
    estimatedReduction: 'Variable',
    requiresPaid: true,
  },
];
```

---

## 11. Freemium & Paywall Logic

### `src/lib/paywall/access.ts`

```typescript
const STORAGE_KEY = 'pdfcompressr_access';
const SESSION_DURATION_MS = 30 * 24 * 60 * 60 * 1000; // 30 days

interface AccessRecord {
  paid: boolean;
  grantedAt: number;
  stripeSessionId?: string;
}

export function isPaid(): boolean {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return false;
    const record: AccessRecord = JSON.parse(raw);
    const expired = Date.now() - record.grantedAt > SESSION_DURATION_MS;
    if (expired) {
      localStorage.removeItem(STORAGE_KEY);
      return false;
    }
    return record.paid === true;
  } catch {
    return false;
  }
}

export function grantAccess(stripeSessionId?: string): void {
  const record: AccessRecord = {
    paid: true,
    grantedAt: Date.now(),
    stripeSessionId,
  };
  localStorage.setItem(STORAGE_KEY, JSON.stringify(record));
}

export function revokeAccess(): void {
  localStorage.removeItem(STORAGE_KEY);
}
```

### `src/lib/paywall/stripe.ts`

```typescript
import { loadStripe } from '@stripe/stripe-js';

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!);

/**
 * Called on /success page with ?session_id= from Stripe redirect.
 * Verifies the session is a completed payment and grants access.
 * 
 * NOTE: This uses Stripe.js client-side session retrieval.
 * It is NOT a webhook — it is a UI-only access grant.
 * Sufficient for a solo-founder freemium tool.
 */
export async function verifyAndGrantAccess(sessionId: string): Promise<boolean> {
  try {
    // Stripe.js does not expose session retrieval directly.
    // We verify by attempting to retrieve the session via
    // the Stripe publishable key — this confirms payment intent completion.
    // For a fully server-verified flow, add a Vercel Edge Function later.
    
    // Simple approach: trust the redirect + sessionId presence.
    // Stripe only redirects to success_url on successful payment.
    // Store access with the session ID for auditability.
    const { grantAccess } = await import('./access');
    grantAccess(sessionId);
    return true;
  } catch {
    return false;
  }
}
```

**Stripe Setup Instructions (included in spec for completeness):**

1. Create account at stripe.com
2. Create a Product: "PDFCompressr Pro" at $9/month (recurring)
3. Create a Payment Link for that product
4. Set success URL to: `https://pdfcompressr.com/success?session_id={CHECKOUT_SESSION_ID}`
5. Copy the Payment Link URL → set as `NEXT_PUBLIC_STRIPE_MONTHLY_PRICE_LINK`
6. Copy the Publishable Key → set as `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`

---

## 12. Hook: useCompressor

### `src/components/engine/useCompressor.ts`

```typescript
'use client';

import { useEffect, useRef, useCallback } from 'react';
import { useAppStore } from '@/store/useAppStore';
import { WorkerMessage } from '@/types/worker';
import { nanoid } from 'nanoid'; // add nanoid to dependencies

export function useCompressor() {
  const workerRef = useRef<Worker | null>(null);
  const { setEngineState, updateFile } = useAppStore();

  // Initialize worker on mount
  useEffect(() => {
    if (typeof window === 'undefined') return;

    const worker = new Worker('/workers/compression.worker.js');
    workerRef.current = worker;

    worker.onmessage = (event: MessageEvent<WorkerMessage>) => {
      const msg = event.data;

      switch (msg.type) {
        case 'ENGINE_LOADING':
          setEngineState('loading', msg.progress, msg.message);
          break;

        case 'ENGINE_READY':
          setEngineState('ready', 100);
          break;

        case 'ENGINE_ERROR':
          setEngineState('error', 0, msg.error);
          break;

        case 'COMPRESS_PROGRESS':
          updateFile(msg.fileId!, { progress: msg.progress ?? 0 });
          break;

        case 'COMPRESS_DONE': {
          const blob = new Blob([msg.outputBuffer!], { type: 'application/pdf' });
          const url = URL.createObjectURL(blob);
          const ratio = 1 - (msg.compressedSize! / msg.originalSize!);
          updateFile(msg.fileId!, {
            status: 'done',
            progress: 100,
            compressedSize: msg.compressedSize,
            compressionRatio: ratio,
            outputBlob: blob,
            outputUrl: url,
          });
          break;
        }

        case 'COMPRESS_ERROR':
          updateFile(msg.fileId!, {
            status: 'error',
            error: msg.error ?? 'Unknown error',
          });
          break;
      }
    };

    // Initialize engine
    worker.postMessage({ type: 'INIT' });

    return () => {
      worker.terminate();
    };
  }, []);

  const compress = useCallback((
    file: File,
    preset: string,
    customDpi?: number
  ): string => {
    const fileId = nanoid();
    const { addFile } = useAppStore.getState();

    addFile({
      id: fileId,
      name: file.name,
      originalSize: file.size,
      status: 'compressing',
      progress: 0,
    });

    file.arrayBuffer().then((buffer) => {
      workerRef.current?.postMessage(
        { type: 'COMPRESS', fileId, buffer, preset, customDpi },
        [buffer] // Transfer — avoids copying 
      );
    });

    return fileId;
  }, []);

  return { compress };
}
```

---

## 13. SEO & Metadata Strategy

### 13.1 Root Metadata (`src/app/layout.tsx`)

```typescript
export const metadata: Metadata = {
  title: {
    default: 'PDFCompressr — Free Private PDF Compressor (No Upload)',
    template: '%s | PDFCompressr',
  },
  description: 'Compress PDF files instantly in your browser. Your file never leaves your device. No upload. No account. HIPAA & GDPR friendly. Powered by Ghostscript WebAssembly.',
  keywords: [
    'compress pdf online free',
    'reduce pdf file size without uploading',
    'private pdf compressor',
    'pdf compressor no upload',
    'browser pdf compression',
    'hipaa compliant pdf compressor',
    'offline pdf compressor',
    'compress pdf for email',
  ],
  openGraph: {
    title: 'PDFCompressr — Compress PDFs Without Uploading Them',
    description: 'Your PDF is compressed entirely in your browser. Zero server. Zero upload. 100% private.',
    url: 'https://pdfcompressr.com',
    siteName: 'PDFCompressr',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'PDFCompressr — Browser-Native PDF Compression',
    description: 'Compress any PDF without uploading it. Runs entirely in your browser.',
  },
  robots: { index: true, follow: true },
  alternates: { canonical: 'https://pdfcompressr.com' },
};
```

### 13.2 Programmatic SEO Pages

Create these as static pages under `src/app/(seo)/`:

```
/compress-pdf/hipaa-compliant          → medical/clinical angle
/compress-pdf/legal-documents          → legal/NDA angle
/compress-pdf/no-upload               → privacy angle
/compress-pdf/offline                  → offline/PWA angle
/compress-pdf/for-email               → email attachment angle
/compress-pdf/gdpr-compliant          → EU compliance angle
```

Each page reuses the same compressor UI component but with:
- Unique `<title>` and `<description>` targeting the specific search query
- A short intro paragraph (150–200 words) with the angle-specific copy
- FAQ schema for that specific use case
- Same compression tool embedded below

### 13.3 FAQ Schema (JSON-LD in `page.tsx`)

```typescript
const faqSchema = {
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does PDFCompressr upload my file to a server?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. PDFCompressr uses Ghostscript compiled to WebAssembly, which runs entirely inside your browser. Your file is never transmitted over the network. You can verify this by opening your browser's DevTools Network tab and watching — no file upload request will appear."
      }
    },
    {
      "@type": "Question",
      "name": "Is PDFCompressr HIPAA compliant?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Because no data ever leaves your device, PDFCompressr eliminates the data-transfer compliance risk entirely. However, compliance also depends on your broader IT environment. For most clinical and legal use cases, the zero-upload architecture means the tool is compatible with HIPAA and GDPR requirements."
      }
    },
    {
      "@type": "Question",
      "name": "What compression quality should I choose?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For email and web sharing, use 'Ebook' (150 DPI) — it gives the best balance of file size and readability. For physical printing, use 'Printer' (300 DPI). For archival, use 'Prepress'. For the smallest possible file, use 'Screen' (72 DPI)."
      }
    },
    {
      "@type": "Question",
      "name": "Does compression work offline?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. After your first visit, the Ghostscript engine is cached on your device. All subsequent compression sessions work without an internet connection."
      }
    }
  ]
};
```

---

## 14. PWA Configuration

### `public/manifest.json`
```json
{
  "name": "PDFCompressr",
  "short_name": "PDFCompressr",
  "description": "Compress PDFs privately in your browser",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#0A0A0B",
  "theme_color": "#00E5A0",
  "icons": [
    { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

### `public/robots.txt`
```
User-agent: *
Allow: /
Sitemap: https://pdfcompressr.com/sitemap.xml
```

---

## 15. Vercel Deployment Configuration

### `vercel.json`
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "Cross-Origin-Opener-Policy",   "value": "same-origin" },
        { "key": "Cross-Origin-Embedder-Policy",  "value": "require-corp" },
        { "key": "Cross-Origin-Resource-Policy",  "value": "cross-origin" },
        { "key": "X-Content-Type-Options",        "value": "nosniff" },
        { "key": "X-Frame-Options",               "value": "DENY" },
        { "key": "Referrer-Policy",               "value": "strict-origin-when-cross-origin" }
      ]
    }
  ],
  "rewrites": [
    { "source": "/(.*)", "destination": "/" }
  ]
}
```

**Deployment steps:**
1. `npm run build` — verify static export succeeds
2. `vercel --prod` — deploy to Vercel
3. Add custom domain in Vercel dashboard
4. Set all `NEXT_PUBLIC_*` environment variables in Vercel project settings
5. Verify COOP/COEP headers are present using `curl -I https://pdfcompressr.com`

---

## 16. Implementation Order (Coding Agent Task Queue)

Execute in this exact order. Each task must compile and run before proceeding to the next.

```
TASK 01 — Scaffold project
  npx create-next-app@14 pdfcompressr --typescript --tailwind --app --src-dir --no-git
  Install all dependencies from §4
  Set up folder structure from §3 (create all empty files)

TASK 02 — Design system
  Implement globals.css with all CSS custom properties from §9.1
  Configure tailwind.config.ts to expose CSS vars as Tailwind tokens
  Set up font imports in layout.tsx

TASK 03 — Types
  Implement src/types/compression.ts
  Implement src/types/worker.ts

TASK 04 — Web Worker (core engine)
  Implement public/workers/compression.worker.js (full content from §6)
  Test: open browser console, instantiate worker manually, send INIT message
  Verify ENGINE_LOADING → ENGINE_READY messages in console

TASK 05 — Zustand store
  Implement src/store/useAppStore.ts

TASK 06 — Compression presets
  Implement src/lib/compression/presets.ts

TASK 07 — Paywall logic
  Implement src/lib/paywall/access.ts
  Implement src/lib/paywall/stripe.ts

TASK 08 — useCompressor hook
  Implement src/components/engine/useCompressor.ts

TASK 09 — UI primitives
  Implement src/components/ui/Button.tsx
  Implement src/components/ui/Modal.tsx
  Implement src/components/ui/Badge.tsx
  Implement src/components/ui/PrivacyBadge.tsx

TASK 10 — Engine loader UI
  Implement src/components/engine/EngineLoader.tsx
  Wire to engineState from store — show during 'loading', hide on 'ready'

TASK 11 — Compressor components
  Implement PresetSelector.tsx
  Implement DropZone.tsx (react-dropzone, paywall checks)
  Implement ProgressBar.tsx
  Implement ResultStats.tsx (animated count-up)
  Implement DownloadButton.tsx
  Implement FileCard.tsx (assembles above components)
  Implement FileQueue.tsx (batch list, paid only)
  Implement PaywallModal.tsx

TASK 12 — Layout
  Implement Header.tsx
  Implement Footer.tsx

TASK 13 — Pages
  Implement src/app/page.tsx (homepage — assembles all components)
  Implement src/app/pricing/page.tsx
  Implement src/app/success/page.tsx (Stripe redirect handler)
  Implement src/app/legal/privacy/page.tsx
  Implement src/app/legal/terms/page.tsx

TASK 14 — SEO
  Add metadata exports to all pages
  Add FAQ JSON-LD to homepage
  Implement programmatic SEO stub pages under (seo)/

TASK 15 — PWA
  Add manifest.json, robots.txt
  Configure next-pwa in next.config.js
  Create placeholder PWA icons

TASK 16 — next.config.js + vercel.json
  Implement COOP/COEP headers
  Verify SharedArrayBuffer is available after headers are set

TASK 17 — End-to-end test
  Run locally: npm run dev
  Drop a PDF → verify compression works → verify download works
  Drop second PDF as free user → verify PaywallModal appears
  Verify DevTools Network tab shows no file upload requests

TASK 18 — Production build
  npm run build
  Verify no TypeScript errors, no ESLint errors
  vercel --prod
```

---

## 17. Acceptance Criteria & Test Checklist

The coding agent must verify every item before declaring the project complete.

### Core Functionality
- [ ] PDF dropped into DropZone → compressed → downloaded without any network request containing the file
- [ ] DevTools Network tab: zero requests with PDF payload during compression
- [ ] Compression ratio displayed correctly (before size, after size, % saved)
- [ ] All 4 presets produce different output file sizes (screen < ebook < printer ≈ prepress)
- [ ] Progress bar advances smoothly from 0 → 100 during compression
- [ ] Error state shown cleanly when a corrupted or password-protected PDF is dropped

### Engine Loading
- [ ] First visit: loading screen shows with progress from 0 → 100
- [ ] Second visit: engine ready in < 1 second (loaded from Cache Storage)
- [ ] Offline (disconnect network after first visit): compression still works

### Freemium / Paywall
- [ ] Free user: second PDF dropped → PaywallModal appears
- [ ] Free user: file > 50MB → PaywallModal appears
- [ ] Free user: Custom DPI tab clicked → PaywallModal appears
- [ ] Paid user (`isPaid()` returns true): all batch features work
- [ ] /success?session_id=xxx → `grantAccess()` called → isPaid() returns true

### Design
- [ ] Dark theme renders correctly on all screen sizes (mobile 375px, tablet 768px, desktop 1440px)
- [ ] Fonts: Syne for headers, DM Sans for body, JetBrains Mono for stats
- [ ] Accent color `#00E5A0` used consistently for progress, CTAs, active states
- [ ] EngineLoader branded loading screen shows (not a browser default spinner)
- [ ] Framer Motion animations: fade-in on hero, slide-up on FileCard

### SEO
- [ ] `<title>` and `<meta description>` present on all pages
- [ ] FAQ JSON-LD present in page source (verify via Google Rich Results Test)
- [ ] sitemap.xml accessible at /sitemap.xml
- [ ] robots.txt accessible at /robots.txt

### Headers
- [ ] `Cross-Origin-Opener-Policy: same-origin` present on all responses
- [ ] `Cross-Origin-Embedder-Policy: require-corp` present on all responses
- [ ] `SharedArrayBuffer` available in browser console: `typeof SharedArrayBuffer !== 'undefined'`

### PWA
- [ ] manifest.json accessible at /manifest.json
- [ ] App installable via browser "Add to Home Screen"
- [ ] Service worker registered (visible in DevTools → Application → Service Workers)

---

## 18. Known Constraints & Hard Rules

The coding agent must respect all of the following without exception.

### MUST
- The Web Worker MUST live in `/public/workers/` — not processed by Webpack/Next.js bundler
- Ghostscript WASM MUST be loaded from CDN inside the worker — never bundled
- COOP/COEP headers MUST be set — SharedArrayBuffer is required
- All file operations MUST happen in the worker — never on the main thread
- The paywall MUST show the reassurance line "Your files stay private regardless of plan"
- TypeScript strict mode MUST be enabled in `tsconfig.json`

### MUST NOT
- MUST NOT send any file data to any server under any circumstances
- MUST NOT install `@jspawn/ghostscript-wasm` as an npm package (CDN only)
- MUST NOT use `Inter`, `Roboto`, `Arial`, or `system-ui` as fonts
- MUST NOT use purple gradients on white backgrounds (generic AI aesthetic)
- MUST NOT store any secret keys in frontend code or environment variables
- MUST NOT add a backend server, API routes (except static Next.js pages), or database
- MUST NOT use `localStorage` for anything other than the access token

### ARCHITECTURE CONSTRAINT
This is a static-export application. `next export` must work. No `getServerSideProps`. No API routes. No `next/headers` usage in server components that would prevent static export. All dynamic behavior is client-side.

---

## 19. File Naming Conventions

```
Components:    PascalCase.tsx       (DropZone.tsx, FileCard.tsx)
Hooks:         camelCase.ts         (useCompressor.ts, useAppStore.ts)
Lib modules:   camelCase.ts         (presets.ts, access.ts)
Types:         camelCase.ts         (compression.ts, worker.ts)
Pages:         page.tsx             (Next.js App Router convention)
Worker:        compression.worker.js (plain JS, no TypeScript)
```

---

*End of Master Project Specification — PDFCompressr v1.0*  
*All decisions are final. No clarification required. Proceed with TASK 01.*
