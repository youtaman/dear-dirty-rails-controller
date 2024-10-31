# DearDirtyController

DearDirtyControllerは1つのcontrollerに1つのアクションを実装する方法を提供します。

## Example of use in rails

```ruby
class GetUserController
  include DearDirtyController::Mixin

  before do
    Rails.logger.info "[START] get user"
  end

  execute do
    request = ActionDispatch::Request.new(@args)
    params = ActionController::Parameters.new(request.params)
    User.find(params[:id])
  end

  after do
    Rails.logger.info "[END] get user"
  end

  serialize do |user|
    {
      user: {
        last_name: user.last_name,
        first_name: user.first_name,
        name: user.name
      }
    }
  end
end
```

`DearDirtyController::Mixin`をincludeするだけなので、特定のcontrollerでのみ使用するという選択が可能です。
上記はrailsでの使用例ですが、ApplicationControllerを継承する必要はありません。

`before`, `execute`, `after`, `serialize`のうち必要なものにブロックを渡すだけでアクションを実装することができます。

### Routing

railsの通常のルーティングに`DearDirtyController::Mixin`をincludeしたクラスを渡すだけです。
`namespace`や`scope`, `get`等は変わらずに使えますが、`resource`, `resources`は使用できない点に注意してください。

この記載方法によりどのcontrollerに処理を実装されているのが明瞭であり、また、エディタのコードジャンプ等も使えるようになります。

```ruby
  scope :api do
    get "/users/:id", to: GetUserController
    post "users", to: PostUserController
  end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "dear-dirty-controller", require: "dear_dirty_controller"
```

And then execute:

```
$ bundle install
```


## Documentation

### usable instance variables

| name | description |
|---|---|
| @args | .callに渡される引数の配列 |
| @context | before, execute, after, serializeブロック内で共有可能な変数 |

### execute

```ruby
class XxxController
  include DearDirtyController::Mixin

  execute do
    # do anything
  end
end
```

### before, after hook

before hook内では`skip_execution!`メソッドを呼び出すことでexecuteブロックの実行をキャンセルできます。

```ruby
class XxxController
  include DearDirtyController::Mixin

  before do
    @context.current_user = get_user_method
    if @context.current_user.nil?
      skip_execution!
      body { message: "User not found" }
      status 404
    end
  end

  # implement anything

  after do
    if @context.success? # success? is set by execute block
      MailSender.call
    end
  end
end
```

### serialize, serializer

`serialize`, `serializer`を使用して`execute`の結果をserializeすることができます
`serialize`と`serializer`が同時に使用されている場合、`serialize`に渡したブロックが優先されます。
どちらも使用されていない場合、デフォルトで`.to_json`が呼び出されます。

```ruby
class XxxSerializer
  def self.serialize(user)
    {
      id: user.id,
      name: user.name
    }
  end
end

def XxxController
  include DearDirtyController::Mixin

  serializer XxxSerializer, method: :serialize # method optionのデフォルト値は:call

  serialize do |user|
    {
      id: user.id,
      name: user.name
    }
  end
end
```

### rescue_from, rescue_all

```ruby
class XxxController
  include DearDirtyController::Mixin

  rescue_from ActiveRecord::RecordNotFound do |_error|
    status 404
    body "record not found"
  end

  rescue_all do |_error|
    status 501
    body "something went wrong"
  end

  execute do
    user = User.find(-1) # raise ActiveRecord::RecordNotFound
  end
end
```

### headers, content_type, status, body

`headers`, `content_type`, `status`, `body`メソッドを用いてレスポンスを設定することができます。
`headers`, `content_type`, `status`はクラスメソッドも用意していますが、インスタンスメソッドが使用された場合はインスタンスメソッドに渡された値を優先します。

```ruby
class XxxController
  include DearDirtyController::Mixin

  headers { "X-SOME-KEY": "xxxx" }
  content_type "Application/json"
  status 200

  before do
    user = User.find_by(id: 1)
  end

  execute do
    if user.present?
      body { id: user.id, name: user.name }
    else
      status 404
      body "user not found"
    end
  end
end
```

## Tips for rails

### request

`@args`に格納されているActionDispatch::Routingから渡される引数をActionDispatch::Requestのインスタンスにすることで
通常のApplicationControllerと同様にリクエストを扱うことができるようになります。
この処理をBaseControllerとして定義することをお勧めします。

```ruby
class BaseController
  include DearDirtyController::Mixin
  attr_reader :request

  def initialize(args)
    super
    @request = ActionDispatch::Request.new(args)
  end

  def params
    ActionController::Parameters.new(request.params)
  end
end

class XxxController < BaseController
  execute do
    User.find(params[:id])
  end
end
```
