;;; nxhtmltest-helpers.el --- Helper functions for testing
;;
;; Author: Lennart Borgman (lennart O borgman A gmail O com)
;; Created: 2008-07-08T19:10:54+0200 Tue
;; Version: 0.1
;; Last-Updated: 2008-07-08T19:11:22+0200 Tue
;; URL:
;; Keywords:
;; Compatibility:
;;
;; Features that might be required by this library:
;;
;;   Cannot open load file: test-helpers.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Change log:
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

(defun nxhtmltest-mumamo-error-messages ()
  (ert-get-messages "^MuMaMo error"))

(defun nxhtmltest-should-no-mumamo-errors ()
  (ert-should (not (nxhtmltest-mumamo-error-messages))))

(defun nxhtmltest-mumamo-error-messages ()
  (ert-get-messages "^MuMaMo error"))

(defun nxhtmltest-should-no-nxml-errors ()
  (ert-should (not (ert-get-messages "Internal nXML mode error"))))

(defun nxhtmltest-be-really-idle (seconds &optional prompt-mark)
  (unless prompt-mark (setq prompt-mark ""))
  (with-timeout (4 (message "<<<< %s - not really idle any more at %s"
                            prompt-mark
                            (format-time-string "%H:%M:%S")))
    (let ((prompt (format
                   ">>>> %s Starting beeing really idle %s seconds at %s"
                   prompt-mark
                   seconds
                   (format-time-string "%H:%M:%S ..."))))
      (message "%s" prompt)
      (read-minibuffer prompt)
      (redisplay))))

;;(nxhtmltest-be-really-idle 4 "HERE I AM!!")

(defmacro* nxhtmltest-with-temp-buffer (file-name-form &body body)
  (declare (indent 1) (debug t))
  (let ((file-name (gensym "file-name-")))
    `(let ((,file-name (nxhtml-get-test-file-name ,file-name-form)))
       (with-temp-buffer
         ;; Give the buffer a name that allows us to switch to it
         ;; quickly when debugging a failure.
         (rename-buffer (format "Test input %s"
                                (file-name-nondirectory ,file-name))
                        t)
         (insert-file-contents ,file-name)
         (save-window-excursion
           ;; Switch to buffer so it will show immediately when
           ;; debugging a failure.
           (switch-to-buffer (current-buffer))
           ,@body)))))

;; Fix-me: This does not work as I intended. A lot of buffers lying
;; around ...
(defvar nxhtmltest-test-buffers nil)

(defun nxhtmltest-kill-test-buffers ()
  "Delete test buffers from unsuccessful tests."
  (interactive)
  (let ((failed (get-buffer nxhtmltest-failed-buffers-name)))
    (when failed (kill-buffer failed)))
  (dolist (buf nxhtmltest-test-buffers)
    (when (buffer-live-p buf)
      (kill-buffer buf)))
  (setq nxhtmltest-test-buffers nil))

(defun nxhtmltest-list-test-buffers ()
  "List test buffers from unsuccessful tests."
  (interactive)
  (setq nxhtmltest-test-buffers
        (delq nil
              (mapcar (lambda (buf)
                        (when (buffer-live-p buf)
                          buf))
                      nxhtmltest-test-buffers)))
  (let ((ert-buffer (get-buffer "*ert*"))
        (buffers nxhtmltest-test-buffers))
    (when ert-buffer (setq buffers (cons ert-buffer buffers)))
    (switch-to-buffer
     (let ((Buffer-menu-buffer+size-width 40))
       (list-buffers-noselect nil buffers)))
    (rename-buffer nxhtmltest-failed-buffers-name t))
  (unless nxhtmltest-test-buffers
    (message "No test buffers from unsuccessful tests")))

(defvar nxhtmltest-failed-buffers-name "*Ert Failed Test Buffers*")

(defvar nxhtmltest-persistent-buffer-mode-map
  (let ((map (make-sparse-keymap)))
    ;; Add menu bar entries for test buffer and test function
    (define-key map [(control ?c) ?? ?t] 'nxhtmltest-persistent-go-test)
    (define-key map [(control ?c) ?? ?f] 'nxhtmltest-persistent-go-file)
    map))
(defun nxhtmltest-persistent-go-test ()
  (interactive)
  (ert-find-test-other-window nxhtmltest-persistent-buffer-test))
(defun nxhtmltest-persistent-go-file ()
  (interactive)
  (find-file-other-window nxhtmltest-persistent-buffer-file))

(define-minor-mode nxhtmltest-persistent-buffer-mode
  "Helpers for those buffers ..."
  )
(put 'nxhtmltest-persistent-buffer-mode 'permanent-local t)
(defvar nxhtmltest-persistent-buffer-test nil)
(make-variable-buffer-local 'nxhtmltest-persistent-buffer-test)
(put 'nxhtmltest-persistent-buffer-test 'permanent-local t)
(defvar nxhtmltest-persistent-buffer-file nil)
(make-variable-buffer-local 'nxhtmltest-persistent-buffer-file)
(put 'nxhtmltest-persistent-buffer-file 'permanent-local t)

(defmacro* nxhtmltest-with-persistent-buffer (file-name-form &body body)
  "Insert FILE-NAME-FORM in a temporary buffer and eval BODY.
If success then delete the temporary buffer, otherwise keep it.

To delete all temporary buffers from unsuccessful test you can
use `nxhtmltest-kill-test-buffers'."
  (declare (indent 1) (debug t))
  (let ((file-name (gensym "file-name-")))
    `(let* ((,file-name (nxhtml-get-test-file-name ,file-name-form))
            (nxhtmltest-this-file ,file-name)
            (mode-line-buffer-identification (list (propertize "%b" 'face 'highlight)))
            ;; Give the buffer a name that allows us to switch to it
            ;; quickly when debugging a failure.
            (temp-buf
             (generate-new-buffer
              (format "%s"
                      (ert-this-test)
                      ;;(file-name-nondirectory ,file-name)
                      ;; Fix-me: I would like to have the test name
                      ;; here. Is that possible?
                      ))))
       (unless (file-readable-p ,file-name)
         (if (file-exists-p ,file-name)
             (error "Can't read %s" ,file-name)
           (error "Can't find %s" ,file-name)))
       (message "Testing with file %s" ,file-name)
       (setq nxhtmltest-test-buffers (cons temp-buf nxhtmltest-test-buffers))
       (with-current-buffer temp-buf
         (nxhtmltest-persistent-buffer-mode 1)
         (setq nxhtmltest-persistent-buffer-file ,file-name)
         (setq nxhtmltest-persistent-buffer-test (ert-this-test))
         ;; Avoid global font lock
         (let ((font-lock-global-modes nil))
           ;; Turn off font lock in buffer
           (font-lock-mode -1)
           (when (> emacs-major-version 22)
             (assert (not font-lock-mode) t "%s %s" "in nxhtmltest-with-persistent-buffer"))
           (insert-file-contents ,file-name)
           (save-window-excursion
             ;; Switch to buffer so it will show immediately when
             ;; debugging a failure.
             (switch-to-buffer-other-window (current-buffer))
             ,@body)
           ;; Fix-me: move to success list.
           (kill-buffer temp-buf))))))


(defun nxhtml-get-test-file-name (file-name)
  (expand-file-name file-name nxhtmltest-files-root))


;;; Fontification methods

(defvar nxhtmltest-default-fontification-method nil)

(defun nxhtmltest-get-fontification-method ()
  "Ask user for default fontification method."
  (let* ((collection
          '(
            ("Fontify as usual (wait)" fontify-as-usual)
            ("Fontify by calling timer handlers" fontify-w-timer-handlers)
            ("Call fontify-buffer" fontify-buffer)
            ))
         (hist (mapcar (lambda (rec)
                         (car rec))
                       collection))
         (method-name (or t
                          (completing-read "Default fontification method: "
                                           collection nil t
                                           (car (nth 1 collection))
                                           'hist))))
    (setq nxhtmltest-default-fontification-method
          ;;(nth 1 (assoc method-name collection))
          'fontify-w-timer-handlers
          )))

(defun nxhtmltest-fontify-as-usual (seconds prompt-mark)
  (font-lock-mode 1)
  (font-lock-wait (nxhtmltest-be-really-idle seconds prompt-mark)))

(defun nxhtmltest-fontify-w-timers-handlers ()
    (dolist (timer (copy-list timer-idle-list))
      (timer-event-handler timer))
    (redisplay t))

(defun nxhtmltest-fontify-buffer ()
  (font-lock-fontify-buffer)
  (redisplay t))

(defun nxhtmltest-fontify-default-way (seconds &optional pmark)
  ;;(assert (not font-lock-mode))
  (case nxhtmltest-default-fontification-method
    (fontify-as-usual         (nxhtmltest-fontify-as-usual seconds pmark))
    (fontify-w-timer-handlers (nxhtmltest-fontify-w-timers-handlers))
    (fontify-buffer           (nxhtmltest-fontify-buffer))
    (t (error "Unrecognized default fontification method: %s"
              nxhtmltest-default-fontification-method))))


(provide 'nxhtmltest-helpers)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; nxhtmltest-helpers.el ends here
