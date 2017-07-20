;;; dired-column.el --- Open dired in columns.

;; Git: https://github.com/matthewbauer/dired-column
;; Version: 0.01
;; Created: 2017-06-05
;; Keywords: dired, columns

;; This file is NOT part of GNU Emacs.

;;; Commentary:

;;; Code:

(require 'dired)

(defgroup dired-column nil
  "Open dired in columns."
  :group 'dired)

(defcustom dired-column-direction 'right
  "Direction to open columns toward."
  :group 'dired-column)

(defcustom dired-column-width 40
  "Width of each dired column."
  :group 'dired-column)

(defun dired-column-get-furthest-dir-window (direction window)
  "Get the furthest DIRECTION window relative to WINDOW."
  (let ((new-window (window-in-direction direction window))
	window)
    (while new-window
      (setq window new-window)
      (setq new-window (window-in-direction direction window)))
    window))

(defun dired-column-opposite-direction (direction)
  "Get opposite direction of DIRECTION."
  (pcase direction
    ('right 'left)
    ('left 'right)
    ('above 'below)
    ('below 'above)))

(defun dired-column-on-all-windows-direction (func direction window)
  "Run FUNC on all windows in the direction DIRECTION of WINDOW."
  (let ((new-window (window-in-direction direction window)))
    (while new-window
      (funcall func new-window)
      (setq new-window (window-in-direction direction new-window)))))

(defun dired-column-display-buffer-direction (buffer direction width)
  "Display BUFFER in direction DIRECTION leaving WIDTH for current buffer."
  (let ((window
	 (cond
	  ((get-buffer-window buffer (selected-frame)))
	  ((window-in-direction direction))
	  (t
	   (unless (>= (window-total-width) (* 2 width))
             (let ((opposite-direction
                    (dired-column-opposite-direction direction)))
               (delete-window
                (dired-column-get-furthest-dir-window opposite-direction
                                                      (selected-window)))
               (dired-column-on-all-windows-direction 'minimize-window
                                                      opposite-direction
                                                      (selected-window))))
	   (split-window (selected-window) width direction)))))
    (window--display-buffer buffer
                            window
                            'window
                            nil
                            display-buffer-mark-dedicated)
    window))

;;;###autoload
(defun dired-column-find-file ()
  "Display dired to the right as columns."
  (interactive)
  (let* ((file-or-dir (dired-get-file-for-visit))
	 (buffer (find-file-noselect file-or-dir)))
    (select-window
     (dired-column-display-buffer-direction buffer
                                            dired-column-direction
                                            dired-column-width))))

(provide 'dired-column)
;;; dired-column.el ends here
