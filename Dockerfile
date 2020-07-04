FROM ruby:2.6

#rails6からyarnのインストールが必須
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list 
#ruby:2.6.0を指定するとnodejsのバージョンが低くwebpackerが
#インストールできないためバージョンを指定
RUN curl -SL https://deb.nodesource.com/setup_14.x | bash
#nodejsをインストール
RUN apt-get install -y nodejs
#yarnをインストール
RUN apt-get install -y yarn 

RUN mkdir /myapp

WORKDIR /myapp
#初回のdocker-composeのために必要
COPY Gemfile /myapp/Gemfile
#同じく必要
COPY Gemfile.lock /myapp/Gemfile.lock

RUN bundle install

COPY . /myapp
#server.pidファイルが既に存在する場合にサーバーが再起動しないようにする
#rails固有の問題を解決するエントリポイントスクリプト
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
