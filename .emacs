;(require 'site-gentoo)

;; Get rid of statrup message
(setq inhibit-startup-message t)

;; Highlight parenthesis
(show-paren-mode)

(setq default-tab-width 8)

;; Set utf-8 encoding
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Auto-fill mode breaks lines on whitespace at EOL
(auto-fill-mode 1)


;; CC Mode specific stuff
;; Default mode
(setq c-default-style '((java-mode . "java")
                        (awk-mode . "awk")
                        (other . "linux")))

;; Typing characters ; or { reindents in new line
(setq-default c-electric-flag 1)

;; Basic indentation level
(setq c-basic-offset 4)

(add-hook 'c-mode-common-hook
          (lambda ()
            (c-subword-mode 1)))

;; Enter indents line
(defun my-make-CR-do-indent ()
  (define-key c-mode-base-map "\C-m" 'c-context-line-break))
(add-hook 'c-initialization-hook 'my-make-CR-do-indent)

;; Stuff modifying modeline
(column-number-mode 1)
(size-indication-mode 1)

(whitespace-global-mode 1)

;; Switch off blinking cursor
(blink-cursor-mode -1)
;; Switch off toolbar in GUI
(tool-bar-mode -1)

;; Set up colors, when emacs is run in X window
(if window-system (progn
   (set-foreground-color "grey77")
   (set-cursor-color     "grey77")
   (set-background-color "grey10")
   (set-default-font "-*-fixed-medium-r-*-*-15-140-*-*-c-*-iso8859-2"))
)

;; Manage the geometric size of initial window.
(setq initial-frame-alist '((width . 113) (height . 54)))

;; Syntax Highlight
(global-font-lock-mode 1)

;; Always end a file with a newline
(setq require-final-newline t)


;; Some helper functions to keep whitespace in buffer
(defun remove-element-helper (tolist list element)
  (if (or (eq (car list) element) (not list))
      (setq tolist (append tolist (cdr list)))
    (setq tolist (append tolist (cons (car list) ())))
    (remove-element-helper tolist (cdr list) element)))


(defun remove-element (list element)
  "Remove element from list"
  (let (newlist)
    (remove-element-helper newlist list element)))

;; Get rid of untabify-before-write, so lines with whitespace only characters are preserved
(add-hook 'before-save-hook (lambda ()
                              (setq write-file-functions
                                    (remove-element write-file-functions 'untabify-before-write))
                              (cons t write-file-functions)))

(defun electric-pair ()
  "Insert character pair without surrounding spaces"
  (interactive)
  (let (parens-require-spaces)
    (insert-pair)))


;; Rails setup

;; Load minor modes
(setq load-path (cons "~/.emacs.d" load-path))
(setq load-path (cons "~/.emacs.d/emacs-rails" load-path))
(setq load-path (cons "~/.emacs.d/rhtml" load-path))
(require 'rhtml-mode)
(require 'rails)

;; Nxhtml for multi-mode php files
(load "~/.emacs.d/nxhtml/autostart.el")
;; Validating partials is not a good idea
(add-hook 'nxhtml-mode-hook
          (lambda ()
            (rng-validate-mode)))

;; ECB setup
(require 'ecb-autoloads)

(setq my-ecb-start t)

(add-hook 'ecb-activate-hook
          (lambda ()
            (setq my-ecb-start nil)
            (global-set-key [?\C-c ?d] 'ecb-goto-window-directories)
            (global-set-key [?\C-c ?e] 'ecb-goto-window-edit1)
            (global-set-key [?\C-c ?h] 'ecb-goto-window-history)))

(add-hook 'ecb-deactivate-hook
          (lambda ()
            (setq my-ecb-start t)
            (global-unset-key [?\C-c ?d])
            (global-unset-key [?\C-c ?e])
            (global-unset-key [?\C-c ?h])))

(defun my-toggle-ecb ()
  (interactive)
  (if my-ecb-start
      (ecb-activate)
    (ecb-deactivate)))


;; C-x e toggles ecb
(global-set-key [?\C-x ?e] 'my-toggle-ecb)

(add-hook 'c-mode-hook
          (lambda ()
            (c-set-style "linux")))

;; Hooks for Ruby
(add-hook 'ruby-mode-hook
          (lambda ()
            (set (make-local-variable 'tab-width) 2)
            (ruby-electric-mode t)
            ))


(add-hook 'rhtml-mode-hook
          (lambda ()
            (set-face-background 'erb-delim-face "grey30")
            (set-face-background 'erb-face "grey25")
            (set-face-foreground 'erb-comment-face "orange2")
            (set-face-foreground 'erb-comment-delim-face "orange1")
            (set-face-foreground 'erb-out-delim-face "red1")
            ))

;; For 4 space indents in php (using cc-mode)
(add-hook 'php-mode-hook
          (lambda ()
            (c-set-style "user")
            ))

;; Load mode for JavaScript
(autoload 'js2-mode "js2" nil t)

;; Default modes
(setq auto-mode-alist (cons '("\.html$"       . nxhtml-mumamo) auto-mode-alist))
(setq auto-mode-alist (cons '("\.phtml$"      . nxhtml-mumamo) auto-mode-alist))
(setq auto-mode-alist (cons '("\.rhtml$"      . rhtml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\.erb$"        . rhtml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\.rpdf$"       . ruby-mode)  auto-mode-alist))
(setq auto-mode-alist (cons '("\.js$"         . js2-mode)   auto-mode-alist))
(setq auto-mode-alist (cons '("\.php"         . php-mode)   auto-mode-alist))
;; Enter python-mode, when visiting scons files
(setq auto-mode-alist (cons '("[sS][cC]on[sf].*" . python-mode)
                            auto-mode-alist))


(require 'autoinsert)
(auto-insert-mode)
(setq auto-insert-directory "~/Templates/")
(setq auto-insert-query t)
(define-auto-insert   "\.py"     "template.py")
(define-auto-insert   "\.c"      "template.c")
(define-auto-insert   "\.php"    "template.php")

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ecb-layout-name "left14")
 '(ecb-options-version "2.32")
 '(ecb-primary-secondary-mouse-buttons (quote mouse-1--mouse-2))
 '(ecb-source-path (quote (("/home/kwalo/" "home") ("/home/kwalo/job/cs/mediachannel.git" "mediachannel") ("/home/kwalo/job/cs/worky.git" "worky"))))
 '(ecb-tip-of-the-day nil)
 '(ecb-tree-expand-symbol-before t)
 '(ecb-tree-indent 3)
 '(ecb-windows-width 33)
 '(indent-tabs-mode nil)
 '(mumamo-background-chunk-major (quote mumamo-background-chunk-major))
 '(nxhtml-default-encoding (quote utf-8))
 '(nxhtml-skip-welcome t)
 '(rails-ws:default-server-type "mongrel")
 '(truncate-partial-width-windows nil)
 '(whitespace-check-indent-whitespace t)
 '(whitespace-check-leading-whitespace nil)
 '(whitespace-check-trailing-whitespace nil)
 '(whitespace-indent-regexp "^	*\\(                                                \\)+")
 '(whitespace-silent t)
 '(x-select-enable-clipboard t)
 '(yaml-indent-offset 4))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(flymake-errline ((((class color)) (:background "DarkRed"))))
 '(mode-line ((t (:background "grey25" :foreground "#cfcfcf" :box (:line-width -1 :style released-button)))))
 '(mumamo-background-chunk-major ((((class color) (min-colors 88) (background dark)) (:background "grey10"))))
 '(mumamo-background-chunk-submode ((((class color) (min-colors 88) (background dark)) (:background "grey15")))))
