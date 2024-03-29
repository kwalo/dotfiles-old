;;; ourcomments-util.el --- Utility routines
;;
;; Author: Lennart Borgman <lennart dot borgman at gmail dot com>
;; Created: Wed Feb 21 23:19:07 2007
(defconst ourcomments-util:version "0.24") ;;Version:
;; Last-Updated: 2008-08-11T12:25:12+0200 Mon
;; Keywords:
;; Compatibility: Emacs 22
;;
;; Features that might be required by this library:
;;
;;   None
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;; The functionality given by these small routines should in my
;; opinion be part of Emacs (but they are not that currently).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Change log:
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Popups etc.

(defun point-to-coord (point)
  "Return coordinates of POINT in selected window.
The coordinates are in the form \(\(XOFFSET YOFFSET) WINDOW).
This form is suitable for `popup-menu'."
  ;; Fix-me: showtip.el adds (window-inside-pixel-edges
  ;; (selected-window)). Why?
  (let* ((pn (posn-at-point point))
         (x-y (posn-x-y pn))
         (x (car x-y))
         (y (cdr x-y))
         (pos (list (list x (+ y 20)) (selected-window))))
    pos))

(defun popup-menu-at-point (menu &optional prefix)
  "Popup the given menu at point.
This is similar to `popup-menu' and MENU and PREFIX has the same
meaning as there.  The position for the popup is however where
the window point is."
  (let ((where (point-to-coord (point))))
    (popup-menu menu where prefix)))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Toggles in menus

(defmacro define-toggle (symbol value doc &rest args)
  "Declare SYMBOL as a customizable variable with a toggle function.
The purpose of this macro is to define a defcustom and a toggle
function suitable for use in a menu.

The arguments have the same meaning as for `defcustom' with these
restrictions:

- The :type keyword cannot be used.  Type is always 'boolean.
- VALUE must be t or nil.

DOC and ARGS are just passed to `defcustom'.

A `defcustom' named SYMBOL with doc-string DOC and a function
named SYMBOL-toggle is defined.  The function toggles the value
of SYMBOL.  It takes no parameters.

To create a menu item something similar to this can be used:

    \(define-key map [SYMBOL]
      \(list 'menu-item \"Toggle nice SYMBOL\"
            'SYMBOL-toggle
            :button '(:toggle . SYMBOL)))"
  (declare (doc-string 3))
  (list
   'progn
   (let ((var-decl (list 'custom-declare-variable
                         (list 'quote symbol)
                         (list 'quote value)
                         doc)))
     (while args
       (let ((arg (car args)))
         (setq args (cdr args))
         (unless (symbolp arg)
           (error "Junk in args %S" args))
         (let ((keyword arg)
               (value (car args)))
           (unless args
             (error "Keyword %s is missing an argument" keyword))
           (setq args (cdr args))
           (cond
            ((not (memq keyword '(:type)))
             (setq var-decl (append var-decl (list keyword value))))
            (t
             (lwarn '(define-toggle) :error "Keyword %s can't be used here"
                    keyword))))))
     (when (assoc :type var-decl) (error ":type is set.  Should not happen!"))
     (setq var-decl (append var-decl (list :type '(quote boolean))))
     var-decl)
   (let* ((SYMBOL-toggle (intern (concat (symbol-name symbol) "-toggle")))
          (SYMBOL-name (symbol-name symbol))
          (fun-doc (concat "Toggles the \(boolean) value of `"
                           SYMBOL-name
                           "'.\n"
                           "For how to set it permanently see this variable.\n"
                           ;;"\nDescription of `" SYMBOL-name "':\n" doc
                           )))
     `(defun ,SYMBOL-toggle ()
        ,fun-doc
        (interactive)
        (customize-set-variable (quote ,symbol) (not ,symbol)))
     )))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Indentation of regions

;; From an idea by weber <hugows@gmail.com>
;; (defun indent-line-or-region ()
;;   "Indent line or region.
;; Only do this if indentation seems bound to \\t.

;; Call `indent-region' if region is active, otherwise
;; `indent-according-to-mode'."
;;   (interactive)
;;   ;; Do a wild guess if we should indent or not ...
;;   (let* ((indent-region-mode)
;;          ;; The above hides the `indent-line-or-region' binding
;;          (t-bound (key-binding [?\t])))
;;     (if (not
;;          (save-match-data
;;            (string-match "indent" (symbol-name t-bound))))
;;         (call-interactively t-bound t)
;;       (if (and mark-active ;; there is a visible region selected
;;                transient-mark-mode)
;;           (indent-region (region-beginning) (region-end))
;;         (indent-according-to-mode))))) ;; indent line

;; (define-minor-mode indent-region-mode
;;   "Use \\t to indent line or region.
;; The key \\t is bound to `indent-line-or-region' if this mode is
;; on."
;;   :global t
;;   :keymap '(([?\t] . indent-line-or-region)))
;; (when indent-region-mode (indent-region-mode 1))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Minor modes

;; (defmacro define-globalized-minor-mode-with-on-off (global-mode mode
;;                                                     turn-on turn-off
;;                                                     &rest keys)
;;   "Make a global mode GLOBAL-MODE corresponding to buffer-local minor MODE.
;; This is a special variant of `define-globalized-minor-mode' for
;; mumamo.  It let bounds the variable GLOBAL-MODE-checking before
;; calling TURN-ON or TURN-OFF.

;; TURN-ON is a function that will be called with no args in every buffer
;;   and that should try to turn MODE on if applicable for that buffer.
;; TURN-OFF is a function that turns off MODE in a buffer.
;; KEYS is a list of CL-style keyword arguments.  As the minor mode
;;   defined by this function is always global, any :global keyword is
;;   ignored.  Other keywords have the same meaning as in `define-minor-mode',
;;   which see.  In particular, :group specifies the custom group.
;;   The most useful keywords are those that are passed on to the
;;   `defcustom'.  It normally makes no sense to pass the :lighter
;;   or :keymap keywords to `define-globalized-minor-mode', since these
;;   are usually passed to the buffer-local version of the minor mode.

;; If MODE's set-up depends on the major mode in effect when it was
;; enabled, then disabling and reenabling MODE should make MODE work
;; correctly with the current major mode.  This is important to
;; prevent problems with derived modes, that is, major modes that
;; call another major mode in their body."

;;   (let* ((global-mode-name (symbol-name global-mode))
;;          (pretty-name (easy-mmode-pretty-mode-name mode))
;;          (pretty-global-name (easy-mmode-pretty-mode-name global-mode))
;;          (group nil)
;;          (extra-keywords nil)
;;          (MODE-buffers (intern (concat global-mode-name "-buffers")))
;;          (MODE-enable-in-buffers
;;           (intern (concat global-mode-name "-enable-in-buffers")))
;;          (MODE-check-buffers
;;           (intern (concat global-mode-name "-check-buffers")))
;;          (MODE-cmhh (intern (concat global-mode-name "-cmhh")))
;;          (MODE-major-mode (intern (concat (symbol-name mode)
;;                                           "-major-mode")))
;;          (MODE-checking (intern (concat global-mode-name "-checking")))
;;          keyw)

;;     ;; Check keys.
;;     (while (keywordp (setq keyw (car keys)))
;;       (setq keys (cdr keys))
;;       (case keyw
;;         (:group (setq group (nconc group (list :group (pop keys)))))
;;         (:global (setq keys (cdr keys)))
;;         (t (push keyw extra-keywords) (push (pop keys) extra-keywords))))

;;     (unless group
;;       ;; We might as well provide a best-guess default group.
;;       (setq group
;;             `(:group ',(intern (replace-regexp-in-string
;;                                 "-mode\\'" "" (symbol-name mode))))))

;;     `(progn

;;        ;; Define functions for the global mode first so that it can be
;;        ;; turned on during load:

;;        ;; List of buffers left to process.
;;        (defvar ,MODE-buffers nil)

;;        ;; The function that calls TURN-ON in each buffer.
;;        (defun ,MODE-enable-in-buffers ()
;;          (let ((,MODE-checking nil))
;;            (dolist (buf ,MODE-buffers)
;;              (when (buffer-live-p buf)
;;                (with-current-buffer buf
;;                  (if ,mode
;;                      (unless (eq ,MODE-major-mode major-mode)
;;                        (setq ,MODE-checking t)
;;                        (,mode -1)
;;                        (,turn-on)
;;                        (setq ,MODE-checking nil)
;;                        (setq ,MODE-major-mode major-mode))
;;                    (setq ,MODE-checking t)
;;                    (,turn-on)
;;                    (setq ,MODE-checking nil)
;;                    (setq ,MODE-major-mode major-mode)))))))
;;        (put ',MODE-enable-in-buffers 'definition-name ',global-mode)

;;        (defun ,MODE-check-buffers ()
;;          (,MODE-enable-in-buffers)
;;          (setq ,MODE-buffers nil)
;;          (remove-hook 'post-command-hook ',MODE-check-buffers))
;;        (put ',MODE-check-buffers 'definition-name ',global-mode)

;;        ;; The function that catches kill-all-local-variables.
;;        (defun ,MODE-cmhh ()
;;          (add-to-list ',MODE-buffers (current-buffer))
;;          (add-hook 'post-command-hook ',MODE-check-buffers))
;;        (put ',MODE-cmhh 'definition-name ',global-mode)


;;        (defvar ,MODE-major-mode nil)
;;        (make-variable-buffer-local ',MODE-major-mode)

;;        ;; The actual global minor-mode
;;        (define-minor-mode ,global-mode
;;          ,(format "Toggle %s in every possible buffer.
;; With prefix ARG, turn %s on if and only if ARG is positive.
;; %s is enabled in all buffers where `%s' would do it.
;; See `%s' for more information on %s."
;;                   pretty-name pretty-global-name pretty-name turn-on
;;                   mode pretty-name)
;;          :global t ,@group ,@(nreverse extra-keywords)

;;          ;; Setup hook to handle future mode changes and new buffers.
;;          (if ,global-mode
;;              (progn
;;                (add-hook 'after-change-major-mode-hook
;;                          ',MODE-enable-in-buffers)
;;                ;;(add-hook 'find-file-hook ',MODE-check-buffers)
;;                (add-hook 'find-file-hook ',MODE-cmhh)
;;                (add-hook 'change-major-mode-hook ',MODE-cmhh))
;;            (remove-hook 'after-change-major-mode-hook ',MODE-enable-in-buffers)
;;            ;;(remove-hook 'find-file-hook ',MODE-check-buffers)
;;            (remove-hook 'find-file-hook ',MODE-cmhh)
;;            (remove-hook 'change-major-mode-hook ',MODE-cmhh))

;;          ;; Go through existing buffers.
;;          (let ((,MODE-checking t))
;;            (dolist (buf (buffer-list))
;;              (with-current-buffer buf
;;                ;;(if ,global-mode (,turn-on) (when ,mode (,mode -1)))
;;                (if ,global-mode (,turn-on) (,turn-off))
;;                ))))

;;        )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Unfilling
;;
;; The idea is from
;;   http://interglacial.com/~sburke/pub/emacs/sburke_dot_emacs.config

(defun unfill-paragraph ()
  "Unfill the current paragraph."
  (interactive) (with-unfilling 'fill-paragraph))
;;(defalias 'unwrap-paragraph 'unfill-paragraph)

(defun unfill-region ()
  "Unfill the current region."
  (interactive) (with-unfilling 'fill-region))
;;(defalias 'unwrap-region 'unfill-region)

(defun unfill-individual-paragraphs ()
  "Unfill individual paragraphs in the current region."
  (interactive) (with-unfilling 'fill-individual-paragraphs))
;;(defalias 'unwrap-individual-paragraphs 'unfill-individual-paragraphs)

(defun with-unfilling (fn)
  "Unfill using the fill function FN."
  (let ((fill-column 10000000)) (call-interactively fn)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Widgets


;; (rassq 'genshi-nxhtml-mumamo mumamo-defined-turn-on-functions)
;; (major-modep 'nxhtml-mode)
;; (major-modep 'nxhtml-mumamo)
;; (major-modep 'jsp-nxhtml-mumamo)
;; (major-modep 'asp-nxhtml-mumamo)
;; (major-modep 'django-nxhtml-mumamo)
;; (major-modep 'eruby-nxhtml-mumamo)
;; (major-modep 'eruby-nxhtml-mumamo)
;; (major-modep 'smarty-nxhtml-mumamo)
;; (major-modep 'embperl-nxhtml-mumamo)
;; (major-modep 'laszlo-nxml-mumamo)
;; (major-modep 'genshi-nxhtml-mumamo)
;; (major-modep 'javascript-mode)
;; (major-modep 'css-mode)
(defun major-or-multi-majorp (value)
  (or (multi-major-modep value)
      (major-modep value)))

(defun multi-major-modep (value)
  "Return t if VALUE is a multi major mode function."
  (and (fboundp value)
       (rassq value mumamo-defined-turn-on-functions)))

(defun major-modep (value)
  "Return t if VALUE is a major mode function."
  (let ((sym-name (symbol-name value)))
    ;; Do some reasonable test to find out if it is a major mode.
    ;; Load autoloaded mode functions.
    ;;
    ;; Fix-me: Maybe test for minor modes? How was that done?
    (when (and (fboundp value)
               (commandp value)
               (not (memq value '(flyspell-mode
                                  isearch-mode
                                  savehist-mode
                                  )))
               (< 5 (length sym-name))
               (string= "-mode" (substring sym-name (- (length sym-name) 5)))
               (if (and (listp (symbol-function value))
                        (eq 'autoload (car (symbol-function value))))
                   (progn
                     (message "loading ")
                     (load (cadr (symbol-function value)) t t))
                 t)
               (or (memq value
                         ;; Fix-me: Complement this table of known major modes:
                         '(fundamental-mode
                           xml-mode
                           nxml-mode
                           nxhtml-mode
                           css-mode
                           javascript-mode
                           php-mode
                           ))
                   (and (intern-soft (concat sym-name "-hook"))
                        (boundp (intern-soft (concat sym-name "-hook"))))
                   (progn (message "Not a major mode: %s" value)
                          ;;(sit-for 4)
                          nil)
                   ))
      t)))

(define-widget 'major-mode-function 'function
  "A major mode lisp function."
  :complete-function (lambda ()
                       (interactive)
                       (lisp-complete-symbol 'major-or-multi-majorp))
  :prompt-match 'major-or-multi-majorp
  :prompt-history 'widget-function-prompt-value-history
  :match-alternatives '(major-or-multi-majorp)
  :validate (lambda (widget)
              (unless (major-or-multi-majorp (widget-value widget))
                (widget-put widget :error (format "Invalid function: %S"
                                                  (widget-value widget)))
                widget))
  :value 'fundamental-mode
  :tag "Major mode function")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Lines

;; Changed from move-beginning-of-line to beginning-of-line to support
;; physical-line-mode.
(defun ourcomments-move-beginning-of-line(arg)
  "Move point to beginning of line or indentation.
See `beginning-of-line' for ARG.

If `physical-line-mode' is on then the visual line beginning is
first tried."
  (interactive "p")
  (let ((pos (point)))
    (call-interactively 'beginning-of-line arg)
    (when (= pos (point))
      (if (= 0 (current-column))
          (skip-chars-forward " \t")
        (backward-char)
        (beginning-of-line)))))
(put 'ourcomments-move-beginning-of-line 'CUA 'move)

(defun ourcomments-move-end-of-line(arg)
  "Move point to end of line or indentation.
See `end-of-line' for ARG.

If `physical-line-mode' is on then the visual line ending is
first tried."
  (interactive "p")
  (or arg (setq arg 1))
  (let ((pos (point)))
    (call-interactively 'end-of-line arg)
    (when (= pos (point))
      (if (= (line-end-position) (point))
          (skip-chars-backward " \t")
        (forward-char)
        (end-of-line)))))
(put 'ourcomments-move-end-of-line 'CUA 'move)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Keymaps

(defun ourcomments-find-keymap-variables (keymap---)
  "Return a list of keymap variables with value KEYMAP--.
Ignore `special-event-map', `global-map', `overriding-local-map'    
and `overriding-terminal-local-map'."
  (let ((vars nil))
    (mapatoms (lambda (symbol)
                (unless (memq symbol '(keymap---
                                       special-event-map
                                       global-map
                                       overriding-local-map
                                       overriding-terminal-local-map
                                       ))
                  (let (val)
                    (if (boundp symbol)
                        (setq val (symbol-value symbol))
                      (when (keymapp symbol)
                        (setq val (symbol-function symbol))))
                    (when (equal val keymap---)
                      (push symbol vars))))))
    vars))

;; This is a replacement for describe-key-briefly.
;;(global-set-key [f1 ?c] 'find-keymap-binding-key)
(defun find-keymap-binding-key (&optional key insert untranslated)
  "Try to print names of keymap from which KEY fetch its definition.
Look in current active keymaps and find keymap variables with the
same value as the keymap where KEY is bound.  Print a message
with those keymap variable names.  Return a list with the keymap
variable symbols.

When called interactively prompt for KEY.

INSERT and UNTRANSLATED should normall be nil (and I am not sure
what they will do ;-)."
  ;; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ;; From describe-key-briefly. Keep this as it is for easier update.
  (interactive
   (let ((enable-disabled-menus-and-buttons t)
	 (cursor-in-echo-area t)
	 saved-yank-menu)
     (unwind-protect
	 (let (key)
	   ;; If yank-menu is empty, populate it temporarily, so that
	   ;; "Select and Paste" menu can generate a complete event.
	   (when (null (cdr yank-menu))
	     (setq saved-yank-menu (copy-sequence yank-menu))
	     (menu-bar-update-yank-menu "(any string)" nil))
	   (setq key (read-key-sequence "Describe key (or click or menu item): "))
	   ;; If KEY is a down-event, read and discard the
	   ;; corresponding up-event.  Note that there are also
	   ;; down-events on scroll bars and mode lines: the actual
	   ;; event then is in the second element of the vector.
	   (and (vectorp key)
		(let ((last-idx (1- (length key))))
		  (and (eventp (aref key last-idx))
		       (memq 'down (event-modifiers (aref key last-idx)))))
		(read-event))
	   (list
	    key
	    (if current-prefix-arg (prefix-numeric-value current-prefix-arg))
	    1
            ))
       ;; Put yank-menu back as it was, if we changed it.
       (when saved-yank-menu
	 (setq yank-menu (copy-sequence saved-yank-menu))
	 (fset 'yank-menu (cons 'keymap yank-menu))))))
  (if (numberp untranslated)
      (setq untranslated (this-single-command-raw-keys)))
  (let* ((event (if (and (symbolp (aref key 0))
			 (> (length key) 1)
			 (consp (aref key 1)))
		    (aref key 1)
		  (aref key 0)))
	 (modifiers (event-modifiers event))
	 (standard-output (if insert (current-buffer) t))
	 (mouse-msg (if (or (memq 'click modifiers) (memq 'down modifiers)
			    (memq 'drag modifiers)) " at that spot" ""))
	 (defn (key-binding key t))
	 key-desc)
    ;; Handle the case where we faked an entry in "Select and Paste" menu.
    (if (and (eq defn nil)
	     (stringp (aref key (1- (length key))))
	     (eq (key-binding (substring key 0 -1)) 'yank-menu))
	(setq defn 'menu-bar-select-yank))
    ;; Don't bother user with strings from (e.g.) the select-paste menu.
    (if (stringp (aref key (1- (length key))))
	(aset key (1- (length key)) "(any string)"))
    (if (and (> (length untranslated) 0)
	     (stringp (aref untranslated (1- (length untranslated)))))
	(aset untranslated (1- (length untranslated)) "(any string)"))
    ;; Now describe the key, perhaps as changed.
    (setq key-desc (help-key-description key untranslated))
    ;;
    ;; End of part from describe-key-briefly.
    ;; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    ;; Find the keymap:
    (let* ((maps (current-active-maps))
           ret
           lk)
      (if (or (null defn) (integerp defn) (equal defn 'undefined))
          (setq ret 'not-defined)
        (catch 'mapped
          (while (< 1 (length maps))
            (setq lk (lookup-key (car maps) key t))
            (when (and lk (not (numberp lk)))
              (setq ret (ourcomments-find-keymap-variables (car maps)))
              (when ret
                (throw 'mapped (car maps))))
            (setq maps (cdr maps))))
        (unless ret
          (setq lk (lookup-key global-map key t))
          (when (and lk (not (numberp lk)))
            (setq ret '(global-map)))))
      (cond
       ((eq ret 'not-defined)
        (message "%s%s not defined in any keymap" key-desc mouse-msg))
       ((listp ret)
        (if (not ret)
            (message "%s%s is bound to `%s', but don't know where"
                     key-desc mouse-msg defn)
          (if (= 1 (length ret))
              (message "%s%s is bound to `%s' in keymap variable `%s'"
                       key-desc mouse-msg defn (car ret))
            (message "%s%s is bound to `%s' in keymap variables `%s'"
                     key-desc mouse-msg defn ret))))
       (t
        (error "ret=%s" ret)))
      ret)))

;; (ourcomments-find-keymap-variables (current-local-map))
;; (keymapp 'ctl-x-4-prefix)
;; (equal 'ctl-x-4-prefix (current-local-map))
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Misc.

(defun ourcomments-latest-changelog ()
  (let ((changelogs
         '("ChangeLog"
           "admin/ChangeLog"
           "doc/emacs/ChangeLog"
           "doc/lispintro/ChangeLog"
           "doc/lispref/ChangeLog"
           "doc/man/ChangeLog"
           "doc/misc/ChangeLog"
           "etc/ChangeLog"
           "leim/ChangeLog"
           "lib-src/ChangeLog"
           "lisp/ChangeLog"
           "lisp/erc/ChangeLog"
           "lisp/gnus/ChangeLog"
           "lisp/mh-e/ChangeLog"
           "lisp/org/ChangeLog"
           "lisp/url/ChangeLog"
           "lwlib/ChangeLog"
           "msdos/ChangeLog"
           "nextstep/ChangeLog"
           "nt/ChangeLog"
           "oldXMenu/ChangeLog"
           "src/ChangeLog"
           "test/ChangeLog"))
        )
    (emacs-root (expand-file-name ".." exec-directory)
    )))

(defun ourcomments-read-symbol (prompt predicate)
  "Basic function for reading a symbol for describe-* functions.
Prompt with PROMPT and show only symbols satisfying function
PREDICATE.  PREDICATE takes one argument, the symbol."
  (let* ((symbol (symbol-at-point))
	 (enable-recursive-minibuffers t)
	 val)
    (when predicate
      (unless (and symbol
                   (symbolp symbol)
                   (funcall predicate symbol))
        (setq symbol nil)))
    (setq val (completing-read (if symbol
                                   (format
                                    "%s (default %s): " prompt symbol)
                                 (format "%s: " prompt))
                               obarray
                               predicate
                               t nil nil
                               (if symbol (symbol-name symbol))))
    (if (equal val "") symbol (intern val))))

(defun ourcomments-command-at-point ()
  (let ((fun (function-called-at-point)))
    (when (commandp fun)
      fun)))

(defun describe-command (command)
  "Like `describe-function', but prompts only for interactive commands."
  (interactive
   (let ((fn (ourcomments-command-at-point))
	 (enable-recursive-minibuffers t)
	 val)
     (setq val (completing-read (if fn
				    (format "Describe command (default %s): " fn)
				  "Describe command: ")
				obarray 'commandp t nil nil
				(and fn (symbol-name fn))))
     (list (if (equal val "")
	       fn (intern val)))))
  (describe-function command))


(defun buffer-narrowed-p ()
  "Return non-nil if the current buffer is narrowed."
  (/= (buffer-size)
      (- (point-max)
         (point-min))))

(defvar describe-symbol-alist nil)

(defun describe-symbol-add-known(property description)
  (when (assq property describe-symbol-alist)
    (error "Already known property"))
  (setq describe-symbol-alist
        (cons (list property description)
              describe-symbol-alist)))

;;(describe-symbol-add-known 'variable-documentation "Doc for variable")
;;(describe-symbol-add-known 'cl-struct-slots "defstruct slots")

(defun property-list-keys (plist)
  "Return list of key names in property list PLIST."
  (let ((keys))
    (while plist
      (setq keys (cons (car plist) keys))
      (setq plist (cddr plist)))
    keys))

(defun ourcomments-symbol-type (symbol)
  "Return a list of types where symbol SYMBOL is used.
The can include 'variable, 'function and variaus 'cl-*."
  (symbol-file symbol)
  )

(defun ourcomments-defstruct-p (symbol)
  "Return non-nil if symbol SYMBOL is a CL defstruct."
  (let ((plist (symbol-plist symbol)))
    (and (plist-member plist 'cl-struct-slots)
         (plist-member plist 'cl-struct-type)
         (plist-member plist 'cl-struct-include)
         (plist-member plist 'cl-struct-print))))

(defun ourcomments-defstruct-slots (symbol)
  (unless (ourcomments-defstruct-p symbol)
    (error "Not a CL defstruct symbol: %s" symbol))
  (let ((cl-struct-slots (get symbol 'cl-struct-slots)))
    (delq 'cl-tag-slot
          (loop for rec in cl-struct-slots
                collect (nth 0 rec)))))

;; (ourcomments-defstruct-slots 'ert-test)

(defun ourcomments-defstruct-file (symbol)
  (unless (ourcomments-defstruct-p symbol)
    (error "Not a CL defstruct symbol: %s" symbol))
  )

(defun ourcomments-member-defstruct (symbol)
  "Return defstruct name if member."
  (when (and (functionp symbol)
             (plist-member (symbol-plist symbol) 'cl-compiler-macro))
    (let* (in-defstruct
           (symbol-file (symbol-file symbol))
           buf
           was-here)
      (unless symbol-file
        (error "Can't check if defstruct member since don't know symbol file"))
      (setq buf (find-buffer-visiting symbol-file))
      (setq was-here (with-current-buffer buf (point)))
      (unless buf
        (setq buf (find-file-noselect symbol-file)))
      (with-current-buffer buf
        (save-restriction
          (widen)
          (let* ((buf-point (find-definition-noselect symbol nil)))
            (goto-char (cdr buf-point))
            (save-match-data
              (when (looking-at "(defstruct (?\\(\\(?:\\sw\\|\\s_\\)+\\)")
                (setq in-defstruct (match-string-no-properties 1))))))
        (if was-here
            (goto-char was-here)
          (kill-buffer (current-buffer))))
      in-defstruct)))
;; (ourcomments-member-defstruct 'ert-test-name)
;; (ourcomments-member-defstruct 'ert-test-error-condition)

(defun ourcomments-custom-group-p (symbol)
  (and (intern-soft symbol)
       (or (and (get symbol 'custom-loads)
                (not (get symbol 'custom-autoload)))
           (get symbol 'custom-group))))

(defun describe-custom-group (symbol)
  "Describe customization group SYMBOL."
  (interactive
   (list
    (ourcomments-read-symbol "Customization group"
                             'ourcomments-custom-group-p)))
  (message "g=%s" symbol))
;; nxhtml

;; Added this to current-load-list in cl-macs.el
;; (describe-defstruct 'ert-stats)
(defun describe-defstruct (symbol)
  (interactive (list (ourcomments-read-symbol "Describe defstruct"
                                              'ourcomments-defstruct-p)))
  (if (not (ourcomments-defstruct-p symbol))
      (message "%s is not a CL defstruct." symbol)
  (with-output-to-temp-buffer (help-buffer)
    (help-setup-xref (list #'describe-defstruct symbol) (interactive-p))
    (with-current-buffer (help-buffer)
      (insert "This is a description of a CL thing.")
      (insert "\n\n")
      (insert (format "%s is a CL `defstruct'" symbol))
      (let ((file (symbol-file symbol)))
        (if file
            ;; Fix-me: .elc => .el
            (let ((name (file-name-nondirectory file)))
              (insert "defined in file %s.\n" (file-name-nondirectory file)))
          (insert ".\n")))
      (insert "\n\nIt has the following slot functions:\n")
      (let ((num-slot-funs 0)
            (slots (ourcomments-defstruct-slots symbol)))
        (dolist (slot slots)
          (if (not (fboundp (intern-soft (format "%s-%s" symbol slot))))
              (insert (format "    Do not know function for slot %s\n" slot))
            (setq num-slot-funs (1+ num-slot-funs))
            (insert (format "    `%s-%s'\n" symbol slot))))
        (unless (= num-slot-funs (length slots))
          (insert "  No information about some slots, maybe :conc-name was used\n")))))))

;;(defun describe-deftype (type)
(defun describe-symbol(symbol)
  "Show information about SYMBOL.
Show SYMBOL plist and whether is is a variable or/and a
function."
  (interactive (list (ourcomments-read-symbol "Describe symbol" nil)))
;;;    (let* ((s (symbol-at-point))
;;;           (val (completing-read (if (and (symbolp s)
;;;                                          (not (eq s nil)))
;;;                                     (format
;;;                                      "Describe symbol (default %s): " s)
;;;                                   "Describe symbol: ")
;;;                                 obarray
;;;                                 nil
;;;                                 t nil nil
;;;                                 (if (symbolp s) (symbol-name s)))))
;;;      (list (if (equal val "") s (intern val)))))
  (require 'apropos)
  (with-output-to-temp-buffer (help-buffer)
    (help-setup-xref (list #'describe-symbol symbol) (interactive-p))
    (with-current-buffer (help-buffer)
      (insert (format "Description of symbol %s\n\n" symbol))
      (when (plist-get (symbol-plist symbol) 'cl-compiler-macro)
        (insert "(Looks like a CL thing.)\n"))
      (if (boundp symbol)
          (insert (format "- There is a variable `%s'.\n" symbol))
        (insert "- This symbol is not a variable.\n"))
      (if (fboundp symbol)
          (progn
            (insert (format "- There is a function `%s'" symbol))
            (when (ourcomments-member-defstruct symbol)
              (let ((ds-name (ourcomments-member-defstruct symbol)))
                (insert "\n  which is a member of defstruct ")
                (insert-text-button (format "%s" ds-name)
                                    'symbol (intern-soft ds-name)
                                    'action (lambda (button)
                                              (describe-symbol
                                               (button-get button 'symbol))))))
            (insert ".\n"))
        (insert "- This symbol is not a function.\n"))
      (if (facep symbol)
          (insert (format "- There is a face `%s'.\n" symbol))
        (insert "- This symbol is not a face.\n"))
      (if (ourcomments-custom-group-p symbol)
          (progn
            (insert "- There is a customization group ")
            (insert-text-button (format "%s" symbol)
                                'symbol symbol
                                'action (lambda (button)
                                          (describe-custom-group
                                           (button-get button 'symbol))))
            (insert ".\n"))
        (insert "- This symbol is not a customization group.\n"))
      (if (ourcomments-defstruct-p symbol)
          (progn
            (insert (format "- There is a CL defstruct %s with setf-able slots:\n" symbol))
            (let ((num-slot-funs 0)
                  (slots (ourcomments-defstruct-slots symbol)))
              (dolist (slot slots)
                (if (not (fboundp (intern-soft (format "%s-%s" symbol slot))))
                    (insert (format "    Do not know function for slot %s\n" slot))
                  (setq num-slot-funs (1+ num-slot-funs))
                  (insert (format "    `%s-%s'\n" symbol slot))))
              (unless (= num-slot-funs (length slots))
                (insert "  No information about some slots, maybe :conc-name was used\n"))))
        (insert "- This symbol is not a CL defstruct.\n"))
      (insert "\n")
      (let* ((pl (symbol-plist symbol))
             (pl-not-known (property-list-keys pl))
             any-known)
        (if (not pl)
            (insert (format "Symbol %s has no property list\n\n" symbol))
          ;; Known properties
          (dolist (rec describe-symbol-alist)
            (let ((prop (nth 0 rec))
                  (desc (nth 1 rec)))
              (when (plist-member pl prop)
                (setq any-known (cons prop any-known))
                (setq pl-not-known (delq prop pl-not-known))
                (insert
                 "The following keys in the property list are known:\n\n")
                (insert (format "* %s: %s\n" prop desc))
                )))
          (unless any-known
            (insert "The are no known keys in the property list.\n"))
          (let ((pl (ourcomments-format-plist pl "\n  ")))
            ;;(insert (format "plist=%s\n" (symbol-plist symbol)))
            ;;(insert (format "pl-not-known=%s\n" pl-not-known))
            (insert "\nFull property list:\n\n (")
            (insert (propertize pl 'face 'default))
            (insert ")\n\n")))))))

(defun ourcomments-format-plist (pl sep &optional compare)
  (when (symbolp pl)
    (setq pl (symbol-plist pl)))
  (let (p desc p-out)
    (while pl
      (setq p (format "%s" (car pl)))
      (if (or (not compare) (string-match apropos-regexp p))
          (if apropos-property-face
              (put-text-property 0 (length (symbol-name (car pl)))
                                 'face apropos-property-face p))
        (setq p nil))
      (if p
          (progn
            (and compare apropos-match-face
                 (put-text-property (match-beginning 0) (match-end 0)
                                    'face apropos-match-face
                                    p))
            (setq desc (pp-to-string (nth 1 pl)))
            (setq desc (split-string desc "\n"))
            (if (= 1 (length desc))
                (setq desc (concat " " (car desc)))
              (let* ((indent "    ")
                     (ind-nl (concat "\n" indent)))
                (setq desc
                      (concat
                       ind-nl
                       (mapconcat 'identity desc ind-nl)))))
            (setq p-out (concat p-out (if p-out sep) p desc))))
      (setq pl (nthcdr 2 pl)))
    p-out))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ido

(defvar ourcomments-ido-visit-method nil)

(defun ourcomments-ido-buffer-other-window ()
  "Show buffer in other window."
  (interactive)
  (setq ourcomments-ido-visit-method 'other-window)
  (call-interactively 'ido-exit-minibuffer))

(defun ourcomments-ido-buffer-other-frame ()
  "Show buffer in other frame."
  (interactive)
  (setq ourcomments-ido-visit-method 'other-frame)
  (call-interactively 'ido-exit-minibuffer))

(defun ourcomments-ido-buffer-raise-frame ()
  "Raise frame showing buffer."
  (interactive)
  (setq ourcomments-ido-visit-method 'raise-frame)
  (call-interactively 'ido-exit-minibuffer))

(defun ourcomments-ido-mode-advice()
  (when (memq ido-mode '(both buffer))
    (let ((the-ido-minor-map (cdr ido-minor-mode-map-entry)))
      (define-key the-ido-minor-map [(control tab)] 'ido-switch-buffer))
    (let ((map ido-buffer-completion-map))
      (define-key map [(control tab)]       'ido-next-match)
      (define-key map [(control shift tab)] 'ido-prev-match)
      (define-key map [(control backtab)]   'ido-prev-match)
      (define-key map [(shift return)]   'ourcomments-ido-buffer-other-window)
      (define-key map [(control return)] 'ourcomments-ido-buffer-other-frame)
      (define-key map [(meta return)]   'ourcomments-ido-buffer-raise-frame))))

;;(add-hook 'ido-setup-hook 'ourcomments-ido-mode-advice)
;;(remove-hook 'ido-setup-hook 'ourcomments-ido-mode-advice)
(defvar ourcomments-ido-adviced nil)
(unless ourcomments-ido-adviced
(defadvice ido-mode (after
                     ourcomments-ido-add-ctrl-tab
                     disable)
  "Add C-tab to ido buffer completion."
  (ourcomments-ido-mode-advice)
  ad-return-value)
;; (ad-activate 'ido-mode)
;; (ad-deactivate 'ido-mode)

(defadvice ido-visit-buffer (before
                             ourcomments-ido-visit-buffer-other
                             disable)
  "Advice to show buffers in other window, frame etc."
  (when ourcomments-ido-visit-method
    (ad-set-arg 1 ourcomments-ido-visit-method)
    (setq ourcomments-ido-visit-method nil)
    ))
(setq ourcomments-ido-adviced t)
)

;;(ad-deactivate 'ido-visit-buffer)
;;(ad-activate 'ido-visit-buffer)

(defvar ourcomments-ido-old-state ido-mode)

(defcustom ourcomments-ido-ctrl-tab nil
  "Enable buffer switching using C-Tab with function `ido-mode'.
This changes buffer switching with function `ido-mode' the
following way:

- You can use C-Tab.

- You can show the selected buffer in three ways independent of
  how you entered function `ido-mode' buffer switching:

  * S-return: other window
  * C-return: other frame
  * M-return: raise frame

Those keys are selected to at least be a little bit reminiscent
of those in for example common web browsers."
  :type 'boolean
  :set (lambda (sym val)
         (set-default sym val)
         (if val
             (progn
               (ad-activate 'ido-visit-buffer)
               (ad-update 'ido-visit-buffer)
               (ad-enable-advice 'ido-visit-buffer 'before
                                 'ourcomments-ido-visit-buffer-other)
               (ad-activate 'ido-mode)
               (ad-update 'ido-mode)
               (ad-enable-advice 'ido-mode 'after
                                 'ourcomments-ido-add-ctrl-tab)
               (setq ourcomments-ido-old-state ido-mode)
               (ido-mode (or ido-mode 'buffer))
               )
           (ad-disable-advice 'ido-visit-buffer 'before
                              'ourcomments-ido-visit-buffer-other)
           (ad-disable-advice 'ido-mode 'after
                              'ourcomments-ido-add-ctrl-tab)
           ;; For some reason this little complicated construct is
           ;; needed. If they are not there the defadvice
           ;; disappears. Huh.
           (if ourcomments-ido-old-state
               (ido-mode ourcomments-ido-old-state)
             (when ido-mode (ido-mode -1)))
           ))
  :group 'emacsw32
  :group 'convenience)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; New Emacs instance

(defun ourcomments-find-emacs ()
  (let ((exec-path (list exec-directory)))
    (executable-find "emacs")))

(defun emacs()
  "Start a new Emacs."
  (interactive)
  (recentf-save-list)
  (call-process (ourcomments-find-emacs) nil 0 nil)
  (message "Started 'emacs' - it will be ready soon ..."))

(defun emacs-buffer-file()
  "Start a new Emacs showing current buffer file.
If there is no buffer file start with `dired'."
  (interactive)
  (recentf-save-list)
  (let ((file (buffer-file-name)))
    ;;(unless file (error "No buffer file name"))
    (if file
        (progn
          (call-process (ourcomments-find-emacs) nil 0 nil file)
          (message "Started 'emacs buffer-file-name' - it will be ready soon ..."))
      (call-process (ourcomments-find-emacs) nil 0 nil "--eval"
                    (format "(dired \"%s\")" default-directory)))))

(defun emacs--debug-init()
  (interactive)
  (call-process (ourcomments-find-emacs) nil 0 nil "--debug-init")
  (message "Started 'emacs --debug-init' - it will be ready soon ..."))

(defun emacs-Q()
  "Start new Emacs without any customization whatsoever."
  (interactive)
  (call-process (ourcomments-find-emacs) nil 0 nil "-Q")
  (message "Started 'emacs -Q' - it will be ready soon ..."))

(defun emacs-Q-nxhtml()
  "Start new Emacs with -Q and load nXhtml."
  (interactive)
  (let ((autostart (expand-file-name "../../EmacsW32/nxhtml/autostart.el"
                                     exec-directory)))
    (call-process (ourcomments-find-emacs) nil 0 nil "-Q"
                  "--debug-init"
                  "--load" autostart
                  )
    (message "Started 'emacs -Q --load \"%s\"' - it will be ready soon ..."
             autostart)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Searching

(defun grep-get-files ()
  "Return list of files in a grep-mode buffer."
  (or (compilation-buffer-p (current-buffer))
      (error "Not in a compilation buffer"))
  (let ((here (point))
        files
        loc)
    (goto-char (point-min))
    ;; fix-me: How do you check if all is fontified?
    (font-lock-fontify-buffer)
    (while (setq loc
                 (condition-case err
                     (compilation-next-error 1)
                   (error
                    ;; This should be the end, but give a message for
                    ;; easier debugging.
                    (message "%s" err)
                         nil)))
      ;;(message "here =%s, loc=%s" (point) loc)
      (let ((file (caar (nth 2 (car loc)))))
        (setq file (expand-file-name file))
        (add-to-list 'files file)))
    (goto-char here)
    ;;(message "files=%s" files)
    files))

;; Mostly copied from dired-do-query-replace-regexp. Fix-me: finish, test
(defun grep-do-query-replace-regexp (from to &optional delimited)
  "Do `query-replace-regexp' of FROM with TO, on all files in *grep*.
Third arg DELIMITED (prefix arg) means replace only word-delimited matches.
If you exit (\\[keyboard-quit], RET or q), you can resume the query replace
with the command \\[tags-loop-continue]."
  ;;'grep-regexp-history
  (interactive
   (let ((common
	  (query-replace-read-args
	   "Query replace regexp in files in *grep*" t t)))
     (list (nth 0 common) (nth 1 common) (nth 2 common))))
  (dolist (file (grep-get-files))
    (let ((buffer (get-file-buffer file)))
      (if (and buffer (with-current-buffer buffer
			buffer-read-only))
	  (error "File `%s' is visited read-only" file))))
  (tags-query-replace from to delimited
		      '(grep-get-files)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Info

(defun info-open-file (info-file)
  "Open an info file in `Info-mode'."
  (interactive
   (let ((name (read-file-name "Info file: "
                               nil ;; dir
                               nil ;; default-filename
                               t   ;; mustmatch
                               nil ;; initial
                               ;; predicate:
                               (lambda (file)
                                 (or (file-directory-p file)
                                     (string-match ".*\\.info\\'" file))))))
     (list name)))
  (info info-file))

(provide 'ourcomments-util)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ourcomments-util.el ends here
