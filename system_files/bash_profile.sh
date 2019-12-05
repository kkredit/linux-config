
source ~/.profile

# Setup Ruby
RUBY_VERSION=2.5.1
if [[ -d ~/.rvm/gems/ruby-$RUBY_VERSION/bin ]]; then
    PATH=~/.rvm/gems/ruby-$RUBY_VERSION/bin:$PATH
    rvm use $RUBY_VERSION > /dev/null
fi

