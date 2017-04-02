;;; init-package-elpa --- Configuration for packages managed by elpa.

;;; Commentary:
;;; Load packages configuration managed by elpa.
;;; Generally speaking, everything in this configuration file is platform
;;; independent, i.e., once you download it from server, it will download
;;; necessary packages automatically.  You don't need to do anything but offer a
;;; accessible network.  Then get a cup of coffee to wait until the download
;;; completes.

;;; Code:

;;; Standard package repositories
;; melpa for most packages
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://melpa-stable.milkbox.net/packages/"))
;; org repository for completeness
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
;; marmalade packages
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))

(package-initialize)

(defconst required-packages
  '(
    ac-ispell
    adaptive-wrap
    anzu
    auctex
    auto-complete
    auto-complete-clang
    auto-complete-c-headers
    auto-highlight-symbol
    autopair
    avy
    blank-mode
    bookmark+
    cal-china-x
    chinese-fonts-setup
    cmake-mode
    column-marker
    color-theme
    color-theme-solarized
    company
    company-c-headers
    company-shell
    cpputils-cmake
    csharp-mode
    cursor-chg
    dim
    dired+
    dired-single
    dired-sort-menu+
    everything
    fill-column-indicator
    fish-mode
    flycheck
    flyspell-popup
    haskell-mode
    hide-lines
    icicles
    iedit
    indent-guide
    irony
    ivy
    java-snippets
    linum-relative
    logview
    lua-mode
    magit
    markdown-mode
    markdown-preview-mode
    minimap
    modeline-posn
    modern-cpp-font-lock
    multiple-cursors
    origami
    pandoc-mode
    paredit
    plantuml-mode
    powerline-evil
    protobuf-mode
    psvn
    rainbow-mode
    session
    smart-mode-line
    smart-mode-line-powerline-theme
    sos
    sr-speedbar
    swiper
    switch-window
    tabbar
    vimrc-mode
    websocket
    workgroups2
    xcscope
    yasnippet
    youdao-dictionary
    ztree
    ))

(defun ensure-packages ()
  "install lost packages"
  (interactive)
  (unless package-archive-contents
    (package-refresh-contents))
  (dolist (package required-packages)
    (unless (package-installed-p package)
      (package-install package))))

(ensure-packages)

;;; configuration of packages, ordered alphabetically

;; ac-ispell
;; Completion words longer than 4 characters
(custom-set-variables
 '(ac-ispell-requires 4)
 '(ac-ispell-fuzzy-limit 2))

(eval-after-load "auto-complete"
  '(progn
     (ac-ispell-setup)))

(add-hook 'git-commit-mode-hook 'ac-ispell-ac-setup)
(add-hook 'mail-mode-hook 'ac-ispell-ac-setup)
(add-hook 'prog-mode-hook 'ac-ispell-ac-setup)
(add-hook 'text-mode-hook 'ac-ispell-ac-setup)
(add-hook 'org-mode-hook 'ac-ispell-ac-setup)

;; adaptive-wrap
(add-hook 'visual-line-mode-hook 'adaptive-wrap-prefix-mode)

;; anzu
(global-anzu-mode +1)
(global-set-key [remap query-replace] 'anzu-query-replace)
(global-set-key [remap query-replace-regexp] 'anzu-query-replace-regexp)

;; auto-complete
(ac-config-default)                             ; auto-complete
(ac-flyspell-workaround)                        ; fix collisions with flyspell
(ac-linum-workaround)                           ; fix collisions with linum
(global-auto-complete-mode t)                   ; enable auto-complete-mode globally
(add-hook 'prog-mode-hook 'auto-complete-mode)
(add-hook 'text-mode-hook 'auto-complete-mode)
(add-hook 'org-mode-hook 'auto-complete-mode)
(require 'semantic/bovine/gcc)
(require 'semantic/bovine/c)
(load (expand-file-name "~/.emacs.d/auto-complete-clang-extension"))
(setq semantic-c-dependency-system-include-path
      ac-clang-extension-all-include-dirs)
(mapc (lambda (dir)
        (semantic-add-system-include dir 'c++-mode)
        (semantic-add-system-include dir 'c-mode))
      ac-clang-extension-all-include-dirs)
(if (file-exists-p "~/.emacs.d/init-package-manual.el")
    (load "~/.emacs.d/init-package-manual.el"))

;; auto-highlight-symbol-mode
(require 'auto-highlight-symbol)
(add-hook 'prog-mode-hook 'auto-highlight-symbol-mode)

;; autopair
(require 'autopair)
(if (version< emacs-version "24.4")
    (autopair-global-mode 1))

;; avy
(global-set-key (kbd "M-g f") 'avy-goto-line)
(avy-setup-default)

;; blank-mode
(global-set-key (kbd "C-c C-b") 'whitespace-mode) ; show whitespace

;; bookmark+
; rebind bmkp prefix key to "C x /"
(setq bmkp-bookmark-map-prefix-keys (quote ("/")))
(setq bmkp-last-as-first-bookmark-file nil)
; change annoying bookmark name face color in terminal mode
(require 'bookmark+-bmu)
(when (not (display-graphic-p))
  (set-face-attribute
   'bmkp-local-file-without-region nil
   :foreground "green"))
; automatically save change
(setq bookmark-save-flag 1)

;; cal-china-x
(require 'cal-china-x)
(setq mark-holidays-in-calendar t)
(setq cal-china-x-important-holiday
      cal-china-x-chinese-holidays)
(setq calendar-holidays
      (append cal-china-x-important-holidays
              cal-china-x-general-holidays
              other-holidays))

;; chinese-fonts-setup
(require 'chinese-fonts-setup)
(chinese-fonts-setup-enable)

;; color-theme-solarized
(set-terminal-parameter nil 'background-mode 'dark)
(set-frame-parameter nil 'background-mode 'dark)
(if (window-system)
    (load-theme 'solarized t))

;; column-marker
(column-marker-1 80)                    ; column marker width

;; cpputils-cmake
(add-hook 'c-mode-common-hook
          (lambda ()
            (if (derived-mode-p 'c-mode 'c++-mode)
                (cppcm-reload-all))))

;; dim
(defun simplify-mode-alias ()
  "Shorten mode line major/minor modes names."
  (dim-major-names
   '(
     (emacs-lisp-mode     "Eλ")
     (makefile-gmake-mode "GM")
     (scheme-mode         "λ")
     ))
  (dim-minor-names
   '(
     (auto-fill-function         " _")
     (auto-revert-mode           " ^")
     (auto-complete-mode         "")
     (auto-highlight-symbol-mode "")
     (autopair-mode              "")
     (anzu-mode                  "")
     (abbrev-mode                "")
     (hs-minor-mode              "")
     (ivy-mode                   "")
     )))
(eval-after-load "~/.emacs.d/init.el" (simplify-mode-alias))
(add-hook 'workgroups-mode-hook
          (lambda ()
            (dim-minor-name 'workgroups-mode "")))
(add-hook 'yas-minor-mode-hook
          (lambda ()
            (dim-minor-name 'yas-minor-mode  " ->")))
(add-hook 'paredit-mode-hook
          (lambda ()
            (dim-minor-name 'paredit-mode    " ()")))
(add-hook 'flyspell-mode-hook
          (lambda ()
            (dim-minor-name 'flyspell-mode   " √")))

;; dired-single
(add-hook 'dired-mode-hook
          (lambda ()
            (define-key dired-mode-map (kbd "RET") 'dired-single-buffer)
            (define-key dired-mode-map (kbd "<mouse-1>") 'dired-single-buffer-mouse)
            (define-key dired-mode-map (kbd "^")
              (lambda ()
                (interactive)
                (dired-single-buffer "..")))))

;; everything
(if (eq system-type 'windows-nt)
    (setq everything-cmd "D:/Program Files/Everything/es.exe"))

;; fill-column-indicator
(setq fci-rule-width 1)
(setq fci-rule-color "darkblue")

;; flycheck-mode
(global-flycheck-mode)

;; flyspell-mode
(require 'ispell)
(setq ispell-local-dictionary-alist
      '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8)))
(if (eq system-type 'windows-nt)
    (progn
      (setq ispell-program-name "aspell")
      (setq ispell-alternate-dictionary "~/.emacs.d/windows/dict.txt")))
(ispell-change-dictionary "american" t)
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-prog-mode)
(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1)))) ;disable spell check for log mode

;; flyspell-popup
(add-hook 'flyspell-mode-hook #'flyspell-popup-auto-correct-mode)

;; icicle-mode
(require 'icicles)
(eval-after-load "icicles-opt.el"
  (add-hook 'icicle-mode-hook
            (lambda ()
              (setq my-icicle-top-level-key-bindings
                    (mapcar (lambda (lst)
                              (unless (string= "icicle-occur" (nth 1 lst)) lst))
                            icicle-top-level-key-bindings))
              (setq icicle-top-level-key-bindings my-icicle-top-level-key-bindings) )))
(icy-mode 1)

;; iedit-mode
(require 'iedit)
(defun iedit-dwim (arg)
  "Starts iedit but uses \\[narrow-to-defun] to limit its scope."
  (interactive "P")
  (if arg
      (iedit-mode)
    (save-excursion
      (save-restriction
        (widen)
        ;; this function determines the scope of `iedit-start'.
        (if iedit-mode
            (iedit-done)
          ;; `current-word' can of course be replaced by other
          ;; functions.
          (narrow-to-defun)
          (iedit-start (current-word) (point-min) (point-max)))))))
(global-set-key (kbd "C-c ; s") 'iedit-dwim)

;; irony-mode
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)
;; replace the `completion-at-point' and `complete-symbol' bindings in
;; irony-mode's buffers by irony-mode's function
(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(setq w32-pipe-read-delay 0)

;; indent-guide
(setq indent-guide-recursive t)

;; ivy
; for unknown reasons, Emacs crash in
; terminal when ivy-mode is enabled, so
; enable this minor mode only when the
; Emacs is run under window system
(require 'ivy)
(setq ivy-use-virtual-buffers t)
(if (window-system)
    (ivy-mode 1)
  (progn
    (message "Terminal mode, ivy disabled")
    (ivy-mode 0)
    ))

;; langtool
(require 'langtool)
(setq langtool-mother-tongue "en-US")
(setq langtool-language-tool-jar
      "~/languagetool/languagetool-commandline.jar")
(global-set-key "\C-x4w" 'langtool-check)
(global-set-key "\C-x4W" 'langtool-check-done)
(global-set-key "\C-x4l" 'langtool-switch-default-language)
(global-set-key "\C-x44" 'langtool-show-message-at-point)
(global-set-key "\C-x4c" 'langtool-correct-buffer)
(defun langtool-autoshow-detail-popup (overlays)
  "Show langtool check result automatically."
  (when (require 'popup nil t)
    ;; Do not interrupt current popup
    (unless (or popup-instances
                ;; suppress popup after type `C-g` .
                (memq last-command '(keyboard-quit)))
      (let ((msg (langtool-details-error-message overlays)))
        (popup-tip msg)))))
(setq langtool-autoshow-message-function
      'langtool-autoshow-detail-popup)

;; logview-mode
(require 'logview)
(setq
 logview-additional-timestamp-formats
 (quote (("Android Logcat Time Format"
          (java-pattern . "MM-dd HH:mm:ss.SSS")
          (aliases "MM-dd HH:mm:ss.SSS")))))
(setq
 logview-additional-level-mappings
 (quote (("Logcat"
          (error "E")
          (warning "W")
          (information "I")
          (debug "D")
          (trace "V")
          (aliases "android")))))
(setq
 logview-additional-submodes
 (quote (("Android"
          (format . "TIMESTAMP LEVEL NAME THREAD:")
          (levels . "Logcat")
          (timestamp "Android Logcat Time Format")
          (aliases "logcat"))
         ("Android-nontime"
          (format . "LEVEL NAME THREAD:")
          (levels . "Logcat")
          (aliases "logcat-n"))
         ("threadtime"
          (format . "TIMESTAMP THREAD THREAD LEVEL NAME:")
          (levels . "Logcat")
          (timestamp "Android Logcat Time Format")
          (aliases "logcat")))))

;; lua-mode
(setq lua-indent-level 4)

;; markdown-mode
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\README*" . markdown-mode))

;; modern-c++-font-lock
(require 'modern-cpp-font-lock)
(modern-c++-font-lock-global-mode t)

;; multiple-cursors
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)

;; origami
(dolist (hook '(
                prog-mode-hook
                ))
  (add-hook hook 'origami-mode))
(global-set-key (kbd "C-c C-f") 'origami-toggle-node)
(global-set-key (kbd "C-c M-f") 'origami-toggle-all-nodes)

;; paredit
(dolist (hook '(emacs-lisp-mode-hook
                eval-expression-minibuffer-setup-hook
                ielm-mode-hook
                lisp-mode-hook
                lisp-interaction-mode-hook
                scheme-mode-hook))
  (add-hook hook 'enable-paredit-mode))

;; plantuml-mode
(add-to-list 'auto-mode-alist '("\\.puml\\'" . plantuml-mode))
(add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode))

;; smart-mode-line
(require 'smart-mode-line)
(setq sml/no-confirm-load-theme t)
(setq sml/shorten-directory t)
(setq sml/shorten-modes t)
(setq sml/name-width 40)
(sml/setup)

;; sr-speedbar
(custom-set-variables
 '(sr-speedbar-default-width 100)
 '(sr-speedbar-max-width 100))

;; switch-window
(global-set-key (kbd "C-x o") 'switch-window) ; rebind `C-x o' to switch-window

;; tabbar-mode
(tabbar-mode)
(load "~/.emacs.d/init-tabbar-theme.el") ; theme
(if (display-graphic-p)                  ; key-binding
    (progn
      (global-set-key [C-tab] 'tabbar-forward-tab)
      (global-set-key (kbd "C-c <C-tab>") 'tabbar-backward-tab))
  (progn
    (global-set-key (kbd "C-c t n") 'tabbar-forward-tab)
    (global-set-key (kbd "C-c t p") 'tabbar-backward-tab)))

;; vimrc-mode
(add-to-list 'auto-mode-alist '("vim\\(rc\\)?$" . vimrc-mode))

;; workgroups2
(require 'workgroups2)
(setq wg-emacs-exit-save-behavior           'save)      ; Options: 'save 'ask nil
(setq wg-workgroups-mode-exit-save-behavior 'save)      ; Options: 'save 'ask nil
;; Mode Line changes
(setq wg-mode-line-display-on t)          ; Default: (not (featurep 'powerline))
(setq wg-flag-modified t)                 ; Display modified flags as well
(setq wg-mode-line-decor-left-brace "["
      wg-mode-line-decor-right-brace "]"  ; how to surround it
      wg-mode-line-decor-divider ":")
(workgroups-mode 1)

;; xcscope
(require 'xcscope)
(setq cscope-option-do-not-update-database t)
(cscope-setup)
(add-hook 'java-mode-hook #'cscope-minor-mode)

;; yasnippet
(require 'yasnippet)
(yas-global-mode 1)
(add-hook 'prog-mode-hook #'yas-minor-mode)
;; Remove Yasnippet's default tab key binding
(define-key yas-minor-mode-map (kbd "<tab>") nil)
(define-key yas-minor-mode-map (kbd "TAB") nil)
;; Set Yasnippet's key binding to shift+tab
(define-key yas-minor-mode-map (kbd "<backtab>") 'yas-expand)
;; Alternatively use Control-c + tab
(define-key yas-minor-mode-map (kbd "\C-c TAB") 'yas-expand)
;; push yasnippet into auto complete sources
(setq ac-sources (append '(ac-source-yasnippet) ac-sources))

;; youdao-dictionary
(require 'youdao-dictionary)
(global-set-key (kbd "C-c y") 'youdao-dictionary-search-at-point)

(provide 'init-package-elpa)
;;; init-package-elpa.el ends here
