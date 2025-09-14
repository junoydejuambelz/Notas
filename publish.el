;;; publish.el --- Org-mode publishing configuration for notes

;;; Commentary:
;;; This file sets up publishing for the converted notes from Quarto to org-mode

;;; Code:

(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(package-install 'htmlize)

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
                        <a href=\"#\" class=\"dropbtn\">🔬 HoTT</a>
                        <div class=\"dropdown-content\">
                                <a href=\"/HoTT/index.html\">📋 Resumen</a>
                                <a href=\"/HoTT/introduccion.html\">🚀 Introducción</a>
                                <a href=\"/HoTT/juicios.html\">⚖️ Juicios</a>
                                <a href=\"/HoTT/transitividad.html\">🔛 Transitividad </a>
                                <a href=\"/HoTT/exponenciales.html\">🗼 Exponenciales</a>
                                <a href=\"/HoTT/igualdad.html\">🟰 Igualdad</a>
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
         :html-head-extra "<link rel='stylesheet' href='/style.css' />")

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
