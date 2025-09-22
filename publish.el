;;; publish.el --- Org-mode publishing configuration for notes

;;; Commentary:
;;; This file sets up publishing for the converted notes from Quarto to org-mode

;;; Code:

(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(let ((timestamp-dir (expand-file-name "./.org-timestamps/")))
  (mkdir timestamp-dir t)
  (setq org-publish-timestamp-directory timestamp-dir))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(package-install 'htmlize)

(require 'ox-publish)
(require 'ob-python)
(require 'org-entities)

(defvar my/org-entity-replacements nil
  "Pairs of LaTeX-like entity strings and their UTF-8 replacements.")

(defun my/org-build-entity-replacements ()
  "Build `my/org-entity-replacements` from Org's entity tables."
  (setq my/org-entity-replacements nil)
  (dolist (entity (append org-entities-user org-entities))
    (when (consp entity)
      (let ((latex (nth 1 entity))
            (utf8 (nth 6 entity)))
        (when (and (stringp latex)
                   (string-prefix-p "\\" latex)
                   (stringp utf8)
                   (> (length latex) 0)
                   (> (length utf8) 0))
          (push (cons latex utf8) my/org-entity-replacements)))))
  (setq my/org-entity-replacements
        (sort my/org-entity-replacements
              (lambda (a b)
                (> (length (car a)) (length (car b)))))))

(unless my/org-entity-replacements
  (my/org-build-entity-replacements))

(defvar my/org-lean4-available nil
  "Non-nil when Lean 4 Babel integration is available during publishing.")

(setq my/org-lean4-available
      (condition-case err
          (progn
            (unless (or (featurep 'ob-lean4)
                        (locate-library "ob-lean4"))
              (unless (package-installed-p 'lean4-mode)
                (package-install 'lean4-mode)))
            (if (require 'ob-lean4 nil t)
                t
              (progn
                (message "Lean4 support unavailable: missing ob-lean4")
                nil)))
        (error
         (message "Lean4 support unavailable: %s" (error-message-string err))
         nil)))

(unless my/org-lean4-available
  (message "Skipping Lean 4 code blocks; install lean4-mode to enable evaluation."))

;; Enable org-babel for code execution during publishing
(let ((babel-languages '((python . t)
                         (emacs-lisp . t)
                         (shell . t))))
  (when my/org-lean4-available
    (push '(lean4 . t) babel-languages))
  (org-babel-do-load-languages 'org-babel-load-languages babel-languages))

;; Don't ask for confirmation when executing code blocks during publishing
(setq org-confirm-babel-evaluate nil)

;; Export source and result blocks by default so code output appears in HTML
(dolist (pair '((:exports . "both")
                (:results . "output replace")
                (:eval . "yes")))
  (setq org-babel-default-header-args
        (cons pair (assoc-delete-all (car pair) org-babel-default-header-args))))

;; Set clean execution environment to avoid shell contamination
(setq org-babel-python-command "python3")
(setq python-shell-interpreter "python3")

;; Configure default header arguments to ensure results are exported
(setq org-babel-default-header-args:python
      '((:results . "output replace")
        (:exports . "both")
        (:eval . "yes")
        (:session . "default")
        (:cache . "no")))

(setq org-babel-default-header-args:shell
      '((:results . "output replace")
        (:exports . "both")
        (:eval . "yes")))

(setq org-babel-default-header-args:emacs-lisp
      '((:results . "output replace")
        (:exports . "both")
        (:eval . "yes")))

(when my/org-lean4-available
  (setq org-babel-default-header-args:lean4
        '((:results . "output replace")
          (:exports . "both")
          (:eval . "yes"))))

;; Ensure org-babel evaluates code during export
(setq org-export-babel-evaluate t)
(setq org-export-use-babel t)

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

(defun my/org-html-replace-entities-in-code (text backend info)
  "Render Org entities like \\alpha inside HTML code-ish elements."
  (if (and text (org-export-derived-backend-p backend 'html))
      (let ((result text))
        (dolist (pair my/org-entity-replacements result)
          (setq result
                (replace-regexp-in-string (regexp-quote (car pair))
                                          (cdr pair)
                                          result t t))))
    text))

(add-to-list 'org-export-filter-src-block-functions
             #'my/org-html-replace-entities-in-code)
(add-to-list 'org-export-filter-inline-src-block-functions
             #'my/org-html-replace-entities-in-code)
(add-to-list 'org-export-filter-code-functions
             #'my/org-html-replace-entities-in-code)
(add-to-list 'org-export-filter-verbatim-functions
             #'my/org-html-replace-entities-in-code)

(defun my-org-html-preamble (plist)
  "Generate HTML preamble with navbar."
  "<nav class=\"navbar\">
        <div class=\"navbar-brand\">
            <a href=\"/index.html\">🏠 Home</a>
        </div>
        <div class=\"navbar-menu\">
                <div class=\"navbar-item dropdown\">
                        <a href=\"#\" class=\"dropbtn\">🖥️ Computación</a>
                        <div class=\"dropdown-content\">
                                <a href=\"/Computacion/index.html\">📋 Resumen</a>
                                <div class=\"dropdown-submenu\">
                                        <a href=\"#\" class=\"submenu-btn\">⚙️ Algoritmos</a>
                                        <div class=\"submenu-content\">
                                                <a href=\"/Computacion/Algoritmos/index.html\">📋 Resumen</a>
                                                <a href=\"/Computacion/Algoritmos/pensamiento.html\">🧠 Pensamiento algorítmico</a>
                                        </div>
                                </div>
                        </div>
                </div>
                <div class=\"navbar-item dropdown\">
                        <a href=\"#\" class=\"dropbtn\">🤖 AI</a>
                        <div class=\"dropdown-content\">
                                <a href=\"/AI/index.html\">📋 Resumen</a>
                                <div class=\"dropdown-submenu\">
                                        <a href=\"#\" class=\"submenu-btn\">📚 CS229</a>
                                        <div class=\"submenu-content\">
                                                <a href=\"/AI/CS229/index.html\">📋 Resumen</a>
                                                <a href=\"/AI/CS229/AprendizajeSupervisado/aprendizaje_supervisado.html\">🎯 Aprendizaje Supervisado</a>
                                                <a href=\"/AI/CS229/AprendizajeSupervisado/regresion_lineal.html\">📈 Regresión Lineal</a>
                                        </div>
                                </div>
                                <div class=\"dropdown-submenu\">
                                        <a href=\"#\" class=\"submenu-btn\">🏗️ DataCamp</a>
                                        <div class=\"submenu-content\">
                                                <a href=\"/AI/DataCamp/index.html\">📋 Resumen</a>
                                                <a href=\"/AI/DataCamp/desglosando_el_transformer.html\">🔍 Desglosando el Transformer</a>
                                                <a href=\"/AI/DataCamp/embedding_y_codificacion_posicional.html\">🔗 Embedding y Codificación Posicional</a>
                                        </div>
                                </div>
                        </div>
                </div>
                <div class=\"navbar-item dropdown\">
                        <a href=\"#\" class=\"dropbtn\">🔤 Tipos</a>
                        <div class=\"dropdown-content\">

                                <div class=\"dropdown-submenu\">
                                        <a href=\"#\" class=\"submenu-btn\">✍️ Pruebas y tipos</a>
                                        <div class=\"submenu-content\">
                                                <a href=\"/Tipos/ProofsAndTypes/index.html\">📋 Resumen </a>
                                                <a href=\"/Tipos/ProofsAndTypes/sentido.html\">🧠 Sentido, denotación y semántica</a>
                                        </div>
                                </div>

                                <div class=\"dropdown-submenu\">
                                        <a href=\"#\" class=\"submenu-btn\">🔬 HoTT</a>
                                        <div class=\"submenu-content\">
                                                <div class=\"dropdown-submenu\">
                                                        <a href=\"#\" class=\"submenu-btn\">🏫 HoTT (Carnegie Mellon)</a>
                                                        <div class=\"submenu-content\">
                                                                <a href=\"/Tipos/HoTT/Curso/index.html\">📋 Resumen</a>
                                                                <a href=\"/Tipos/HoTT/Curso/introduccion.html\">🚀 Introducción</a>
                                                                <a href=\"/Tipos/HoTT/Curso/juicios.html\">⚖️ Juicios</a>
                                                                <a href=\"/Tipos/HoTT/Curso/transitividad.html\">🔛 Transitividad </a>
                                                                <a href=\"/Tipos/HoTT/Curso/exponenciales.html\">🗼 Exponenciales</a>
                                                                <a href=\"/Tipos/HoTT/Curso/igualdad.html\">🟰 Igualdad</a>
                                                        </div>
                                                </div>

                                                <div class=\"dropdown-submenu\">
                                                        <a href=\"#\" class=\"submenu-btn\">📚 Introducción a HoTT (Rijke)</a>
                                                        <div class=\"submenu-content\">
                                                                <a href=\"/Tipos/HoTT/Rijke/index.html\">📋 Resumen </a>
                                                                <a href=\"/Tipos/HoTT/Rijke/intro.html\">📖 Introducción </a>
                                                        </div>
                                                </div>
                                        </div>
                                </div>

                                <div class=\"dropdown-submenu\">
                                        <a href=\"#\" class=\"submenu-btn\">🖥️ Lean</a>
                                        <div class=\"submenu-content\">
                                                <a href=\"/Tipos/Lean/index.html\">📋 Resumen </a>
                                        </div>
                                </div>
                        </div>
                </div>
        </div>
  </nav>")

(setq org-publish-project-alist
      '(
        ;; Notes content
        ("notes-content"
         :base-directory "/home/mou/Desktop/Notas/"
         :base-extension "org"
         :publishing-directory "/home/mou/Desktop/Notas/public/"
         :recursive t
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :auto-preamble t
         :auto-sitemap t
         :sitemap-filename "sitemap.html"
         :sitemap-title "Mis Notas"
         :sitemap-sort-files anti-chronologically
         :with-author nil
         :with-date nil
         :with-toc nil
         :section-numbers nil
         :html-validation-link nil
         :html-head-include-default-style nil
         :html-preamble my-org-html-preamble
         :html-postamble nil
         :babel-evaluate t
         :html-head-extra "<link rel='stylesheet' href='/style.css' />\n<script defer src='/navbar.js'></script>")

        ;; Static files (images, etc.)
        ("notes-static"
         :base-directory "/home/mou/Desktop/Notas/"
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf"
         :publishing-directory "/home/mou/Desktop/Notas/public/"
         :recursive t
         :exclude "Emacs/emacs\\.d/"
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
  processEnvironments: true,
  packages: {'[+]': ['ams', 'newcommand', 'configmacros', 'action', 'cancel', 'color', 'enclose', 'mhchem', 'unicode', 'verb']}
  },
  loader: {
  load: ['[tex]/newcommand', '[tex]/configmacros', '[tex]/action', '[tex]/cancel', '[tex]/color', '[tex]/enclose', '[tex]/mhchem', '[tex]/unicode', '[tex]/verb']
  },
  options: {
  skipHtmlTags: ['script', 'noscript', 'style', 'textarea', 'pre']
  }
  };
  </script>
  <script src=\"%PATH\"></script>
  <script>
  MathJax.startup.defaultReady();
  </script>")

(org-publish-all t)
