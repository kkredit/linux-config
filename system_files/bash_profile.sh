# shellcheck disable=SC2148,1090
source ~/.profile

export BASH_SILENCE_DEPRECATION_WARNING=1

# Setup Ruby
RUBY_VERSION=2.5.8
if [[ -d ~/.rvm/gems/ruby-$RUBY_VERSION/bin ]]; then
    PATH=~/.rvm/gems/ruby-$RUBY_VERSION/bin:$PATH
    rvm use $RUBY_VERSION > /dev/null
    source ~/.rails.bash
fi

source ~/.bashrc

