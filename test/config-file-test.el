;;; config-file-test.el --- Tests for config file functions  -*- lexical-binding: t; -*-

;; Copyright (C) 2013  Sebastian Wiesner

;; Author: Sebastian Wiesner <lunaryorn@gmail.com>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Tests for config file location functions.

;;; Code:

(require 'test-helper)

(require 'projectile)

(ert-deftest flycheck-locate-config-file-absolute-path/just-a-base-name ()
  (with-temp-buffer
    (cd flycheck-testsuite-dir)
    (should-not (flycheck-locate-config-file-absolute-path "flycheck-testsuite.el"
                                                           'emacs-lisp))))

(ert-deftest flycheck-locate-config-file-absolute-path/with-path ()
  (with-temp-buffer
    (cd flycheck-testsuite-dir)
    (should (equal (flycheck-locate-config-file-absolute-path "../Makefile"
                                                              'emacs-lisp)
                   (f-join flycheck-testsuite-dir "../Makefile")))))



(ert-deftest flycheck-locate-config-file-projectile/existing-file-inside-a-project ()
  (with-temp-buffer
    (set-visited-file-name (f-join flycheck-testsuite-dir "foo")
                           :no-query)
    (should (projectile-project-p))
    (should (equal
             (flycheck-locate-config-file-projectile "Makefile" 'emacs-lisp)
             (f-join flycheck-testsuite-dir "../Makefile")))))

(ert-deftest flycheck-locate-config-file-projectile/not-existing-file-inside-a-project ()
  (with-temp-buffer
    (set-visited-file-name (f-join flycheck-testsuite-dir "foo")
                           :no-query)
    (should (projectile-project-p))
    (should-not (flycheck-locate-config-file-projectile "Foo" 'emacs-lisp))))

(ert-deftest flycheck-locate-config-file-projectile/outside-a-project ()
  (with-temp-buffer
    (set-visited-file-name (f-join temporary-file-directory "foo")
                           :no-query)
    (should-not (projectile-project-p))
    (should-not (flycheck-locate-config-file-projectile "Foo" 'emacs-dir))))

(ert-deftest flycheck-locate-config-file-ancestor-directories/not-existing-file ()
  (with-temp-buffer
    (setq buffer-file-name (f-join flycheck-testsuite-dir "flycheck-testsuite.el"))
    (should-not (flycheck-locate-config-file-ancestor-directories
                 "foo" 'emacs-lisp))))

(ert-deftest flycheck-locate-config-file-ancestor-directories/file-on-same-level ()
  (with-temp-buffer
    (setq buffer-file-name (f-join flycheck-testsuite-dir "flycheck-testsuite.el"))
    (should (equal (flycheck-locate-config-file-ancestor-directories
                    "test-helper.el" 'emacs-lisp)
                   (f-join flycheck-testsuite-dir "test-helper.el")))))

(ert-deftest flycheck-locate-config-file-ancestor-directories/file-on-parent-level ()
  (with-temp-buffer
    (setq buffer-file-name (f-join flycheck-testsuite-dir "flycheck-testsuite.el"))
    (should (equal (flycheck-locate-config-file-ancestor-directories
                    "Makefile" 'emacs-lisp)
                   (f-join flycheck-testsuite-dir "../Makefile")))))

(ert-deftest flycheck-locate-config-file/not-existing-file ()
  (flycheck-testsuite-with-env (list (cons "HOME" flycheck-testsuite-dir))
    (should-not (flycheck-locate-config-file-home "foo" 'emacs-lisp))))

(ert-deftest flycheck-locate-config-file/existing-file-in-parent-directory ()
  (flycheck-testsuite-with-env (list (cons "HOME" flycheck-testsuite-dir))
    (should-not (flycheck-locate-config-file-home "Makefile" 'emacs-lisp))))

(ert-deftest flycheck-locate-config-file/existing-file-in-home-directory ()
  (flycheck-testsuite-with-env (list (cons "HOME" flycheck-testsuite-dir))
    (should (equal (flycheck-locate-config-file-home
                          "test-helper.el" 'emacs-lisp)
                         (f-join flycheck-testsuite-dir "test-helper.el")))))

;;; config-file-test.el ends here
