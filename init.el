;;; init --- my init file
;;; Commentary:
;;; Code:

;; --------------------------------------------------
;; UTIL
(defmacro comment (&rest body)
  "Comment out one or more s-expressions."
  nil)

;; --------------------------------------------------
;; GARBAGE COLLECTION
;; Minimize garbage collection during startup
(setq gc-cons-threshold most-positive-fixnum)

;; Lower threshold back to 8 MiB (default is 800kB)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (expt 2 23))))

;; --------------------------------------------------
;; STARTUP PERFORMANCE

;; Use a hook so the message doesn't get clobbered by other messages.
;; Ref: https://blog.d46.us/advanced-emacs-startup/
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; --------------------------------------------------
;; NATIVE COMP
;; Suppress display of native comp warnings buffer.
(customize-set-variable 'warning-minimum-level :error)

;; --------------------------------------------------
;; STRAIGHT
;; Ref: https://github.com/radian-software/straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; TODO automate updating
;; straight-fetch-all
;; straight-merge-all
;; straight-freeze-versions
;; commit

;; Configure use-package to use straight.el by default
(customize-set-variable 'straight-use-package-by-default t)

;; --------------------------------------------------
;; USE PACKAGE
;; Ref: https://github.com/jwiegley/use-package
;; Ref: https://jeffkreeftmeijer.com/emacs-straight-use-package/
(straight-use-package 'use-package)
(require 'use-package)

;; --------------------------------------------------
;; NO-LITTERING

;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
					;(setq user-emacs-directory "~/.cache/emacs")

(use-package no-littering)

;; Override where auto save files are saved.
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

;; Override where customizations are saved.
(setq custom-file (no-littering-expand-var-file-name "custom.el"))

;; --------------------------------------------------
;; MINIMAL UI
(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room
(menu-bar-mode -1)          ; Disable the menu bar
(setq visible-bell t)       ; Set up the visible bell

;; --------------------------------------------------
;; FRAME
;; Set frame transparency
;; Make frame transparency overridable
;; (defvar efs/frame-transparency '(90 . 90))
(defvar efs/frame-transparency '(100 . 100))
(set-frame-parameter (selected-frame) 'alpha efs/frame-transparency)
(add-to-list 'default-frame-alist `(alpha . ,efs/frame-transparency))

;; Start window in full screen mode.
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-hook 'emacs-startup-hook
          (lambda ()
	    ;; Note: toggle-frame-fullscreen doesn't work until after some delay on linux.
	    (run-with-timer 1 nil
              (lambda ()
		(toggle-frame-fullscreen)))))

;; --------------------------------------------------
;; FILES
(customize-set-variable 'global-auto-revert-mode t)

;; --------------------------------------------------
;; FONT
(defvar efs/default-font-size 140)
(defvar efs/default-variable-font-size 140)

(set-face-attribute 'default nil        :font "Fira Code" :height efs/default-font-size)
(set-face-attribute 'fixed-pitch nil    :font "Fira Code" :height efs/default-font-size)
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height efs/default-variable-font-size :weight 'regular)

;; --------------------------------------------------
;; THEME
;; Ref: https://github.com/doomemacs/themes
(use-package doom-themes
  :init
  (load-theme 'doom-palenight t)
  (set-face-foreground 'font-lock-string-face  "yellow3")
  (set-face-foreground 'font-lock-comment-face "light green"))

;; --------------------------------------------------
;; WINDOW DIVIDERS
;; Note: the bottom divider only displays if the modeline is hidden.
(set-face-foreground    'window-divider                      "gray25")
;; (customize-set-variable 'window-divider-default-right-width  5)
;; (customize-set-variable 'window-divider-default-bottom-width 5)
(window-divider-mode-apply t)

;; --------------------------------------------------
;; MODELINE

;; Home: https://github.com/seagle0128/doom-modeline
;; Configuration: https://github.com/seagle0128/doom-modeline#customize
;; *NOTE:* The first time you load your configuration on a new machine,
;; you'll need to run `M-x all-the-icons-install-fonts` so that mode line
;; icons display correctly.
(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

;; Put modeline in minibuffer
;; Note: more or less works but not pretty like doom
;; (use-package mini-modeline)
;; Note: hmm for terminal, don't hide modeline since bottom window dividers don't wok

;; --------------------------------------------------
;; YES/NO
(defalias 'yes-or-no-p 'y-or-n-p)

;; --------------------------------------------------
;; WHITESPACE
(add-hook 'before-save-hook 'untabify)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; --------------------------------------------------
;; DISCOVERABILITY
(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

;; --------------------------------------------------
;; GENERAL
(use-package general
  :init
  (general-define-key
   "C-c C-o" 'browse-url))

;; --------------------------------------------------
;; CRUX
(use-package crux)

;; --------------------------------------------------
;; MAGIT
(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; --------------------------------------------------
;; GIT GUTTER
;; Ref: https://www.reddit.com/r/emacs/comments/cbh8f0/minimal_looking_diff_in_fringegutter/
;; Git gutter is great for giving visual feedback on changes, but it doesn't play well
;; with org-mode using org-indent. So I don't use it globally.
(use-package git-gutter
  :defer t
  :hook ((markdown-mode . git-gutter-mode)
         (prog-mode . git-gutter-mode)
         (conf-mode . git-gutter-mode))
  :init
  :config
  (setq git-gutter:disabled-modes '(org-mode asm-mode image-mode)
        git-gutter:update-interval 1
        git-gutter:window-width 2
        git-gutter:ask-p nil)
  (defhydra hydra-git-gutter (:body-pre (git-gutter-mode 1)
					:hint nil)
   "
 Git gutter:
   _j_: next hunk        _s_tage hunk     _q_uit
   _k_: previous hunk    _r_evert hunk    _Q_uit and deactivate git-gutter
   ^ ^                   _p_opup hunk
   _h_: first hunk
   _l_: last hunk        set start _R_evision
 "
   ("j" git-gutter:next-hunk)
   ("k" git-gutter:previous-hunk)
   ("h" (progn (goto-char (point-min))
               (git-gutter:next-hunk 1)))
   ("l" (progn (goto-char (point-min))
               (git-gutter:previous-hunk 1)))
   ("s" git-gutter:stage-hunk)
   ("r" git-gutter:revert-hunk)
   ("p" git-gutter:popup-hunk)
   ("R" git-gutter:set-start-revision)
   ("q" nil :color blue)
   ("Q" (progn (git-gutter-mode -1)
               ;; git-gutter-fringe doesn't seem to
               ;; clear the markup right away
               (sit-for 0.1)
               (git-gutter:clear))
    :color blue)))

(use-package git-gutter-fringe
  :diminish git-gutter-mode
  :after git-gutter
  :demand fringe-helper
  :config
  ;; subtle diff indicators in the fringe
  ;; places the git gutter outside the margins.
  (setq-default fringes-outside-margins t)
  ;; thin fringe bitmaps
  (define-fringe-bitmap 'git-gutter-fr:added
  [224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224]
  nil nil 'center)
  (define-fringe-bitmap 'git-gutter-fr:modified
  [224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224]
  nil nil 'center)
  (define-fringe-bitmap 'git-gutter-fr:deleted
  [0 0 0 0 0 0 0 0 0 0 0 0 0 128 192 224 240 248]
  nil nil 'center))

;; --------------------------------------------------
;; FISH
(use-package fish-mode)

;; --------------------------------------------------
;; FLYCHECK
(use-package flycheck
  :init (global-flycheck-mode))

;; --------------------------------------------------
;; COMPANY
(use-package company
  :init (global-company-mode))

;; --------------------------------------------------
;; YASNIPPET
;; lsp tries to load this by default
(use-package yasnippet)

;; --------------------------------------------------
;; Set scripts to executable on save.
(add-hook 'after-save-hook
  'executable-make-buffer-file-executable-if-script-p)

;; --------------------------------------------------
;; PROJECTILE
(use-package projectile
  :init
  (projectile-mode +1)
  (setq projectile-create-missing-test-files t)

  :bind-keymap
  ("C-c p" . projectile-command-map))

;; --------------------------------------------------
;; VERTICO
(use-package vertico
  :init
  (vertico-mode)

  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)

  ;; Show more candidates
  ;; (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  ;; (setq vertico-cycle t)
  )

;; Optionally use the `orderless' completion style. See
;; `+orderless-dispatch' in the Consult wiki for an advanced Orderless style
;; dispatcher. Additionally enable `partial-completion' for file path
;; expansion. `partial-completion' is important for wildcard support.
;; Multiple files can be opened at once with `find-file' if you enter a
;; wildcard. You may also give the `initials' completion style a try.
(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; A few more useful configurations...
(use-package emacs
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; Alternatively try `consult-completing-read-multiple'.
  (defun crm-indicator (args)
    (cons (concat "[CRM] " (car args)) (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

;; --------------------------------------------------
;; MARGINALIA
(use-package marginalia
  ;; Either bind `marginalia-cycle` globally or only in the minibuffer
  :bind (("M-A" . marginalia-cycle)
         :map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init configuration is always executed (Not lazy!)
  :init

  ;; Must be in the :init section of use-package such that the mode gets
  ;; enabled right away. Note that this forces loading the package.
  (marginalia-mode))

;; --------------------------------------------------
;; CONSULT
(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h" . consult-history)
         ("C-c m" . consult-mode-command)
         ("C-c k" . consult-kmacro)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ("<help> a" . consult-apropos)            ;; orig. apropos-command
         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings (search-map)
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s m" . consult-multi-occur)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi))           ;; needed by consult-line to detect isearch

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  ;; :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Optionally replace `completing-read-multiple' with an enhanced version.
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key (kbd "M-."))
  ;; (setq consult-preview-key (list (kbd "<S-down>") (kbd "<S-up>")))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme
   :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-recent-file
   consult--source-project-recent-file
   ;; :preview-key (kbd "M-.")
   :preview-key '(:debounce 0.2 any)
   )

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; (kbd "C-+")

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-root-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;; There are multiple reasonable alternatives to chose from.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-root-function #'consult--project-root-default-function)
  ;;;; 2. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-root-function #'projectile-project-root)
  ;;;; 3. vc.el (vc-root-dir)
  ;; (setq consult-project-root-function #'vc-root-dir)
  ;;;; 4. locate-dominating-file
  ;; (setq consult-project-root-function (lambda () (locate-dominating-file "." ".git")))
)

;; --------------------------------------------------
;; CLOJURE
;; TODO http://ccann.github.io/2015/10/18/cider.html
;; TODO https://github.com/howardabrams/dot-files/blob/master/emacs-clojure.org
;; TODO https://github.com/mpenet/clojure-snippets

;; clj-kondo
(use-package flycheck-clj-kondo)

(use-package clojure-mode
  :mode (("\\.clj\\'" . clojure-mode)
         ("\\.edn\\'" . clojure-mode))
  :hook ((clojure-mode . lsp)
	 (clojure-mode . yas-minor-mode))
  :config
  (require 'flycheck-clj-kondo))

;; cider
(use-package cider)

;; paren highlighting
(show-paren-mode t)
(use-package rainbow-delimiters
  :hook (clojure-mode . rainbow-delimiters-mode))

;; --------------------------------------------------
;; BABASHKA
(projectile-register-project-type
 'babashka     '("bb.edn")
 :project-file "bb.edn"
 :test-suffix  "_test")

;; --------------------------------------------------
;; LSP
;; Ref: https://emacs-lsp.github.io/lsp-mode/tutorials/how-to-turn-off/

(use-package lsp-mode
  ;; :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  :init
  (setq lsp-headerline-breadcrumb-enable nil)

  :custom
  (setq lsp-keymap-prefix "C-c l")

  :hook ((lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

(use-package lsp-ui
  :commands lsp-ui-mode)

(use-package lsp-treemacs
  :commands lsp-treemacs-errors-list)

;; --------------------------------------------------
;; LISPY
(add-hook 'emacs-lisp-mode-hook (lambda () (lispy-mode 1)))
(add-hook 'clojure-mode-hook #'lispy-mode)
;; (defvar lispy-compat)
(use-package lispy
  :defer t
  :init (setq lispy-compat '(cider magit-blame-mode)))

;; --------------------------------------------------
;; SCREEN SHARING

;; TODO treemacs
;; ctrl-t transpose-chars
;; alt-t  transpose-words
;; control-shift-T ?

;; Line numbers
;; (global-display-line-numbers-mode t)
;; (column-number-mode)

;; Disable line numbers for some modes
;; (dolist (mode '(org-mode-hook
;; 		term-mode-hook
;; 		shell-mode-hook
;; 		treemacs-mode-hook
;; 		eshell-mode-hook))
;;   (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Log commands being entered.
;; TODO doesn't seem to work
;; (use-package command-log-mode
;;   :commands command-log-mode)

;; --------------------------------------------------
;; NIX
(use-package nix-mode
  :defer t
  :mode "\\.nix\\'")

;; --------------------------------------------------
;; ORG MODE
(add-hook 'org-mode-hook
	  (lambda ()
	    (org-babel-do-load-languages
	     'org-babel-load-languages '((dot . t)))))

;; --------------------------------------------------
;; RIPGREP

;; - fast
;; - buttons to configure
;; - no syntax highlighting
;; - replaced my buffer with search results WTF
;; (use-package deadgrep)

;; --------------------------------------------------
;; WINDOW MANAGEMENT

(use-package free-keys)

;; ace-window
;; TODO M-o is bound to lispy-left-maybe
(use-package ace-window
  :bind (("C-x o" . ace-window)))

;; edwina - https://github.com/ajgrf/edwina
(use-package edwina
  :config
  (setq display-buffer-base-action '(display-buffer-below-selected))
  (edwina-setup-dwm-keys)
  (edwina-mode 1))

;; --------------------------------------------------
;; Runtime Performance
;; Dial the GC threshold back down so that garbage collection happens
;; more frequently but in less time.
(setq gc-cons-threshold (* 2 1000 1000))

(provide 'init)
;;; init.el ends here
