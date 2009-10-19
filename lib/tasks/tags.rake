# -*- ruby -*-

desc "rebuild TAGS file for emacs"
task :tags do
  Kernel.system("ctags-exuberant -a -e -f TAGS --tag-relative -R app lib vendor")
end
