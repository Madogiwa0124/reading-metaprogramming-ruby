class Class
  def redefine_method(name, &block)
    remove_method(name) if method_defined?(name)
    define_method(name, &block)
  end
end

# Q1.
# 次の動作をする A1 class を実装する
# - "//" を返す "//"メソッドが存在すること

class A1
  define_method('//') { '//' }
end

# Q2.
# 次の動作をする A2 class を実装する
# - 1. "SmartHR Dev Team"と返すdev_teamメソッドが存在すること
# - 2. initializeに渡した配列に含まれる値に対して、"hoge_" をprefixを付与したメソッドが存在すること
# - 2で定義するメソッドは下記とする
#   - 受け取った引数の回数分、メソッド名を繰り返した文字列を返すこと
#   - 引数がnilの場合は、dev_teamメソッドを呼ぶこと

class A2

  def initialize(args)
    args.uniq.each { |arg| define_prefix_method(arg.to_s) }
  end

  def define_prefix_method(arg, prefix='hoge')
    name = [prefix, arg].join('_')
    self.class.class_eval do
      redefine_method(name) { |n| n ? name * n : dev_team }
    end
  end

  def dev_team
    'SmartHR Dev Team'
  end
end

# Q3.
# 次の動作をする OriginalAccessor モジュール を実装する
# - OriginalAccessorモジュールはincludeされたときのみ、my_attr_accessorメソッドを定義すること
# - my_attr_accessorはgetter/setterに加えて、boolean値を代入した際のみ真偽値判定を行うaccessorと同名の?メソッドができること

module OriginalAccessor
  def self.included(obj)
    obj.class.class_eval do
      define_method(:my_attr_accessor) do |arg|
        attr_reader arg
        redefine_method("#{arg}=") do |val|
          instance_variable_set("@#{arg}", val)
          self.class.class_eval { toggle_bool_method(arg, val) }
        end

        private

        def toggle_bool_method(name, val)
          method_name = "#{name}?"
          if [true, false].include?(val)
            define_method(method_name) { send(name.to_s) }
          elsif method_defined?(method_name)
            remove_method(method_name)
          end
        end
      end
    end
  end
end
