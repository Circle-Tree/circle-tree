# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
# require 'bootsnap'
# env = ENV['RAILS_ENV'] || "development"
# Bootsnap.setup(
#   cache_dir:            'tmp/cache',          # キャッシュを保存するパス
#   development_mode:     env == 'development', # RACK_ENV、RAILS_ENV
#   load_path_cache:      true,                 # $LOAD_PATHをキャッシュする
#   autoload_paths_cache: true,                 # ActiveSupport::Dependencies.autoload_pathsをキャッシュする
#   compile_cache_iseq:   false,                 # rubyの実行結果をキャッシュする
#   compile_cache_yaml:   true                  # YAMLのコンパイル結果をキャッシュする
# )
