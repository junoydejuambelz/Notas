;;; publish.el --- Org-mode publishing configuration for notes

;;; Commentary:
;;; This file sets up publishing for the converted notes from Quarto to org-mode

;;; Code:

(require 'ox-publish)
(require 'ob-python)

;; Enable org-babel for code execution during publishing
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (emacs-lisp . t)
   (shell . t)))

;; Don't ask for confirmation when executing code blocks during publishing
(setq org-confirm-babel-evaluate nil)

;; Set clean execution environment to avoid shell contamination
(setq org-babel-python-command "python3")
(setq python-shell-interpreter "python3")

;; Configure default header arguments to ensure results are exported
(setq org-babel-default-header-args:python
      '((:results . "output")
        (:exports . "both")
        (:session . "default")
        (:cache . "no")))

;; Ensure org-babel evaluates code during export
(setq org-export-babel-evaluate t)

;; Hook to set clean environment before publishing
(defun setup-clean-publish-environment (backend)
  "Set up clean environment for publishing to avoid shell contamination."
  (setenv "BASH_ENV" "")
  (setenv "PROMPT_COMMAND" "")
  (setenv "PS1" "")
  (setenv "TERM" "dumb")
  (setq shell-file-name "/bin/bash")
  (setq shell-command-switch "-c"))

;; Apply clean environment setup before publishing
(add-hook 'org-export-before-processing-hook 'setup-clean-publish-environment)

;; Simple approach: let org-babel handle evaluation during export naturally
;; This should work with the :exports both header arguments

(defun my-org-html-preamble (plist)
  "Generate HTML preamble with navbar."
  "<nav class=\"navbar\">
  <div class=\"navbar-brand\">
    <a href=\"/index.html\">🏠 Home</a>
  </div>
  <div class=\"navbar-menu\">
    <div class=\"navbar-item dropdown\">
      <a href=\"#\" class=\"dropbtn\">🤖 AI</a>
      <div class=\"dropdown-content\">
        <a href=\"/AI/index.html\">📋 Resumen</a>
        <div class=\"dropdown-submenu\">
          <a href=\"#\" class=\"submenu-btn\">📚 CS229 ▶</a>
          <div class=\"submenu-content\">
            <a href=\"/AI/CS229/index.html\">📋 Resumen</a>
            <a href=\"/AI/CS229/AprendizajeSupervisado/aprendizaje_supervisado.html\">🎯 Aprendizaje Supervisado</a>
            <a href=\"/AI/CS229/AprendizajeSupervisado/regresion_lineal.html\">📈 Regresión Lineal</a>
          </div>
        </div>
        <div class=\"dropdown-submenu\">
          <a href=\"#\" class=\"submenu-btn\">🏗️ DataCamp ▶</a>
          <div class=\"submenu-content\">
            <a href=\"/AI/DataCamp/index.html\">📋 Resumen</a>
            <a href=\"/AI/DataCamp/desglosando_el_transformer.html\">🔍 Desglosando el Transformer</a>
            <a href=\"/AI/DataCamp/embedding_y_codificacion_posicional.html\">🔗 Embedding y Codificación Posicional</a>
          </div>
        </div>
      </div>
    </div>
    <div class=\"navbar-item dropdown\">
      <a href=\"#\" class=\"dropbtn\">🔬 HoTT</a>
      <div class=\"dropdown-content\">
        <a href=\"/HoTT/index.html\">📋 Resumen</a>
        <a href=\"/HoTT/introduccion.html\">🚀 Introducción</a>
        <a href=\"/HoTT/juicios.html\">⚖️ Juicios</a>
      </div>
    </div>
  </div>
</nav>")

(setq org-publish-project-alist
      '(
        ;; Notes content
        ("notes-content"
         :base-directory "/home/mou/Notas/org-mode-notes/"
         :base-extension "org"
         :publishing-directory "/home/mou/Notas/org-mode-notes/_site/"
         :recursive t
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :auto-preamble t
         :auto-sitemap t
         :sitemap-filename "sitemap.html"
         :sitemap-title "Mis Notas"
         :sitemap-sort-files anti-chronologically
         :with-author t
         :with-date t
         :with-toc t
         :section-numbers t
         :html-validation-link nil
         :html-head-include-default-style nil
         :html-preamble my-org-html-preamble
         :html-postamble nil
         :babel-evaluate t
         :html-head-extra "<style>
/* Reset and base styles */
* {
  box-sizing: border-box;
}
html, body, h1, h2, h3, h4, h5, h6, p, ul, ol, li, div {
  margin: 0;
  padding: 0;
}
html {
  font-size: 16px;
  scroll-behavior: smooth;
}
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  background: #0d1117;
  color: #e6edf3;
  line-height: 1.65;
}
#content {
  max-width: min(1200px, 90vw);
  margin: 0 auto;
  padding: 2rem clamp(1.5rem, 4vw, 3rem);
  background: #0d1117;
}

/* Navbar Styles */
.navbar {
  background: rgba(13, 17, 23, 0.95);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid #21262d;
  position: sticky;
  top: 0;
  z-index: 1000;
  padding: 1rem 0;
  margin-bottom: 3rem;
}
.navbar-brand a {
  font-size: 1.25rem;
  font-weight: 600;
  color: #58a6ff !important;
  text-decoration: none;
  margin-left: clamp(1rem, 4vw, 3rem);
  transition: color 0.2s ease;
}
.navbar-brand a:hover {
  color: #79c0ff !important;
}
.navbar-menu {
  float: right;
  margin-right: clamp(1rem, 4vw, 3rem);
}
.navbar-item {
  display: inline-block;
  position: relative;
  margin-left: 1rem;
}
.dropbtn {
  background: none;
  color: #e6edf3 !important;
  padding: 0.5rem 1rem;
  font-size: 0.9rem;
  font-weight: 500;
  border: none;
  cursor: pointer;
  text-decoration: none;
  border-radius: 6px;
  transition: all 0.2s ease;
}
.dropbtn:hover {
  background: rgba(56, 139, 253, 0.1);
  color: #58a6ff !important;
}
.dropdown {
  position: relative;
  display: inline-block;
}
.dropdown-content {
  display: none;
  position: absolute;
  background: #161b22;
  border: 1px solid #21262d;
  min-width: 220px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
  z-index: 1001;
  border-radius: 8px;
  padding: 0.5rem 0;
  right: 0;
  margin-top: 0.5rem;
}
.dropdown-content a {
  color: #e6edf3 !important;
  padding: 0.75rem 1rem;
  text-decoration: none;
  display: block;
  border-radius: 6px;
  margin: 0 0.5rem;
  transition: all 0.2s ease;
  font-size: 0.875rem;
}
.dropdown-content a:hover {
  background: rgba(56, 139, 253, 0.1);
  color: #58a6ff !important;
}
.dropdown:hover .dropdown-content {
  display: block;
}
.dropdown-submenu {
  position: relative;
}
.submenu-btn {
  position: relative;
}
.submenu-content {
  display: none;
  position: absolute;
  left: 100%;
  top: 0;
  background-color: #3a3a3a;
  min-width: 250px;
  box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.3);
  border-radius: 4px;
  padding: 0.5rem 0;
}
.dropdown-submenu:hover .submenu-content {
  display: block;
}
.navbar::after {
  content: \"\";
  display: table;
  clear: both;
}

/* Typography */
h1, h2, h3, h4, h5, h6 {
  color: #f0f6fc;
  font-weight: 600;
  margin: 2.5rem 0 1rem 0;
  line-height: 1.3;
}
h1 { font-size: 2rem; }
h2 {
  font-size: 1.5rem;
  border-bottom: 1px solid #21262d;
  padding-bottom: 0.5rem;
}
h3 { font-size: 1.25rem; }
h4 { font-size: 1.125rem; }
.title {
  text-align: center;
  color: #58a6ff;
  font-size: 2.5rem;
  font-weight: 700;
  margin: 2rem 0;
  letter-spacing: -0.025em;
}
.outline-2 {
  margin-bottom: 3rem;
}
.outline-3, .outline-4 {
  margin-bottom: 2rem;
}
p {
  margin: 1rem 0;
  color: #c9d1d9;
}
/* Code blocks */
pre {
  background: #161b22;
  border: 1px solid #21262d;
  color: #e6edf3;
  padding: 1rem;
  border-left: 3px solid #58a6ff;
  border-radius: 8px;
  overflow-x: auto;
  overflow-y: auto;
  max-height: 600px;
  font-size: 0.875rem;
  margin: 1.5rem 0;
  font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
}
code {
  background: rgba(110, 118, 129, 0.1);
  color: #ff7b72;
  padding: 0.2em 0.4em;
  border-radius: 4px;
  font-size: 0.875em;
  font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
}
pre code {
  background: none;
  padding: 0;
  color: inherit;
}
blockquote {
  background: #0d1117;
  border: 1px solid #21262d;
  border-left: 4px solid #58a6ff;
  color: #8b949e;
  padding: 1rem 1.5rem;
  margin: 1.5rem 0;
  border-radius: 8px;
  font-style: italic;
}
a {
  color: #58a6ff;
  text-decoration: none;
  transition: color 0.2s ease;
}
a:hover {
  color: #79c0ff;
  text-decoration: underline;
}
/* Tables */
table {
  border-collapse: collapse;
  width: 100%;
  margin: 1.5rem 0;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #21262d;
}
th, td {
  padding: 0.75rem 1rem;
  text-align: left;
  border-bottom: 1px solid #21262d;
}
th {
  background: #161b22;
  color: #f0f6fc;
  font-weight: 600;
  font-size: 0.875rem;
}
td {
  color: #c9d1d9;
}
tr:nth-child(even) td {
  background: rgba(110, 118, 129, 0.05);
}
tr:hover td {
  background: rgba(56, 139, 253, 0.1);
}
/* Table of contents */
#table-of-contents {
  background: #161b22;
  border: 1px solid #21262d;
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 3rem;
}
#table-of-contents h2 {
  color: #58a6ff;
  margin: 0 0 1rem 0;
  font-size: 1.25rem;
}
#table-of-contents ul {
  list-style: none;
  padding-left: 1rem;
}
#table-of-contents li {
  margin: 0.5rem 0;
}
#table-of-contents a {
  color: #c9d1d9;
  font-size: 0.9rem;
}
#table-of-contents a:hover {
  color: #58a6ff;
}

/* Source containers */
.org-src-container {
  margin: 1.5rem 0;
}

/* Code results styling with orange bar */
pre.example {
  background: #161b22;
  border: 1px solid #21262d;
  color: #e6edf3;
  padding: 1rem;
  border-left: 3px solid #f85149;
  border-radius: 8px;
  overflow-x: auto;
  overflow-y: auto;
  max-height: 400px;
  margin: 1.5rem 0;
  font-size: 0.875rem;
  font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
}

/* Images */
.figure {
  text-align: center;
  margin: 2rem 0;
}
.figure img {
  max-width: 100%;
  border-radius: 8px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
  border: 1px solid #21262d;
}

/* Lists */
ul, ol {
  padding-left: 2rem;
  margin: 1rem 0;
}
li {
  margin: 0.5rem 0;
  color: #c9d1d9;
}

/* Math */
.MathJax {
  color: #e6edf3;
}

/* LaTeX horizontal scrolling - only for display equations */
mjx-container[display='true'] {
  overflow-x: auto;
  overflow-y: hidden;
  max-width: 100%;
  margin: 1rem 0;
  padding: 0.5rem;
  background: rgba(110, 118, 129, 0.05);
  border-radius: 6px;
  border-left: 3px solid #a5a5a5;
  display: block;
  scrollbar-width: thin;
  scrollbar-color: transparent transparent;
  transition: scrollbar-color 0.3s ease;
}

/* Show scrollbar on hover for Firefox */
mjx-container[display='true']:hover {
  scrollbar-color: #6e7681 #21262d;
}

/* Webkit scrollbars - hidden by default */
mjx-container[display='true']::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

mjx-container[display='true']::-webkit-scrollbar-track {
  background: transparent;
  border-radius: 4px;
  transition: background 0.3s ease;
}

mjx-container[display='true']::-webkit-scrollbar-thumb {
  background: transparent;
  border-radius: 4px;
  transition: background 0.3s ease;
}

/* Show scrollbar on hover for Webkit */
mjx-container[display='true']:hover::-webkit-scrollbar-track {
  background: #21262d;
}

mjx-container[display='true']:hover::-webkit-scrollbar-thumb {
  background: #6e7681;
}

mjx-container[display='true']:hover::-webkit-scrollbar-thumb:hover {
  background: #8b949e;
}

/* Inline math - keep inline */
mjx-container:not([display='true']) {
  display: inline;
  padding: 0.1rem 0.2rem;
}

/* Custom scrollbar styling */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: #21262d;
  border-radius: 4px;
}

::-webkit-scrollbar-thumb {
  background: #6e7681;
  border-radius: 4px;
  transition: background 0.2s ease;
}

::-webkit-scrollbar-thumb:hover {
  background: #8b949e;
}

::-webkit-scrollbar-corner {
  background: #21262d;
}

/* Firefox scrollbar styling */
* {
  scrollbar-width: thin;
  scrollbar-color: #6e7681 #21262d;
}

/* Overflow containers with fade effect */
.overflow-container {
  position: relative;
}

.overflow-container::after {
  content: '';
  position: absolute;
  bottom: 0;
  right: 0;
  width: 20px;
  height: 20px;
  background: linear-gradient(135deg, transparent 50%, #161b22 50%);
  pointer-events: none;
  opacity: 0.7;
}

/* Better table overflow */
.table-wrapper {
  overflow-x: auto;
  margin: 1.5rem 0;
  border: 1px solid #21262d;
  border-radius: 8px;
}

.table-wrapper table {
  margin: 0;
  border: none;
}

/* Responsive improvements */

/* Large screens (desktops) */
@media (min-width: 1400px) {
  #content {
    max-width: min(1400px, 85vw);
    padding: 3rem clamp(2rem, 6vw, 4rem);
  }

  pre {
    max-height: 700px;
    font-size: 0.9rem;
  }

  pre.example {
    max-height: 500px;
    font-size: 0.9rem;
  }

  h1 { font-size: 2.25rem; }
  h2 { font-size: 1.75rem; }
  .title { font-size: 3rem; }
}

/* Medium-large screens */
@media (min-width: 1024px) and (max-width: 1399px) {
  #content {
    max-width: min(1200px, 88vw);
  }

  pre {
    max-height: 650px;
  }

  pre.example {
    max-height: 450px;
  }
}

/* Tablets */
@media (min-width: 769px) and (max-width: 1023px) {
  #content {
    max-width: min(900px, 92vw);
    padding: 2rem clamp(1.5rem, 3vw, 2.5rem);
  }

  pre {
    max-height: 500px;
  }

  pre.example {
    max-height: 350px;
  }
}

/* Mobile */
@media (max-width: 768px) {
  #content {
    max-width: 95vw;
    padding: 1rem;
  }

  pre {
    max-height: 300px;
    font-size: 0.8rem;
  }

  pre.example {
    max-height: 250px;
    font-size: 0.8rem;
  }

  .navbar-brand a {
    margin-left: 1rem;
  }

  .navbar-menu {
    margin-right: 1rem;
  }

  h1 { font-size: 1.75rem; }
  h2 { font-size: 1.5rem; }
  .title { font-size: 2rem; }
}

</style>

")

        ;; Static files (images, etc.)
        ("notes-static"
         :base-directory "/home/mou/Notas/org-mode-notes/"
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf"
         :publishing-directory "/home/mou/Notas/org-mode-notes/_site/"
         :recursive t
         :publishing-function org-publish-attachment)

        ;; Combined project
        ("notes"
         :components ("notes-content" "notes-static"))))

;; MathJax support for LaTeX
(setq org-html-mathjax-options
      '((path "https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js")
        (scale "100")
        (align "center")
        (font "TeX")
        (linebreaks "false")
        (autonumber "AMS")
        (indent "0em")
        (multlinewidth "85%")
        (tagindent ".8em")
        (tagside "right")))

(setq org-html-mathjax-template
      "<script>
  window.MathJax = {
    tex: {
      inlineMath: [['$', '$'], ['\\\\(', '\\\\)']],
      displayMath: [['$$', '$$'], ['\\\\[', '\\\\]']],
      processEscapes: true,
      processEnvironments: true
    },
    options: {
      skipHtmlTags: ['script', 'noscript', 'style', 'textarea', 'pre']
    }
  };
</script>
<script src=\"%PATH\"></script>")

;;; publish.el ends here
