# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# project relates exports
export glob=/repo/yongwu/glob
export globcore=martini
export globbin=gltd4a-METH.bin
export sw=/repo/yongwu/sw
export board=fglt-b
export oamip=10.9.69.237
export bldversion=000
export swbuildlog=~/board.make.log


# User specific aliases and functions
alias ll='ls -lh'
alias lvnc='start_vnc 1920x1080'
alias findbyname='find ./ -name'
alias agrep='alias | grep'
alias hgrep='history | grep'
alias lgrep='ll | grep'
alias echoglob='echo glob:${glob} globcore:${globcore} globbin:${globbin}'
alias echoboard='echo sw:${sw} board:${board} bldversion:${bldversion}'
alias echooamip='echo oamip:${oamip}'

alias buildlog='tail -f ${swbuildlog}'

alias tftpoam='tftp ${oamip}'
alias ltshell='ssh -oPort=5022 -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@${oamip}'

alias cdsw='cd ${sw}'
alias cdbuild='cd ${sw}/build/${board}/OS'
alias cdglob='cd $glob'
alias cdglobbld='cd ${glob}/build/${globcore}/glob'

alias cpglobbin='cp ${glob}/build/${globcore}/glob/${globbin} ${sw}/vobs/dsl/sw/flat/GponGlob/glob/build/${globcore}/glob/${globbin}'
alias updateglobbldinfo='find ${glob} -name build_info.o -exec rm -f {} \;'

alias hgarchive='rm ~/project.zip ; hg archive ~/project.zip -X ".hg*"'

alias swgrep='grep --include=\*.{c,h,cc,cpp,hh,hpp} -rn ${sw} -e'
alias swgrepheader='grep --include=\*.{h,hh,hpp} -rn ${sw} -e'
alias swgrepimplementation='grep --include=\*.{c,cc,cpp} -rn ${sw} -e'

PATH=$PATH:$HOME/.local/bin:$HOME/bin:/ap/local/Linux_x86_64/shell

export PATH

function pushdinalias() {
    eval pushd `alias $1 | awk -F= '{print $2}' | awk '{print $2}' | sed "s/'$//"`
}

function clioam() {
    export expscript=~/.cliexpect
    export clipwd="      "
    [ -z "$1" ] || export clipwd=$1
    echo "#!/usr/bin/expect" > ${expscript}
    echo set timeout 30 >> ${expscript}
    # another way to login is using "telnet ${oamip}"
    echo spawn ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -l isadmin ${oamip} >> ${expscript} 
    echo expect \"*assword:\" >> ${expscript}
    echo "send \"${clipwd}\\r\"" >> ${expscript}
    echo interact >> ${expscript}
    expect -f ${expscript}
}

function ntoam() {
    export expscript=~/.ntexpect
    echo "#!/usr/bin/expect" > ${expscript}
    echo set timeout 30 >> ${expscript}
    echo spawn octopus STDIO ${oamip}:udp:23 >> ${expscript} 
    echo "send \"\\r\\r\"" >> ${expscript}
    echo expect \"*ogin:\" >> ${expscript}
    echo "send \"shell\\r\"" >> ${expscript}
    echo expect \"*assword:\" >> ${expscript}
    echo "send \"nt\\r\"" >> ${expscript}
    echo interact >> ${expscript}
    expect -f ${expscript}
}

function setboard() {
    echo before update...
    echoboard
    echoglob
    
    export board=$1
    export globcore=`grep FPGA_ARCH_${board} ${sw}/vobs/dsl/sw/flat/GponGlob/Makefile | awk -F= '{print $2}' | sed 's/^\s*//'`
    export globbin=`grep TARGET_${board} ${sw}/vobs/dsl/sw/flat/GponGlob/Makefile | awk -F= '{print $2}' | sed 's/^\s*//' | sed 's/\$.*/\-METH\.bin/'`

    echo after update...
    echoboard
    echoglob
    
    echo update done
}

function showchangesets() {
    pushd ${sw}
    echo sw changeset: 
    hg log -r "ancestor($1)"

    echo glob changeset: 
    hg cat vobs/dsl/sw/flat/BUILDCFG/extRepo/GponGlob_glob.cfg -r "ancestor($1)"

    revision=`hg cat vobs/dsl/sw/flat/BUILDCFG/extRepo/GponGlob_glob.cfg -r "ancestor($1)" | grep REVISION | awk -F= '{print $2}'`
    popd
    
    pushd ${glob}
    hg log -r ${revision}
    popd
}

function swmake() {
    pushdinalias cdbuild
    nohup make IVY=ivy $1 VERS=${bldversion} -j24 > ~/board.make.log 2>&1 &
    popd 
}

function globmake() {
    updateglobbldinfo
    pushdinalias cdglobbld 
    make MEDIUM=ETH
    popd
}

function makeall() {
    echo build glob
    globmake
    echo build glob finished
    
    echo glob bin update
    cpglobbin

    echo build sw
    swmake M=GponGlob

    buildlog --pid=$! 
}

PS1='`pwd` \$'

