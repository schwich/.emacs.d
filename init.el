(setq inhibit-startup-message t)

;; Emacs actually predates UTF8, which to my mind is kinda nuts. So we'll force
;; Emacs to always use unicode characters and UTF8 everywhere.
(when (fboundp 'set-charset-priority)
    (set-charset-priority 'unicode))
(prefer-coding-system                   'utf-8)
(set-terminal-coding-system             'utf-8)
(set-keyboard-coding-system             'utf-8)
(set-selection-coding-system            'utf-8)
(setq locale-coding-system              'utf-8)
(setq-default buffer-file-coding-system 'utf-8)

;; ui general settings
(setq-default frame-title-format '("Emacs :: %b")
              display-line-numbers 'visual
              display-line-numbers-current-absolute t ;; show line number of current line instead of 0
              display-line-numbers-width 4 ;; enough space for huge files
              display-line-numbers-widen nil ;; disable dynamic sizing of line number width
              visible-bell nil ;; no bells
              ring-bell-function #'ignore ;; NO BELLS
              )

;; get rid of unneeded gui elements
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
;; (menu-bar-mode -1)

;; stop emacs from beeping when you hit top/bot of file
;; (setq visible-bell t)

;; make ESC quit prompts (maybe remove after installing Evil mode?
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; C-x C-r is more useful for recent files instead of opening a file as readonly
(global-set-key "\C-x\ \C-r" 'counsel-recentf)

;; leader keys
(defvar jjs-leader-key "SPC" "The default leader key")
(defvar jjs-leader-secondary-key "C-SPC" "The secondary leader key")
(defvar jjs-major-leader-key "," "The default major mode leader key")
(defvar jjs-major-leader-secondary-key "M-," "The secondary major mode leader key")

;; default fonts
(set-face-attribute 'default nil :font "JetBrains Mono" :height 130)
(set-face-attribute 'fixed-pitch nil :font "JetBrains Mono" :height 130)
(set-face-attribute 'variable-pitch nil :font "Cambria" :height 160)


;; set up tabs
(defvar jjs-tab-width 2 "The default tab width for indentation, in spaces")
(setq-default indent-tabs-mode nil ;; don't use tabs, use spaces
	      tab-width jjs-tab-width
	      require-final-newline t) ;; always end files with a newline

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
;; init use-package on non-linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; general
(use-package general
  :commands
  (general-define-key general-override-mode general-evil-setup general--simulate-keys)
  :config
    (setq general-override-states '(insert emacs hybrid normal visual motion operator replace))
    (general-override-mode)
    (general-evil-setup)
    (general-create-definer jjs-leader
			    :states '(normal insert emacs)
			    :prefix jjs-leader-key
			    :non-normal-prefix jjs-leader-secondary-key)
    (general-create-definer jjs-major-leader
			    :states '(normal insert emacs)
			    :prefix jjs-major-leader-key
			    :non-normal-prefix jjs-major-leader-secondary-key)
    (general-nmap "SPC m" (general-simulate-key "," :which-key "major mode")))

;; open recent files
(use-package recentf
  :commands (recentf-mode recentf-track-opened-file)
  :init
  (setq recentf-max-saved-items 1000
	recentf-auto-cleanup 'never)
  (recentf-mode 1))
	      
;; if files are changed in other programs while open in Emacs, make sure to reload
(use-package autorevert
  :commands (global-auto-revert-mode)
  :init
  (setq global-auto-revert-non-file-buffers t ;; refresh any buffer that implements autorevert
	auto-revert-verbose nil) ;; be silent when refreshing a buffer
  (global-auto-revert-mode))

;; line numbers
(global-display-line-numbers-mode t)
(add-hook 'org-mode-hook (lambda () (display-line-numbers-mode 0)))
;; column numbers
(column-number-mode 1)

;; parens config
;; color brackets
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))
;; show matching parens
(use-package paren
  :commands (show-paren-mode)
  :init (show-paren-mode)
  :config
  (setq-default show-paren-delay 0
		show-paren-highlight-openparen t ;; always show matching paren
		show-paren-when-point-inside-paren t)) ;; show paren when inside a block

;; theme
(use-package doom-modeline
  :init (doom-modeline-mode 1)) ;; for a prettier mode line
(use-package all-the-icons)
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold nil) ;; I don't like bold keywords
  (load-theme 'doom-solarized-dark t)
  (doom-themes-visual-bell-config))

;; ivy, swiper, and counsel
(use-package ivy
  :bind (("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 ("C-d" . ivy-switch-buffer-kill))
  :config
  (ivy-mode 1))
(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package swiper) ;; for searching in file

(use-package counsel
  :bind (
	 :map minibuffer-local-map
	      ("C-r" . 'counsel-minibuffer-history))
  :config
  (counsel-mode 1)
  (setq ivy-initial-inputs-alist nil)) ;; don't start searches with ^

;; this gets set automatically for some reason, don't touch it
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(browse-kill-ring company company-mode uniquify evil-smartparens smartparens evil-goggles evil-commentary general undo-fu evil-surround evil-collection evil helpful visual-fill-column org-appear org-superstar which-key ivy-rich counsel use-package swiper doom-themes doom-modeline)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; continue config

(use-package helpful
  :general
  (jjs-leader
    "h c" '(describe-command :wk "describe command")
    "h d" '(helpful-at-point :wk "describe at point")
    "h f" '(describe-function :wk "describe function")
    "h k" '(describe-key :wk "describe key")
    "h m" '(helpful-macro :wk "describe macro")
    "h M" '(describe-mode :wk "describe mode")
    "h v" '(describe-variable :wk "describe variable"))
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package which-key
  :init
  (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3)
  (setq which-key-allow-evil-operators t)
  (setq which-key-sort-order 'which-key-key-order-alpha))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

(setq org-directory "d:/Dropbox/org/")

;; org mode
(defun jjs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (auto-fill-mode 0)
  (visual-line-mode 1)
  ;; ensure that anything that should be fixed-pitch, is
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)

  ; capture
  (setq org-default-notes-file (concat org-directory "notes.org"))
  (setq org-capture-templates
        '(("t" "Todo" entry (file+headline "d:/Dropbox/org/tasks.org" "Inbox")
           "* TODO %?\n")
          ("j" "Journal" entry (file+datetree "d:/Dropbox/org/journal.org")
           "* %?\nEntered on %U\n %i\n %a")
          ("i" "ideas")
          ("ib" "blog idea" entry (file+headline (concat org-directory "writing-ideas.org") "blog ideas")
           "")
          ("iw" "writing idea" entry (file+headline (concat org-directory "writing-ideas.org") "ideas to write about")
           "")
          ("ii" "general idea" entry (file (concat org-directory "ideas.org"))
           ""))
  )
)

(use-package org
  :hook (org-mode . jjs/org-mode-setup)
  :general
  (jjs-major-leader 'org-mode-map

    "h" '(:ignore t :wk "headings")
    "h d" '(org-demote-subtree :wk "demote subtree")
    "h p" '(org-promote-subtree :wk "promote subtree")

    "t" '(:ignore t :wk "todo")
    "t t" '(org-todo :wk "org-todo")


    )
  :config
  (setq org-ellipsis " ▼ ")
  (setq org-hide-emphasis-markers t)) ;; use org-appear to only show them when hovering
  
(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode)
  :config
  (setq org-superstar-headline-bullets-list '("■" "▲" "●" "◆" "□" "△" "○" "◇"))
  (dolist (face '((org-level-1 . 1.2)
		  (org-level-2 . 1.1)
		  (org-level-3 . 1.05)
		  (org-level-4 . 1.0)
		  (org-level-5 . 0.9)
		  (org-level-6 . 0.8)
		  (org-level-7 . 0.8)
		  (org-level-8 . 0.8)))
    (set-face-attribute (car face) nil :font "Cambria" :weight 'regular :height (cdr face))))

;; shows org markup when hovered over 
(use-package org-appear
  :after org
  :hook (org-mode . org-appear-mode))

(defun jjs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
	visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

;; for centering text nicely in text modes
(use-package visual-fill-column
  :after org
  :hook (org-mode . jjs/org-mode-visual-fill))

;; evil configuration
(use-package evil
  ;; this allows you to exit out of insert mode with "jk"
  ;; if you ever need to type jk literally, just put a very slight delay on j
  ;; you can still type J as necessary, jelly jam jordan, you don't really notice the delay 
  :general
  (general-imap "j" (general-key-dispatch 'self-insert-command
                      :timeout 0.25
                      "k" 'evil-normal-state))
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-undo-system 'undo-fu) ;; default undo is trash
  (setq evil-want-C-u-scroll t) ;; in vim C-u is used for scroll
  (setq evil-search-module 'swiper) ;; use Swiper for searches
  :config
  (evil-mode 1))

;; instead of having to try to consistently create a key theme for a ton of various packages,
;; the emacs and evil community came together to crowd configure 
(use-package evil-collection
  :after evil
  :commands evil-collection-init
  :config
  (evil-collection-init))

;; commenting out regions
(use-package evil-commentary
  :commands evil-commentary-mode
  :init (evil-commentary-mode))

;; vim-surround
(use-package evil-surround
  :after evil
  :commands global-evil-surround-mode
  :config
  (global-evil-surround-mode 1))

;; show visual hints for actions you just did, like replacing a line, etc.
(use-package evil-goggles
  :commands evil-goggles-mode
  :init (evil-goggles-mode)
  :config
  (setq evil-goggles-duration 0.100) ;; default is 0.200
  )

;; when we use smartparens we also want to ensure that we enable the
;; corresponding evil counterpart so things work as we expect
(use-package evil-smartparens
  :hook (smartparens-enabled-hook . evil-smartparens-mode))

(use-package undo-fu
  :after evil
  :config
  (define-key evil-normal-state-map "u" 'undo-fu-only-undo)
  (define-key evil-normal-state-map "\C-r" 'undo-fu-only-redo))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; base editor config ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package smartparens
  :init (require 'smartparens-config)
  :hook (prog-mode . smartparens-strict-mode))

;; default which-key prefixes
(jjs-leader
 "SPC" '(counsel-M-x :wk "M-x") ;; ignore means to not run a command, this makes it a "prefix", also, :wk is shortcut for ":which-key" which sets the name for which-key to display

 "b" '(:ignore t :wk "buffers")
 "bb" 'switch-to-buffer
 "bn" 'evil-next-buffer
 "bp" 'evil-prev-buffer
 "bd" 'kill-this-buffer

 "f" '(:ignore t :wk "files")
 "ff" 'counsel-find-file
 "fr" 'counsel-recentf

 "g" '(:ignore t :wk "git")

 "h" '(:ignore t :wk "help")

 "o" '(:ignore t :wk "org")
 "ol" 'org-store-link
 "oa" 'org-agenda
 "oc" 'org-capture

 "s" '(:ignore t :wk "search")
 "ss" 'swiper

 "w" '(:ingore t :wk "windows")
 "wd" 'evil-window-delete
 "wl" 'evil-window-right
 "wh" 'evil-window-left
 "wj" 'evil-window-down
 "wk" 'evil-window-up
 "wv" 'evil-window-vsplit
 "wm" 'delete-other-windows
 
 )

;; highlights current line (like vim)
(use-package hl-line
  :commands global-hl-line-mode
  :init (global-hl-line-mode)
  :config
  (setq global-hl-line-sticky-flag nil)) ;; don't highlight current line in inactive buffers

;; remembers where you last where in a file
(use-package saveplace
  :commands (save-place-mode)
  :init (save-place-mode))

;; check out these projects in the future:

;; magit

;; projectile
;; counsel-projectile

;; hydra

;; company
(use-package company
  :init (global-company-mode))


(use-package browse-kill-ring)
