;;; vagrant.el --- Manage a vagrant box from emacs

;;; Version: 0.6.1
;;; Author: Robert Crim <rob@servermilk.com>
;;; Url: https://github.com/ottbot/vagrant.el
;;; Keywords: vagrant chef
;;; Created: 08 August 2013

;;; Commentary:

;; This package lets you send vagrant commands while working within a
;; project containing a Vagrantfile.
;;
;; It will traverse the directory tree until a Vagrantfile is found
;; and assume this is the box you want to work with. It can be handy
;; to bring a box up, (re)provision, or even ssh to without leaving
;; emacs.
;;
;; The emacs command `vagrant-up` will run `vagrant up` in a shell,
;; other commands follow the pattern `vagrant-X` emacs command runs
;; `vagrant X` in the shell. An exception is vagrant-edit, which will
;; open the Vagrantfile for editing.

;;; Code:
(defgroup vagrant nil
  "Customization group for `vagrant.el'."
  :group 'tools)

(defcustom vagrant-up-options ""
  "Options to run vagrant up command."
  :group 'vagrant)

(defcustom vagrant-project-directory "~/vagrant"
  "The path to a Vagrant sandbox."
  :group 'vagrant
  :type 'string)

;;;###autoload
(defun vagrant-kill-all-buffers ()
  "Kill all Vagrant buffers."
  (interactive)
  (kill-matching-buffers "*Vagrant*"))

;;;###autoload
(defun vagrant-box-list ()
  "List Vagrant boxes."
  (interactive)
  (global-vagrant-command "vagrant box list"))

;;;###autoload
(defun vagrant-box-update ()
  "Update the Vagrant box used in the directory-local Vagrant config."
  (interactive)
  (vagrant-directory-local-command "vagrant box update"))

;;;###autoload
(defun vagrant-up ()
  "Bring up the vagrant box."
  (interactive)
  (vagrant-directory-local-command (concat "vagrant up " vagrant-up-options)))

;;;###autoload
(defun vagrant-provision ()
  "Provision the vagrant box."
  (interactive)
  (vagrant-directory-local-command "vagrant provision"))

;;;###autoload
(defun vagrant-destroy ()
  "Destroy the vagrant box."
  (interactive)
  (vagrant-directory-local-command "vagrant destroy"))

;;;###autoload
(defun vagrant-destroy-force ()
  "Destroy the vagrant box without promting for confirmation."
  (interactive)
  (vagrant-directory-local-command "vagrant destroy --force"))

;;;###autoload
(defun vagrant-reload ()
  "Reload the vagrant box."
  (interactive)
  (vagrant-directory-local-command "vagrant reload"))

;;;###autoload
(defun vagrant-resume ()
  "Resume the vagrant box."
  (interactive)
  (vagrant-directory-local-command "vagrant resume"))

;;;###autoload
(defun vagrant-ssh ()
  "SSH to the vagrant box."
  (interactive)
  (vagrant-directory-local-command "vagrant ssh"))

;;;###autoload
(defun vagrant-ssh-command (x)
  "pass a command to the vagrant box through ssh."
  (interactive "sCommand to run by ssh:")
  (vagrant-directory-local-command (format "vagrant ssh -c %s" x )));

;;;###autoload
(defun vagrant-status ()
  "Show the vagrant box status."
  (interactive)
  (vagrant-directory-local-command "vagrant status"))
;;;###autoload

(defun vagrant-global-status ()
  "Show the vagrant box status."
  (interactive)
  (global-vagrant-command "vagrant global-status"))

;;;###autoload
(defun vagrant-suspend ()
  "Suspend the vagrant box."
  (interactive)
  (vagrant-directory-local-command "vagrant suspend"))

;;;###autoload
(defun vagrant-halt ()
  "Halt the vagrant box."
  (interactive)
  (vagrant-directory-local-command "vagrant halt"))

;;;###autoload
(defun vagrant-rsync ()
  "Sync folders with rsync as configured in Vagrantfile."
  (interactive)
  (vagrant-directory-local-command "vagrant rsync"))

;;;###autoload
(defun vagrant-init ()
  "Initialize a Vagrant environment in cwd."
  (interactive)
  (global-vagrant-command "vagrant init"))

;;;###autoload
(defun vagrant-edit ()
  "Edit the Vagrantfile."
  (interactive)
  (find-file (vagrant-locate-vagrantfile)))

;;;###autoload
(defun vagrant-kill-dormant-buffers ()
  (interactive)
  (dolist (x (buffer-list))
    (if
        (and
         (vagrant--is-vagrant-buffer x)
         (not (get-buffer-process x)))
        (kill-buffer x))))

(defvar-local vagrant-vagrantfile nil
  "Default path to Vagrantfile")

(defun vagrant-locate-vagrantfile (&optional dir)
  "Find Vagrantfile for DIR."
  (or (locate-dominating-file (or dir default-directory) "Vagrantfile")
      (or vagrant-vagrantfile
          (error "No Vagrantfile found in %s or any parent directory" dir))))

(defun vagrant-directory-local-command (cmd)
  "Run the vagrant command CMD in an async buffer."
  (let* ((default-directory (file-name-directory (vagrant-locate-vagrantfile)))
         (name (if current-prefix-arg
                   (completing-read "Vagrant box: " (vagrant--box-list)))))
    (async-shell-command (if name (concat cmd " " name) cmd) "*Vagrant*")))

(defun global-vagrant-command (cmd)
  "Run the vagrant command CMD in an async buffer, where CMD does not require a Vagrantfile in cwd."
    (async-shell-command cmd "*Vagrant*"))

(defun vagrant--box-list ()
  "List of vagrant box names."
  (let ((dir ".vagrant/machines/"))
    (delq nil
          (mapcar (lambda (name)
                    (and (not (member name '("." "..")))
                         (file-directory-p (concat dir name))
                         name))
                  (directory-files dir)))))

(defun vagrant--is-vagrant-buffer (x)
  "returns t if the string '*Vagrant*' in buffer name"
  ;; TODO needs unit test
  (if (string-match "*Vagrant*" (buffer-name x))
      t));

(provide 'vagrant)

;;; vagrant.el ends here
