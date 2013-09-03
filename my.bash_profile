#!/bin/bash

#set terminal highlight
if brew list | grep coreutils > /dev/null ; then
  PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
  alias ls='ls -F --show-control-chars --color=auto'
  eval `gdircolors -b $HOME/.dir_colors`
fi

#cmd
alias vi='vim'
alias ll='ls -l'
alias la='ls -la'
alias grep='grep --color'
alias egrep='egrep --color'


#ssh server
alias ssh@server='ssh levy.liul@login1.cm3.taobao.org'
alias ssh@simbo='ssh simbo@10.19.6.48'
alias mysql@dev='mysql -urisk -prisk -h10.20.149.13 -P3306 -b risk'
alias mysql@ut='mysql -utest -p1qaz@2wsx -h10.20.149.16 -P3306 -b ointest_ut'
alias mysql@test='mysql -utest -p1qaz@2wsx -h10.20.149.14 -b -P3306 ointest'
alias mysql@auto='mysql -utest -p1qaz@2wsx -h10.20.154.175 -b ointest'
alias mysql@perf='mysql -uointest_test -pointest_test -h10.20.129.146 -b ointest_test'
alias mysql@sea='mysql -uroot -p123456 -h10.20.157.171 -b sea_bridge'
alias ssh@vps='ssh admin@192.154.105.222'
alias gfw='ssh -CNgf guest@192.154.105.222 -D 127.0.0.1:7070'

#maven cmd
alias mvna='mvn archetype:generate'
alias mvnc='mvn compile'
alias mvnct='mvn test-compile'
alias mvnd='mvn deploy'
alias mvne='mvn eclipse:clean eclipse:eclipse  -Duse.release.version'
alias mvnec='mvn eclipse:clean'
alias mvner='mvn -r eclipse:eclipse'
alias mvni='mvn clean  install -Dmaven.test.skip=true  -Duse.release.version'
alias mvnrm='mvn clean'
alias mvnt='mvn test'
alias mvnp='mvn package'
alias mvns='mvn site'
alias mvndt='mvn dependency:tree'
alias mvnia='mvn clean  install -Dmaven.test.skip=true -Dautoconf.skip'
#move maven settings.xml to standard config
alias mvncs='sudo mv /usr/alibaba/maven/conf/settings.xml /usr/alibaba/maven/conf/settings.xml2'
#move maven settings.xml to alibaba config
alias mvnca='sudo mv /usr/alibaba/maven/conf/settings.xml2 /usr/alibaba/maven/conf/settings.xml'
alias mvnj='mvn idea:clean idea:idea  -Duse.release.version'

#svn cmd
alias svi='svn info'
alias svu='svn up'
alias svco='svn co'
alias svci='svn ci -m " "'
alias sva='svn add'
alias svrm='svn del'
alias svst='svn st'
alias svsw='svn sw'
alias svl='svn log'
alias svls='svn log --stop-on-copy'
alias svm='svn merge'
alias svmd='svn merge --dry-run'
alias svr='svn resolved'
alias svv='svn revert'
alias svvr='svn revert -R'
alias svd='svn diff'
alias svrmb='sh ~/shell/svrm_batch'
alias svab='sh ~/shell/sva_batch'

#git cmd
alias gita='git add'
alias gitc='git commit -m '
alias gitps='git push origin master'
alias gitpl='git pull'
alias gitst='git status'
alias gitrm="git rm"
alias gitd="git diff"

#other
alias tfn='tail -fn 200'
alias ks='bin/killws;bin/startws'
alias vh='sudo vi /etc/hosts'
alias scrot='scrot -s'
alias tarc='tar czvf'
alias tarx='tar xzvf'
alias findfs='find . -type f -size'
alias openme='nautilus $PWD'
alias rmf='rm -rf'
alias cpf='cp -rf'
#alias netstat='netstat -tlnp'
alias clojure='java -cp /Users/zxb/app/clojure-1.5.1/clojure-1.5.1.jar clojure.main'
#alias lein='/Users/zxb/app/lein'
alias bower='/usr/local/share/npm/bin/bower'
alias lessc='/Users/zxb/work/less.js/bin/lessc'
alias sips='sips -Z'

export PATH=/Users/zxb/work/shell:$PATH

ZOOKEEPER_HOME='/Users/zxb/app/zookeeper-3.4.5'
export PATH=$ZOOKEEPER_HOME/bin:$ZOOKEEPER_HOME/conf:$PATH
