## Master AI Project Specification: Privacy-First Local PDF Compressor
Copy and paste the following comprehensive technical specification directly into your AI coding assistant (e.g., Cursor, GitHub Copilot Workspace, or Claude) to initiate the scaffolding and implementation of the project.
### 1. Project Overview & Architecture Philosophy
**Project Name:** PDFCompressr (Privacy-First Local PDF Compressor)
**Core Philosophy:** To completely eliminate server compute costs and guarantee total data privacy, the traditional cloud-based processing model must be replaced with a localized, client-side execution environment. The application must be engineered to run locally in the client's web browser utilizing WebAssembly (WASM), executing native binary operations on the device hardware.
**Value Proposition:** Zero-upload, hardware-accelerated, instantaneous document size reduction with 100% data privacy guaranteed.
### 2. Technology Stack Requirements
 * **Core Framework:** Build the application using Next.js.
 * **Rendering for Discoverability:** Implement Server-Side Rendering (SSR) or Static Site Generation (SSG). By serving pre-rendered HTML directly from the server, automated bots like Googlebot can instantly read programmatic niche landing pages (e.g., /pdf/legal-briefs) in milliseconds without having to execute complex client-side JavaScript.
 * **Client-Side Execution Engine:** * WebAssembly (WASM): This is the foundation of the local execution, allowing you to run native binary operations directly on the user's device hardware.
   * Compression Libraries: Utilize a specialized WASM package compiled from standard C/C++ compression libraries, such as Ghostscript or a Web-wrapped MuPDF.
   * Image Down-sampling: For documents laden with heavy graphics, integrate custom JavaScript wrappers utilizing pdf-lib alongside HTML5 Canvas operations to manipulate and compress images locally.
 * **Application Packaging:** Package the web application as a Progressive Web App (PWA) so it can be installed directly onto desktop or mobile environments. This architecture enables the tool to run completely offline, allowing users to process files on planes, off the grid, or entirely within highly-secured corporate networks that restrict internet access.
### 3. Core Features & Logic Directives
**A. In-Memory Execution & Zero Transit**
 * When a user drags and drops a document into the tool, the browser's local CPU executes the WebAssembly binary code and processes the file entirely inside local memory.
 * The file never leaves the user's machine, and an immediate browser download is triggered upon completion.
**B. Radical Trust Mechanisms (UI/UX)**
 * **The "Network Disconnect" UX Dare:** Add a highly visible toggle or notice instructing users to drop their file, turn off their Wi-Fi, and hit compress. The tool will still work instantly, proving to skeptical corporate or legal users that you never touch a server.
 * **Visual Processing Logs:** Instead of a generic loading spinner, output a real-time terminal feed directly in the browser UI (e.g., *"[WASM] Executing Ghostscript downsampling"* ) as the compiler runs.
**C. Freemium Paywall & Local Enforcement**
 * **Local Usage Tracking:** To manage free-tier limitations without a backend database, store the user's daily usage metrics directly inside the browser's localStorage or IndexedDB.
 * **Execution Blocking:** Write JavaScript logic that increments a local counter each time a file finishes compressing. Once the free limit is reached, the application blocks the file stream from processing and triggers an upgrade modal.
 * **Cryptographic Licensing:** To protect premium tiers (especially for offline PWA users), secure the frontend constraints and unlock premium features by utilizing local cryptographic license keys.
**D. Programmatic SEO (pSEO) Engine**
 * **Subfolder Architecture:** Use dynamic routing subfolders instead of subdomains to ensure domain authority is shared (e.g., compresslocal.com/pdf/bank-statements, compresslocal.com/pdf/legal-briefs).
 * **Dynamic Variable Swapping:** Read the URL slug and dynamically inject tailored placeholder data, titles, and niche-specific SEO content zones into the server-rendered HTML template.
 * **Niche Pre-sets:** Automatically adjust the local WASM engine parameters based on the page. For /architectural-blueprints, set the default to "High Quality/Low Compression"; for /bank-statements, set it to "Max Compression".
### 4. Required Project Directory Scaffolding
```text
/pdf-compressr-master
├── /public
│   ├── manifest.json              # PWA manifest configuration
│   ├── /wasm                      # Compiled Ghostscript/MuPDF WebAssembly binaries
│   └── /icons                     # PWA offline installation assets
├── /src
│   ├── /app
│   │   ├── layout.tsx             # Next.js global layout
│   │   ├── page.tsx               # Primary landing page (Generic Compressor)
│   │   ├── /pdf                   # pSEO Hub Page Directory
│   │   │   ├── page.tsx           # Hub directory ("Browse by Document Type")
│   │   │   └── /[industry]        # Dynamic programmatic route
│   │   │       └── page.tsx       # SSG dynamic page renderer
│   ├── /components
│   │   ├── /Dropzone              # Local file ingestion UI
│   │   ├── /TerminalLogs          # Live WASM execution visualizer UI
│   │   ├── /TrustBadge            # "Network Disconnect UX Dare" component
│   │   └── /PaywallModal          # Upgrade trigger for batch processing
│   ├── /lib
│   │   ├── /wasm-runner           # Wrapper logic connecting WASM to browser thread
│   │   ├── /pdf-lib-utils         # Image downsampling fallbacks (HTML5 Canvas + pdf-lib)
│   │   ├── /local-storage         # Free-tier usage tracking via IndexedDB/localStorage
│   │   └── /crypto-license        # Cryptographic offline license verification logic
│   └── /data
│       └── pseo-config.json       # Database of industries, SEO text, and compression pre-sets
├── next.config.mjs                # Next.js config (enable WASM bundling, configure PWA plugin)
└── package.json

```
### 5. AI Implementation Steps
**Step 1: Initialization & pSEO Routing**
Initialize the Next.js application. Set up the dynamic routing under /src/app/pdf/[industry]/page.tsx. Create the pseo-config.json containing mock data for "legal-briefs", "bank-statements", and "architectural-blueprints". Implement SSG to statically generate these pages based on the JSON configuration, swapping out the <title>, <meta> descriptions, and heading text.
**Step 2: Client-Side Compression Logic**
Implement the /lib/wasm-runner and /lib/pdf-lib-utils. Set up the pdf-lib instance combined with HTML5 Canvas to handle basic graphic down-sampling directly in the browser memory. Ensure the output immediately triggers a local blob download without making any fetch() or POST requests.
**Step 3: The User Interface & Radical Trust**
Build the drag-and-drop ingestion zone. Implement the /components/TerminalLogs to listen to the compression execution state and print realistic logging strings (e.g., *"Reading file bits into browser memory (0B uploaded)..."* ) to the UI. Implement the "Network Disconnect" toggle instructions visually above the dropzone.
**Step 4: Paywall & Local State Enforcement**
Implement the /lib/local-storage functions. Write a hook that checks local_compressions_today on initialization. If the user successfully processes a file, increment the integer. If they attempt a third file or a batch drag-and-drop operation, block the file stream execution and render the /components/PaywallModal.
**Step 5: Offline PWA Packaging**
Configure next-pwa in the next.config.mjs. Ensure all WASM binaries in /public/wasm and the core application routes are aggressively cached by the service worker so the entire application functions flawlessly without a Wi-Fi connection.
