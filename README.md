# BaseSitePathLocker

This is the plugin of MovableType which provides site-specific BaseSitePath.

## MOTIVATION

MovableType をマルチサイト構成で運用する場合，あるサイトのデータを書き込む先の設定 *サイトパス* を変更できると，別のサイトのデータを破壊できてしまう．ユーザに[サイト管理者ロール](https://www.movabletype.jp/documentation/mt7/admin-guide/users-and-groups/role-and-permission/overview/)を割り当てると，そのユーザはサイトパスを変更できるから，他サイトのデータを破壊できてしまうことになるため，サイト管理者ロールを割り当てることができない．しかし，サイト管理者ロールを割り当てないと，子サイトを作るなどの作業を全て，システム管理者に依頼する必要が発生して，システム管理者の作業負荷が増大してしまう問題がある．

## METHODLOGY

MovableType には，[BaseSitePath](https://movabletype.org/documentation/appendices/config-directives/basesitepath.html) というディレクティブがある．

```
BaseSitePath /var/www/vhosts
```

のような指定を `mt-config.cgi` に記述しておくと，`/var/www/vhosts/` のサブディレクトリ以外の場所をサイトパスとして指定できないように制限できる．

このプラグインは，サイトを新規作成したり，サイトの設定を変更して保存する時に呼び出される `MT::CMS::Common::save` 関数のラッパー関数を用意し，ラッパー関数内で `BaseSitePath` を適宜に変更することにより，サイト管理者が別サイトのデータを破壊することを防止する．

具体的には，以下のように動作する．

 1. 設定変更しようとしているユーザがシステム管理者である場合は，`BaseSitePath` の設定を変更しない．
 2. 設定変更しようとしているサイトに親サイトが存在する場合は，親サイトのサイトパスを `BaseSitePath` に設定する．つまり，子サイトのサイトパスを変更する場合，親サイトのサイトパスのサブディレクトリでなければならない．
 3. 設定変更しようとしているサイトに親サイトが存在しない場合は，現在のサイトパスを `BaseSitePath` に設定する．つまり，あるサイトのサイトパスを変更する場合，システム管理者によって設定されたサイトパスのサブディレクトリでなければならない．

## AUTHOR

 * TSUCHIYA Masatoshi
